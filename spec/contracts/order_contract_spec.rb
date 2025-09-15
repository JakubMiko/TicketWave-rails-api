# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderContract do
  subject(:contract) { described_class.new }

  let(:ticket_batch) { create(:ticket_batch) }

  before do
    allow(ticket_batch).to receive(:available_tickets).and_return(3)
  end

  it "accepts valid params" do
    result = contract.call(quantity: 2, ticket_batch: ticket_batch)

    expect(result).to be_success
  end

  it "rejects when quantity is missing" do
    result = contract.call(ticket_batch: ticket_batch)

    expect(result).not_to be_success
    expect(result.errors.to_h).to have_key(:quantity)
  end

  it "rejects when ticket_batch is missing" do
    result = contract.call(quantity: 1)

    expect(result).not_to be_success
    expect(result.errors.to_h).to have_key(:ticket_batch)
  end

  it "rejects when quantity is not greater than 0" do
    result = contract.call(quantity: 0, ticket_batch: ticket_batch)

    expect(result).not_to be_success
    expect(result.errors.to_h[:quantity]).to include(/must be greater than 0/)
  end

  it "rejects when quantity is greater than available tickets" do
    result = contract.call(quantity: 5, ticket_batch: ticket_batch)

    expect(result).not_to be_success
    expect(result.errors.to_h[:quantity]).to include("is greater than available tickets (3)")
  end
end
