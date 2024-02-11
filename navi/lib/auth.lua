local mp = require("MessagePack")

-- Function to perform an HTTP POST request
local function http_post(url, data)
    local http = require("socket.http")
    local ltn12 = require("ltn12")

    local response_body = {}
    local result, respcode, respheaders, respstatus = http.request{
        method = "POST",
        url = url,
        source = ltn12.source.string(data),
        headers = {
            ["content-type"] = "binary/message-pack",
            ["content-length"] = tostring(#data)
        },
        sink = ltn12.sink.table(response_body)
    }

    return result, respcode, table.concat(response_body), respheaders, respstatus
end

-- URL of the Metasploit RPC service
local url = "http://localhost:55552/api/1.0"
local method = "auth.login"
local username = "pakemon"
local password = "pakemon"

-- Prepare the MessagePack data
local data = mp.pack({ method, username, password })

-- Perform the POST request
local result, respcode, body, respheaders, respstatus = http_post(url, data)

local function authenticate(url, username, password)
    local method = "auth.login"
    local data = mp.pack({ method, username, password })

    local result, respcode, body, respheaders, respstatus = http_post(url, data)

    if result then
        local unpacked = mp.unpack(body)
        if unpacked and unpacked.result == "success" then
            return unpacked.token  -- Return the session token
        end
    end

    error("Authentication failed: " .. tostring(body))
end

-- Check the response
if result then
    -- Unpack the MessagePack response
    local unpacked = mp.unpack(body)
else
    print("Error: " .. tostring(body))
end

return authenticate
