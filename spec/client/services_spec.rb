require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Cloudfoundry::Client::Services" do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("no_logged/client", :record => :new_episodes) do
        @cf_client = client_no_logged()
      end
    end

    use_vcr_cassette "no_logged/services", :record => :new_episodes

    it "should raise an AuthError exception when creating a provisioned service" do
      expect {
        created = @cf_client.create_service("redis", "redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when listing provisioned services at target cloud" do
      expect {
        services = @cf_client.list_services()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when retrieving provisioned service information from target cloud" do
      expect {
        service_info = @cf_client.service_info("redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when binding a provisioned service to an application at target cloud" do
      expect {
        binded = @cf_client.bind_service("redis-mock", "newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when unbinding a provisioned service to an application at target cloud" do
      expect {
        unbinded = @cf_client.unbind_service("redis-mock", "newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when deleting a provisioned service at target cloud" do
      expect {
        deleted = @cf_client.delete_service("redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("user_logged/client", :record => :new_episodes) do
        @cf_client = client_user_logged()
      end
    end

    use_vcr_cassette "user_logged/services", :record => :new_episodes

    it "should raise a BadParams exception when creating a provisioned service with a blank system service" do
      expect {
        created = @cf_client.create_service("", "redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when creating a provisioned service with a blank name" do
      expect {
        created = @cf_client.create_service("redis", "")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when creating a provisioned service with an invalid system service" do
      expect {
        created = @cf_client.create_service("noservice", "redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should return true if a new provisioned service is created at target cloud" do
      VCR.use_cassette("user_logged/services_create_action", :record => :new_episodes, :exclusive => true) do
        created = @cf_client.create_service("redis", "redis-mock")
        created.should be_true
      end
    end

    it "should raise a BadRequest exception when creating a provisioned service that already exists at target cloud" do
      expect {
        created = @cf_client.create_service("redis", "redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::BadRequest)
    end

    it "should get a proper list of provisioned services at target cloud" do
      services = @cf_client.list_services()
      services.should have_at_least(1).items
      service_info = services.first
      service_info.should have_key :type
      service_info.should have_key :vendor
      service_info.should have_key :name
      service_info.should have_key :version
      service_info.should have_key :tier
      service_info.should have_key :meta
      service_info.should have_key :properties
    end

    it "should raise a BadParams exception when retrieving information about a provisioned service with a blank name" do
      expect {
        service_info = @cf_client.service_info("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a NotFound exception when retrieving information about a provisioned service that does not exists at target cloud" do
      expect {
        service_info = @cf_client.service_info("noservice")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should properly get provisioned service information from target cloud" do
      service_info = @cf_client.service_info("redis-mock")
      service_info.should have_key :type
      service_info.should have_key :vendor
      service_info.should have_key :name
      service_info.should have_key :version
      service_info.should have_key :tier
      service_info.should have_key :meta
      service_info.should have_key :properties
    end

    it "should raise a BadParams exception when binding to an application a provisioned service with a blank name" do
      expect {
        binded = @cf_client.bind_service("", "appname")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when binding a provisioned service to an application with a blank name" do
      expect {
        binded = @cf_client.bind_service("redis-mock", "")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a NotFound exception when binding to an application a provisioned service that does not exists" do
      expect {
        binded = @cf_client.bind_service("noservice", "appname")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should raise a NotFound exception when binding a provisioned service to an application that does not exists" do
      expect {
        binded = @cf_client.bind_service("redis-mock", "appname")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should return true if a provisioned service is binded to an application at target cloud" do
      VCR.use_cassette("user_logged/services_bind_action", :record => :new_episodes, :exclusive => true) do
        manifest = {
          :name => "newapp",
          :uris => ["newapp.vcap.me"],
          :instances => 1,
          :staging => {:model => "node"},
          :resources => {:memory => 64}
        }
        created = @cf_client.create_app("newapp", manifest)
        binded = @cf_client.bind_service("redis-mock", "newapp")
        binded.should be_true
      end
    end

    it "should raise a BadParams exception when binding a provisioned service to an application already binded" do
      expect {
        binded = @cf_client.bind_service("redis-mock", "newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when unbinding from an application a provisioned service with a blank name" do
      expect {
        unbinded = @cf_client.unbind_service("", "appname")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when unbinding a provisioned service from an application with a blank name" do
      expect {
        unbinded = @cf_client.unbind_service("redis-mock", "")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a NotFound exception when unbinding a provisioned service that does not exists from an application" do
      expect {
        unbinded = @cf_client.unbind_service("noservice", "appname")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should raise a NotFound exception when unbinding a provisioned service from an application that does not exists" do
      expect {
        unbinded = @cf_client.unbind_service("redis-mock", "appname")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should return true if a provisioned service is binded to an application at target cloud" do
      VCR.use_cassette("user_logged/services_unbind_action", :record => :new_episodes, :exclusive => true) do
        unbinded = @cf_client.unbind_service("redis-mock", "newapp")
        unbinded.should be_true
      end
    end

    it "should raise a BadParams exception when unbinding a provisioned service from an application that is not binded" do
      VCR.use_cassette("user_logged/services_unbind_fail_action", :record => :new_episodes, :exclusive => true) do
        expect {
          unbinded = @cf_client.unbind_service("redis-mock", "newapp")
        }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
        deleted = @cf_client.delete_app("newapp")
      end
    end

    it "should raise a BadParams exception when deleting a provisioned service with a blank name" do
      expect {
        deleted = @cf_client.delete_service("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a NotFound exception when deleting a provisioned service that does not exists at target cloud" do
      expect {
        deleted = @cf_client.delete_service("noservice")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should return true if a provisioned service is deleted at target cloud" do
      deleted = @cf_client.delete_service("redis-mock")
      deleted.should be_true
    end
  end
end