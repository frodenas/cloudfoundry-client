module CloudFoundry
  class Client
    # CloudFoundry API Request Methods.
    module Request

      # Performs an HTTP GET request to the target cloud.
      #
      # @param [String] path Path to request at target cloud.
      # @param [Hash] options
      # @option options [Boolean] :raw true if response must not be parsed.
      def get(path, options = {})
        request(:get, path, options)
      end

      # Performs an HTTP POST request to the target cloud.
      #
      # @param [String] path Path to request at target cloud.
      # @param [Hash] body Body of the request to the target cloud.
      # @param [Hash] options
      # @option options [Boolean] :raw true if response must not be parsed.
      def post(path, body = {}, options = {})
        request(:post, path, options, body)
      end

      # Performs an HTTP PUT request to the target cloud.
      #
      # @param [String] path Path to request at target cloud.
      # @param [Hash] body Body of the request to the target cloud.
      # @param [Hash] options
      # @option options [Boolean] :raw true if response must not be parsed.
      def put(path, body = {}, options = {})
        request(:put, path, options, body)
      end

      # Performs an HTTP DELETE request to the target cloud.
      #
      # @param [String] path Path to request at target cloud.
      # @param [Hash] options
      # @option options [Boolean] :raw true if response must not be parsed.
      def delete(path, options = {})
        request(:delete, path, options)
      end

      private

      # Sets a new connection to target cloud.
      #
      # @param [Hash] options
      # @option options [Boolean] :raw true if response must not be parsed.
      # @return [Faraday::Connection] A Faraday Connection.
      def connection(options = {})
        connection_options = {
          :proxy => @proxy_url,
          :url => @target_url
        }
        connection = Faraday.new(connection_options) do |builder|
          builder.use Faraday::Request::Multipart
          builder.use Faraday::Request::UrlEncoded
          builder.use Faraday::Request::JSON unless options[:raw]
          builder.adapter @net_adapter
          builder.use CloudFoundry::Client::Response::ParseJSON unless options[:raw]
          builder.use CloudFoundry::Client::Response::CloudError
        end
      end

      # Performs a request to the target cloud.
      #
      # @param [Symbol] method HTTP method to use.
      # @param [String] path Path to request at target cloud.
      # @param [Hash] options
      # @param [Hash] payload Body of the request to the target cloud.
      # @option options [Boolean] :raw true if response must not be parsed.
      def request(method, path, options = {}, payload = nil)
        headers = {}
        headers["User-Agent"] = "cloudfoundry-client-" + CloudFoundry::Client::VERSION
        headers["AUTHORIZATION"] = @auth_token if @auth_token
        headers["PROXY-USER"] = @proxy_user if @proxy_user
        headers["X-VCAP-Trace"] = @trace_key if @trace_key
        headers["Accept"] = "application/json" unless options[:raw]
        headers["Content-Type"] = "application/json" unless options[:raw]
        response = connection(options).send(method, path) do |request|
          request.headers = headers
          request.body = payload unless payload && payload.empty?
        end
        options[:raw] ? response : response.body
      end
    end
  end
end