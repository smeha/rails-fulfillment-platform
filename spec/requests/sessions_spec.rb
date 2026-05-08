require "rails_helper"

RSpec.describe "Internal user sessions", type: :request do
  describe "GET /" do
    it "redirects unauthenticated internal users to the sign-in page" do
      get root_path

      expect(response).to redirect_to(login_path)
    end

    it "renders the dashboard for authenticated internal users" do
      internal_user = create(:internal_user)

      sign_in(internal_user)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Operations Dashboard")
      expect(response.body).to include(internal_user.email)
    end
  end

  describe "POST /session" do
    it "signs in active internal users with valid credentials" do
      internal_user = create(:internal_user)

      post session_path, params: { session: { email: " #{internal_user.email.upcase} ", password: internal_user.password } }

      expect(response).to redirect_to(root_path)
      expect(internal_user.reload.last_sign_in_at).to be_present
    end

    it "rejects invalid credentials" do
      internal_user = create(:internal_user)

      post session_path, params: { session: { email: internal_user.email, password: "wrong-password" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Invalid email or password.")
    end

    it "rejects inactive internal users" do
      internal_user = create(:internal_user, active: false)

      post session_path, params: { session: { email: internal_user.email, password: internal_user.password } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Invalid email or password.")
    end
  end

  describe "DELETE /session" do
    it "signs out internal users" do
      sign_in(create(:internal_user))

      delete session_path
      get root_path

      expect(response).to redirect_to(login_path)
    end
  end

  def sign_in(internal_user)
    post session_path, params: { session: { email: internal_user.email, password: internal_user.password } }
  end
end
