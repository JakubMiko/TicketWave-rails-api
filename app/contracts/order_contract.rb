class OrderContract < ApplicationContract
  params do
    required(:quantity).filled(:integer, gt?: 0)
    required(:ticket_batch).filled
  end

  rule(:quantity, :ticket_batch) do
    if key?(:quantity) && key?(:ticket_batch)
      batch = values[:ticket_batch]
      quantity = values[:quantity]
      if batch.respond_to?(:available_tickets) && quantity > batch.available_tickets
        key(:quantity).failure("is greater than available tickets (#{batch.available_tickets})")
      end
    end
  end
end
