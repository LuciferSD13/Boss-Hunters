relic_torn_prayer_card = class(relicBaseClass)

function relic_torn_prayer_card:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function relic_torn_prayer_card:GetModifierIncomingDamage_Percentage(params)
	if HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then return end
	if self:GetParent():GetMana() >= params.original_damage then
		self:GetParent():ReduceMana( params.original_damage )
		return -999
	elseif not self:GetParent():HasModifier("relic_ritual_candle") then
		return 50
	end
end