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

	if votedYes > votedNo + (players - voted) then -- yes votes exceed non-votes and no votes
		self:GiveRelicChoices(true)
		return true
	elseif votedNo > votedYes + (players - voted) then -- no votes exceed yes and non-votes and every other situation
		self:EndEvent(true)
		return true
	end
	return false
end

local function GiveRelicChoices(self)
	local votesWithOfuda = 0
	local votesWithout = 0
	for _, hero in ipairs( HeroList:GetRealHeroes() ) do
		local pID = hero:GetPlayerID()
		local cursedTable = {}
		local uniqueTable = {}
		for i = 1, 3 do
			table.insert(cursedTable, RelicManager:RollRandomRelicForPlayer(pID, "RARITY_UNCOMMON", false, true) )
		end
		for i = 1, 3 do
			table.insert(uniqueTable, RelicManager:RollRandomRelicForPlayer(pID, "RARITY_UNCOMMON", false, false) )
		end
		
		RelicManager:PushCustomRelicDropsForPlayer(pID, cursedTable)
		RelicManager:PushCustomRelicDropsForPlayer(pID, uniqueTable)
		if self._playerChoices[pID] and hero:HasRelic("relic_unique_ofuda") and hero:FindModifierByName("relic_unique_ofuda"):GetStackCount() > 0 then
			votesWithOfuda = votesWithOfuda + 1
		elseif self._playerChoices[pID] then
			votesWithout = votesWithout + 1
		end
	end
	if votesWithOfuda < votesWithout then
		GameRules:SetLives(1, true)
	else
		for id, vote in pairs(self._playerChoices) do
			local hero = PlayerResource:GetSelectedHeroEntity(id)
			if vote and hero:HasRelic("relic_unique_ofuda")  and hero:FindModifierByName("relic_unique_ofuda"):GetStackCount() > 0 then
				local ofuda = hero:FindModifierByName("relic_unique_ofuda")
				ofuda:DecrementStackCount()
			end
		end
	end
	self:EndEvent(true)
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
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "sepulcher_event_graverobber", choices = 2})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
	}
	self.timeRemaining = 15
	self.eventEnded = false
	self.waitTimer = Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.eventEnded then
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
	self._playerChoices = {}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vListenerHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	
	self.eventEnded = true
	self.timeRemaining = -1
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["SecondChoice"] = SecondChoice,
	["GiveRelicChoices"] = GiveRelicChoices,
}

return funcs