# frozen_string_literal: true

json.timeWeightedReturn @totalReturnTWR
json.perName do
  json.array! @returnTWR, partial: 'client_portfolios/return', as: :value
end
