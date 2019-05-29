relic_soldiers_banner = class(relicBaseClass)

function relic_soldiers_banner:OnCreated()
	self.ar = 150 - self:GetParent():GetBaseAttackRange()
	if IsServer() then
		self:GetParent().originalAttackCapability = self:GetParent():GetAttackCapability()
		self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
		self:StartIntervalThink(0)
	end
end

function relic_soldiers_banner:OnDestroy()
	if IsServer() then
		self:GetParent():SetAttackCapability( self:GetParent().originalAttackCapability )
	end
end

function relic_soldiers_banner:OnIntervalThink()
	self.ar = 0
	self.ar = 150 - self:GetParent():GetBaseAttackRange()
end


function relic_soldiers_banner:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function relic_soldiers_banner:GetModifierAttackRangeBonus()
	return self.ar
end

function relic_soldiers_banner:GetModifierPhysicalArmorBonus()
	return 6
end

function relic_soldiers_banner:GetModifierMoveSpeedBonus_Percentage()
	return 15
end