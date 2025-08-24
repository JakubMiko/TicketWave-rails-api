# frozen_string_literal: true

class Admins::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /admin/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    respond_to do |format|
      format.html do
        render Devise::Admins::Sessions::FormComponent.new(
          resource: resource,
          resource_name: resource_name,
          devise_mapping: devise_mapping
        )
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal-alert",
          Ui::AlertComponent.new(
            description: flash[:alert],
            variant: :error
          ).render_in(view_context)
        )
      end
    end
  end

  # POST /admin/sign_in
  def create
    super
  end

  # DELETE /admin/sign_out
  def destroy
    super
  end

  protected

  # Jeśli chcesz dodać dodatkowe parametry do logowania, odkomentuj poniższą metodę
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def after_sign_in_path_for(resource)
    admins_dashboard_path
  end
end
