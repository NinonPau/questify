class ApplicationController < ActionController::Base
  # Devise gem: every route will be protected by authentication through username
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end

  # Pundit gem: uncomment to activate authorization
  include Pundit::Authorization

  # Pundit: allow-list approach
  after_action :verify_authorized, unless: :skip_pundit?
  after_action :verify_policy_scoped, if: :pundit_policy_scoped?


  # Uncomment when you *really understand* Pundit!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
     flash[:alert] = "You are not authorized to perform this action."
     redirect_to(root_path)
  end

  private
  def pundit_policy_scoped?
    !skip_pundit? && action_name == "index"
  end


  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
