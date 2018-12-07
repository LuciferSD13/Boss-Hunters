huskar_fire_within = class({})

function huskar_fire_within:IsStealable()
	return true
end

function huskar_fire_within:IsHiddenWhenStolen()
	return false
end

function huskar_fire_within:OnSpellStart()
	local caster = self:GetCaster()
	
	local damage = self:GetTalentSpecialValueFor("damage")
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("disarm_duration")
	local kbDistance = self:GetTalentSpecialValueFor("knockback_distance")
	local kbDuration = self:GetTalentSpecialValueFor("knockback_duration")
	
	local talent1 = caster:HasTalent("special_bonus_unique_huskar_fire_within_1")
	local tDuration = caster:FindTalentValue("special_bonus_unique_huskar_fire_within_1", "duration")
	
	local delay
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		self:DealDamage( caster, enemy, damage )
		enemy:ApplyKnockBack(caster:GetAbsOrigin(), kbDuration, kbDuration, math.max(50, kbDistance - CalculateDistance(enemy, caster)), 0, caster, self, false)
		local modifier = enemy:Disarm(self, caster, duration)
		if delay then
			delay = ( delay + modifier:GetRemainingTime() ) / 2
		else
			delay = modifier:GetRemainingTime()
		end
		if talent1 then
			enemy:AddNewModifier( caster, self, "modifier_huskar_fire_within_talent", {duration = duration + tDuration})
		end
	end
	self:StartDelayedCooldown( delay or 0 )
	ParticleManager:FireParticle("particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	caster:EmitSound("Hero_Huskar.Inner_Fire.Cast")
end

modifier_huskar_fire_within_talent = class({})
LinkLuaModifier("modifier_huskar_fire_within_talent", "heroes/hero_huskar/huskar_fire_within", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_fire_within_talent:OnCreated()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_huskar_fire_within_1")
end

function modifier_huskar_fire_within_talent:OnRefresh()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_huskar_fire_within_1")
end

function modifier_huskar_fire_within_talent:GetModifierAttackSpeedBonus()
	return self.as
end