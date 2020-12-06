# frozen_string_literal: true

json.extract! portfolio, :id, :name, :created_at, :updated_at
json.url client_portfolios_url(portfolio, format: :json)
