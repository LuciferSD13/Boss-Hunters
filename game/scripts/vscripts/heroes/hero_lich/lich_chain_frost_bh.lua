lich_chain_frost_bh = class({})

function lich_chain_frost_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("jump_range")
end

function lich_chain_frost_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	self:FireChainFrost(target)
	caster:EmitSound("Hero_Lich.ChainFrost")
end

function lich_chain_frost_bh:FireChainFrost(target, source, bounces)
	self:FireTrackingProjectile("particles/units/heroes/hero_lich/lich_chain_frost.vpcf", 
								target, 
								self:GetTalentSpecialValueFor("projectile_speed"), 
								{source = source or self:GetCaster(),
								 origin = (source or self:GetCaster()):GetAbsOrigin(),
								 extraData = {bounces = bounces or self:GetTalentSpecialValueFor("jumps")}}, 
								DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, 
								true, 
								true, 
								self:GetTalentSpecialValueFor("vision_radius") )
end

function lich_chain_frost_bh:OnProjectileHit_ExtraData( target, position, extraData )
	if target then
		local caster = self:GetCaster()
		
		local damage = self:GetTalentSpecialValueFor("damage")
		local duration = self:GetTalentSpecialValueFor("slow_duration")
		local jumpRadius = self:GetTalentSpecialValueFor("jump_range")
		local bounces = ( tonumber(extraData.bounces) or 0 )
		
		self:DealDamage( caster, target, damage )
		if caster:HasTalent("special_bonus_unique_lich_chain_frost_2") then
			target:AddChill(self, caster, duration, math.abs( self:GetTalentSpecialValueFor("slow_movement_speed") ) )
		else
			target:AddNewModidifier( caster, self, "modifier_lich_chain_frost_bh", {duration = duration})
		end
		target:EmitSound("Hero_Lich.ChainFrostImpact.Hero")
		if bounces > 0 or caster:HasTalent("special_bonus_unique_lich_chain_frost_1") then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, jumpRadius ) ) do
				if enemy ~= target then
					bounces = bounces - 1
					self:FireChainFrost(enemy, target, bounces)
					return
				end
			end
		end
	else
		self.projectileTable[projID] = nil
	end
end

modifier_lich_chain_frost_bh = class({})
LinkLuaModifier( "modifier_lich_chain_frost_bh", "heroes/hero_lich/lich_chain_frost_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lich_chain_frost_bh:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("slow_movement_speed")
	self.as = self:GetTalentSpecialValueFor("slow_attack_speed")
end

function modifier_lich_chain_frost_bh:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("slow_movement_speed")
	self.as = self:GetTalentSpecialValueFor("slow_attack_speed")
end

function modifier_lich_chain_frost_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_lich_chain_frost_bh:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_lich_chain_frost_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_lich_chain_frost_bh:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end