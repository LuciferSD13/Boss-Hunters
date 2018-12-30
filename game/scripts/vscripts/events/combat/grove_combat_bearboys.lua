local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 3 + math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) )
	self.eventHandler = Timers:CreateTimer(3, function()
		local enemyName = "npc_dota_boss26_mini"
		if RollPercentage(30) then
			enemyName = "npc_dota_boss26"
		end
		local spawn = CreateUnitByName(enemyName, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		if enemyName == "npc_dota_boss26" then
			spawn:SetCoreHealth(2200)
		else
			spawn:SetCoreHealth(1450)
		end
		
		spawn.unitIsRoundNecessary = true
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 6
		end
	end)
	
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
	}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss26", context)
	PrecacheUnitByNameSync("npc_dota_boss26_mini", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs