item_lifeweavers_clockwork = class({})
LinkLuaModifier( "modifier_item_lifeweavers_clockwork_passive", "items/item_lifeweavers_clockwork.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_lifeweavers_clockwork:GetIntrinsicModifierName()
	return "modifier_item_lifeweavers_clockwork_passive"
end

modifier_item_lifeweavers_clockwork_passive = class(itemBaseClass)

function modifier_item_lifeweavers_clockwork_passive:OnCreated()
	self.status_amp = self:GetSpecialValueFor("status_amp")
	self.spell_amp = self:GetSpecialValueFor("bonus_spell_amp")
	self.mr = self:GetSpecialValueFor("bonus_mana_regen")
	self.intellect = self:GetSpecialValueFor("bonus_intellect")
	self.bonus_mana = self:GetSpecialValueFor("bonus_mana")
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	self.mLifesteal = self:GetSpecialValueFor("mob_lifesteal") / 100
end

function modifier_item_lifeweavers_clockwork_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_lifeweavers_clockwork_passive:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local lifesteal = self.lifesteal
		if params.inflictor then 
			ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
			if not params.unit:IsRoundNecessary() then
				lifesteal = self.mLifesteal
			end
		end
		local flHeal = params.damage * lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_item_lifeweavers_clockwork_passive:GetModifierSpellAmplify_Percentage(params)
	return self.spell_amp
end

function modifier_item_lifeweavers_clockwork_passive:GetModifierStatusAmplify_Percentage(params)
	return self.status_amp
end

function modifier_item_lifeweavers_clockwork_passive:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_lifeweavers_clockwork_passive:GetModifierBonusStats_Intellect()
	return self.intellect
end