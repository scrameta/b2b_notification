# frozen_string_literal: true

json.array! @portfolios, partial: 'client_portfolios/portfolio', as: :portfolio
