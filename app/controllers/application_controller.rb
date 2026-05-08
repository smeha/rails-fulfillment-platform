class ApplicationController < ActionController::Base
  before_action :require_internal_user
  helper_method :current_internal_user

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def current_internal_user
    @current_internal_user ||= InternalUser.find_by(id: session[:internal_user_id]) if session[:internal_user_id]
  end

  def require_internal_user
    return if current_internal_user&.active?

    reset_session
    redirect_to login_path, alert: "Please sign in to continue."
  end
end
