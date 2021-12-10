jail_zone = nil
release_zone = nil
function onCreate(is_world_create)
	if g_savedata.jailed == nil then
		g_savedata.jailed = {}
	end
	
	local zones = server.getZones("jail")
	if zones[1] ~= nil then
		jail_zone = zones[1]
	end
	
	local zones = server.getZones("release")
	if zones[1] ~= nil then
		release_zone = zones[1]
	end
end

function onTick(game_ticks)
	for _, player in pairs(server.getPlayers()) do
		if g_savedata.jailed[tostring(player.steam_id)] ~= nil then
			local ploc, ok = server.getPlayerPos(player.id)
			if ok then
				in_zone, _ = server.isInZone(ploc, "jail")
				if not in_zone then
					server.setPlayerPos(player.id, jail_zone.transform)
				end
			end
		end
	end
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, ...)
	-- TODO: Pull authorized user list from web API
	if not is_admin then return end
	local args = {...}
	command = string.lower(command)
	if command ~= "?jail" and command ~="?j" and command ~= "?release" and command ~="?r" then 
		return
	end
	
	local targ_pid = tonumber(args[1])
    if targ_pid == nil then
    	server.announce("[Error]", "Please provide a valid peer ID", user_peer_id)
        return
    end
	local player = getPlayer(targ_pid)
	if player == nil then
		server.announce("[Error]", "Player not found", user_peer_id)
		return
	end

	if command == "?jail" or command == "?j" then
		g_savedata.jailed[tostring(player.steam_id)] = "Unspecified"
		server.announce("[Server]", string.format("%s has been thrown in jail!", player.name), -1)
		return
	end
	
	if (command == "?release" or command =="?r") and (g_savedata.jailed[tostring(player.steam_id)] ~= nil) then
		server.announce("[Server]", string.format("%s has been released from jail!", player.name),  -1)
		g_savedata.jailed[tostring(player.steam_id)] = nil
		server.setPlayerPos(player.id, release_zone.transform)
		return
	end
end

function getPlayer(peer_id)
	for _, player in pairs(server.getPlayers()) do
		if player.id == peer_id then return player end
	end
end
