	local function CheckPlayerChoices(self)
	local votedYes = 0
	local votedNo = 0
	local voted = 0
	local players = 0
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			players = players + 1
			if self._playerChoices[i] ~= nil then
				voted = voted + 1
				if self._playerChoices[i] then
					votedYes = votedYes + 1
				else
					votedNo = votedNo + 1
				end
			end
		end
	end
	
	if not self.eventEnded then
		if votedYes > votedNo + (players - voted) then -- yes votes exceed non-votes and no votes
			self:StartCombat(true)
			return true
		elseif votedNo > votedYes + (players - voted) then -- no votes exceed yes and non-votes and every other situation
			self:StartCombat(false)
			return true
		end
	end
	return false
end

local function StartCombat(self, bFight)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	if bFight then
		self.eventTargetToBeProtected:Fear(nil, self.eventTargetToBeProtected, 600)
		self._vEventHandles = {
			ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
		}
		self:EndEventTimer( )
		self.eventType = EVENT_TYPE_COMBAT
		self.bossesToSpawn = math.max( 1, math.floor( math.log( (RoundManager:GetRaidsFinished() + 1) / 2 ) ) )
		self.mobsToSpawn = math.max( math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) ) )
		self.helpedTreant = true
		BOSS_SPAWNS = {"npc_dota_boss21", "npc_dota_boss23_m", "npc_dota_boss_alpha_wolf"}
		MOB_SPAWNS = {	"npc_dota_boss26_mini", 
						"npc_dota_boss6", 
						"npc_dota_creature_broodmother",
						"npc_dota_boss_wolf", 
						-- "npc_dota_boss_greater_centaur", 
						-- "npc_dota_boss_dire_hellbear"
		}
		
		local bossToSpawn = BOSS_SPAWNS[RandomInt(1, #BOSS_SPAWNS)]
		local mobToSpawn = MOB_SPAWNS[RandomInt(1, #MOB_SPAWNS)]
		
		self.enemiesToSpawn = self.bossesToSpawn + self.mobsToSpawn
		Timers:CreateTimer(20, function()
			local spawn = CreateUnitByName(bossToSpawn, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.bossesToSpawn = self.bossesToSpawn - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			spawn:Taunt(nil, self.eventTargetToBeProtected, 600)
			if self.bossesToSpawn > 0 then
				return 15 / (RoundManager:GetRaidsFinished() + 1)
			end
		end)
		Timers:CreateTimer(5, function()
			local spawn = CreateUnitByName(mobToSpawn, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.mobsToSpawn = self.mobsToSpawn - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			spawn:Taunt(nil, self.eventTargetToBeProtected, 600)
			if self.mobsToSpawn > 0 then
				return 5 / (RoundManager:GetRaidsFinished() + 1)
			end
		end)
	else
		self:EndEvent(true)
	end
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = false
	CheckPlayerChoices(self)
end

local function StartEvent(self)	
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "grove_event_help_treant", choices = 2})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
	}
	self._vEventHandles = {}
	self.eventEnded = false
	self.eventTargetToBeProtected = CreateUnitByName("npc_dota_event_treant", RoundManager:GetHeroSpawnPosition(), true, nil, nil, DOTA_TEAM_GOODGUYS)
	self.eventTargetToBeProtected:SetCoreHealth( 2000 );
	self.eventTargetToBeProtected:SetHealth( 1000 );
	self.waitTimer = self:StartEventTimer(  )
	LinkLuaModifier("event_buff_help_treant", "events/modifiers/event_buff_help_treant", LUA_MODIFIER_MOTION_NONE)
	self._playerChoices = {}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	for _, eID in pairs( self._vListenerHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	
	if self.helpedTreant and bWon then
		if not self.eventTargetToBeProtected:IsNull() and self.eventTargetToBeProtected:IsAlive() then
			self.eventTargetToBeProtected:Blink( Vector( 0, 0 ) )
			self.eventTargetToBeProtected:ForceKill( false )
		end
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddBlessing("event_buff_help_treant")
		end
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = "grove_event_help_treant", reward = 1})
	elseif not self.eventTargetToBeProtected:IsNull() and self.eventTargetToBeProtected:IsAlive() then
		
	end
	
	self.eventEnded = true
	self.timeRemaining = -1
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss23_m", context)
	PrecacheUnitByNameSync("npc_dota_boss21", context)
	PrecacheUnitByNameSync("npc_dota_boss26_mini", context)
	PrecacheUnitByNameSync("npc_dota_boss6", context)
	PrecacheUnitByNameSync("npc_dota_creature_broodmother", context)
	PrecacheUnitByNameSync("npc_dota_boss10", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "grove_combat_2"
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_spawner" ) ) do
			table.insert( RoundManager.spawnPositions, spawnPos:GetAbsOrigin() )
		end
		self.heroSpawnPosition = self.heroSpawnPosition or nil
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_heroes") ) do
			self.heroSpawnPosition = spawnPos:GetAbsOrigin()
			break
		end
		self.spawnLoadCompleted = true
	end
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["LoadSpawns"] = LoadSpawns,
	["FirstChoice"] = FirstChoice,
	["SecondChoice"] = SecondChoice,
	["StartCombat"] = StartCombat,
}

return funcs