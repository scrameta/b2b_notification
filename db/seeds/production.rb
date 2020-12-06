# TODO: Real seeding for prod
# e.g. schedule loading new market data with housekeeping etc etc
$LOAD_PATH.unshift File.expand_path('db/seeds')
require 'development'
