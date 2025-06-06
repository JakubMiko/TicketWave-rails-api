# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    self.resource = resource_class.new(sign_up_params)
    respond_to do |format|
      format.html do
        render Devise::Users::Registrations::FormComponent.new(
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
        format.html do
          render Devise::Users::Registrations::FormComponent.new(
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

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end


  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :role ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    users_dashboard_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
