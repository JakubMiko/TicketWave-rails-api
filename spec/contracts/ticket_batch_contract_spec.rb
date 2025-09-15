# frozen_string_literal: true

require "rails_helper"

RSpec.describe TicketBatchContract do
  let(:event) { build(:event, date: Time.zone.now + 10.days) }
  let(:existing_batch) do
    build(
      :ticket_batch,
      sale_start: Time.zone.now + 1.day,
      sale_end: Time.zone.now + 3.days,
      event: event
    )
  end

  let(:valid_params) do
    {
      available_tickets: 100,
      price: 50.0,
      sale_start: Time.zone.now + 4.days,
      sale_end: Time.zone.now + 5.days
    }
  end

  subject(:contract) { described_class.new(event: event, existing_batches: [ existing_batch ]) }

  it "accepts valid params" do
    result = contract.call(valid_params)

    expect(result).to be_success
  end

  it "rejects when available_tickets is not greater than 0" do
    params = valid_params.merge(available_tickets: 0)
    result = contract.call(params)

    expect(result).not_to be_success
    expect(result.errors.to_h[:available_tickets]).to include(/must be greater than 0/)
  end

  it "rejects when price is not greater than 0" do
    params = valid_params.merge(price: 0)

    result = contract.call(params)
    expect(result).not_to be_success
    expect(result.errors.to_h[:price]).to include(/must be greater than 0/)
  end

  it "rejects when sale_start is after sale_end" do
    params = valid_params.merge(sale_start: Time.zone.now + 6.days, sale_end: Time.zone.now + 5.days)
    result = contract.call(params)

    expect(result).not_to be_success
    expect(result.errors.to_h[:sale_start]).to include(/start.*earlier.*end/i)
  end

  it "rejects when sale_end is after event date" do
    params = valid_params.merge(sale_end: event.date + 1.day)
    result = contract.call(params)

    expect(result).not_to be_success
    expect(result.errors.to_h[:sale_end]).to include(/end.*earlier.*event/i)
  end

  it "rejects when sales period overlaps with existing batch" do
    params = valid_params.merge(sale_start: Time.zone.now + 2.days, sale_end: Time.zone.now + 4.days)
    result = contract.call(params)

    expect(result).not_to be_success
    expect(result.errors.to_h[:sale_start] || result.errors.to_h[:sale_end]).to include(/conflict|overlap/i)
  end
end
