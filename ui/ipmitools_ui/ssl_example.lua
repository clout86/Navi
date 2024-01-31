local https = require("ssl.https")
local ltn12 = require("ltn12")
local mime = require("mime")  -- For Base64 encoding

-- Function to encode credentials in Base64
local function encodeBase64(str)
    return mime.b64(str)
end

function getSystemInfo(idrac_ip, username, password)
    local response_body = {}
    local res, code, response_headers = https.request {
        url = "https://" .. idrac_ip .. "/api/system/info",
        method = "GET",
        headers = {
            ["Authorization"] = "Basic " .. encodeBase64(username .. ":" .. password)
        },
        sink = ltn12.sink.table(response_body),
        protocol = "tlsv1_2" -- Specify the SSL/TLS protocol version if needed
    }
    return table.concat(response_body)
end
