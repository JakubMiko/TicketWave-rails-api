# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    respond_to do |format|
      format.html { render_form }
      format.turbo_stream { render_turbo_alert }
    end
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def render_form
    render Devise::Users::Sessions::FormComponent.new(
      resource: resource,
      resource_name: resource_name,
      devise_mapping: devise_mapping
    )
  end

  def render_turbo_alert
    render turbo_stream: turbo_stream.replace(
      "modal-alert",
      Ui::AlertComponent.new(
        description: flash[:alert],
        variant: :error
      ).render_in(view_context)
    )
  end

  def after_sign_in_path_for(resource)
    flash[:notice] = "You have been logged in successfully"
    current_user.admin? ? admins_dashboard_path : users_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    flash[:notice] = "You have been logged out successfully"
    root_path
  end
end
