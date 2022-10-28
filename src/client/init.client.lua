print("Hello world, from client!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Rodux = require(ReplicatedStorage.Common.Rodux)
local RoactRodux = require(ReplicatedStorage.Common.RoactRodux)
local Roact = require(ReplicatedStorage.Common.Roact)

local initialState = {
    hp = 10,
    text = "Before",
    timer = 5,
}

-- Rodux ---------------------------------------------------

local function GetHit(damage)
    return {
        type = "GetHit",
        damage = damage,
    }
end

local function ChangeText(newText)
    return {
        type = "ChangeText",
        text = newText,
    }
end

local function DecreaseTimer()
    return {
        type = "DecreaseTimer",
    }
end

local textReducer = Rodux.createReducer( initialState, {
    GetHit = function(state, action)
        return {
            hp = state.hp - action.damage,
            text = state.text,
            timer = state.timer,
        }
    end,
    ChangeText = function(state, action)
        return {
            hp = state.hp,
            text = action.text,
            timer = state.timer,
        }
    end,
    DecreaseTimer = function(state, action)
        return {
            hp = state.hp,
            text = state.text,
            timer = state.timer - 1,
        }
    end,
})

local store = Rodux.Store.new(textReducer, initialState, {
    Rodux.loggerMiddleware,
})

-- Roact ---------------------------------------------------

local function MyComponent(props)
    local hp = props.hp
    local text = props.text
    local timer = props.timer

    return Roact.createElement("ScreenGui", nil, {
        HelloWorld = Roact.createElement("TextLabel", {
            Size = UDim2.new(0, 100, 0, 100),
            Text = "Text: " .. text,
        }),
        HpLabel = Roact.createElement("TextLabel", {
            Size = UDim2.new(0, 100, 0, 100),
            Position = UDim2.new(0, 100, 0, 0),
            Text = "HP: " .. hp,
        }),
        TimerLabel = Roact.createElement("TextLabel", {
            Size = UDim2.new(0, 100, 0, 100),
            Position = UDim2.new(0, 200, 0, 0),
            Text = "Timer: " .. timer,
        }),
    })
end

MyComponent = RoactRodux.connect(
    function(state, props)
        return {
            hp = state.hp,
            text = state.text,
            timer = state.timer,
        }
    end
)(MyComponent)

local app = Roact.createElement(RoactRodux.StoreProvider, {
    store = store,
}, {
    Main = Roact.createElement(MyComponent),
})

Roact.mount(app, Players.LocalPlayer.PlayerGui)

-- Dispatchers ----------------------------------------

local time = 5
while wait(1) do
    if time == 0 then
        store:dispatch(GetHit(5))
        store:dispatch(ChangeText("After"))
        break
    else
        time = time - 1
        store:dispatch(DecreaseTimer())
    end
end