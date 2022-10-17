print("Hello world, from client!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Rodux = require(ReplicatedStorage.Common.Rodux)
local RoactRodux = require(ReplicatedStorage.Common.RoactRodux)
local Roact = require(ReplicatedStorage.Common.Roact)

-- Rodux ---------------------------------------------------

local function ChangeText(newText)
    return {
        type = "ChangeText",
        newText = newText,
    }
end

local textReducer = Rodux.createReducer("", {
    ChangeText = function(state, action)
        return action.newText
    end,
})

local store = Rodux.Store.new(textReducer, nil, {
    Rodux.loggerMiddleware,
})

-- Roact ---------------------------------------------------

local function MyComponent(props)
    local newText = props.newText

    if newText == nil then
        newText = " "
    end

    return Roact.createElement("ScreenGui", nil, {
        HelloWorld = Roact.createElement("TextLabel", {
            Size = UDim2.new(0, 400, 0, 300),
            Text = "Current value: " .. newText,
        })
    })
end

MyComponent = RoactRodux.connect(
    function(state, props)
        return {
            newText = state,
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

store:dispatch(ChangeText("Before"))

local time = 5
while wait(1) do
    if time == 0 then
        store:dispatch(ChangeText("After"))
        break
    else
        time = time - 1
    end
end