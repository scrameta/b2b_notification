# frozen_string_literal: true

require 'sequel'
require 'byebug'
require 'pycall/import'
# require 'business'
# calendar = Business::Calendar.new(
#  working_days: %w( mon tue wed thu fri ),
#  holidays: [],    # array items are either parseable date strings, or real Date objects
#  extra_working_dates: [], # Makes the calendar to consider a weekend day as a working day.
# )
# dateIter = calendar.add_business_days(dateIter,1)

DB = Sequel.connect('sqlite://db/development.sqlite3') # TODO: env
# DB = Sequel.connect(ARGV[1]) #TODO env
# DB = Sequel.connect('postgres://user:password@host:port/database_name') # requires pg

class TradeSeeder
  include PyCall::Import

  def initialize(database, investment_date)
    @database = database
    @investment_date = investment_date

    fetch_prices
  end

  def seed(client, portfolio, investment)
    # Recommended in data science slides, for performance
    # Use wrapped python!
    # https://fr.slideshare.net/urubatan/data-science-in-ruby-is-it-possible-is-it-fast-should-we-use-it-169709579
    pyimport :math
    pyimport :numpy, as: :np
    pyimport :pandas, as: :pd

    df = pd.DataFrame.new(data: { ticker: @ticker, openprice: @openprice })
    value_of_each = investment / df.shape[0]
    shares = np.floor(value_of_each / df.openprice)
    df['shares'] = shares
    invested = (df.shares * df.openprice).sum
    cash = investment - invested

    # This is our initial portfolio, as of this date
    puts df
    puts "cash:#{cash}"

    # To apply it to other dates, we have corporate actions to deal with, splits, dividends, mergers etc.
    # For now keep it simple and just store these trades

    # Store it for a client
    portfolio = @database["select p.id from portfolios p join clients c on p.client_id=c.id where c.username='#{client}' limit 1"]

    # ticker,buy/sell,price,qty,date
    portfolios = Array.new(df.shape[0], portfolio)
    investment_dates = Array.new(df.shape[0], @investment_date)
    ticker_array = df.ticker.to_numpy.tolist
    side = Array.new(df.shape[0], 1) # 1=buy,2=sell,3=shortsell etc
    price = df.openprice.to_numpy.tolist
    quantity = df.shares.to_numpy.tolist
    rows = ticker_array.zip(side, price, quantity, investment_dates, portfolios)
    @database[:trades].import(%i[ticker side price quantity tradeDate portfolio_id], rows)
  end

  private

  def fetch_prices
    opens = <<~END_SQL
      select ticker,open,date from market_data where date='#{@investment_date.strftime('%F')}' limit 40
    END_SQL
    # Direct fetch with sequels
    opens_data = DB[opens]
    ticker = []
    openprice = []
    opens_data.each do |row|
      ticker.append(row[:ticker])
      openprice.append(row[:open])
    end
    @ticker = ticker
    @openprice = openprice
  end
end

seeder = TradeSeeder.new(database = DB, investment_date = Date.new(2020, 10, 1))
positions = seeder.seed(client = 'bgates', portfolio = 'myfirstportfolio', investment = 100_000)
