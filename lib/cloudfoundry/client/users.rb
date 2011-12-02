module CloudFoundry
  class Client
    # CloudFoundry API Users methods.
    module Users
      # Logs the user in and returns the auth_token provided by the target cloud.
      #
      # @param [String] email The user's email.
      # @param [String] password The user's password.
      # @return [String] CloudFoundry API Authorization Token.
      # @raise [CloudFoundry::Client::Exception::BadParams] when email is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when password is blank.
      # @raise [CloudFoundry::Client::Exception::Forbidden] when login fails.
      def login(email, password)
        raise CloudFoundry::Client::Exception::BadParams, "Email cannot be blank" if email.nil? || email.empty?
        raise CloudFoundry::Client::Exception::BadParams, "Password cannot be blank" if password.nil? || password.empty?
        response_info = post("#{CloudFoundry::Client::USERS_PATH}/#{email}/tokens", {:password => password})
        raise CloudFoundry::Client::Exception::Forbidden, "Login failed" unless response_info &&  response_info[:token]
        @user = email
        @proxy_user = nil
        @auth_token = response_info[:token]
      end

      # Checks if the user is logged in at the cloud target.
      #
      # @return [Boolean] Returns true if user is logged in, false otherwise.
      def logged_in?
        return false unless cloud_info = cloud_info()
        return false unless cloud_info[:user]
        return false unless cloud_info[:usage]
        @user = cloud_info[:user]
        true
      end

      # Sets a user proxied access
      #
      # @param [String] email The user's email to be proxied.
      # @return [String] Proxied user.
      # @raise [CloudFoundry::Client::Exception::BadParams] when email is blank.
      # @admin True
      def set_proxy_user(email)
        raise CloudFoundry::Client::Exception::BadParams, "Email cannot be blank" if email.nil? || email.empty?
        @proxy_user = email
      end

      # Unsets a user proxied access
      #
      # @return [nil]
      def unset_proxy_user()
        @proxy_user = nil
      end

      # Returns the list of users on the target cloud.
      #
      # @return [Hash] List of users on the target cloud.
      # @admin True
      def list_users()
        require_login
        get(CloudFoundry::Client::USERS_PATH)
      end

      # Returns information about a user on the target cloud.
      #
      # @param [String] email The user's email.
      # @return [Hash] User information on the target cloud.
      # @raise [CloudFoundry::Client::Exception::BadParams] when email is blank.
      # @authenticated True
      # @admin Only when retrieving information about others users.
      def user_info(email)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Email cannot be blank" if email.nil? || email.empty?
        get("#{CloudFoundry::Client::USERS_PATH}/#{email}")
      end

      # Creates a new user on the target cloud.
      #
      # @param [String] email The user's email.
      # @param [String] password The user's password.
      # @return [Boolean] Returns true if user is created.
      # @raise [CloudFoundry::Client::Exception::BadParams] when email is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when password is blank.
      def create_user(email, password)
        raise CloudFoundry::Client::Exception::BadParams, "Email cannot be blank" if email.nil? || email.empty?
        raise CloudFoundry::Client::Exception::BadParams, "Password cannot be blank" if password.nil? || password.empty?
        post(CloudFoundry::Client::USERS_PATH, {:email => email, :password => password})
        true
      end

      # Updates the user's password  on the target cloud.
      #
      # @param [String] email The user's email.
      # @param [String] password The user's password.
      # @return [Boolean] Returns true if user is updated.
      # @raise [CloudFoundry::Client::Exception::BadParams] when email is blank.
      # @raise [CloudFoundry::Client::Exception::BadParams] when password is blank.
      # @authenticated True
      # @admin Only when updating password for others users.
      def update_user(email, password)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Email cannot be blank" if email.nil? || email.empty?
        raise CloudFoundry::Client::Exception::BadParams, "Password cannot be blank" if password.nil? || password.empty?
        user_info = user_info(email)
        user_info[:password] = password
        put("#{CloudFoundry::Client::USERS_PATH}/#{email}", user_info)
        true
      end

      # Deletes a user on the target cloud.
      #
      # @param [String] email The user's email.
      # @return [Boolean] Returns true if user is deleted.
      # @raise [CloudFoundry::Client::Exception::BadParams] when email is blank.
      # @admin True
      def delete_user(email)
        require_login
        raise CloudFoundry::Client::Exception::BadParams, "Email cannot be blank" if email.nil? || email.empty?
        delete("#{CloudFoundry::Client::USERS_PATH}/#{email}", :raw => true)
        true
      end
    end
  end
end