require "rails_helper"

RSpec.describe "Events", type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  describe "GET /events" do
    it "renders index for guest" do
      event = create(:event, name: "Sample Event")
      get events_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.name)
    end
  end

  describe "GET /events/:id" do
    it "renders show for guest" do
      get event_path(event)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.name)
    end
  end

  describe "GET /events/new" do
    context "when not logged in" do
      it "redirects to login" do
        get new_event_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before { login_as(user, scope: :user) }

      it "renders new event form" do
        get new_event_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("form")
      end
    end
  end

  describe "POST /events" do
    let(:valid_params) do
      {
        event: {
          name: "Test Event",
          description: "desc",
          place: "Test Place",
          date: 2.days.from_now,
          category: "music"
        }
      }
    end

    let(:invalid_params) do
      {
        event: {
          name: "",
          description: "",
          place: "",
          date: "",
          category: ""
        }
      }
    end

    context "when not logged in" do
      it "redirects to login" do
        post events_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before { login_as(user, scope: :user) }

      it "creates event and redirects" do
        expect {
          post events_path, params: valid_params
        }.to change(Event, :count).by(1)
        expect(response).to redirect_to(events_path)
      end

      it "does not create event with invalid params" do
        expect {
          post events_path, params: invalid_params
        }.not_to change(Event, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Name must be filled")
        expect(response.body).to include("Description must be filled")
        expect(response.body).to include("Place must be filled")
        expect(response.body).to include("Category must be filled")
        expect(response.body).to include("Date must be filled")
      end
    end
  end

  describe "GET /events/:id/edit" do
    context "when not logged in" do
      it "redirects to login" do
        get edit_event_path(event)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before { login_as(user, scope: :user) }

      it "renders edit form" do
        get edit_event_path(event)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("form")
      end
    end
  end

  describe "PATCH /events/:id" do
    let(:update_params) do
      {
        event: {
          name: "Updated Event",
          description: "desc",
          place: "Test Place",
          date: 2.days.from_now,
          category: "music"
        }
      }
    end

    context "when not logged in" do
      it "redirects to login" do
        patch event_path(event), params: update_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before { login_as(user, scope: :user) }

      it "updates event and redirects" do
        patch event_path(event), params: update_params
        expect(response).to redirect_to(events_path)
        expect(event.reload.name).to eq("Updated Event")
      end
    end
  end

  describe "DELETE /events/:id" do
    context "when not logged in" do
      it "redirects to login" do
        delete event_path(event)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      before { login_as(user, scope: :user) }
      let!(:event_to_delete) { create(:event) }

      it "deletes event and redirects" do
        expect {
          delete event_path(event_to_delete)
        }.to change(Event, :count).by(-1)
        expect(response).to redirect_to(events_path)
      end
    end
  end
end
