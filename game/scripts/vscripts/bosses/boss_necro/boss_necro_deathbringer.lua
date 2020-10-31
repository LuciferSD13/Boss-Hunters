boss_necro_deathbringer = class({})

function boss_necro_deathbringer:GetIntrinsicModifierName()
	return "modifier_boss_necro_deathbringer"
end

modifier_boss_necro_deathbringer = class({})
LinkLuaModifier("modifier_boss_necro_deathbringer", "bosses/boss_necro/boss_necro_deathbringer", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_necro_deathbringer:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_boss_necro_deathbringer:OnDeath(params)
	if params.attacker == self:GetParent() and not params.attacker:PassivesDisabled() and not params.unit:WillReincarnate() then
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_boss_necro_deathbringer_damage", {} )
	end
end

function modifier_boss_necro_deathbringer:IsHidden()
	return true
end

modifier_boss_necro_deathbringer_damage = class({})
LinkLuaModifier("modifier_boss_necro_deathbringer_damage", "bosses/boss_necro/boss_necro_deathbringer", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_necro_deathbringer_damage:OnCreated()
	self.amp = self:GetSpecialValueFor("bonus_damage")
end

function modifier_boss_necro_deathbringer_damage:OnRefresh()
	self.amp = self:GetSpecialValueFor("bonus_damage")
end

function modifier_boss_necro_deathbringer_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_boss_necro_deathbringer_damage:GetModifierTotalDamageOutgoing_Percentage()
	self:Destroy()
	return self.amp
end
