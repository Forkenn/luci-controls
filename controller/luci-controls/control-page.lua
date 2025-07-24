module("luci.controller.luci-controls.control-page", package.seeall)

local json = require("luci.jsonc")
local nixio = require("nixio")

local config_path = "/etc/config/luci-controls.json"
local config_cache = {
    mtime = nil,
    data = nil
}

function index()
    entry({"admin", "control-page"}, firstchild(), "Local Controls", 70).dependent=false
    entry({"admin", "control-page", "state-manager"}, call("action_devices"), "State Managment", 1)
    entry({"admin", "control-page", "action"}, call("device_action"), nil).leaf = true
    entry({"admin", "control-page", "status"}, call("device_status"), nil).leaf = true
end

local function load_config()
    local stat = nixio.fs.stat(config_path)
    if not stat then
        nixio.syslog("err", "[control-app] Failed to find JSON config file")
        return {}
    end
    
    local current_mtime = stat.mtime
    if config_cache.mtime == current_mtime and config_cache.data then
        return config_cache.data
    end
    
    local content = nixio.fs.readfile(config_path)
    if not content then
        nixio.syslog("err", "[control-app] Failed to read JSON config file")
        return {}
    end

    local parsed = json.parse(content)
    if not parsed or type(parsed) ~= "table" then
        nixio.syslog("err", "[control-app] Failed to parse JSON config file")
        return {}
    end

    config_cache.mtime = current_mtime
    config_cache.data = parsed
    return parsed
end

local function is_host_up(ip)
    local cmd = "ping -c 1 -W 1 " .. ip .. " >/dev/null 2>&1"
    return os.execute(cmd) == 0
end

local function load_devices()
    local devices = {}
    local parsed = load_config()

    for _, device in ipairs(parsed) do
        table.insert(devices, {
            name = device.name,
            ip = device.ip,
            up = is_host_up(device.ip)
        })
    end

    --local uci = require("luci.model.uci").cursor()
    --uci:foreach("control-app", "device", function(s)
    --    table.insert(devices, {
    --        name = s.name,
    --        ip = s.ip,
    --        up = is_host_up(s.ip)
    --    })
    --end)

    return devices
end

function action_devices()
    luci.template.render("luci-controls/control-page", { devices = load_devices() })
end

function device_status()
    local http = require("luci.http")

    http.prepare_content("application/json")
    http.write(json.stringify(load_devices()))
end

function device_action()
    local http = require("luci.http")
    local action = http.formvalue("do")

    local form_ip = http.formvalue("ip")
    local device = nil

    local config = load_config()
    for _, dev in ipairs(config) do
        if form_ip == dev.ip then
            device = dev
            break
        end
    end

    if device and action then
        local cmd
        if action == "reboot" then
            cmd = string.format("ssh -i %s %s@%s 'reboot'", device.key, device.user, device.ip)
        elseif action == "shutdown" then
            cmd = string.format("ssh -i %s %s@%s 'shutdown -h now'", device.key, device.user, device.ip)
        end

        if cmd then
            os.execute(cmd .. " &")
        end
	else
		nixio.syslog("err", "[control-app] Device not found for IP: " .. form_ip)
    end

    http.redirect(luci.dispatcher.build_url("admin", "control-page", "state-manager"))
end
