module CfConnectionHelper
  def client_data()
    @target = CloudFoundry::Client::DEFAULT_TARGET
    @user = "user@vcap.me"
    @password = "foobar"
    @auth_token = "04085b084922117573657240766361702e6d65063a0645546c2b073101dc4e2219f848b1aea2d82a2a6981750fa1aac61104aed60f"
  end

  def client_no_logged()
    @user = nil
    @auth_token = nil
    cf_client = CloudFoundry::Client.new()
  end

  def client_user_logged()
    @user = "user@vcap.me"
    @auth_token = "04085b084922117573657240766361702e6d65063a0645546c2b073101dc4e2219f848b1aea2d82a2a6981750fa1aac61104aed60f"
    cf_client = CloudFoundry::Client.new({:auth_token => @auth_token})
  end

  def client_admin_logged()
    @user = "admin@vcap.me"
    @auth_token = "04085b0849221261646d696e40766361702e6d65063a0645546c2b070101dc4e22196ec60283e0258107d4a7d98f66644938607fb049"
    cf_client = CloudFoundry::Client.new({:auth_token => @auth_token})
  end
end