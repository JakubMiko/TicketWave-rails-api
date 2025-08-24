# frozen_string_literal: true

class Devise::Admins::Sessions::FormComponent < BaseComponent
  attr_reader :resource, :resource_name, :devise_mapping

  def initialize(resource:, resource_name:, devise_mapping:)
    @resource = resource
    @resource_name = resource_name
    @devise_mapping = devise_mapping
  end
end
