# frozen_string_literal: true
require 'byebug'
require 'csv'

class MarketDataSeed
  def initialize(database,market_data_path)
    csvs = Dir.children(market_data_path)
    tables = []
    tickers = []
    csvs.each do |csv|
      ticker = csv.sub(/_.*/, '')
      tickers.push(ticker)
      table = CSV.read(File.join(market_data_path, csv), headers: :first_row)
      tables.push(table)
    end
    
    headers = tables[0].headers
    byrow = []
    tables.zip(tickers).each do |table, ticker|
      table.by_row.each do |row|
        rowh = row.to_h;
        rowh['ticker'] = ticker
        rowh['date'] = rowh.delete 'timestamp'
        byrow.push(rowh)
      end
    end

    MarketDatum.insert_many(byrow)
  end
end
