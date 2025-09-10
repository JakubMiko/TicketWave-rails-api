class UserContract < ApplicationContract
  params do
    required(:email).filled(:string)
    required(:password).filled(:string)
    required(:password_confirmation).filled(:string)
    required(:first_name).filled(:string)
    required(:last_name).filled(:string)
  end

  rule(:email) do
    key.failure("has already been taken") if User.exists?(email: value)
  end

  rule(:password, :password_confirmation) do
    key(:password_confirmation).failure("does not match password") if values[:password] != values[:password_confirmation]
  end
end
