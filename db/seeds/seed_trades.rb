# frozen_string_literal: true

require 'byebug'
require 'pycall/import'
# require 'business'
# calendar = Business::Calendar.new(
#  working_days: %w( mon tue wed thu fri ),
#  holidays: [],    # array items are either parseable date strings, or real Date objects
#  extra_working_dates: [], # Makes the calendar to consider a weekend day as a working day.
# )
# dateIter = calendar.add_business_days(dateIter,1)

class TradeSeeder
  include PyCall::Import

  def initialize(database, investment_date)
    @database = database
    @investment_date = investment_date

    # Recommended in data science slides, for performance
    # Use wrapped python!
    # https://fr.slideshare.net/urubatan/data-science-in-ruby-is-it-possible-is-it-fast-should-we-use-it-169709579
    pyimport :math
    pyimport :numpy, as: :np
    pyimport :pandas, as: :pd

    fetch_prices
  end

  def seed(client, portfolio_name, investment)
    target_portfolio = compute_portfolio(investment)
    dump_portfolio(target_portfolio, investment)

    # To apply it to other dates, we have corporate actions to deal with, splits, dividends, mergers etc.
    # For now keep it simple and just store these trades

    # Store it for a client
    portfolio_id = @database.execute("select p.id from portfolios p join clients c on p.client_id=c.id where c.username='#{client}' and p.name='#{portfolio_name}'")
    portfolio_id = portfolio_id[0]['id']

    # ticker,buy/sell,price,qty,date
    portfolio_ids = Array.new(target_portfolio.shape[0], portfolio_id)
    investment_dates = Array.new(target_portfolio.shape[0], @investment_date.strftime('%F'))
    ticker_array = target_portfolio.ticker.to_numpy.tolist
    side = Array.new(target_portfolio.shape[0], 1) # 1=buy,2=sell,3=shortsell etc
    price = target_portfolio.price.to_numpy.tolist
    quantity = target_portfolio.shares.to_numpy.tolist

    rows = ticker_array.zip(side, price, quantity, investment_dates, portfolio_ids)
    keys = ['ticker', 'side', 'price', 'quantity', 'tradeDate', 'portfolio_id']
    rows.map! { |row| Hash[keys.zip(row)] }
    Trade.insert_many(rows)
  end

  private

  def compute_portfolio(investment)
    value_of_each = investment / @prices.shape[0]
    shares = np.floor(value_of_each / @prices.price)
    target_portfolio = @prices.clone
    target_portfolio['shares'] = shares
    return target_portfolio
  end

  def dump_portfolio(target_portfolio, investment)
    invested = (target_portfolio.shares * target_portfolio.price).sum
    remaining_cash = investment - invested

    puts "Compute portfolio:"
    puts target_portfolio
    puts "Remaining cash: #{remaining_cash}"
  end

  def fetch_prices
    # 'execution' price for our trades, which we did in the opening auction!
    opens = <<~END_SQL
      select ticker,open,date from market_data where date='#{@investment_date.strftime('%F')}'
    END_SQL

    # Direct fetch with active record
    opens_data = @database.execute(opens)
    ticker = []
    openprice = []
    opens_data.each do |row|
      ticker.append(row['ticker'])
      openprice.append(row['open'])
    end
    @prices = pd.DataFrame.new(data: { ticker: ticker, price: openprice })
  end
end
