item_jar_of_souls = class({})
LinkLuaModifier( "modifier_item_jar_of_souls_handle_damage", "items/item_jar_of_souls.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_jar_of_souls_handle_heal", "items/item_jar_of_souls.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_jar_of_souls:GetIntrinsicModifierName()
	return "modifier_item_jar_of_souls_passive"
end

function item_jar_of_souls:OnSpellStart()
	EmitSoundOn("DOTA_Item.SpiritVessel.Cast", self:GetCaster())
	if self:GetCursorTarget():GetTeam() == self:GetCaster():GetTeam() then
		EmitSoundOn("DOTA_Item.SpiritVessel.Target.Ally", self:GetCursorTarget())

		ParticleManager:FireRopeParticle("particles/items4_fx/spirit_vessel_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), self:GetCursorTarget(), {})
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_jar_of_souls_handle_heal", {Duration = self:GetSpecialValueFor("duration")})
	else
		EmitSoundOn("DOTA_Item.SpiritVessel.Target.Enemy", self:GetCursorTarget())

		ParticleManager:FireRopeParticle("particles/items4_fx/spirit_vessel_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), self:GetCursorTarget(), {})
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_jar_of_souls_handle_damage", {Duration = self:GetSpecialValueFor("duration")})
	end
end


modifier_item_jar_of_souls_handle_heal = class({})
function modifier_item_jar_of_souls_handle_heal:OnCreated()
	self.regen = self:GetAbility():GetSpecialValueFor("damage_heal")
	self:GetAbility().casted = true
end

function modifier_item_jar_of_souls_handle_heal:OnDestroy()
	self:GetAbility().casted = false
end

function modifier_item_jar_of_souls_handle_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			}
end

function modifier_item_jar_of_souls_handle_heal:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_item_jar_of_souls_handle_heal:GetEffectName()
	return "particles/items4_fx/spirit_vessel_heal.vpcf"
end

function modifier_item_jar_of_souls_handle_heal:IsDebuff()
	return false
end

modifier_item_jar_of_souls_handle_damage = class({})
function modifier_item_jar_of_souls_handle_damage:OnCreated()
	if IsServer() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetAbility():GetSpecialValueFor("damage_heal"), {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
		self:StartIntervalThink(1.0)
	end
	self.disable = self:GetSpecialValueFor("disables_healing")
	self:GetAbility().casted = true
end

function modifier_item_jar_of_souls_handle_damage:OnRefresh()
	if IsServer() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetAbility():GetSpecialValueFor("damage_heal"), {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
	end
	self.disable = self:GetSpecialValueFor("disables_healing")
	self:GetAbility().casted = true
end

function modifier_item_jar_of_souls_handle_damage:OnDestroy()
	self:GetAbility().casted = false
end

function modifier_item_jar_of_souls_handle_damage:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetAbility():GetSpecialValueFor("damage_heal"), {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
end

function modifier_item_jar_of_souls_handle_damage:GetEffectName()
	return "particles/items4_fx/spirit_vessel_damage.vpcf"
end

function modifier_item_jar_of_souls_handle_damage:IsDebuff()
	return true
end

function modifier_item_jar_of_souls_handle_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_HEALING,
			}
end

function modifier_item_jar_of_souls_handle_damage:GetDisableHealing()
	return tonumber(self.disable)
end

modifier_item_jar_of_souls_passive = class(itemBaseClass)
LinkLuaModifier( "modifier_item_jar_of_souls_passive", "items/item_jar_of_souls.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_jar_of_souls_passive:OnCreated()
	self.manaregen = self:GetSpecialValueFor("bonus_mana_regen")
	self.stat = self:GetSpecialValueFor("bonus_all")
end

function modifier_item_jar_of_souls_passive:OnRefresh()
end

function modifier_item_jar_of_souls_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			}
end

function modifier_item_jar_of_souls_passive:GetModifierConstantManaRegen()
	return self.manaregen
end


function modifier_item_jar_of_souls_passive:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_jar_of_souls_passive:GetModifierBonusStats_Agility()
	return self.stat
end

function modifier_item_jar_of_souls_passive:GetModifierBonusStats_Intellect()
	return self.stat
end

function modifier_item_jar_of_souls_passive:IsHidden()
	return true
end

function modifier_item_jar_of_souls_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end