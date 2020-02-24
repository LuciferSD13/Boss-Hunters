item_creed_of_knowledge = class({})

function item_creed_of_knowledge:IsConsumable()
	return true
end

function item_creed_of_knowledge:OnSpellStart()
	if self:GetCaster():IsAlive() then
		EmitSoundOn("Item.TomeOfKnowledge", self:GetCaster() )
		self:GetCaster():AddXP( math.min( self:GetSpecialValueFor("max_xp"), self:GetSpecialValueFor("bonus_xp") + self:GetSpecialValueFor("xp_gain") * RoundManager:GetEventsFinished() ) * self:GetCurrentCharges() )
		self:Destroy()
	end
end