modifier_illusion_bonuses = class({})

function modifier_illusion_bonuses:OnCreated()
	self:GetParent().unitOwnerEntity = self:GetCaster()
	local agility = self:GetCaster():GetAgility()
	local strength = self:GetCaster():GetStrength()
	self.as = agility * 1
	self.ms = agility * 0.05
	self.hp = strength * 18
	if self:GetCaster():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
		self.as = self.as * 1.25
		self.ms = agility * 0.0625
	elseif self:GetCaster():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
		self.hp = strength * 22.5
	end
	
	self.ar = self:GetCaster():GetAttackRange()
	if IsServer() then
		EmitSoundOn("General.Illusion.Create", self:GetParent())

		self.ps = self:GetCaster():GetProjectileSpeed()
		self:StartIntervalThink( FrameTime() )
	end
end

function modifier_illusion_bonuses:OnRefresh()
	self:OnCreated()
end

function modifier_illusion_bonuses:OnIntervalThink()
	self:GetParent():SetHealth( self:GetCaster():GetHealth() )
	self:StartIntervalThink(-1)
end

function modifier_illusion_bonuses:OnDestroy()
	if IsServer() then
		EmitSoundOn("General.Illusion.Destroy", self:GetParent())
		
		if self:GetParent().wearableList then
			for _, wearable in ipairs( self:GetParent().wearableList ) do
				UTIL_Remove( wearable )
			end
			self:GetParent().wearableList = nil
		end
	end
end

function modifier_illusion_bonuses:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_DEATH
    }

    return funcs
end

function modifier_illusion_bonuses:GetModifierHealthBonus( params )
	return self.hp
end

function modifier_illusion_bonuses:GetModifierAttackRangeOverride( params )
	return self.ar
end

function modifier_illusion_bonuses:GetModifierAttackSpeedBonus( params )
    return self.as
end

function modifier_illusion_bonuses:GetModifierProjectileSpeedBonus()
	return self.ps
end

function modifier_illusion_bonuses:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_illusion_bonuses:OnDeath(params)
	if params.unit == self:GetParent() then
		params.unit:AddNoDraw( )
		for _, wearable in ipairs( params.unit.wearableList ) do
			wearable:AddNoDraw( )
		end
	end
end

function modifier_illusion_bonuses:IsHidden()
    return true
end

function modifier_illusion_bonuses:RemoveOnDeath()
	return false
end

function modifier_illusion_bonuses:IsPurgable()
	return false
end