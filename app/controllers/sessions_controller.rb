class SessionsController < ApplicationController
  skip_before_action :require_internal_user, only: %i[new create]
  before_action :redirect_authenticated_internal_user, only: %i[new create]

  def new
  end

  def create
    internal_user = InternalUser.find_by(email: session_params[:email].to_s.strip.downcase)

    if internal_user&.active? && internal_user.authenticate(session_params[:password].to_s)
      sign_in(internal_user)
      redirect_to root_path, notice: "Signed in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Signed out successfully."
  end

  private

  def session_params
    params.expect(session: %i[email password])
  end

  def sign_in(internal_user)
    reset_session
    session[:internal_user_id] = internal_user.id
    internal_user.update!(last_sign_in_at: Time.current)
  end

  def redirect_authenticated_internal_user
    redirect_to root_path if current_internal_user&.active?
  end
end
