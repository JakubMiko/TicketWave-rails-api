class Admins::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_admin_credentials, only: [ :new, :create ]
  before_action :configure_sign_up_params, only: [ :create ]
  skip_before_action :require_no_authentication, only: [ :new, :create ]

  def new
    self.resource = resource_class.new(sign_up_params)
    respond_to do |format|
      format.html do
        render Devise::Admins::Registrations::FormComponent.new(
          resource: resource,
          resource_name: resource_name,
          minimum_password_length: @minimum_password_length
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

  def create
    build_resource(sign_up_params)

    resource.role = "admin" if resource.respond_to?(:role)

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
        format.html do
          render Devise::Admins::Registrations::FormComponent.new(
            resource: resource,
            resource_name: resource_name,
            minimum_password_length: @minimum_password_length
          ), status: :unprocessable_entity
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal-alert",
            Ui::AlertComponent.new(
              description: alert_message,
              variant: :error
            ).render_in(view_context)
          ), status: :unprocessable_entity
        end
      end
    end
  end

  protected

  def authenticate_admin_credentials
    authenticate_or_request_with_http_basic("Admin Sign Up") do |username, password|
      username == Rails.application.credentials.dig(:admin, :username) &&
      password == Rails.application.credentials.dig(:admin, :password)
    end
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :role ])
  end

  def after_sign_up_path_for(resource)
    admins_dashboard_path
  end
end
