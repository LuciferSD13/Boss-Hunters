item_titan_blade = class({})
function item_titan_blade:GetIntrinsicModifierName()
	return "modifier_item_titan_blade_handle"
end

modifier_item_titan_blade_handle = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_titan_blade_handle", "items/item_titan_blade.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_titan_blade_handle:OnCreated()
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_titan_blade_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_titan_blade_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE 
			}
end

function modifier_item_titan_blade_handle:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_titan_blade_handle:GetModifierPreAttack_BonusDamage()
	return self.damage
end