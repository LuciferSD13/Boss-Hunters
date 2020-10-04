if IsClient() then return end

if IsServer() then
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.heal = thisEntity:FindAbilityByName("boss16m_heal_aura")
		if thisEntity.heal then
			thisEntity.heal:SetLevel( math.ceil(GameRules:GetGameDifficulty() / 2) )
		end
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target then
				if thisEntity.conflag and thisEntity.conflag:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.conflag:entindex()
					})
					return thisEntity.conflag:GetCastPoint() + 0.1
				end
				if thisEntity.dragonfire and thisEntity.dragonfire:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.dragonfire:entindex()
					})
					return thisEntity.dragonfire:GetCastPoint() + 0.1
				end
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return AI_THINK_RATE end
	end
end