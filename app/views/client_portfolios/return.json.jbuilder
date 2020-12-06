# frozen_string_literal: true

json.timeWeightedReturn @total_time_weighted_return
json.perName do
  json.array! @returnTWR, partial: 'client_portfolios/return', as: :value
end
