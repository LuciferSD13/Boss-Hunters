relic_cursed_unbridled_power = class(relicBaseClass)

function relic_cursed_unbridled_power:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			}
end

function relic_cursed_unbridled_power:GetModifierTotalDamageOutgoing_Percentage(params)
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") and params.attacker == self:GetParent() then
		if params.damage_type ~= DAMAGE_TYPE_PURE and params.inflictor ~= self:GetAbility() then
			self:GetAbility():DealDamage( params.attacker, params.unit, params.original_damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = params.damage_flags} )
			return -999
		end
	end
end

function relic_cursed_unbridled_power:GetModifierIncomingDamage_Percentage(params)
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") and params.unit == self:GetParent() then
		if params.damage_type ~= DAMAGE_TYPE_PURE and params.inflictor ~= self:GetAbility() then
			self:GetAbility():DealDamage( params.attacker, self:GetParent(),  params.original_damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = params.damage_flags} )
			return -999
		end
	end
end