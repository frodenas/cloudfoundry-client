CloudFoundry Ruby Client Gem
============================

This is a Ruby wrapper for the [CloudFoundry](http://cloudfoundry.org/) API, the industry’s first open Platform as a
Service (PaaS) offering.

Installation
------------

    gem install cloudfoundry-client

Continuous Integration
----------------------

[![Build Status](https://secure.travis-ci.org/frodenas/cloudfoundry-client.png)](http://travis-ci.org/frodenas/cloudfoundry-client)

Documentation
-------------

[http://rdoc.info/gems/cloudfoundry-client](http://rdoc.info/gems/cloudfoundry-client)

Usage Examples
--------------

### Connection and login:

    require "cloudfoundry-client"
    cf_client = CloudFoundry::Client.new({:target_url => "https://api.cloudfoundry.com"})
    cf_client.login("user@vcap.me", "password")

### Retrieve information from target cloud:

    cloud_info = cf_client.cloud_info()
    cloud_runtimes_info = cf_client.cloud_runtimes_info()
    cloud_services_info = cf_client.cloud_services_info()

### Actions for applications:

    apps = cf_client.list_apps()
    app_info = cf_client.app_info("appname")
    app_instances = cf_client.app_instances("appname")
    app_stats = cf_client.app_stats("appname")
    app_crashes = cf_client.app_crashes("appname")
    app_files = cf_client.app_files("appname", "/")
    app_files = cf_client.app_files("appname", "/logs/stdout.log")
    created = cf_client.create_app("appname", manifest)
    updated = cf_client.update_app("appname", manifest)
    update_info = cf_client.update_app_info("appname")
    deleted = cf_client.delete_app("appname")
    uploaded = cf_client.upload_app("appname", zipfile, manifest)
    zipfile = cf_client.download_app("appname")

### Actions for services:

    services = cf_client.list_services()
    service_info = cf_client.service_info("redis-12345")
    created = cf_client.create_service("redis", "redis-12345")
    deleted = cf_client.delete_service("redis-12345")
    binded = cf_client.bind_service("redis-12345", "appname")
    unbinded = cf_client.unbind_service("redis-12345", "appname")

### Actions for users (some of them require an admin user):

    users = cf_client.list_users()
    user_info = cf_client.user_info("user@vcap.me")
    created = cf_client.create_user("user@vcap.me", "password")
    updated = cf_client.update_user("user@vcap.me", "new_password")
    deleted = cf_client.delete_user("user@vcap.me")

Contributing
------------
In the spirit of [free software](http://www.fsf.org/licensing/essays/free-sw.html), **everyone** is encouraged to help
improve this project.

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by closing [issues](http://github.com/frodenas/cloudfoundry-client/issues)
* by reviewing patches


Submitting an Issue
-------------------
We use the [GitHub issue tracker](http://github.com/frodenas/cloudfoundry-client/issues) to track bugs and features.
Before submitting a bug report or feature request, check to make sure it hasn't already been submitted. You can indicate
support for an existing issuse by voting it up. When submitting a bug report, please include a
[Gist](http://gist.github.com/) that includes a stack trace and any details that may be necessary to reproduce the bug,
including your gem version, Ruby version, and operating system. Ideally, a bug report should include a pull request with
 failing specs.


Submitting a Pull Request
-------------------------
1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Run <tt>rake doc:yard</tt>. If your changes are not 100% documented, go back to step 4.
6. Add specs for your feature or bug fix.
7. Run <tt>rake spec</tt>. If your changes are not 100% covered, go back to step 6.
8. Commit and push your changes.
9. Submit a pull request. Please do not include changes to the gemspec, version, or history file. (If you want to create
your own version for some reason, please do so in a separate commit.)


Authors
-------

By [Ferran Rodenas](http://www.rodenas.org/) <frodenas@gmail.com>
Based on the [VMC - VMware Cloud CLI](https://github.com/cloudfoundry/vmc)

Copyright
---------

See [LICENSE](https://github.com/frodenas/cloudfoundry-client/blob/master/LICENSE) for details.
Copyright (c) 2011 [Ferran Rodenas](http://www.rodenas.org/).