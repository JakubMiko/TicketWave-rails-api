# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Orders", type: :request do
  let(:user) { create(:user) }

  describe "GET /orders" do
    context "when not logged in" do
      it "redirects to login" do
        get orders_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before do
        create_list(:order, 3, user: user)
        login_as(user, scope: :user)
      end

      it "renders orders index" do
        get orders_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Orders")
      end
    end
  end
end
