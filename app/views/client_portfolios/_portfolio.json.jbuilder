json.extract! portfolio, :id, :name, :created_at, :updated_at
json.url clientPortfolios_url(portfolio, format: :json)
