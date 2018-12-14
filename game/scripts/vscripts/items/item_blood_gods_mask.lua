item_blood_gods_mask = class({})


function item_blood_gods_mask:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_blood_gods_mask_active", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn( "DOTA_Item.MaskOfMadness.Activate", self:GetCaster() )
end

function item_blood_gods_mask:GetIntrinsicModifierName()
	return "modifier_item_blood_gods_mask"
end

item_blood_gods_mask_2 = class(item_blood_gods_mask)
item_blood_gods_mask_3 = class(item_blood_gods_mask)
item_blood_gods_mask_4 = class(item_blood_gods_mask)
item_blood_gods_mask_5 = class(item_blood_gods_mask)

LinkLuaModifier( "modifier_item_blood_gods_mask_active", "items/item_blood_gods_mask.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_blood_gods_mask_active = class({})

function modifier_item_blood_gods_mask_active:OnCreated()
	self.as = self:GetSpecialValueFor("active_attack_speed")
	self.dmg = self:GetSpecialValueFor("active_bonus_damage")
	self.ms = self:GetSpecialValueFor("active_movement_speed")
	self.amp = self:GetSpecialValueFor("active_damage_taken")
end

function modifier_item_blood_gods_mask_active:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_item_blood_gods_mask_active:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_item_blood_gods_mask_active:GetModifierBaseDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_item_blood_gods_mask_active:GetModifierIncomingDamage_Percentage()
	return self.amp
end

function modifier_item_blood_gods_mask_active:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_item_blood_gods_mask_active:GetEffectName()
	return "particles/items2_fx/mask_of_madness.vpcf"
end

function modifier_item_blood_gods_mask_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_item_blood_gods_mask_active:StatusEffectPriority()
	return 5
end

LinkLuaModifier( "modifier_item_blood_gods_mask", "items/item_blood_gods_mask.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_blood_gods_mask = class({})
function modifier_item_blood_gods_mask:OnCreated()
	self.bonus_health = self:GetSpecialValueFor("bonus_health")
	self.lifesteal = self:GetSpecialValueFor("melee_lifesteal") / 100
	if self:GetParent():IsRangedAttacker() then
		self.lifesteal = self:GetSpecialValueFor("ranged_lifesteal") / 100
	end
end

function modifier_item_blood_gods_mask:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_item_blood_gods_mask:OnTakeDamage(params)
	if params.attacker == self:GetParent() and not params.inflictor then
		local flHeal = params.damage * self.lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_item_blood_gods_mask:GetModifierHealthBonus()
	return self.health
end

function modifier_item_blood_gods_mask:IsHidden()
	return true
end

function modifier_item_blood_gods_mask:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end