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
      let!(:user_order1) { create(:order, user: user, total_price: 50.0) }
      let!(:user_order2) { create(:order, user: user, total_price: 75.0) }
      let!(:other_user) { create(:user) }
      let!(:other_user_order) { create(:order, user: other_user, total_price: 100.0) }

      before do
        login_as(user, scope: :user)
      end

      it "renders orders index" do
        get orders_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(user_order1.total_price.to_s)
        expect(response.body).to include(user_order2.total_price.to_s)
        expect(response.body).not_to include(other_user_order.total_price.to_s)
      end
    end
  end

  describe "GET /orders/:id" do
    let(:order) { create(:order, user: user, total_price: 150.0) }

    context "when not logged in" do
      it "redirects to login" do
        get order_path(order)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in as the order owner" do
      before { login_as(user, scope: :user) }

      it "renders the order details" do
        get order_path(order)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(order.total_price.to_s)
      end
    end
  end

  describe "GET /events/:event_id/ticket_batches/:ticket_batch_id/orders/new(.:format)" do
    let(:ticket_batch) { create(:ticket_batch) }
    context "when not logged in" do
      it "allows access to new order page" do
        get new_ticket_batch_order_path(event_id: ticket_batch.event.id, ticket_batch_id: ticket_batch.id)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when logged in" do
      before { login_as(user, scope: :user) }

      it "allows access to new order page" do
        get new_ticket_batch_order_path(event_id: ticket_batch.event.id, ticket_batch_id: ticket_batch.id)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /orders" do
    let(:event) { create(:event) }
    let(:ticket_batch) { create(:ticket_batch, event: event, available_tickets: 10, price: 15.0) }
    let(:valid_params) do
      {
        order: {
          ticket_batch_id: ticket_batch.id,
          user_id: user.id,
          total_price: 100.0,
          quantity: 1
        }
      }
    end
    let(:invalid_params) do
      {
        order: {
          ticket_batch_id: ticket_batch.id,
          user_id: user.id,
          total_price: 20.0,
          quantity: nil
        },
        ticket_batch_id: ticket_batch.id
      }
    end

    context "when not logged in" do
      it "allows order creation as guest" do
        params = {
          order: {
            ticket_batch_id: ticket_batch.id,
            total_price: 100.0,
            quantity: 1,
            guest_email: "guest@example.com",
            guest_first_name: "Guest",
            guest_last_name: "User",
            guest_password: "password123",
            guest_password_confirmation: "password123"
          }
        }
        expect {
          post orders_path, params: params.merge(ticket_batch_id: ticket_batch.id)
        }.to change(Order, :count).by(1)
        order = Order.last
        expect(response).to redirect_to(confirmation_order_path(order))
      end
    end

    context "when logged in" do
      before { login_as(user, scope: :user) }

      it "allows order creation" do
        expect {
          post orders_path, params: valid_params.merge(ticket_batch_id: ticket_batch.id)
        }.to change(Order, :count).by(1)
        order = Order.order(:created_at).last
        expect(response).to redirect_to(confirmation_order_path(order))
      end

      it "does not allow order creation with invalid params" do
        expect {
          post orders_path, params: invalid_params
        }.not_to change(Order, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
