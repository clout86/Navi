local mp = require("MessagePack")
local authenticate = require("lib.auth")
local metasploit = {}



-- Function to perform an HTTP POST request
function metasploit.http_post(url, data)
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

-- Function to get the list of exploits
function metasploit.get_exploits(url, token)
    local method = "module.exploits"
    local data = mp.pack({ method, token })

    local result, respcode, body, respheaders, respstatus = metasploit.http_post(url, data)

    if result then
        return mp.unpack(body)
    else
        error("Error retrieving exploits: " .. tostring(body))
    end
end

-- Function to get information about a specific module
function metasploit.get_module_info(url, token, module_type, module_name)
    local method = "module.info"
    local data = mp.pack({ method, token, module_type, module_name })

    local result, respcode, body, respheaders, respstatus = metasploit.http_post(url, data)

    if result then
        return mp.unpack(body)
    else
        error("Error retrieving module information: " .. tostring(body))
    end
end

-- Function to execute a module (exploit/auxiliary) in Metasploit
function metasploit.module_execute(url, token, module_type, module_name, options)
    local method = "module.execute"
    local data = mp.pack({ method, token, module_type, module_name, options })

    local result, respcode, body, respheaders, respstatus = metasploit.http_post(url, data)

    if result then
        return mp.unpack(body)
    else
        error("Error executing module: " .. tostring(body))
    end
end

-- Function to load a plugin in Metasploit
function metasploit.plugin_load(url, token, plugin_name, options)
    local method = "plugin.load"
    local data = mp.pack({ method, token, plugin_name, options })

    local result, respcode, body, respheaders, respstatus = metasploit.http_post(url, data)

    if result then
        return mp.unpack(body)
    else
        error("Error loading plugin: " .. tostring(body))
    end
end

-- Function to list active jobs in Metasploit
function metasploit.list_jobs(url, token)
    local method = "job.list"
    local data = mp.pack({ method, token })

    local result, respcode, body, respheaders, respstatus = metasploit.http_post(url, data)

    if result then
        return mp.unpack(body)
    else
        error("Error listing jobs: " .. tostring(body))
    end
end



return metasploit

