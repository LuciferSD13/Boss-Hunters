if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.bloodlust = thisEntity:FindAbilityByName("boss_ogre_magi_bloodlust")
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local radius = thisEntity.bloodlust:GetCastRange()
		local allies = FindUnitsInRadius( thisEntity:GetTeam(), thisEntity:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
		if thisEntity:HasModifier("modifier_ogre_magi_bloodlust") and thisEntity.bloodlust:IsFullyCastable() then
			for _,ally in pairs(allies) do
				if not ally:HasModifier("modifier_ogre_magi_bloodlust") then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = ally:entindex(),
						AbilityIndex = thisEntity.bloodlust:entindex()
					})
					return AI_THINK_RATE
				end
			end
		elseif not thisEntity:HasModifier("modifier_ogre_magi_bloodlust") and thisEntity.bloodlust:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = thisEntity:entindex(),
				AbilityIndex = thisEntity.bloodlust:entindex()
			})
			return AI_THINK_RATE
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end