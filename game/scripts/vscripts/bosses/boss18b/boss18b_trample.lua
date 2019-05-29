boss18b_trample = class({})

function boss18b_trample:OnAbilityPhaseStart(direction, radius)
	local caster = self:GetCaster()
	local newRad = radius or self:GetSpecialValueFor("starting_radius")
	local newPos = caster:GetAbsOrigin() + (direction or CalculateDirection(self:GetCursorPosition(), caster)) * self:GetSpecialValueFor("jump_distance")
	ParticleManager:FireWarningParticle(newPos, newRad)
	return true
end

function boss18b_trample:OnSpellStart()
	local caster = self:GetCaster()
	local vDir = CalculateDirection(self:GetCursorPosition(), caster)
	
	local jump_distance = self:GetSpecialValueFor("jump_distance")
	local radius = self:GetSpecialValueFor("starting_radius")
	local jumps = self:GetSpecialValueFor("jumps")
	if caster:GetHealthPercent() < 66 then jumps = jumps + 1 end
	if caster:GetHealthPercent() < 33 then jumps = jumps + 1 end
	local position = caster:GetAbsOrigin() + vDir * jump_distance
	local growth = self:GetSpecialValueFor("radius_growth")
	Timers:CreateTimer(function()
		if not caster or caster:IsNull() then return end
		position = caster:GetAbsOrigin() + vDir * jump_distance
		local blocked = self:BlinkAndBreak(position, radius)
		if blocked then return end
		jumps = jumps - 1
		if jumps > 0 then
			self:OnAbilityPhaseStart(vDir, radius)
			radius = radius + growth
			jump_distance = jump_distance + growth
			return self:GetCastPoint()
		end
	end)
end

function boss18b_trample:BlinkAndBreak(newPos, radius)
	local caster = self:GetCaster()
	caster:SmoothFindClearSpace(newPos)
	
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	
	local stunDuration = self:GetSpecialValueFor("stun_duration")
	local damage = self:GetSpecialValueFor("damage")
	
	for _, enemy in ipairs(enemies) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:Stun(enemy, stunDuration)
			self:DealDamage(caster, enemy, damage)
		else
			return true
		end
	end
	GridNav:DestroyTreesAroundPoint( caster:GetAbsOrigin(), radius, true )
	ParticleManager:FireParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = newPos, [1] = Vector(radius, radius, radius)})
	EmitSoundOn("Ability.SandKing_BurrowStrike", caster)
end
