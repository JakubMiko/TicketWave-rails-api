# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TicketBatches", type: :request do
  let(:user) { create(:user, admin: true) }

  describe "GET /events/:event_id/ticket_batches/new" do
    let!(:event) { create(:event) }

    context "when user is not logged in" do
      it "redirects to login" do
        get new_event_ticket_batch_path(event_id: event.id)

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is logged in but not as an admin" do
        let(:non_admin_user) { create(:user, admin: false) }

        before { login_as(non_admin_user, scope: :user) }

        it "redirects to login" do
            get new_event_ticket_batch_path(event_id: event.id)

            expect(response).to redirect_to(root_path)
        end
    end

    context "when user is logged in as an admin" do
        before { login_as(user, scope: :user) }

        it "renders new ticket_batch form" do
            get new_event_ticket_batch_path(event_id: event.id)

            expect(response).to have_http_status(:ok)
            expect(response.body).to include("Add new ticket batch")
        end
    end
  end

  describe "POST /events/:event_id/ticket_batches" do
    let!(:event) { create(:event) }
    let(:valid_params) do
      {
        ticket_batch: {
          available_tickets: 100,
          price: 50,
          sale_start: 1.day.from_now,
          sale_end: 2.days.from_now
        }
      }
    end

    context "when user is not logged in" do
      it "redirects to login" do
        post event_ticket_batches_path(event_id: event.id), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is logged in but not as an admin" do
      let(:non_admin_user) { create(:user, admin: false) }
      before { login_as(non_admin_user, scope: :user) }

      it "redirects to root" do
        post event_ticket_batches_path(event_id: event.id), params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is logged in as an admin" do
      before { login_as(user, scope: :user) }

      it "creates a new ticket batch" do
        expect {
          post event_ticket_batches_path(event_id: event.id), params: valid_params
        }.to change(TicketBatch, :count).by(1)
      end
    end
  end

  describe "EDIT /events/:event_id/ticket_batches/:id/edit" do
    let!(:event) { create(:event) }
    let!(:ticket_batch) { create(:ticket_batch, event: event) }

    context "when user is not logged in" do
      it "redirects to login" do
        get edit_event_ticket_batch_path(event_id: event.id, id: ticket_batch.id)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is logged in but not as an admin" do
      let(:non_admin_user) { create(:user, admin: false) }
      before { login_as(non_admin_user, scope: :user) }

      it "redirects to root" do
        get edit_event_ticket_batch_path(event_id: event.id, id: ticket_batch.id)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is logged in as an admin" do
      before { login_as(user, scope: :user) }

      it "renders edit ticket batch form" do
        get edit_event_ticket_batch_path(event_id: event.id, id: ticket_batch.id)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Edit ticket batch")
      end
    end
  end

  describe "PATCH /events/:event_id/ticket_batches/:id" do
    let!(:event) { create(:event) }
    let!(:ticket_batch) { create(:ticket_batch, event: event) }
    let(:update_params) do
    {
        ticket_batch: {
        price: 99,
        available_tickets: 100,
        sale_start: 1.day.from_now,
        sale_end: 2.days.from_now
        }
    }
    end

    context "when user is not logged in" do
      it "redirects to login" do
        patch event_ticket_batch_path(event_id: event.id, id: ticket_batch.id), params: update_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is logged in but not as an admin" do
      let(:non_admin_user) { create(:user, admin: false) }
      before { login_as(non_admin_user, scope: :user) }

      it "redirects to root" do
        patch event_ticket_batch_path(event_id: event.id, id: ticket_batch.id), params: update_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is logged in as an admin" do
      before { login_as(user, scope: :user) }

      it "updates the ticket batch" do
        patch event_ticket_batch_path(event_id: event.id, id: ticket_batch.id), params: update_params
        expect(ticket_batch.reload.price).to eq(99)
      end
    end
  end

  describe "DELETE /events/:event_id/ticket_batches/:id" do
    let!(:event) { create(:event) }
    let!(:ticket_batch) { create(:ticket_batch, event: event) }

    context "when user is not logged in" do
      it "redirects to login" do
        expect {
          delete event_ticket_batch_path(event_id: event.id, id: ticket_batch.id)
        }.not_to change(TicketBatch, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is logged in but not as an admin" do
      let(:non_admin_user) { create(:user, admin: false) }
      before { login_as(non_admin_user, scope: :user) }

      it "redirects to root" do
        expect {
          delete event_ticket_batch_path(event_id: event.id, id: ticket_batch.id)
        }.not_to change(TicketBatch, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is logged in as an admin" do
        before { login_as(user, scope: :user) }

        it "allows to destroy a ticket_batch" do
        expect {
            delete event_ticket_batch_path(event_id: event.id, id: ticket_batch.id)
        }.to change(TicketBatch, :count).by(-1)
        expect(response).to redirect_to(event_path(event))
        end
    end
  end
end
