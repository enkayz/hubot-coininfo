# Description
#   A Hubot script that shows information from a
#   coin daemon and pricing from various exchanges.
#
# Configuration:
#   None
#
# Commands:
#   hubot convert AMOUNT COIN1 COIN2 - Currency Conversion via Cryptsy
#   hubot chainz COIN getXXX - Get COIN's height, difficulty, etc
#   hubot btce CURR - Get BTC-e exchange for fiat currency (USD,RUR,EUR,GBP,CNH)
#   hubot allcoin COIN - Get COIN-BTC latest exchange data from Allcoin
#   hubot bittrex COIN - Get COIN-BTC latest exchange data from Bittrex
#   hubot bleutrade COIN - Get COIN-BTC latest exchange data from Bleutrade
#   hubot bter COIN - Get COIN-BTC latest exchange data from Bter
#   hubot ccex COIN - Get COIN-BTC latest exchange data from C-Cex
#   hubot cryptsy COIN - Get COIN-BTC latest exchange data from Cryptsy
#   hubot poloniex COIN - Get COIN-BTC latest exchange data from Poloniex
#
# Author:
#   upgradeadvice
#

module.exports = (robot) ->
  h = {'User-Agent':'Hubot CoinInfo Script'}
  #chainz.cryptoid.info API - see https://chainz.cryptoid.info/api.dws
  robot.respond /chainz ([a-zA-Z0-9]+) ([a-zA-Z]+)/i, (msg) ->
    c = msg.match[1].toLowerCase()
    q = msg.match[2].toLowerCase()
    if q in [
        "summary",
        "lasttxs",
        "getbalance",
        "getreceivedbyaddress",
        "multiaddr"]
      msg.reply "#{q} not supported by this bot"
    else
      u = "http://chainz.cryptoid.info/#{c}/api.dws?q=#{q}"
      msg.robot.http(u).headers(h).get() (err, res, body) ->
        chainz = body
        if chainz is "0"
          msg.reply "#{q} not supported for #{c} on chainz API"
        else if res.statusCode isnt 200
          msg.reply "#{c} or #{q} not supported. Error: #{res.statusCode}"
        else
          msg.reply "[OK] #{c} #{q} - #{chainz}
           as listed on chainz.cryptoid.info"

  #allcoin
  robot.respond /allcoin (.*)/i, (msg) ->
    c = msg.match[1].toUpperCase()
    cU = c.toUpperCase()
    u = "https://www.allcoin.com/api2/pair/#{c}_BTC"
    msg.robot.http(u).headers(h).get() (err, res, body) ->
      try
        d = JSON.parse(body)
        if not d.data.trade_price
          msg.reply "No results for #{cU}"
          return
      catch err
        msg.reply "No results for #{cU}"
        return
      d = JSON.parse(body)
      last = d.data.trade_price
      high = d.data.max_24h_price
      low = d.data.min_24h_price
      avg = d.data.avg_24h
      msg.reply "[OK] #{cU}-BTC on Allcoin [Last: #{last}] -
      [High: #{high}] - [Low: #{low}] - [Avg: #{avg}]"

  #btce
  robot.respond /btce (.*)/i, (msg) ->
    c = msg.match[1].toLowerCase()
    cU = c.toUpperCase()
    u = "https://btc-e.com/api/3/ticker/btc_#{c}"
    msg.robot.http(u).headers(h).get() (err, res, body) ->
      try
        d = JSON.parse(body)
        if not d["btc_#{c}"].last
          msg.reply "No results for #{cU}"
          return
      catch err
        msg.reply "No results for #{cU}"
        return
      d = JSON.parse(body)
      last = d["btc_#{c}"].last.toFixed(2)
      high = d["btc_#{c}"].high.toFixed(2)
      low = d["btc_#{c}"].low.toFixed(2)
      avg = d["btc_#{c}"].avg.toFixed(2)
      updated = d["btc_#{c}"].updated
      date = new Date(updated*1000).toUTCString()
      msg.reply "[OK] BTC-#{cU} on BTC-e [Last: #{last}] -
      [High: #{high}] - [Low: #{low}] - [Avg: #{avg}] - [Updated: #{date}]"

  #Bittrex Last Trade Price
  robot.respond /bittrex (.*)/i, (msg) ->
    c = msg.match[1].toLowerCase()
    cU = c.toUpperCase()
    u = "https://bittrex.com/api/v1.1/public/getmarketsummary?market=btc-#{c}"
    msg.robot.http(u).headers(h).get() (err, res, body) ->
      try
        d = JSON.parse(body)
        if not d.result[0].Last
          msg.reply "No results for #{cU}"
          return
      catch err
        msg.reply "No results for #{cU}"
        return
      d = JSON.parse(body)
      last = d.result[0].Last.toFixed(8)
      high = d.result[0].High.toFixed(8)
      low = d.result[0].Low.toFixed(8)
      vol = d.result[0].Volume
      msg.reply "#[OK] {cU}-BTC on Bittrex [Last: #{last}] -
      [High: #{high}] - [Low: #{low}] - [Vol: #{vol}]"

  #Bleutrade
  robot.respond /bleutrade (.*)/i, (msg) ->
    c = msg.match[1].toUpperCase()
    u = "https://bleutrade.com/api/v2/public/getmarketsummary?market=#{c}_BTC"
    msg.robot.http(u).headers(h).get() (err, res, body) ->
      try
        d = JSON.parse(body)
        if not d.result[0].Last
          msg.reply "No results for #{c}"
          return
      catch err
        msg.reply "No results for #{c}"
        return
      last = d.result[0].Last
      high = d.result[0].High
      low = d.result[0].Low
      vol = d.result[0].Volume
      msg.reply "[OK] #{c}-BTC on Bleutrade [Last: #{last}] -
      [High: #{high}] - [Low: #{low}] - [Vol: #{vol}]"

  #c-cex
  robot.respond /ccex (.*)/i, (msg) ->
    c = msg.match[1].toLowerCase()
    cU = c.toUpperCase()
    u = "https://c-cex.com/t/#{c}-btc.json"
    msg.robot.http(u).headers(h).get() (err, res, body) ->
      try
        d = JSON.parse(body)
        if not d.ticker.updated
          msg.reply "No results for #{cU}"
          return
      catch err
        msg.reply "No results for #{cU}"
        return
      d = JSON.parse(body)
      last = d.ticker.lastprice.toFixed(8)
      high = d.ticker.high.toFixed(8)
      low = d.ticker.low.toFixed(8)
      avg = d.ticker.avg.toFixed(8)
      updated = d.ticker.updated
      date = new Date(updated*1000).toUTCString()
      msg.reply "#[OK] {cU}-BTC on C-CEX [Last: #{last}] -
      [High: #{high}] - [Low: #{low}] - [Avg: #{avg}]"
      # - [Updated: #{date}]

  #Cryptsy
  robot.respond /cryptsy (.*)/i, (msg) ->
    c = msg.match[1].toUpperCase()
    u = "https://www.cryptsy.com/api/v2/markets/#{c}_BTC"
    msg.robot.http(u).headers(h).get() (err, res, body) ->
      try
        d = JSON.parse(body)
        if not d.data.last_trade.price
          msg.reply "No results for #{c}"
          return
      catch err
        msg.reply "No results for #{c}"
        return
      d = JSON.parse(body)
      last = d.data.last_trade.price.toFixed(8)
      high = d.data["24hr"].price_high.toFixed(8)
      low = d.data["24hr"].price_low.toFixed(8)
      vol = d.data["24hr"].volume
      msg.reply "#[OK] {c}-BTC on Cryptsy [Last: #{last}] -
      [High: #{high}] - [Low: #{low}] - [Vol: #{vol}]"

  #Bter
  robot.respond /bter (.*)/i, (msg) ->
    c = msg.match[1].toLowerCase()
    cU = c.toUpperCase()
    u = "http://data.bter.com/api/1/ticker/#{c}_btc"
    msg.robot.http(u).headers(h).get() (err, res, body) ->
      try
        d = JSON.parse(body)
        if not d.last
          msg.reply "No results for #{cU}"
          return
      catch err
        msg.reply "No results for #{cU}"
        return
      d = JSON.parse(body)
      last = d.last
      high = d.high
      low = d.low
      avg = d.avg
      msg.reply "[OK] #{cU}-BTC on Bter [Last: #{last}] -
      [High: #{high}] - [Low: #{low}] - [Avg: #{avg}]"

  #poloniex
  robot.respond /poloniex ([a-zA-Z0-9]+)/i, (msg) ->
    c = msg.match[1].toUpperCase()
    u = "https://poloniex.com/public?command=returnTicker"
    msg.robot.http(u).headers(h).get() (err, res, body) ->
      try
        d = JSON.parse(body)
        if not d["BTC_#{c}"].last
          msg.reply "No results for #{c}"
          return
      catch err
        msg.reply "No results for BTC-#{c}"
        return
      d = JSON.parse(body)
      last = d["BTC_#{c}"].last
      high = d["BTC_#{c}"].high24hr
      low = d["BTC_#{c}"].low24hr
      vol = d["BTC_#{c}"].baseVolume
      msg.reply "[OK] BTC-#{c} on Poloniex [Last: #{last}] -
      [High: #{high}] - [Low: #{low}] - [Vol: #{vol}]"

  #convert
  robot.respond /convert ([0-9]*\.?[0-9]+) ([a-zA-Z0-9]+) ([a-zA-Z0-9]+)/i,
  (msg) ->
    u = "https://www.cryptonator.com/api/ticker/"
    try
      amount = msg.match[1]
      c1 = msg.match[2].toUpperCase()
      c2 = msg.match[3].toUpperCase()
    catch IndexError
      msg.reply "Syntax: convert <amount> <coin> <coin>"
      return
    try
      parseFloat(amount)
    catch ValueError
      msg.reply "The 'amount' argument must be an integer or a floating point"
      return
    if parseFloat(amount) < 0
      msg.reply "You can't convert negative amounts of a currency."
      return
    results = []
    u2 = "#{u}#{c1}-#{c2}"
    msg.robot.http(u2).headers(h).get() (err, res, body) ->
      try
        d = JSON.parse(body)
        if d.ticker.error
          msg.reply "No results for #{c1}-#{c2}"
          return
        else if res.statusCode isnt 200
          msg.reply "Error: #{res.statusCode}"
      catch err
        msg.reply "No results for #{c1}-#{c2}"
        return
      price = d.ticker.price
      change = d.ticker.change
      a = parseFloat(price)*parseFloat(amount)
      finalAmount = a.toFixed(8)
      msg.reply "[OK] #{amount} #{c1} is worth #{finalAmount} #{c2} [#{change}]"
