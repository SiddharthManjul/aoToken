local json = require("json")

if not Balances then Balances = { [ao.id] = 100000000000000 } end

if Name ~= "Webentia Coin" then Name = "Webentia Coin" end

if Ticker ~= "COIN" then Ticker = "COIN" end

if Denomination ~= 10 then Denomination = 10 end

if not Logo then Logo = "optional arweave TXID of logo image" end

Handlers.add("info", Handlers.utils.hasMatchingTag("Action", "Info"), function(msg)
    ao.send({ 
        Target = msg.From, 
        Tags = { Name = Name, Ticker = Ticker, Logo = Logo, Denomination = tostring(Denomination) } })
end)

Handlers.add("balance", Handlers.utils.hasMatchingTag("Action", "Balances"), function(msg)
    local bal = "0"

    if (msg.Tags.Target and Balances[msg.Tags.Target]) then
        bal = tostring(Balances[msg.Tags.Target])
    elseif Balances[msg.From] then
        bal = tostring(Balances[msg.From])
    end

    ao.send({
        Target = msg.From,
        Tags = { Target = msg.From, Balance = bal, Ticker = Ticker, Data = json.encode(tonumber(bal)) }
    })
end)

Handlers.add("balances", Handlers.utils.hasMatchingTag("Action", "Balances"), function (msg)
    ao.send({ 
        Target = msg.From, 
        Data = json.encode(Balances)})
end)

Handlers.add("transfer", Handlers.utils.hasMatchingTag("Action", "Transfer"), function (msg)
    assert(type(msg.Tags.Recipent) == "string", "Recipent is required!")
    assert(type(msg.Tags.Quantity) == "string", "Quantity is required!")

    if not Balances[msg.From] then Balances[msg.From] = 0 end

    if not Balances[msg.Tags.Recipent] then Balances[msg.Tags.Recipent] = 0 end

    local qty = tonumber(msg.Tags.Quantity)
    assert(type(qty) == "number", "qty must be number!")

    if Balances[msg.From] >= qty then
        Balances[msg.From] = Balances[msg.From] - qty
        Balances[msg.Tags.Recipent] = Balances[msg.Tags.Recipent] + qty

        if not msg.Tags.Cast then
            ao.send({
                Target = msg.From,
                Tags = { Action = "Debit-Notice", Recipent = msg.Tags.Recipent, Quantity = tostring{qty}}
            })
            ao.send({
                Target = msg.Tags.Recipent,
                Tags = { Action = "Debit-Notice", Sender = msg.From, Quantity = tostring(qty)}
            })
        end
    else ao.send({
        Target = msg.Tags.From,
        Tags = { Action = "Transfer-Error", ["Message-Id"] = msg.Id, Error = "Insufficient Balance!"}
    })
    end
end)

Handlers.add("mint", Handlers.utils.hasMatchingTag("Action", "Mint"), function (msg, env)
    assert(type(msg.Tags.Quantity) == "string", "Quantity is required!")

    if msg.From == env.Process.Id then
        local qty = tonumber(msg.Tags.Quantity)
        Balances[env.Process.Id] = Balances[env.Process.Id] + qty
    else
        ao.send({
            Target = msg.Tags.From,
            Tags = {
                Action = "Mint-Error",
                ["Message-Id"] = msg.Id,
                Error = "Only the process owner can mint new " .. Ticker .. " token!"
            }
        })
    end
end)