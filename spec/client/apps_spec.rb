require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Cloudfoundry::Client::Apps" do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("no_logged/client", :record => :new_episodes) do
        @cf_client = client_no_logged()
      end
    end

    use_vcr_cassette "no_logged/apps", :record => :new_episodes

    it "should raise an AuthError exception when creating an application" do
      expect {
        created = @cf_client.create_app("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when listing all applications at target cloud" do
      expect {
        apps = @cf_client.list_apps()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when retrieving basic application information from target cloud" do
      expect {
        app_info = @cf_client.app_info("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when retrieving application instances information from target cloud" do
      expect {
        app_instances = @cf_client.app_instances("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when retrieving application stats information from target cloud" do
      expect {
        app_stats = @cf_client.app_stats("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when retrieving application crashes information from target cloud" do
      expect {
        app_crashes = @cf_client.app_crashes("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when retrieving application files information from target cloud" do
      expect {
        app_files = @cf_client.app_files("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when updating an application at target cloud" do
      expect {
        updated = @cf_client.update_app("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when retrieving application update status information from target cloud" do
      expect {
        update_info = @cf_client.update_app_info("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when uploading application bits to target cloud" do
      expect {
        appfile = spec_fixture("app.zip")
        upload = @cf_client.upload_app("newapp", appfile)
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when application bits at target cloud" do
      expect {
        appbits = @cf_client.download_app("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it "should raise an AuthError exception when deleting an application at target cloud" do
      expect {
        deleted = @cf_client.delete_app("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("user_logged/client", :record => :new_episodes) do
        @cf_client = client_user_logged()
      end
    end

    use_vcr_cassette "user_logged/apps", :record => :new_episodes

    it "should raise a BadParams exception when creating an application with a blank application name" do
      expect {
        created = @cf_client.create_app("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when creating an application with no manifest" do
      expect {
        created = @cf_client.create_app("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadRequest exception when creating an application with an invalid manifest" do
      expect {
        manifest = {
          :name => "newapp",
        }
        created = @cf_client.create_app("newapp", manifest)
      }.to raise_exception(CloudFoundry::Client::Exception::BadRequest)
    end

    it "should return true if a new application is created at target cloud" do
      VCR.use_cassette("user_logged/apps_create_action", :record => :new_episodes, :exclusive => true) do
        manifest = {
          :name => "newapp",
          :uris => ["newapp.vcap.me"],
          :instances => 1,
          :staging => {:model => "node"},
          :resources => {:memory => 64}
        }
        created = @cf_client.create_app("newapp", manifest)
        created.should be_true
      end
    end

    it "should get a proper list of apps at target cloud" do
      apps = @cf_client.list_apps()
      apps.should have_at_least(1).items
      app_info = apps.first
      app_info.should have_key :name
      app_info.should have_key :staging
      app_info.should have_key :uris
      app_info.should have_key :instances
      app_info.should have_key :runningInstances
      app_info.should have_key :resources
      app_info.should have_key :state
      app_info.should have_key :services
      app_info.should have_key :version
      app_info.should have_key :env
      app_info.should have_key :meta
    end

    it "should raise an BadParams exception when retrieving basic information with blank application name" do
      expect {
        app_info = @cf_client.app_info("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise an NotFound exception when retrieving basic information for an application that does not exists at target cloud" do
      expect {
        app_info = @cf_client.app_info("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should properly get basic application information from target cloud" do
      app_info = @cf_client.app_info("newapp")
      app_info.should have_key :name
      app_info.should have_key :staging
      app_info.should have_key :uris
      app_info.should have_key :instances
      app_info.should have_key :runningInstances
      app_info.should have_key :resources
      app_info.should have_key :state
      app_info.should have_key :services
      app_info.should have_key :version
      app_info.should have_key :env
      app_info.should have_key :meta
    end

    it "should raise an BadParams exception when retrieving instances information with blank application name" do
      expect {
        app_instances = @cf_client.app_instances("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise an NotFound exception when retrieving instances information for an application that does not exists at target cloud" do
      expect {
        app_instances = @cf_client.app_instances("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should properly get application instances information from target cloud" do
      app_instances = @cf_client.app_instances("newapp")
      app_instances.should have_key :instances
    end

    it "should raise an BadParams exception when retrieving stats information with blank application name" do
      expect {
        app_stats = @cf_client.app_stats("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise an NotFound exception when retrieving stats information for an application that does not exists at target cloud" do
      expect {
        app_stats = @cf_client.app_stats("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should properly get empty application stats information from target cloud" do
      app_stats = @cf_client.app_stats("newapp")
      app_stats.should be_empty
    end

    it "should raise an BadParams exception when retrieving crashes information with blank application name" do
      expect {
        app_crashes = @cf_client.app_crashes("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise an NotFound exception when retrieving crashes information for an application that does not exists at target cloud" do
      expect {
        app_crashes = @cf_client.app_crashes("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should properly get application crashes information from target cloud" do
      app_crashes = @cf_client.app_crashes("newapp")
      app_crashes.should have_key :crashes
    end

    it "should raise an BadParams exception when retrieving files information with blank application name" do
      expect {
        app_files = @cf_client.app_files("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise an NotFound exception when retrieving files information for an application that does not exists at target cloud" do
      expect {
        app_files = @cf_client.app_files("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should raise an BadRequest exception when retrieving files information for an application without bits at target cloud" do
      expect {
        app_files = @cf_client.app_files("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::BadRequest)
    end

    it "should raise a BadParams exception when updating an application with a blank name" do
      expect {
        updated = @cf_client.update_app("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when updating an application with no manifest" do
      expect {
        updated = @cf_client.update_app("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a NotFound exception when updating an application that does not exists at target cloud" do
      expect {
        manifest = {
          :name => "noapp",
        }
        updated = @cf_client.update_app("noapp", manifest)
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should return true if an application is updated at target cloud" do
      app_info = @cf_client.app_info("newapp")
      app_info[:instances] = 2
      updated = @cf_client.update_app("newapp", app_info)
      updated.should be_true
    end

    it "should raise a BadParams exception when retrieving update status information with a blank name" do
      expect {
        update_info = @cf_client.update_app_info("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a NotFound exception when retrieving application update status information for an application that does not exists at target cloud" do
      expect {
        update_info = @cf_client.update_app_info("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should raise a BadParams exception when uploading application bits with a blank name" do
      expect {
        upload = @cf_client.upload_app("", nil)
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when uploading application bits with a blank zipfile" do
      expect {
        upload = @cf_client.upload_app("newapp", nil)
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a BadParams exception when uploading application bits with an invalid zipfile" do
      expect {
        upload = @cf_client.upload_app("newapp", "fakefile")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a NotFound exception when uploading application bits for an application that does not exists at target cloud" do
      expect {
        appfile = spec_fixture("app.zip")
        upload = @cf_client.upload_app("noapp", appfile)
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should raise a BadParams exception when downloading application bits with a blank name" do
      expect {
        appbits = @cf_client.download_app("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a NotFound exception when downloading application bits for an application that does not exists at target cloud" do
      expect {
        appbits = @cf_client.download_app("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should raise a NotFound exception when downloading application bits for an application without bits at target cloud" do
      expect {
        appbits = @cf_client.download_app("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should return true if application bits passed as filename are uploaded to the target cloud" do
      VCR.use_cassette("user_logged/apps_upload_filename_action", :record => :new_episodes, :exclusive => true) do
        filename = spec_fixture("app.zip")
        upload = @cf_client.upload_app("newapp", filename)
        upload.should be_true
      end
    end

    it "should return true if application bits passed as file are uploaded to the target cloud" do
      VCR.use_cassette("user_logged/apps_upload_zipfile_action", :record => :new_episodes, :exclusive => true) do
        filename = spec_fixture("app.zip")
        appfile = File.new(filename, "rb")
        upload = @cf_client.upload_app("newapp", appfile)
        upload.should be_true
      end
    end

    it "should return true if an application is started at target cloud" do
      VCR.use_cassette("user_logged/apps_start_action", :record => :new_episodes, :exclusive => true) do
        app_info = @cf_client.app_info("newapp")
        app_info[:state] = "STARTED"
        updated = @cf_client.update_app("newapp", app_info)
        updated.should be_true
      end
    end

    it "should properly get application update status information from target cloud" do
      VCR.use_cassette("user_logged/apps_update_info_action", :record => :new_episodes, :exclusive => true) do
        update_info = @cf_client.update_app_info("newapp")
        update_info.should have_key :state
        update_info.should have_key :since
      end
    end

    it "should properly get application bits from target cloud" do
      VCR.use_cassette("user_logged/apps_download_action", :record => :new_episodes, :exclusive => true) do
        appbits = @cf_client.download_app("newapp")
        appbits.should_not be_empty
      end
    end

    it "should properly get directory information for an application at target cloud" do
      VCR.use_cassette("user_logged/apps_directory_action", :record => :new_episodes, :exclusive => true) do
        app_files = @cf_client.app_files("newapp", "/app")
        app_files.should include("app.js")
      end
    end

    it "should properly get file information for an application at target cloud" do
      VCR.use_cassette("user_logged/apps_file_action", :record => :new_episodes, :exclusive => true) do
        app_file = @cf_client.app_files("newapp", "/app/app.js")
        filebits = ""
        filename = spec_fixture("app.js")
        appfile = File.new(filename, "r")
        while (line = appfile.gets)
          filebits += line
        end
        appfile.close
        app_file.should eql(filebits)
      end
    end

    it "should raise an ServerError exception when retrieving files information for a file that does not exists at target cloud" do
      expect {
        app_files = @cf_client.app_files("newapp", "/app/nofile")
      }.to raise_exception(CloudFoundry::Client::Exception::ServerError)
    end

    it "should properly get application stats information from target cloud" do
      VCR.use_cassette("user_logged/apps_stats_action", :record => :new_episodes, :exclusive => true) do
        app_stats = @cf_client.app_stats("newapp")
        app_stats.should have_at_least(1).items
        app_stats_info = app_stats.first
        app_stats_info.should have_key :stats
      end
    end

    it "should raise a BadParams exception when deleting an application with a blank name" do
      expect {
        deleted = @cf_client.delete_app("")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it "should raise a NotFound exception when deleting an application that does not exists at target cloud" do
      expect {
        deleted = @cf_client.delete_app("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it "should return true if an application is deleted at target cloud" do
      deleted = @cf_client.delete_app("newapp")
      deleted.should be_true
    end
  end
end