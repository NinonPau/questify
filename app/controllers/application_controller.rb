class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Commentez ou supprimez ces lignes si vous voulez désactiver Pundit pour les tests/controller actuels
  # after_action :verify_authorized, except: %i[index random]
  # after_action :verify_policy_scoped, only: :index

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end
end
