module CloudFoundry
  class Client
    # CloudFoundry::Client Exceptions.
    module Exception
      # CloudFoundry Client Exception: Authorization Error.
      class AuthError < RuntimeError; end
      # CloudFoundry Client Exception: Bad Parameters.
      class BadParams < RuntimeError; end
      # CloudFoundry Client Exception: Bad Response Received.
      class BadResponse < RuntimeError; end

      # CloudFoundry Cloud Exception: Bad Request.
      class BadRequest < RuntimeError; end
      # CloudFoundry Cloud Exception: Forbidden.
      class Forbidden < RuntimeError; end
      # CloudFoundry Cloud Exception: Not Found.
      class NotFound < RuntimeError; end
      # CloudFoundry Cloud Exception: Server Error.
      class ServerError < RuntimeError; end
      # CloudFoundry Cloud Exception: Bad Gateway.
      class BadGateway < RuntimeError; end
    end
  end
end