local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("json")

local BettercapAPI = {}

-- Base64 encoding function
local function base64_encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end	

function BettercapAPI:new(host, port, username, password)
    local newObj = {
        host = host or "127.0.0.1",
        port = port or 80,
        auth = username and password and "Basic " .. base64_encode(username .. ":" .. password) or ""
    }
    self.__index = self
    return setmetatable(newObj, self)
end

function BettercapAPI:request(path, method, data)
    local response_body = {}
    local url = string.format("http://%s:%d%s", self.host, self.port, path)

    local request_params = {
        url = url,
        method = method,
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = data and #data or 0,
            ["Authorization"] = self.auth
        },
        source = data and ltn12.source.string(data) or nil,
	        sink = ltn12.sink.table(response_body),
    }

    local res, status = http.request(request_params)

    if not res then
        error("HTTP request failed: " .. (status or "unknown error"))
    end

    local response = table.concat(response_body)
    


    return json.decode(response)
end

function BettercapAPI:postCommand(path, jsonData)
    return self:request(path, "POST", jsonData)
end


function BettercapAPI:getSession()
    return self:request("/api/session", "GET")
end

function BettercapAPI:startModule(moduleName)
    local data = json.encode({ action = "start", name = moduleName })
    return self:request("/api/modules/" .. moduleName, "POST", data)
end

-- Add more functions for other endpoints...



return BettercapAPI
