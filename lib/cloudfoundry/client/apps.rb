module CloudFoundry
  class Client
    # CloudFoundry API Applications methods.
    module Apps
      # Returns the list of applications deployed on the target cloud.
      #
      # @return [Hash] List of applications deployed on the target cloud.
      # @authenticated True
      def list_apps()
        require_login
        get(CloudFoundry::Client::APPS_PATH)
      end

      # Returns basic information about an application deployed on the target cloud.
      #
      # @param [String] name The application name.
      # @return [Hash] Basic application information on the target cloud.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def app_info(name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        get("#{CloudFoundry::Client::APPS_PATH}/#{name}")
      end

      # Returns information about application instances on the target cloud.
      #
      # @param [String] name The application name.
      # @return [Hash] Application instances information on the target cloud.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def app_instances(name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        get("#{CloudFoundry::Client::APPS_PATH}/#{name}/instances")
      end

      # Returns information about application statistics on the target cloud.
      #
      # @param [String] name The application name.
      # @return [Hash] Application statistics information on the target cloud.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def app_stats(name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        stats = []
        stats_raw = get("#{CloudFoundry::Client::APPS_PATH}/#{name}/stats")
        stats_raw.each_pair do |key, entry|
          next unless entry[:stats]
          entry[:instance] = key.to_s.to_i
          entry[:state] = entry[:state].to_sym if entry[:state]
          stats << entry
        end
        stats.sort { |a,b| a[:instance] - b[:instance] }
      end

      # Returns information about application crashes on the target cloud.
      #
      # @param [String] name The application name.
      # @return [Hash] Application crashes information on the target cloud.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def app_crashes(name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        get("#{CloudFoundry::Client::APPS_PATH}/#{name}/crashes")
      end

      # List the directory or a file indicated by the path and instance.
      #
      # @param [String] name The application name.
      # @param [String] path The application directory or file to display.
      # @param [Integer] instance The application instance where directories or files are located.
      # @return [String] Directory list or file bits on the target cloud.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def app_files(name, path = "/", instance = 0)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        url = "#{CloudFoundry::Client::APPS_PATH}/#{name}/instances/#{instance}/files/#{path}"
        url.gsub!('//', '/')
        response_info = get(url, :raw => true)
        response_info.body
      end

      # Creates a new application at target cloud.
      #
      # @param [String] name The application name.
      # @param [Hash] manifest The manifest of the application.
      # @return [Boolean] Returns true if application is created.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application manifest is blank.
      # @authenticated True
      def create_app(name, manifest = {})
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        raise CloudFoundry::Client::Exception::BadParams, "Manifest cannot be blank" if manifest.nil? || manifest.empty?
        app = manifest.dup
        app[:name] = name
        app[:instances] ||= 1
        post(CloudFoundry::Client::APPS_PATH, app)
        true
      end

      # Updates an application at target cloud.
      #
      # @param [String] name The application name.
      # @param [Hash] manifest The manifest of the application.
      # @return [Boolean] Returns true if application is updated.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application manifest is blank.
      # @authenticated True
      def update_app(name, manifest = {})
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        raise CloudFoundry::Client::Exception::BadParams, "Manifest cannot be blank" if manifest.nil? || manifest.empty?
        put("#{CloudFoundry::Client::APPS_PATH}/#{name}", manifest)
        true
      end

      # Checks the status of the latest application update at target cloud.
      #
      # @param [String] name The application name.
      # @return [Hash] Status of the latest application update at target cloud.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def update_app_info(name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        get("#{CloudFoundry::Client::APPS_PATH}/#{name}/update")
      end

      # Deletes an application at target cloud.
      #
      # @param [String] name The application name.
      # @return [Boolean] Returns true if application is deleted.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def delete_app(name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        delete("#{CloudFoundry::Client::APPS_PATH}/#{name}", :raw => true)
        true
      end

      # Uploads the application bits to the target cloud.
      #
      # @param [String] name The application name.
      # @param [File, String] zipfile The application bits, can be a File Object or a filename String.
      # @param [Array] resource_manifest The application resources manifest.
      # @return [Boolean] Returns true if application is uploaded.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application zipfile is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application zipfile is invalid.
      # @authenticated True
      def upload_app(name, zipfile, resource_manifest = [])
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        raise CloudFoundry::Client::Exception::BadParams, "Zipfile cannot be blank" if zipfile.nil?
        upload_data = {}
        begin
          if zipfile.is_a? File
            file = Faraday::UploadIO.new(zipfile, "application/zip")
          else
            filebits = File.new(zipfile, "rb")
            file = Faraday::UploadIO.new(filebits, "application/zip")
          end
        rescue SystemCallError => error
          raise CloudFoundry::Client::Exception::BadParams, "Invalid Zipfile: " + error.message
        end
        upload_data[:application] = file
        upload_data[:resources] = resource_manifest.to_json if resource_manifest
        put("#{CloudFoundry::Client::APPS_PATH}/#{name}/application", upload_data, :raw => true)
        true
      end

      # Downloads the application bits from the target cloud.
      #
      # @param [String] name The application name.
      # @return [String] Application bits.
      # @raise [CloudFoundry::Client::Exception::BadParams] when application name is blank.
      # @authenticated True
      def download_app(name)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Name cannot be blank" if name.nil? || name.empty?
        response_info = get("#{CloudFoundry::Client::APPS_PATH}/#{name}/application", :raw => true)
        response_info.body
      end
    end
  end
end