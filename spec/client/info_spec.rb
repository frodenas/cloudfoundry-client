require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Cloudfoundry::Client::Info" do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("no_logged/client", :record => :new_episodes) do
        @cf_client = client_no_logged()
      end
    end

    use_vcr_cassette "no_logged/info", :record => :new_episodes

    it "should properly get basic information from target cloud" do
      cloud_info = @cf_client.cloud_info()
      cloud_info.should have_key :name
      cloud_info.should have_key :build
      cloud_info.should have_key :support
      cloud_info.should have_key :version
      cloud_info.should have_key :description
      cloud_info.should have_key :allow_debug
    end

    it "should not return user account information from target cloud" do
      cloud_info = @cf_client.cloud_info()
      cloud_info.should_not have_key :user
      cloud_info.should_not have_key :usage
      cloud_info.should_not have_key :limits
    end

    it "should get a proper list of runtimes available at target cloud" do
      cloud_runtimes_info = @cf_client.cloud_runtimes_info()
      cloud_runtimes_info.should have_at_least(1).items
      runtime_info = cloud_runtimes_info.first[1]
      runtime_info.should have_key :version
    end

    it "should raise an AuthError exception when requesting system services" do
      expect {
        cloud_services_info = @cf_client.cloud_services_info()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("user_logged/client", :record => :new_episodes) do
        @cf_client = client_user_logged()
      end
    end

    use_vcr_cassette "user_logged/info", :record => :new_episodes

    it "should properly get basic account information from target cloud" do
      cloud_info = @cf_client.cloud_info()
      cloud_info.should have_key :name
      cloud_info.should have_key :build
      cloud_info.should have_key :support
      cloud_info.should have_key :version
      cloud_info.should have_key :description
      cloud_info.should have_key :allow_debug
    end

    it "should properly get user account information from target cloud" do
      cloud_info = @cf_client.cloud_info()
      cloud_info.should have_key :user
      cloud_info.should have_key :usage
      cloud_info.should have_key :limits
      cloud_info[:user].should eql(@user)
    end

    it "should get a proper list of runtimes available at target cloud" do
      cloud_runtimes_info = @cf_client.cloud_runtimes_info()
      cloud_runtimes_info.should have_at_least(1).items
      runtime_info = cloud_runtimes_info.first[1]
      runtime_info.should have_key :version
    end

    it "should get a proper list of system services available at target cloud" do
      cloud_services_info = @cf_client.cloud_services_info()
      cloud_services_info.should have_at_least(1).items
      system_service_info = cloud_services_info.first[1].values[0].first[1]
      system_service_info.should have_key :id
      system_service_info.should have_key :type
      system_service_info.should have_key :vendor
      system_service_info.should have_key :version
      system_service_info.should have_key :description
      system_service_info.should have_key :tiers
    end
  end
end