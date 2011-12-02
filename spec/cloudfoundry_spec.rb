require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Cloudfoundry" do
  include CfConnectionHelper

  before(:all) do
    client_data()
  end

  use_vcr_cassette "cloudfoundry", :record => :new_episodes

  it "should report its version" do
    CloudFoundry::VERSION.should match(/\d.\d.\d/)
    CloudFoundry::VERSION.should eql(CloudFoundry::Client::VERSION)
  end

  it "should properly initialize when no options are passed" do
    cf_client = CloudFoundry.new()
    cf_client.target_url.should eql(CloudFoundry::Client::DEFAULT_TARGET)
    cf_client.proxy_url.should be_nil
    cf_client.trace_key.should be_nil
    cf_client.auth_token.should be_nil
    cf_client.user.should be_nil
    cf_client.proxy_user.should be_nil
  end

  it "should be a CloudFoundry::Client" do
    cf_client = CloudFoundry.new()
    cf_client.should be_a CloudFoundry::Client
  end

  it "should properly initialize with target_url and auth_token options" do
    cf_client = CloudFoundry.new({:target_url => @target, :auth_token => @auth_token})
    cf_client.target_url.should eql(@target)
    cf_client.proxy_url.should be_nil
    cf_client.trace_key.should be_nil
    cf_client.auth_token.should eql(@auth_token)
    cf_client.user.should eql(@user)
    cf_client.proxy_user.should be_nil
  end

  it "should delegate any method to CloudFoundry::Client" do
    cf_client = CloudFoundry.new({:target_url => @target, :auth_token => @auth_token})
    cloud_info = cf_client.cloud_info()
    cloud_info.should have_key :name
    cloud_info.should have_key :build
    cloud_info.should have_key :support
    cloud_info.should have_key :version
    cloud_info.should have_key :description
    cloud_info.should have_key :allow_debug
  end

  it "should return the same results as a CloudFoundry::Client" do
    VCR.use_cassette("cloudfoundry_vs_client", :record => :new_episodes, :exclusive => true) do
      cf_client_1 = CloudFoundry.new()
      cloud_info_1 = cf_client_1.cloud_info()
      cf_client_2 = CloudFoundry::Client.new()
      cloud_info_2 = cf_client_2.cloud_info()
      cloud_info_1.should eql(cloud_info_2)
    end
  end
end