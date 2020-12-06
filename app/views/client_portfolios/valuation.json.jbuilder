json.totalValueUSD @totalValueUSD
json.perName do
  json.array! @values, partial: 'client_portfolios/value', as: :value
end
