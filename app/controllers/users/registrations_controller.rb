# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]

  # GET /resource/sign_up
  def new
    self.resource = resource_class.new(sign_up_params)
    respond_to do |format|
      format.html { render_form }
      format.turbo_stream { render_turbo_alert }
    end
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.role = "user" if resource.respond_to?(:role)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      alert_message = flash[:alert] || resource.errors.full_messages.join(", ")
      respond_to do |format|
        format.html { render_form(status: :unprocessable_entity) }
        format.turbo_stream { render_turbo_alert(alert_message, status: :unprocessable_entity) }
      end
    end
  end

  protected

  def render_form(status: nil)
    render Devise::Users::Registrations::FormComponent.new(
      resource: resource,
      resource_name: resource_name,
      minimum_password_length: @minimum_password_length
    ), status: status
  end

  def render_turbo_alert(message = flash[:alert], status: nil)
    render turbo_stream: turbo_stream.replace(
      "modal-alert",
      Ui::AlertComponent.new(
        description: message,
        variant: :error
      ).render_in(view_context)
    ), status: status
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name ])
  end

  def after_sign_up_path_for(resource)
    flash[:notice] = "You have been signed up successfully"
    current_user.admin? ? admins_dashboard_path : users_dashboard_path
  end
end
