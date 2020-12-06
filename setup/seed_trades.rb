require 'sequel'
require 'byebug'
#require 'daru'
require 'pycall/import'
#require 'business'

DB = Sequel.connect('sqlite://db/development.sqlite3') #TODO env
#DB = Sequel.connect(ARGV[1]) #TODO env
#DB = Sequel.connect('postgres://user:password@host:port/database_name') # requires pg

client = 'bgates' 
portfolio = 'myfirstportfolio'
investment = 100000
investmentDate = Date.new(2020,10,1)

#opens = <<END_SQL
#with date_range as
#(
#	select min(date) as mindate,max(date) as maxdate from market_data
#)
#select ticker,open,date from market_data join date_range on date=date_range.mindate limit 40
#END_SQL


opens = <<END_SQL
select ticker,open,date from market_data where date='#{investmentDate.strftime("%F")}' limit 40
END_SQL

#Direct fetch with sequels
opens_data = DB[opens]
ticker = []
openprice = []
investmentDate = nil
opens_data.each do |row|
  ticker.append(row[:ticker])
  openprice.append(row[:open])
  investmentDate = row[:date]
end

#byebug

#Attempt to load in daru - seems to need DBI rather than sequel...
#Daru::DataFrame.from_sql(DB, opens)

#Recommended in data science slides, for performance
#Use wrapped python!
#https://fr.slideshare.net/urubatan/data-science-in-ruby-is-it-possible-is-it-fast-should-we-use-it-169709579
include PyCall::Import
pyimport :math
pyimport :numpy, as: :np
pyimport :pandas, as: :pd

df = pd.DataFrame.new(data: {ticker:ticker,openprice:openprice})
valueOfEach = investment / df.shape[0]
shares = np.floor(valueOfEach/df.openprice)
df['shares'] = shares
invested = (df.shares*df.openprice).sum
cash = investment-invested

#This is our initial portfolio, as of this date
puts df
puts "cash:#{cash}"

#To apply it to other dates, we have corporate actions to deal with, splits, dividends, mergers etc.
#For now keep it simple and just store these trades

#calendar = Business::Calendar.new(
#  working_days: %w( mon tue wed thu fri ),
#  holidays: [],    # array items are either parseable date strings, or real Date objects
#  extra_working_dates: [], # Makes the calendar to consider a weekend day as a working day.
#)
#dateIter = calendar.add_business_days(dateIter,1)

#Store it for a client
portfolio = DB["select p.id from portfolios p join clients c on p.client_id=c.id where c.username='#{client}' limit 1"]

#ticker,buy/sell,price,qty,date
portfolios = Array.new(df.shape[0],portfolio)
investmentDates = Array.new(df.shape[0],investmentDate)
tickerArray = df.ticker.to_numpy.tolist
side = Array.new(df.shape[0],1) #1=buy,2=sell,3=shortsell etc
price = df.openprice.to_numpy.tolist
quantity = df.shares.to_numpy.tolist
rows = tickerArray.zip(side,price,quantity,investmentDates,portfolios)
DB[:trades].import([:ticker, :side, :price, :quantity, :tradeDate, :portfolio_id], rows)


