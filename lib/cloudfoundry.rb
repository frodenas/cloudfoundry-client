require 'faraday'
require 'faraday_middleware'
require 'json/pure'

# This is a Ruby wrapper for the CloudFoundry API, the industry’s first open Platform as a Service (PaaS) offering.
module CloudFoundry
  require 'cloudfoundry/client'
  require 'cloudfoundry/constants'
  require 'cloudfoundry/exception'
  require 'cloudfoundry/version'

  # @private
  VERSION = CloudFoundry::Client::VERSION #:nodoc;

  class << self
    # Alias for CloudFoundry::Client.new
    #
    # @return [CloudFoundry::Client] A CloudFoundry::Client Object.
    # @see CloudFoundry::Client#initialize CloudFoundry::Client.new()
    def new(options = {})
      CloudFoundry::Client.new(options)
    end

    # Delegate all methods to CloudFoundry::Client.
    def method_missing(method, *arguments, &block)
      return super unless new.respond_to?(method)
      new.send(method, *arguments, &block)
    end

    # Delegate all methods to CloudFoundry::Client.
    def respond_to?(method, include_private = false)
      new.respond_to?(method, include_private) || super(method, include_private)
    end
  end
end