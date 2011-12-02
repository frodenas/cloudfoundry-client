require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Cloudfoundry::Client::Resources" do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("no_logged/client", :record => :new_episodes) do
        @cf_client = client_no_logged()
      end
    end

    use_vcr_cassette "no_logged/resources", :record => :new_episodes

    it "should raise an AuthError exception when checking resources at target cloud" do
      expect {
        resources = []
        resources_manifest = @cf_client.check_resources(resources)
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("user_logged/client", :record => :new_episodes) do
        @cf_client = client_user_logged()
      end
    end

    use_vcr_cassette "user_logged/resources", :record => :new_episodes

    it "should properly get an empty resources manifest file from target cloud" do
      resources = []
      resources_manifest = @cf_client.check_resources(resources)
      resources_manifest.should be_empty
    end

    it "should properly get a resources manifest file from target cloud" do
      VCR.use_cassette("user_logged/resources_check_action", :record => :new_episodes, :exclusive => true) do
        resources = []
        filename = spec_fixture("app.js")
        resources << {
          :size => File.size(filename),
          :sha1 => Digest::SHA1.file(filename).hexdigest,
          :fn => filename
        }
        resources_manifest = @cf_client.check_resources(resources)
        resources_manifest[0][:size].should eql(resources[0][:size])
        resources_manifest[0][:sha1].should eql(resources[0][:sha1])
      end
    end
  end
end