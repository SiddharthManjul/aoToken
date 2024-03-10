local json = require("json")

if not Balances then Balances = { [ao.id] = 100000000000000 } end

if Name ~= "Webentia Coin" then Name = "Webentia Coin" end

if Ticker ~= "COIN" then Ticker = "COIN" end

if Denomination ~= 10 then Denomination = 10 end

if not Logo then Logo = "optional arweave TXID of logo image" end

Handlers.add("info", Handlers.utils.hasMatchingTag("Action", "Info"), function(msg)
    ao.send({ Target = msg.From, Tags = { Name = Name, Ticker = Ticker, Logo = Logo, Denomination = tostring(Denomination) } })
end)
