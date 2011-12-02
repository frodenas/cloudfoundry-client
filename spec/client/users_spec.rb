require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Cloudfoundry::Client::Users" do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("no_logged/client", :record => :new_episodes) do
        @cf_client = client_no_logged()
      end
    end

    use_vcr_cassette "no_logged/users", :record => :new_episodes

    it "should return true if a new user is created at target cloud" do
      created = @cf_client.create_user("fakeuser1@vcap.me", "foobar")
      created.should be_true
    end

    it "should raise an AuthError exception when listing all users at target cloud" do
      expect {
        users = @cf_client.list_users()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when retrieving user information from target cloud" do
      expect {
        user_info = @cf_client.user_info("user@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when updating a user at target cloud" do
      expect {
        updated = @cf_client.update_user("user@vcap.me", "foobar")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when deleting a user at target cloud" do
      expect {
        deleted = @cf_client.delete_user("user@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should allow to proxy a user" do
      proxied_user = @cf_client.set_proxy_user("user@vcap.me")
      proxied_user.should eql("user@vcap.me")
      proxied_user.should eql(@cf_client.proxy_user)
    end

    it "should raise a Forbidden exception when retrieving proxy user account information from target cloud" do
      VCR.use_cassette("no_logged/users_proxy_action", :record => :new_episodes, :exclusive => true) do
        expect {
          proxied_user = @cf_client.set_proxy_user("user@vcap.me")
          cloud_info = @cf_client.cloud_info()
        }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
      end
    end

    it "should allow to unproxy a user" do
      proxied_user = @cf_client.unset_proxy_user()
      proxied_user.should be_nil
      @cf_client.proxy_user.should be_nil
    end

    it "should not get user account information from target cloud" do
      VCR.use_cassette("no_logged/users_unproxy_action", :record => :new_episodes, :exclusive => true) do
        proxied_user = @cf_client.unset_proxy_user()
        cloud_info = @cf_client.cloud_info()
        cloud_info.should_not have_key :user
      end
    end

    it "should raise a BadParams exception when login with a blank email" do
      expect {
        @cf_client.login("", "foobar")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when login with a blank password" do
      expect {
        @cf_client.login("user@vcap.me", "")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a Forbidden exception if login to the target cloud fails" do
      expect {
        @cf_client.login("user@vcap.me", "password")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it "should return false if user is not logged in at target cloud" do
      @cf_client.logged_in?.should be_false
      @cf_client.user.should be_nil
      @cf_client.auth_token.should be_nil
    end

    it "should allow to login correctly at target cloud and return an auth_token" do
      VCR.use_cassette("no_logged/users_login_action", :record => :new_episodes, :exclusive => true) do
        auth_token = @cf_client.login("user@vcap.me", "foobar")
        @cf_client.user.should_not be_nil
        @cf_client.user.should eql("user@vcap.me")
        @cf_client.auth_token.should_not be_nil
        @cf_client.auth_token.should eql(auth_token)
      end
    end

    it "should return true if user is logged in at target cloud" do
      VCR.use_cassette("no_logged/users_login_action", :record => :new_episodes, :exclusive => true) do
        @cf_client.logged_in?.should be_true
      end
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("user_logged/client", :record => :new_episodes) do
        @cf_client = client_user_logged()
      end
    end

    use_vcr_cassette "user_logged/users", :record => :new_episodes

    it "should return true if a new user is created at target cloud" do
      created = @cf_client.create_user("fakeuser2@vcap.me", "foobar")
      created.should be_true
    end

    it "should raise a Forbidden exception when listing all users at target cloud" do
      expect {
        users = @cf_client.list_users()
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it "should raise an Forbidden exception when retrieving not own user information from target cloud" do
      expect {
        user_info = @cf_client.user_info("fakeuser1@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it "should properly get basic user information from target cloud" do
      user_info = @cf_client.user_info("user@vcap.me")
      user_info.should have_key :email
    end

    it "should raise a Forbidden exception when updating not own user at target cloud" do
      expect {
        updated = @cf_client.update_user("fakeuser1@vcap.me", "foobar")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it "should return true if a user is updated at target cloud" do
      updated = @cf_client.update_user("user@vcap.me", "foobar")
      updated.should be_true
    end

    it "should raise a Forbidden exception when deleting not now user at target cloud" do
      expect {
        deleted = @cf_client.delete_user("fakeuser1@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it "should raise a Forbidden exception when deleting a user at target cloud" do
      expect {
        deleted = @cf_client.delete_user("user@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it "should allow to proxy a user" do
      proxied_user = @cf_client.set_proxy_user("fakeuser1@vcap.me")
      proxied_user.should eql("fakeuser1@vcap.me")
      proxied_user.should eql(@cf_client.proxy_user)
    end

    it "should raise a Forbidden exception when retrieving proxy user account information from target cloud" do
      VCR.use_cassette("user_logged/users_proxy_action", :record => :new_episodes, :exclusive => true) do
        expect {
          proxied_user = @cf_client.set_proxy_user("fakeuser1@vcap.me")
          cloud_info = @cf_client.cloud_info()
        }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
      end
    end

    it "should allow to unproxy a user" do
      proxied_user = @cf_client.unset_proxy_user()
      proxied_user.should be_nil
      @cf_client.proxy_user.should be_nil
    end

    it "should properly get current user account information from target cloud" do
      VCR.use_cassette("user_logged/users_unproxy_action", :record => :new_episodes, :exclusive => true) do
        proxied_user = @cf_client.unset_proxy_user()
        cloud_info = @cf_client.cloud_info()
        cloud_info[:user].should eql(@user)
      end
    end

    it "should return true if user is logged in at target cloud" do
      @cf_client.logged_in?.should be_true
      @cf_client.user.should_not be_nil
      @cf_client.user.should eql(@user)
      @cf_client.auth_token.should_not be_nil
      @cf_client.auth_token.should eql(@auth_token)
    end
  end

  context "with an admin user logged in" do
    before(:all) do
      VCR.use_cassette("admin_logged/client", :record => :new_episodes) do
        @cf_client = client_admin_logged()
      end
    end

    use_vcr_cassette "admin_logged/users", :record => :new_episodes

    it "should raise a BadParams exception when creating a user with a blank email" do
      expect {
        created = @cf_client.create_user("", "foobar")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when creating a user with a blank password" do
      expect {
        created = @cf_client.create_user("fakeuser@vcap.me", "")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadRequest exception when creating a user that already exists at target cloud" do
      expect {
        created = @cf_client.create_user("user@vcap.me", "foobar")
      }.to raise_exception(CloudFoundry::Client::Exception::BadRequest)
    end

    it "should return true if a new user is created at target cloud" do
      VCR.use_cassette("admin_logged/users_create_action", :record => :new_episodes, :exclusive => true) do
        created = @cf_client.create_user("fakeuser@vcap.me", "foobar")
        created.should be_true
      end
    end

    it "should get a proper list of users at target cloud" do
      users = @cf_client.list_users()
      users.should have_at_least(1).items
      user_info = users.first
      user_info.should have_key :email
      user_info.should have_key :admin
      user_info.should have_key :apps
    end

    it "should raise a BadParams exception when retrieving information about a user with a blank email" do
      expect {
        user_info = @cf_client.user_info("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a Forbidden exception when retrieving information about a user that does not exists at target cloud" do
      expect {
        user_info = @cf_client.user_info("nouser@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it "should properly get basic user information from target cloud" do
      user_info = @cf_client.user_info("fakeuser@vcap.me")
      user_info.should have_key :email
    end

    it "should raise a BadParams exception when updating a user with a blank email" do
      expect {
        created = @cf_client.update_user("", "foobar")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when updating a user with a blank password" do
      expect {
        created = @cf_client.update_user("fakeuser@vcap.me", "")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a Forbidden exception when updating a user that does not exists at target cloud" do
      expect {
        updated = @cf_client.update_user("nouser@vcap.me", "foobar")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it "should return true if a user is updated at target cloud" do
      updated = @cf_client.update_user("fakeuser@vcap.me", "foobar")
      updated.should be_true
    end

    it "should raise a BadParams exception when deleting a user with a blank email" do
      expect {
        created = @cf_client.delete_user("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a Forbidden exception when deleting a user that does not exists at target cloud" do
      expect {
        deleted = @cf_client.delete_user("nouser@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it "should return true if a user is deleted at target cloud" do
      deleted = @cf_client.delete_user("fakeuser@vcap.me")
      deleted.should be_true
    end

    it "should return true if a user is deleted at target cloud" do
      deleted = @cf_client.delete_user("fakeuser1@vcap.me")
      deleted.should be_true
    end

    it "should return true if a user is deleted at target cloud" do
      deleted = @cf_client.delete_user("fakeuser2@vcap.me")
      deleted.should be_true
    end

    it "should allow to proxy a user" do
      proxied_user = @cf_client.set_proxy_user("user@vcap.me")
      proxied_user.should eql("user@vcap.me")
      proxied_user.should eql(@cf_client.proxy_user)
    end

    it "should properly get proxy user account information from target cloud" do
      VCR.use_cassette("admin_logged/users_proxy_action", :record => :new_episodes, :exclusive => true) do
        proxied_user = @cf_client.set_proxy_user("user@vcap.me")
        cloud_info = @cf_client.cloud_info()
        cloud_info[:user].should eql("user@vcap.me")
        cloud_info[:user].should eql(@cf_client.proxy_user)
      end
    end

    it "should allow to proxy a user that does not exists at target cloud" do
      proxied_user = @cf_client.set_proxy_user("nouser@vcap.me")
      proxied_user.should eql("nouser@vcap.me")
      proxied_user.should eql(@cf_client.proxy_user)
    end

    it "should raise a Forbidden exception when retrieving proxy user account information that does not exists at target cloud" do
      VCR.use_cassette("admin_logged/users_proxy_nouser_action", :record => :new_episodes, :exclusive => true) do
        expect {
          proxied_user = @cf_client.set_proxy_user("nouser@vcap.me")
          cloud_info = @cf_client.cloud_info()
        }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
      end
    end

    it "should allow to unproxy a user" do
      proxied_user = @cf_client.unset_proxy_user()
      proxied_user.should be_nil
      @cf_client.proxy_user.should be_nil
    end

    it "should properly get current user account information from target cloud" do
      VCR.use_cassette("admin_logged/users_unproxy_action", :record => :new_episodes, :exclusive => true) do
        proxied_user = @cf_client.unset_proxy_user()
        cloud_info = @cf_client.cloud_info()
        cloud_info[:user].should eql(@user)
      end
    end

    it "should return true if user is logged in at target cloud" do
      @cf_client.logged_in?.should be_true
      @cf_client.user.should_not be_nil
      @cf_client.user.should eql(@user)
      @cf_client.auth_token.should eql(@auth_token)
    end
  end
end