class AuthController < ApplicationController
  # This is our new function that comes before Devise's one

  before_action :authenticate_oauth_user!, :except => [:access_token]
  before_action :authenticate_user!, :except => [:access_token]
  skip_before_action :verify_authenticity_token, :only => [:access_token]

  def authorize
    # Note: this method will be called when the user
    # is logged into the provider
    #
    # So we're essentially granting him access to our
    # system by generating certain tokens and then
    # redirecting him back to the params[:redirect_uri]
    # with a random code and the params[:state]


    AccessGrant.prune!
    create_hash = {
      oauth_client: application,
      state: params[:state]
    }
    access_grant = current_user.access_grants.create(create_hash)
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri]), allow_other_host: true
  end

  # POST
  def access_token
    access_grant = AccessGrant.find_by_code(params[:code])
    if access_grant.nil?
      render :json => {:error => "Could not authenticate with the access grant code"}
      return
    end

    application = access_grant.oauth_client
    if application.nil?
      render :json => {:error => "Could not find OAuth application"}
      return
    end

    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}
  end

  def user
    hash = current_user.oauth_payload
    render :json => hash.to_json
  end

  protected

  def application
    @application ||= OauthClient.find_by_app_id(params[:client_id])
  end

  private

  def authenticate_oauth_user!
    if params[:oauth_token]
      access_grant = AccessGrant.where(access_token: params[:oauth_token]).take
      if access_grant.user
        sign_in access_grant.user # Devise sign in
      end
    end
  end

end
