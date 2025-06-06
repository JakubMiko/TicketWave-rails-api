# frozen_string_literal: true

class Devise::Users::Registrations::FormComponent < ViewComponent::Base
  attr_reader :resource, :resource_name, :minimum_password_length

  def initialize(resource:, resource_name:, minimum_password_length: nil)
    @resource = resource
    @resource_name = resource_name
    @minimum_password_length = minimum_password_length
  end
end
