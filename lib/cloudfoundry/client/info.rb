module CloudFoundry
  class Client
    # CloudFoundry API Info methods.
    module Info
      # Returns information about the target cloud and, if logged, information about the user account.
      #
      # @return [Hash] Information about the target cloud and, if logged, information about the user account.
      def cloud_info()
        get(CloudFoundry::Client::CLOUD_INFO_PATH)
      end

      # Returns information about system runtimes that are available on the target cloud.
      #
      # @return [Hash] System Runtimes available on the target cloud.
      def cloud_runtimes_info()
        get(CloudFoundry::Client::CLOUD_RUNTIMES_INFO_PATH)
      end

      # Returns information about system services that are available on the target cloud.
      #
      # @return [Hash] System Services available on the target cloud.
      # @authenticated True
      def cloud_services_info()
        require_login
        get(CloudFoundry::Client::CLOUD_SERVICES_INFO_PATH)
      end
    end
  end
end