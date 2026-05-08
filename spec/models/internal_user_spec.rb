require "rails_helper"

RSpec.describe InternalUser do
  describe "validations" do
    it "normalizes email before validation" do
      internal_user = build(:internal_user, email: " USER@Example.COM ")

      expect(internal_user).to be_valid
      expect(internal_user.email).to eq("user@example.com")
    end

    it "authenticates with the configured password" do
      internal_user = create(:internal_user, password: "secure-password")

      expect(internal_user.authenticate("secure-password")).to eq(internal_user)
      expect(internal_user.authenticate("wrong-password")).to be false
    end
  end
end
