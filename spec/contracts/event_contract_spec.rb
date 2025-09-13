# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventContract do
  subject(:contract) { described_class.new }

  let(:valid_params) do
    {
      name:        "Neon Nights Festival",
      description: "Immersive light show",
      place:       "Warsaw Arena",
      category:    "music",
      date:        DateTime.now + 2.days
    }
  end

  it "accepts valid params" do
    result = contract.call(valid_params)
    expect(result).to be_success
    expect(result.errors).to be_empty
  end

  it "rejects past date with custom message" do
    result = contract.call(valid_params.merge(date: DateTime.now - 1.day))
    expect(result).not_to be_success
    expect(result.errors.to_h[:date]).to include("The event date must be in the future")
  end

  it "requires all mandatory fields" do
    result = contract.call({})
    expect(result).not_to be_success
    expect(result.errors.to_h.keys).to include(:name, :description, :place, :category, :date)
  end

  it "rejects blank strings for required fields (date ok)" do
    result = contract.call(
      name: "", description: "", place: "", category: "", date: DateTime.now + 1.day
    )
    expect(result).not_to be_success
    expect(result.errors.to_h.keys).to include(:name, :description, :place, :category)
    expect(result.errors.to_h).not_to have_key(:date)
  end

  it "allows omitting image (optional)" do
    result = contract.call(valid_params.except(:image))
    expect(result).to be_success
  end

  it "does not validate image format (by design now)" do
    result = contract.call(valid_params.merge(image: "invalid_url"))
    expect(result).to be_success
  end
end
