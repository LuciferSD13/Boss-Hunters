--[[
Broodking AI
]]

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	
	thisEntity.impervious = thisEntity:FindAbilityByName("boss_apotheosis_impervious")
	thisEntity.blessed = thisEntity:FindAbilityByName("boss_apotheosis_blessed_being")
	thisEntity.purifier = thisEntity:FindAbilityByName("boss_apotheosis_purifier")
	thisEntity.potential = thisEntity:FindAbilityByName("boss_apotheosis_latent_potential")
	
	thisEntity.beam = thisEntity:FindAbilityByName("boss_apotheosis_focused_beam")
	thisEntity.rampage = thisEntity:FindAbilityByName("boss_apotheosis_rampage")
	thisEntity.decimate = thisEntity:FindAbilityByName("boss_apotheosis_decimate")
	thisEntity.hunter = thisEntity:FindAbilityByName("boss_apotheosis_ruthless_hunter")
	thisEntity.shield = thisEntity:FindAbilityByName("boss_apotheosis_shield_of_valhalla")
	thisEntity.judge = thisEntity:FindAbilityByName("boss_apotheosis_judge_the_cowards")
	thisEntity.kill = thisEntity:FindAbilityByName("boss_apotheosis_the_end")
	
	AddFOWViewer( DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), 3000, 10, true )
	
	AITimers:CreateTimer(0.1, 	function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.impervious:SetLevel(1)
			thisEntity.blessed:SetLevel(1)
			thisEntity.purifier:SetLevel(1)
			thisEntity.potential:SetLevel(1)
			
			thisEntity.beam:SetLevel(1)
			thisEntity.rampage:SetLevel(1)
			thisEntity.decimate:SetLevel(1)
			thisEntity.hunter:SetLevel(1)
			thisEntity.shield:SetLevel(1)
			thisEntity.judge:SetLevel(1)
			thisEntity.kill:SetLevel(1)
		elseif  math.floor(GameRules.gameDifficulty + 0.5) > 2 then
			thisEntity.impervious:SetLevel(2)
			thisEntity.blessed:SetLevel(2)
			thisEntity.purifier:SetLevel(2)
			thisEntity.potential:SetLevel(2)
			
			thisEntity.beam:SetLevel(2)
			thisEntity.rampage:SetLevel(2)
			thisEntity.decimate:SetLevel(2)
			thisEntity.hunter:SetLevel(2)
			thisEntity.shield:SetLevel(2)
			thisEntity.judge:SetLevel(2)
			thisEntity.kill:SetLevel(2)
		end
		thisEntity.beam:StartCooldown(10)
		thisEntity.rampage:StartCooldown(15)
		thisEntity.decimate:StartCooldown(20)
		thisEntity.judge:StartCooldown(10)
		thisEntity.kill:StartCooldown(25)
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		local lastHealth = thisEntity.lastKnownHealth or thisEntity:GetHealth()
		thisEntity.lastKnownHealth = thisEntity:GetHealth()
		local totalHeroes = thisEntity:FindEnemyUnitsInRadius( thisEntity:GetAbsOrigin(), -1, {type = DOTA_UNIT_TARGET_HERO} )
		if thisEntity.kill:IsFullyCastable() and #totalHeroes > 1 then
			local killTarget = totalHeroes[RandomInt( #totalHeroes, 1 )]
			return CastTheEnd(thisEntity, killTarget )
		end
		if thisEntity.shield:IsFullyCastable() then
			if thisEntity:PassivesDisabled() or AICore:BeingAttacked( thisEntity ) >= math.ceil(#HeroList:GetActiveHeroes() / 2) or thisEntity.lastKnownHealth <= lastHealth * 0.85 then
				return CastShieldOfValhalla( thisEntity )
			end
		end
		if thisEntity.judge:IsFullyCastable() then
			local judgeHeroes = AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.judge:GetTrueCastRange() )
			if judgeHeroes > AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity:GetAttackRange() )
			or judgeHeroes > AICore:BeingAttacked( thisEntity ) then
				return CastJudgeTheCowards( thisEntity )
			end
		end
		if thisEntity.rampage:IsFullyCastable() and RollPercentage(35) then
			return CastRampage(thisEntity)
		end
		if thisEntity.decimate:IsFullyCastable() and RollPercentage( 25 ) then
			return CastDecimate(thisEntity)
		end
		if thisEntity.beam:IsFullyCastable() then
			return CastFocusedBeam(thisEntity)
		end
		if thisEntity.hunter:IsFullyCastable() then
			if target and CalculateDistance( target, thisEntity ) <= thisEntity:GetIdealSpeed() + thisEntity.hunter:GetTrueCastRange() then
				local position = thisEntity:GetAbsOrigin() + CalculateDirection( target, thisEntity ) * math.min( CalculateDistance( target, thisEntity ) * 2, thisEntity.hunter:GetTrueCastRange() )
				return CastRelentlessHunter(thisEntity, position)
			else
				local hunterTarget = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.hunter:GetTrueCastRange() )
				if hunterTarget then
					local position = thisEntity:GetAbsOrigin() + CalculateDirection( hunterTarget, thisEntity ) * math.min( CalculateDistance( hunterTarget, thisEntity ) * 2, thisEntity.hunter:GetTrueCastRange() )
					return CastRelentlessHunter(thisEntity, position)
				end
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end

function CastFocusedBeam(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.beam:entindex()
	})
	return thisEntity.beam:GetCastPoint() + 0.1
end

function CastRampage(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.rampage:entindex()
	})
	return thisEntity.rampage:GetCastPoint() + 0.1
end

function CastDecimate(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.decimate:entindex()
	})
	return thisEntity.decimate:GetCastPoint() + 0.1
end

function CastRelentlessHunter(thisEntity, position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.hunter:entindex()
	})
	return thisEntity.hunter:GetCastPoint() + 0.1
end

function CastShieldOfValhalla(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.shield:entindex()
	})
	return thisEntity.shield:GetCastPoint() + 0.1
end

function CastJudgeTheCowards(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.judge:entindex()
	})
	return thisEntity.judge:GetCastPoint() + 0.1
end

function CastTheEnd(thisEntity, target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.kill:entindex()
	})
	return thisEntity.kill:GetCastPoint() + 0.1
end