item_dust_of_stasis = class({})
LinkLuaModifier( "modifier_item_dust_of_stasis_stasis", "items/item_dust_of_stasis.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_dust_of_stasis:IsConsumable()
	return true
end

function item_dust_of_stasis:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("DOTA_Item.DustOfAppearance.Activate", self:GetCaster() )
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1) ) do
		enemy:AddNewModifier( caster, self, "modifier_item_dust_of_stasis_stasis", {duration = self:GetSpecialValueFor("stasis_duration")})
	end
	ParticleManager:FireParticle("particles/items_fx/dust_of_appearance.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin(), [1] = Vector(1200,1,1)})
	self:SetCurrentCharges(self:GetCurrentCharges() - 1)
	if self:GetCurrentCharges() == 0 then self:Destroy() end
end


modifier_item_dust_of_stasis_stasis = class({})
if IsServer() then
	function modifier_item_dust_of_stasis_stasis:OnCreated()
		self.hp_pct = self:GetSpecialValueFor("hp_pct_break") / 100
		self:OnIntervalThink()
		self.damageTaken = 0
		self:StartIntervalThink(0.1)
	end
	
	function modifier_item_dust_of_stasis_stasis:OnRefresh()
		self.hp_pct = self:GetSpecialValueFor("hp_pct_break") / 100
		self:OnIntervalThink()
		self.damageTaken = 0
		self:StartIntervalThink(0.1)
	end
	
	function modifier_item_dust_of_stasis_stasis:OnIntervalThink()
		local parent = self:GetParent()
		for i = 0, 20 do
			local ability = parent:GetAbilityByIndex(i)
			if ability then
				local cd = ability:GetCooldownTimeRemaining()
				ability:EndCooldown()
				ability:StartCooldown(cd + 0.1)
			end
		end
	end
end

function modifier_item_dust_of_stasis_stasis:CheckState()
	return {[MODIFIER_STATE_FROZEN] = true,
			[MODIFIER_STATE_STUNNED] = true,}
end

function modifier_item_dust_of_stasis_stasis:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_dust_of_stasis_stasis:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_item_dust_of_stasis_stasis:OnTakeDamage(params)
	if params.unit == self:GetParent() and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) then
		self.damageTaken = (self.damageTaken or 0) + params.damage
		if self.damageTaken >= self:GetParent():GetMaxHealth() * self.hp_pct then
			self:Destroy()
		end
	end
end

function modifier_item_dust_of_stasis_stasis:GetEffectName()
	return "particles/items_fx/dust_of_appearance_debuff.vpcf"
end

function modifier_item_dust_of_stasis_stasis:IsDebuff()
	return true
end

function modifier_item_dust_of_stasis_stasis:IsPurgable()
	return false
end

function modifier_item_dust_of_stasis_stasis:GetTexture()
	return "item_dust"
end