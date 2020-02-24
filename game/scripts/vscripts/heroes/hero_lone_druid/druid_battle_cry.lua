druid_battle_cry = class({})
LinkLuaModifier("modifier_druid_battle_cry", "heroes/hero_lone_druid/druid_battle_cry", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_druid_battle_cry_bear", "heroes/hero_lone_druid/druid_battle_cry", LUA_MODIFIER_MOTION_NONE)

function druid_battle_cry:IsStealable()
    return true
end

function druid_battle_cry:IsHiddenWhenStolen()
    return false
end

function druid_battle_cry:GetCastRange(vLocation, hTarget)
    return self:GetTalentSpecialValueFor("radius")
end

function druid_battle_cry:GetCastAnimation()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_druid_transform") then
    	return ACT_DOTA_CAST_ABILITY_4
    else
    	return ACT_DOTA_CAST_ABILITY_3
    end
end

function druid_battle_cry:OnAbilityPhaseStart()
    EmitSoundOn("Hero_LoneDruid.BattleCry.Bear", self:GetCaster())
    return true
end

function druid_battle_cry:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetTalentSpecialValueFor("duration")
	local radius = self:GetTalentSpecialValueFor("radius")

	EmitSoundOn("Hero_LoneDruid.BattleCry", caster)

	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_druid_battle_cry", {Duration = duration})
	end
end

modifier_druid_battle_cry = class({})

function modifier_druid_battle_cry:OnCreated(table)
	self:OnRefresh()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_battle_cry_overhead.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)

		self:AddOverHeadEffect(nfx)

		local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_battle_cry_buff.vpcf", PATTACH_POINT, caster)
					 ParticleManager:SetParticleControlEnt(nfx2, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					 ParticleManager:SetParticleControlEnt(nfx2, 3, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)

		self:AddOverHeadEffect(nfx2)

		self:GetCaster():CalculateStatBonus()
	end
end

function modifier_druid_battle_cry:OnRefresh(table)
	self.bonus_ad = self:GetTalentSpecialValueFor("bonus_ad")
	self.bonus_armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.damage_reduction = self:GetCaster():FindTalentValue("special_bonus_unique_druid_battle_cry_1", "reduction")

	if self:GetCaster():HasTalent("special_bonus_unique_druid_battle_cry_2") then
		self.bonus_int = self:GetParent():GetIntellect()
	end

	if IsServer() then
		self:GetCaster():CalculateStatBonus()
	end
end

function modifier_druid_battle_cry:DeclareFunctions()
	local funcs = {	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
					MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
	return funcs
end

function modifier_druid_battle_cry:GetModifierPreAttack_BonusDamage()
	return self.bonus_ad
end

function modifier_druid_battle_cry:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_druid_battle_cry:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_druid_battle_cry:GetModifierIncomingDamage_Percentage()
	return self.damage_reduction
end

function modifier_druid_battle_cry:IsDebuff()
	return false
end

function modifier_druid_battle_cry:IsPurgable()
	return true
end