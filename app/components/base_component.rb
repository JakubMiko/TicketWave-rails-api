class BaseComponent < ViewComponent::Base
  # This is a base component that can be extended by other components.
  # It can include shared methods or helpers that are common across components.
  delegate :user_signed_in?, :admin_signed_in?, to: :helpers
end
