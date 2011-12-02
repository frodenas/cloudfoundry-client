require 'cloudfoundry/client/apps'
require 'cloudfoundry/client/info'
require 'cloudfoundry/client/request'
require 'cloudfoundry/client/resources'
require 'cloudfoundry/client/response'
require 'cloudfoundry/client/services'
require 'cloudfoundry/client/users'

module CloudFoundry
  # This is a Ruby wrapper for the CloudFoundry API, the industry’s first open Platform as a Service (PaaS) offering.
  class Client
    include CloudFoundry::Client::Apps
    include CloudFoundry::Client::Info
    include CloudFoundry::Client::Request
    include CloudFoundry::Client::Resources
    include CloudFoundry::Client::Services
    include CloudFoundry::Client::Users

    # Returns the HTTP connection adapter that will be used to connect.
    attr_reader :net_adapter
    # Returns the Proxy URL that will be used to connect.
    attr_reader :proxy_url
    # Returns the CloudFoundry API Target URL.
    attr_reader :target_url
    # Returns the CloudFoundry API Trace Key.
    attr_reader :trace_key
    # Returns the CloudFoundry API Authorization Token.
    attr_reader :auth_token
    # Returns the CloudFoundry Logged User.
    attr_reader :user
    # Returns the CloudFoundry Proxied User.
    attr_reader :proxy_user

    # Creates a new CloudFoundry::Client object.
    #
    # @param [Hash] options
    # @option options [Faraday::Adapter] :adapter The HTTP connection adapter that will be used to connect.
    # @option options [String] :proxy_url The Proxy URL that will be used to connect.
    # @option options [String] :target_url The CloudFoundry API Target URL.
    # @option options [String] :trace_key The CloudFoundry API Trace Key.
    # @option options [String] :auth_token The CloudFoundry API Authorization Token.
    # @return [CloudFoundry::Client] A CloudFoundry::Client Object.
    # @raise [CloudFoundry::Client::Exception::BadParams] when target_url is not a valid CloudFoundry API URL.
    # @raise [CloudFoundry::Client::Exception::AuthError] when auth_token is not a valid CloudFoundry API authorization token.
    def initialize(options = {})
      @net_adapter = options[:adapter] || DEFAULT_ADAPTER
      @proxy_url = options[:proxy_url] || nil
      @target_url = options[:target_url] || DEFAULT_TARGET
      @target_url = sanitize_url(@target_url)
      @trace_key = options[:trace_key] || nil
      @auth_token = options[:auth_token] || nil
      @user = nil
      @proxy_user = nil

      raise CloudFoundry::Client::Exception::BadParams, "Invalid CloudFoundry API URL: " + @target_url unless valid_target_url?
      if @auth_token
        raise CloudFoundry::Client::Exception::AuthError, "Invalid CloudFoundry API authorization token" unless logged_in?
      end
    end

    private

    # Sanitizes an URL.
    #
    # @param [String] url URL to sanitize.
    # @return [String] URL sanitized.
    def sanitize_url(url)
      url = url =~ /^(http|https).*/i ? url : "http://#{url}"
      url = url.gsub(/\/+$/, "")
    end

    # Checks if the target_url is a valid CloudFoundry target.
    #
    # @return [Boolean] Returns true if target_url is a valid CloudFoundry API URL, false otherwise.
    def valid_target_url?
      return false unless cloud_info = cloud_info()
      return false unless cloud_info[:name]
      return false unless cloud_info[:build]
      return false unless cloud_info[:support]
      return false unless cloud_info[:version]
      true
    rescue
      false
    end

    # Requires a logged in user.
    #
    # @raise [CloudFoundry::Client::Exception::AuthError] if user is not logged in.
    def require_login
      raise CloudFoundry::Client::Exception::AuthError unless @user || logged_in?
    end
  end
end