module CloudFoundry
  class Client
    # CloudFoundry API Resources methods.
    module Resources
      # Checks which resources are needed to send to the target cloud when uploading application bits.
      #
      # @param [Array] resources A resources manifest.
      # @return [Array] A resources manifest.
      # @authenticated True
      def check_resources(resources)
        require_login
        post(CloudFoundry::Client::RESOURCES_PATH, resources)
      end
    end
  end
end