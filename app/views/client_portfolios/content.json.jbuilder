# frozen_string_literal: true

json.array! @positions, partial: 'client_portfolios/position', as: :position
