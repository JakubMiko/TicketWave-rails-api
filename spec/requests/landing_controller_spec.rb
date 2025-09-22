# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Landing", type: :request do
  let!(:events) { create_list(:event, 3) }

  it "renders landing page for guest" do
    get root_path

    expect(response).to have_http_status(:ok)
    events.each do |event|
      expect(response.body).to include(event.name)
    end
  end

  it "renders landing page for logged in user" do
    user = create(:user)
    login_as(user, scope: :user)

    get root_path

    expect(response).to have_http_status(:ok)
    events.each do |event|
      expect(response.body).to include(event.name)
    end
  end
end
