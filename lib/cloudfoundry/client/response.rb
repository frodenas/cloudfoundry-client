module CloudFoundry
  class Client
    # CloudFoundry Faraday Response Middleware.
    module Response
      # Faraday Response Middleware to parse cloud JSON responses.
      class ParseJSON < Faraday::Response::Middleware
        # Parses a JSON response.
        #
        # @param [String] body HTTP body response.
        # @return [Hash] Parsed body response with symbolized names (keys).
        # @raise [CloudFoundry::Client::Exception::BadResponse] when body can not be parsed.
        def parse(body)
          case body
            when " " then nil
            else JSON.parse(body, :symbolize_names => true, :symbolize_keys => true)
          end
        rescue JSON::ParserError
          raise CloudFoundry::Client::Exception::BadResponse, "Can't parse response into JSON:" + body
        end
      end

      # Faraday Response Middleware to parse cloud errors.
      class CloudError < Faraday::Response::Middleware
        # Checks if an error is returned by target cloud.
        #
        # @param [Hash] env Faraday environment.
        # @raise [CloudFoundry::Client::Exception::BadRequest] when HTTP status is 400.
        # @raise [CloudFoundry::Client::Exception::Forbidden] when HTTP status is 403.
        # @raise [CloudFoundry::Client::Exception::NotFound] when HTTP status is 404.
        # @raise [CloudFoundry::Client::Exception::ServerError] when HTTP status is 500.
        # @raise [CloudFoundry::Client::Exception::BadGateway] when HTTP status is 502.
        def on_complete(env)
          if env[:status].to_i >= 400
            err = case env[:status].to_i
              when 400 then CloudFoundry::Client::Exception::BadRequest
              when 403 then CloudFoundry::Client::Exception::Forbidden
              when 404 then CloudFoundry::Client::Exception::NotFound
              when 500 then CloudFoundry::Client::Exception::ServerError
              when 502 then CloudFoundry::Client::Exception::BadGateway
            end
            raise err, parse_cloud_error_message(env[:status], env[:body])
          end
        end

        # Parses a CloudFoundry error message.
        #
        # @param [String] status Faraday HTTP response status.
        # @param [String] body Faraday HTTP response body.
        # @return [String] CloudFoundry error message.
        def parse_cloud_error_message(status, body)
          parsed_body = JSON.parse(body, :symbolize_names => true)
          if parsed_body && parsed_body[:code] && parsed_body[:description]
            description = parsed_body[:description].gsub("\"","'")
            "Error #{parsed_body[:code]}: #{description}"
          else
            "Error (HTTP #{status}): #{body}"
          end
        rescue JSON::ParserError
          if body.nil? || body.empty?
            "Error (#{status}): No Response Received"
          else
            "Error (JSON #{status}): #{body}"
          end
        end
      end
    end
  end
end