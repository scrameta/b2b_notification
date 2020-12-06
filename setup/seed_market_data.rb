# frozen_string_literal: true

require 'sequel'
require 'byebug'
require 'csv'

DB = Sequel.connect('sqlite://db/development.sqlite3') # TODO: env
# DB = Sequel.connect(ARGV[1]) #TODO env
# DB = Sequel.connect('postgres://user:password@host:port/database_name') # requires pg
#

path = ARGV[1]
csvs = Dir.children(path)
tables = []
tickers = []
csvs.each do |csv|
  ticker = csv.sub(/_.*/, '')
  tickers.push(ticker)
  table = CSV.read(File.join(path, csv), headers: :first_row)
  tables.push(table)
end

headers = tables[0].headers
byrow = []
tables.zip(tickers).each do |table, ticker|
  table.by_row.each do |row|
    byrow.push(row.values_at + [ticker])
  end
end

headers = headers.map { |i| i.sub('timestamp', 'date') }
headers.push('ticker')
DB[:market_data].import(headers, byrow)
