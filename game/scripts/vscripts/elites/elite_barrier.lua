elite_barrier = class({}) 

function elite_barrier:GetIntrinsicModifierName()
	return "modifier_elite_barrier"
end

modifier_elite_barrier = class(relicBaseClass)
LinkLuaModifier("modifier_elite_barrier", "elites/elite_barrier", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_barrier:OnCreated()
	self.cd = self:GetSpecialValueFor("cooldown_effect")
end

function modifier_elite_barrier:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function modifier_elite_barrier:DeclareFunctions()
	return { MODIFIER_PROPERTY_ABSORB_SPELL }
end

function modifier_elite_barrier:GetAbsorbSpell(params)
	if self:GetDuration() == -1 and params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		ParticleManager:FireParticle( "particles/items_fx/immunity_sphere.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		self:SetDuration(self.cd + 0.1, true)
		self:StartIntervalThink(self.cd)
		return 1
	end
end
