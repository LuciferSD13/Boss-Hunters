local function CheckPlayerChoices(self)
	for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
		local pID = hero:GetPlayerID()
		if pID and not self._playerChoices[pID] then
			return false
		end
	end
	self:EndEvent(true)
	return true
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	hero:AddBlessing("event_buff_bloom_crystal")
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	hero:AddGold(800)
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function ThirdChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	RelicManager:PushCustomRelicDropsForPlayer(event.pID, {RelicManager:RollRandomRelicForPlayer(event.pID, "RARITY_COMMON", true, false)})
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function StartEvent(self)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = self:GetEventName(), choices = 3})
	self._vEventHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_3', Context_Wrap( self, 'ThirdChoice') ),
	}
	self.timeRemaining = 30
	self.eventEnded = false
	Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if self.timeRemaining >= 0 then
			self.timeRemaining = self.timeRemaining - 1
			return 1
		elseif not self.eventEnded then
			self:EndEvent(true)
		end
	end)
	
	self._playerChoices = {}
	
	LinkLuaModifier("event_buff_bloom_crystal", "events/modifiers/event_buff_bloom_crystal", LUA_MODIFIER_MOTION_NONE)
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
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
	["ThirdChoice"] = ThirdChoice,
}

return funcs