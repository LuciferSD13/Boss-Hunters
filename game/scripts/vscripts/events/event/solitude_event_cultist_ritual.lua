	local function CheckPlayerChoices(self)
	local votedStop = 0
	local votedJoin = 0
	local votedLeave = 0
	local voted = 0
	local players = 0
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			players = players + 1
			if self._playerChoices[i] ~= nil then
				voted = voted + 1
				if self._playerChoices[i] == 1 then
					votedStop = votedStop + 1
				elseif self._playerChoices[i] == 2 then
					votedJoin = votedJoin + 1
				else
					votedLeave = votedLeave + 1
				end
			end
		end
	end
	local nonVotes = (players - voted)
	if not self.eventEnded and not self.foughtElites then
		if votedStop > votedLeave + votedJoin + nonVotes then
			self:StartCombat(true)
		elseif votedJoin > votedLeave + votedStop + nonVotes then
			self:StartCombat(false)
		elseif votedLeave > votedJoin + votedStop + nonVotes then
			self:EndEvent(true)
		elseif votedStop >= votedJoin + nonVotes and voted > nonVotes then -- pray has priority
			self:StartCombat(true)
		elseif votedJoin >= votedStop + nonVotes and voted > nonVotes then -- fight
			self:StartCombat(false)
		elseif votedLeave > nonVotes then -- most people voted, force leave
			self:EndEvent(true)
		end
	end
	return false
end

local function StartCombat(self, bFight)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	if bFight then
		self.foughtElites = true
		self.eventType = EVENT_TYPE_ELITE

		self.timeRemaining = 0
		self.enemiesToSpawn = math.max( 1, math.floor(RoundManager:GetRaidsFinished() / 3) )
		Timers:CreateTimer(5, function()
			for i = 1, self.enemiesToSpawn do
				local spawn = CreateUnitByName("npc_dota_boss_warlock", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				spawn.unitIsRoundNecessary = true
			end
			self.enemiesToSpawn = 0
			if self.enemiesToSpawn > 0 then
				return 20 / (RoundManager:GetRaidsFinished() + 1)
			end
		end)
	else
		self.timeRemaining = 0
		Timers:CreateTimer(3, function()
			for _, hero in ipairs( HeroList:GetRealHeroes() ) do
				hero:AddCurse("event_buff_cultist_ritual")
				local pID = hero:GetPlayerOwnerID()
				for i = 1, 2 do
					RelicManager:PushCustomRelicDropsForPlayer(pID, {RelicManager:RollRandomRelicForPlayer(pID, "RARITY_COMMON", false, true)})
				end
			end
		end)
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = self:GetEventName(), reward = 1})
		self:EndEvent(true)
	end
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = 1
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = 2
	CheckPlayerChoices(self)
end

local function ThirdChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = 3
	CheckPlayerChoices(self)
end

local function StartEvent(self)	
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = self:GetEventName(), choices = 3})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_3', Context_Wrap( self, 'ThirdChoice') ),
	}
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
	}
	self.timeRemaining = 15
	self.eventEnded = false
	self.foughtElites = false
	self.waitTimer = Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.eventEnded and not self.foughtElites then
			if self.timeRemaining >= 0 then
				self.timeRemaining = self.timeRemaining - 1
				return 1
			else
				if not CheckPlayerChoices(self) then
					self:EndEvent(true)
				end
			end
		end
	end)
	LinkLuaModifier("event_buff_cultist_ritual", "events/modifiers/event_buff_cultist_ritual", LUA_MODIFIER_MOTION_NONE)
	self._playerChoices = {}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	for _, eID in pairs( self._vListenerHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	
	
	self.eventEnded = true
	self.timeRemaining = -1
	Timers:CreateTimer(3, function() RoundManager:EndEvent(bWon) end)
end

function HandoutRewards(self, bWon)
	if self.foughtElites then
		local eventScaling = RoundManager:GetEventsFinished()
		local raidScaling = 1 + RoundManager:GetRaidsFinished() * 0.2
		local playerScaling = GameRules.BasePlayers - HeroList:GetActiveHeroCount()
		local baseXP = ( 700 + ( (50 + 10 * playerScaling) * eventScaling ) ) * raidScaling * 1.5
		local baseGold = ( 250 + ( (20 + 3 * playerScaling) * eventScaling ) ) * raidScaling * 1.5
		if not bWon then
			baseXP = baseXP / 4
			baseGold = baseGold / 4
		end
		
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddGold( baseGold )
			hero:AddExperience( baseXP, DOTA_ModifyXP_Unspecified, false, false )
		end
	end
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss_warlock", context)
	PrecacheUnitByNameSync("npc_dota_boss_warlock_demon", context)
	PrecacheUnitByNameSync("npc_dota_boss_warlock_true_form", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "solitude_event_shrine"
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
	["ThirdChoice"] = ThirdChoice,
	["StartCombat"] = StartCombat,
	["HandoutRewards"] = HandoutRewards,
}

return funcs