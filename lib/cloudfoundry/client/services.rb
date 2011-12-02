module CloudFoundry
  class Client
    # CloudFoundry API Provisioned Services methods.
    module Services
      # Returns a list of provisioned services that are available on the target cloud.
      #
      # @return [Hash] List of provisioned services available on the target cloud.
      # @authenticated True
      def list_services
        require_login
        get(CloudFoundry::Client::SERVICES_PATH)
      end

      # Returns information about a provisioned service on the target cloud.
      #
      # @param [String] name The provisioned service name.
      # @return [Hash] Provisioned service information on the target cloud.
      # @raise [CloudFoundry::Client::Exception::BadParams] when provisioned service name is blank.
      # @authenticated True
      def service_info(name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        get("#{CloudFoundry::Client::SERVICES_PATH}/#{name}")
      end

      # Creates a new provisioned service on the target cloud.
      #
      # @param [String] service The system service to provision.
      # @param [String] name The provisioned service name.
      # @return [Boolean] Returns true if provisioned service is created.
      # @raise [CloudFoundry::Client::Exception::BadParams] when system service is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when system service is not a valid service at target cloud.
      # @raise [CloudFoundry::Client::Exception::BadParams] when provisioned service name is blank.
      # @authenticated True
      def create_service(service, name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Service cannot be blank" if service.nil? || service.empty?
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        service_hash = nil
        services = cloud_services_info() || []
        services.each do |service_type, service_value|
          service_value.each do |vendor, vendor_value|
            vendor_value.each do |version, service_info|
              if service == service_info[:vendor]
                service_hash = {
                  :type => service_info[:type],
                  :vendor => vendor,
                  :version => version,
                  :tier => "free"
                }
                break
              end
            end
          end
        end
        raise CloudFoundry::Client::Exception::BadParams, "Service [#{service}] is not a valid service" unless service_hash
        service_hash[:name] = name
        post(CloudFoundry::Client::SERVICES_PATH, service_hash)
        true
      end

      # Deletes a provisioned service on the target cloud.
      #
      # @param [String] name The provisioned service name.
      # @return [Boolean] Returns true if provisioned service is deleted.
      # @raise [CloudFoundry::Client::Exception::BadParams] when provisioned service name is blank.
      # @authenticated True
      def delete_service(name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        delete("#{CloudFoundry::Client::SERVICES_PATH}/#{name}", :raw => true)
        true
      end

      # Binds a provisioned service to an application on the target cloud.
      #
      # @param [String] name The provisioned service name.
      # @param [String] appname The application name.
      # @return [Boolean] Returns true if provisioned service is binded to application.
      # @raise [CloudFoundry::Client::Exception::BadParams] when provisioned service name is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when provisioned service is already binded to application.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def bind_service(name, appname)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Service Name cannot be blank" if name.nil? || name.empty?
        raise CloudFoundry::Client::Exception::BadParams, "Application Name cannot be blank" if appname.nil? || appname.empty?
        service = service_info(name)
        app = app_info(appname)
        services = app[:services] || []
        service_exists = services.index(name)
        raise CloudFoundry::Client::Exception::BadParams, "Service [#{name}] is already binded to [#{appname}]" if service_exists
        app[:services] = services << name
        update_app(appname, app)
        true
      end

      # Unbinds a provisioned service from an application on the target cloud.
      #
      # @param [String] name The provisioned service name.
      # @param [String] appname The application name.
      # @return [Boolean] Returns true if provisioned service is unbinded from application.
      # @raise [CloudFoundry::Client::Exception::BadParams] when provisioned service name is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when provisioned service is not binded to application.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def unbind_service(name, appname)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Service Name cannot be blank" if name.nil? || name.empty?
        raise CloudFoundry::Client::Exception::BadParams, "Application Name cannot be blank" if appname.nil? || appname.empty?
        service = service_info(name)
        app = app_info(appname)
        services = app[:services] || []
        service_deleted = services.delete(name)
        raise CloudFoundry::Client::Exception::BadParams, "Service [#{name}] is not binded to [#{name}]" unless service_deleted
        app[:services] = services
        update_app(appname, app)
        true
      end
    end
  end
end