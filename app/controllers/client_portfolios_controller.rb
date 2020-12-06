require 'byebug'
require 'date'
require 'pycall/import'

class ClientPortfoliosController < ApplicationController
  # Recommended in data science slides, for performance
  # Use wrapped python!
  # https://fr.slideshare.net/urubatan/data-science-in-ruby-is-it-possible-is-it-fast-should-we-use-it-169709579
  include PyCall::Import

  def index
    client = verify_client { return }
    @portfolios = Portfolio.where(client: client)
  end

  def content
    client = verify_client { return }
    username = client.username
    portfolio = Portfolio.find(params.require(:id))
    dt = Date.today
    positiondf = portfolio_as_of(portfolio, username, dt)
    ticker = positiondf.ticker.to_numpy.tolist
    pos = positiondf.pos.to_numpy.tolist
    @positions = []
    ticker.zip(pos).each do |position|
      @positions.append({ ticker: position[0], shares: position[1] })
    end
  end

  def valuation
    client = verify_client { return }
    username = client.username
    portfolio = Portfolio.find(params.require(:id))

    dt = Date.new(2020, 12, 3) # TODO: should be now, but do not want to fetch new data
    positiondf = portfolio_as_of(portfolio, username, dt)

    query = <<END_SQL
    select ticker,adjusted_close,close,date from market_data where date='#{dt.strftime('%F')}'
END_SQL
    mktdata = queryToDataFrame(query)
    mktdata = mktdata.set_index(mktdata.ticker)
    positiondf[:close] = mktdata.close

    positiondf[:value] = positiondf.close * positiondf.pos # TODO: fx...
    total = positiondf[:value].sum

    ticker = positiondf.ticker.to_numpy.tolist
    value = positiondf.value.to_numpy.tolist

    @totalValueUSD = total.tolist
    @values = []
    ticker.zip(value).each do |value|
      @values.append({ ticker: value[0], valueUSD: value[1] })
    end
  end

  def return
    client = verify_client { return }
    username = client.username
    portfolio = Portfolio.find(params.require(:id))
    return_from = Date.new(2020, 11, 2) # TODO: dates
    return_to = Date.new(2020, 12, 1)
    positiondf = portfolio_as_of(portfolio, username, return_from) #In reality the position could change...

    # Compute returns
    query = <<END_SQL
select ticker,adjusted_close,close,date from market_data where date>='#{return_from.strftime('%F')}' and date<='#{return_to.strftime("%F")}'
END_SQL
    mktdata = queryToDataFrame(query)
    mktdata[:returns] = mktdata.groupby(:ticker).adjusted_close.pct_change.fillna(0)
    
    # Get position at start - in reality we'd need to handle intraday pnl, position changes, corporate actions(splits, divs, mergers), tax in period etc
    # The client also probably still has a small cash balance too
    # These are handled in adjusted returns, but not if we change position
    # Now compute the twr
    mktdata[:ret1] = mktdata.returns + 1
    mktdata[:twr] = mktdata.groupby(:ticker).ret1.cumprod
    market_data_from = mktdata[mktdata.date == return_from.strftime('%F')]
    market_data_from = market_data_from.set_index(market_data_from.ticker)
    market_data_to = mktdata[mktdata.date == return_to.strftime('%F')]
    market_data_to = market_data_to.set_index(market_data_to.ticker)
    market_data_to[:twrPre] = market_data_from.twr
    market_data_to[:twrPeriod] = (market_data_to.twr / market_data_to.twrPre) - 1

    # Join with position
    # Value position on these two dates (sanity check)
    # Value position by twr
    position = positiondf.set_index(positiondf.ticker)
    position[:twrPeriod] = market_data_to.twrPeriod
    position[:closePre] = market_data_from.close
    position[:adjClosePre] = market_data_from.adjusted_close
    position[:adjClosePost] = market_data_to.adjusted_close

    weight = (position.pos * position.closePre) / (position.pos * position.closePre).sum

    return_twr = (weight * position.twrPeriod).sum
    # return_SANITY = ((position.adjClosePost*position.pos).sum/(position.adjClosePre*position.pos).sum)-1
    # puts "Return TWR:#{return_twr*100}% value:#{return_SANITY*100}%"
   
    ticker = position.ticker.to_numpy.tolist
    twr = position.twrPeriod.to_numpy.tolist
    weight = weight.to_numpy.tolist
   
    @totalReturnTWR = return_twr.tolist
    @returnTWR = []
    ticker.zip(twr, weight).each do |value|
      @returnTWR.append({ ticker: value[0], totalWeightedReturn: value[1], weight: value[2] })
    end
  end

  private

  # ref: https://stackoverflow.com/questions/5490952/how-to-merge-array-of-hashes-to-get-hash-of-arrays-of-values
  def collect_values(hashes)
    {}.tap { |r| hashes.each { |h| h.each { |k, v| (r[k]||=[]) << v } } }
  end

  # run query and convert result to a pandas dataframe
  def queryToDataFrame(query)
    pyimport :math
    pyimport :numpy, as: :np
    pyimport :pandas, as: :pd
    pyimport :datetime # pycall does not seem to handle ruby/python date translation well

    @client = verify_client { return }
    data = ActiveRecord::Base.connection.execute(query)
    bycol = collect_values(data)
    bycol.each_key do |key|
      if !bycol[key].empty? && bycol[key][1].is_a?(Date)
        bycol[key].map! { |val| val.strftime('%F') }
      end
    end
    pd.DataFrame.new(data: bycol)

    # sequels version...
    #    cols = data.columns
    #    bycol = {}
    #    cols.each do |col|
    #      bycol[col] = []
    #    end
    #    data.each do |row|
    #      cols.each do |col|
    #        val = row[col]
    #        if val.is_a?(Date)
    #          val = val.strftime('%F')
    #        end
    #        bycol[col].append(val)
    #      end
    #    end
  end

  # Get position from trades - in reality we'd need to handle more
  # e.g. intraday pnl, position changes, corporate actions(splits, divs, mergers), tax in period etc
  def portfolio_as_of(portfolio, username, dt)
    portfolioname = portfolio.name
    # Get portfolio
    query = <<END_SQL
select ticker,side,price,quantity,tradeDate
  from trades tr
  join portfolios pr on pr.id=tr.portfolio_id
  join clients cl on cl.id=pr.client_id
  where
   cl.username = '#{username}'
   and pr.name = '#{portfolioname}'
   and tr.tradeDate < '#{dt.strftime('%F')}'
  order by tr.tradeDate asc
END_SQL
    trades = queryToDataFrame(query)
    if trades.shape[0]>0
      trades[:posChange] = (trades[:side] == 1 ? 1 : -1) * trades[:quantity]
      trades[:pos] = trades.groupby(:ticker).posChange.cumsum
      position = trades.groupby(:ticker).pos.last
      position = position.reset_index()
      position = position.set_index(position.ticker)
    else
      position = pd.DataFrame.new(data: {ticker: [], pos: []} );
    end
  end

end
