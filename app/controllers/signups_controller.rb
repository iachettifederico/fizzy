class SignupsController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_signup_path, alert: "Try again later." }
  before_action :redirect_authenticated_user
  before_action :ensure_signups_allowed

  layout "public"

  def new
    @signup = Signup.new
  end

  def create
    signup = Signup.new(signup_params)
    if signup.valid?(:identity_creation)
      redirect_to_session_magic_link signup.create_identity
    else
      head :unprocessable_entity
    end
  end

  private
    def redirect_authenticated_user
      redirect_to new_signup_completion_path if authenticated?
    end

    def ensure_signups_allowed
      unless signups_allowed?
        render plain: "Signups are currently disabled. Please contact the administrator for an invitation.", status: :forbidden
      end
    end

    def signups_allowed?
      ENV.fetch("ALLOW_SIGNUPS", "true") == "true"
    end

    def signup_params
      params.expect signup: :email_address
    end
end
