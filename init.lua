local fails = {}

local max_fails = tonumber(core.settings:get("abf.max_auth_fails")) or 3
local wait_time = tonumber(core.settings:get("abf.wait_time")) or 300

core.register_on_authplayer(function(name, ip, is_success)
	if not (name and ip) then return end
	if not is_success then
		fails[name] = (fails[name] or 0) + 1
		fails[ip] = (fails[ip] or 0) + 1
	else
		fails[name] = nil
		fails[ip] = nil
	end
end)

core.register_on_prejoinplayer(function(name, ip)
	if not (name and ip) then return end
	if (fails[name] and fails[name] > max_fails) or (fails[ip] and fails[ip] > max_fails) then
		core.after(wait_time, function()
			fails[name] = nil
			fails[ip] = nil
		end)
		core.log("action", name.." ["..ip.."] temp-banned for too many auth fails")
		return "Too many authentification fails. Try again after "..wait_time.." seconds."
	end
end)
