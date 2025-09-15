# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserContract do
  subject(:contract) { described_class.new }

  let(:valid_params) do
    {
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Jan",
      last_name: "Kowalski"
    }
  end

  it "accepts valid params" do
    result = contract.call(valid_params)

    expect(result).to be_success
  end

  it "rejects when email is missing" do
    params = valid_params.except(:email)
    result = contract.call(params)

    expect(result).not_to be_success
    expect(result.errors.to_h).to have_key(:email)
  end

  it "rejects when password and confirmation do not match" do
    params = valid_params.merge(password_confirmation: "different")
    result = contract.call(params)

    expect(result).not_to be_success
    expect(result.errors.to_h[:password_confirmation]).to include("does not match password")
  end

  it "rejects when email is already taken" do
    create(:user, email: valid_params[:email])
    result = contract.call(valid_params)
    expect(result).not_to be_success
    expect(result.errors.to_h[:email]).to include("has already been taken")
  end

  it "rejects when first_name is missing" do
    params = valid_params.except(:first_name)
    result = contract.call(params)

    expect(result).not_to be_success
    expect(result.errors.to_h).to have_key(:first_name)
  end

  it "rejects when last_name is missing" do
    params = valid_params.except(:last_name)
    result = contract.call(params)

    expect(result).not_to be_success
    expect(result.errors.to_h).to have_key(:last_name)
  end
end
