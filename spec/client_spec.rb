require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Cloudfoundry::Client" do
  include CfConnectionHelper

  before(:all) do
    client_data()
  end

  use_vcr_cassette "client", :record => :new_episodes

  it "should report its version" do
    CloudFoundry::Client::VERSION.should match(/\d.\d.\d/)
  end

  it "should properly initialize when no options are passed" do
    cf_client = CloudFoundry::Client.new()
    cf_client.target_url.should eql(CloudFoundry::Client::DEFAULT_TARGET)
    cf_client.proxy_url.should be_nil
    cf_client.trace_key.should be_nil
    cf_client.auth_token.should be_nil
    cf_client.user.should be_nil
    cf_client.proxy_user.should be_nil
  end

  it "should properly initialize with only proxy_url option" do
    cf_client = CloudFoundry::Client.new({:proxy_url => "http://proxy.rodenas.org"})
    cf_client.target_url.should eql(CloudFoundry::Client::DEFAULT_TARGET)
    cf_client.proxy_url.should eql("http://proxy.rodenas.org")
    cf_client.trace_key.should be_nil
    cf_client.auth_token.should be_nil
    cf_client.user.should be_nil
    cf_client.proxy_user.should be_nil
  end

  it "should properly initialize with only target_url option" do
    cf_client = CloudFoundry::Client.new({:target_url => @target})
    cf_client.target_url.should eql(@target)
    cf_client.proxy_url.should be_nil
    cf_client.trace_key.should be_nil
    cf_client.auth_token.should be_nil
    cf_client.user.should be_nil
    cf_client.proxy_user.should be_nil
  end

  it "should normalize a target_url with no scheme" do
    cf_client = CloudFoundry::Client.new({:target_url => "api.vcap.me"})
    cf_client.target_url.should eql("http://api.vcap.me")
  end

  it "should not normalize a target_url with an http scheme" do
    cf_client = CloudFoundry::Client.new({:target_url => "http://api.vcap.me"})
    cf_client.target_url.should eql("http://api.vcap.me")
  end

  it "should not normalize a target_url with an https scheme" do
    cf_client = CloudFoundry::Client.new({:target_url => "https://api.cloudfoundry.com"})
    cf_client.target_url.should eql("https://api.cloudfoundry.com")
  end

  it "should properly initialize with only trace_key option" do
    cf_client = CloudFoundry::Client.new({:trace_key => "22"})
    cf_client.target_url.should eql(CloudFoundry::Client::DEFAULT_TARGET)
    cf_client.proxy_url.should be_nil
    cf_client.trace_key.should eql("22")
    cf_client.auth_token.should be_nil
    cf_client.user.should be_nil
    cf_client.proxy_user.should be_nil
  end

  it "should properly initialize with only auth_token option" do
    cf_client = CloudFoundry::Client.new({:auth_token => @auth_token})
    cf_client.target_url.should eql(CloudFoundry::Client::DEFAULT_TARGET)
    cf_client.proxy_url.should be_nil
    cf_client.trace_key.should be_nil
    cf_client.auth_token.should eql(@auth_token)
    cf_client.user.should eql(@user)
    cf_client.proxy_user.should be_nil
  end

  it "should properly initialize with target_url and auth_token options" do
    cf_client = CloudFoundry::Client.new({:target_url => @target, :auth_token => @auth_token})
    cf_client.target_url.should eql(@target)
    cf_client.proxy_url.should be_nil
    cf_client.trace_key.should be_nil
    cf_client.auth_token.should eql(@auth_token)
    cf_client.user.should eql(@user)
    cf_client.proxy_user.should be_nil
  end

  it "should raise a BadParams exception when target_url is an invalid URL" do
    expect {
      cf_client = CloudFoundry::Client.new({:target_url => "fakeaddress"})
    }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
  end

  it "should raise a BadParams exception when target_url is an invalid CloudFoundry target" do
    expect {
      cf_client = CloudFoundry::Client.new({:target_url => "http://www.example.com"})
    }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
  end

  it "should raise an AuthError exception when auth_token is invalid in the CloudFoundry target" do
    VCR.use_cassette("client_invalid", :record => :new_episodes, :exclusive => true) do
      expect {
        cf_client = CloudFoundry::Client.new({:auth_token => "invalid_auth_token"})
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end
end
