module CloudFoundry
  class Client
    # The HTTP connection adapter that will be used to connect if none is set.
    DEFAULT_ADAPTER = :net_http

    # Default CloudFoundry API Target URL.
    DEFAULT_TARGET = "http://api.vcap.me"

    # CloudFoundry API Info Path.
    CLOUD_INFO_PATH = "/info"

    # CloudFoundry API System Services Info Path.
    CLOUD_SERVICES_INFO_PATH = "/info/services"

    # CloudFoundry API Runtimes Info Path.
    CLOUD_RUNTIMES_INFO_PATH = "/info/runtimes"

    # CloudFoundry API Applications Path.
    APPS_PATH = "/apps"

    # CloudFoundry API Resources Path.
    RESOURCES_PATH = "/resources"

    # CloudFoundry API Services Path.
    SERVICES_PATH = "/services"

    # CloudFoundry API Users Path.
    USERS_PATH = "/users"
  end
end
