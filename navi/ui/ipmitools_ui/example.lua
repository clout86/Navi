local http = require("socket.http")
local ltn12 = require("ltn12")

function getSystemInfo(idrac_ip, username, password)
    local response_body = {}
    local res, code, response_headers = http.request {
        url = "http://" .. idrac_ip .. "/api/system/info",
        method = "GET",
        headers = {
            ["Authorization"] = "Basic " .. encodeBase64(username .. ":" .. password)
        },
        sink = ltn12.sink.table(response_body)
    }
    return table.concat(response_body)
end


function runRemoteIPMICommand(remote_ip, username, command)
    local full_command = string.format("ssh %s@%s '%s'", username, remote_ip, command)
    return os.execute(full_command)
end

