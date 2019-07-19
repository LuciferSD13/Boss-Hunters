chen_tank_shockwave = class({})
function chen_tank_shockwave:IsStealable()
	return true
end

function chen_tank_shockwave:IsHiddenWhenStolen()
	return false
end

function chen_tank_shockwave:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()
	local radius = self:GetTalentSpecialValueFor("radius")

	EmitSoundOn("Hero_Leshrac.Split_Earth", caster)
	EmitSoundOn("Hero_Omniknight.Purification", caster)

	ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT, caster, {[0]=point,[1]=Vector(radius,radius,radius)})
	ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_POINT, caster, {[0]=point,[1]=Vector(radius,radius,radius)})

	local enemies = caster:FindEnemyUnitsInRadius(point, radius)
	for _,enemy in pairs(enemies) do
		local intellect = 0
		if caster:GetOwner() then
			intellect = caster:GetOwner():GetIntellect()
		else
			intellect = caster:GetIntellect()
		end
		local damage = intellect * self:GetTalentSpecialValueFor("damage") / 100
		self:DealDamage(caster, enemy, damage)
		enemy:ApplyKnockBack(enemy:GetAbsOrigin(), self:GetSpecialValueFor("duration"), self:GetSpecialValueFor("duration"), 0, 350, caster, self)
	end

	caster:ModifyThreat(self:GetSpecialValueFor("threat_gain"))
end