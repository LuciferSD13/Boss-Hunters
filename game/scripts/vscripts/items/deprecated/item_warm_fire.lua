item_warm_fire = class({})

function item_warm_fire:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_warm_fire") then
		return "custom/warm_fire"
	else
		return "custom/warm_fire_off"
	end
end

function item_warm_fire:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_warm_fire")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_warm_fire", {})
	end
end

function item_warm_fire:GetIntrinsicModifierName()
	return "modifier_item_warm_fire"
end

modifier_item_warm_fire = class(toggleModifierBaseClass)
LinkLuaModifier( "modifier_item_warm_fire", "items/item_warm_fire.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_warm_fire:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.maxRadius = self:GetSpecialValueFor("radius")
	self.minRadius = self:GetSpecialValueFor("min_radius")
	self.radiusDelta = self:GetSpecialValueFor("radius_change")
	if IsServer() then
		self.cumulativeDist = {}
		self.lastPos = self:GetCaster():GetAbsOrigin()
		self:StartIntervalThink(0.1)
		self.pFX = ParticleManager:CreateParticle("particles/items/item_warm_fire_radius.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.pFX, 1, Vector(self.radius,0,0) )
		self:AddEffect( self.pFX )
	end
end

function modifier_item_warm_fire:OnIntervalThink()
	table.insert(self.cumulativeDist, CalculateDistance( self.lastPos, self:GetCaster():GetAbsOrigin() ) )
	self.lastPos = self:GetCaster():GetAbsOrigin()
	if #self.cumulativeDist > 9 then
		table.remove(self.cumulativeDist, 1)
	end
	local distance = 0
	for id, amount in ipairs(self.cumulativeDist) do
		distance = distance + amount
	end
	if distance > 150 and self.minRadius < self.radius then
		self.radius = math.max( self.radius - self.radiusDelta * 0.1, self.minRadius )
		ParticleManager:SetParticleControl( self.pFX, 1, Vector(self.radius,0,0) )
	elseif distance < 150 and self.maxRadius > self.radius then
		self.radius = math.min( self.radius + self.radiusDelta * 0.1, self.maxRadius )
		ParticleManager:SetParticleControl( self.pFX, 1, Vector(self.radius,0,0) )
	end
end

function modifier_item_warm_fire:OnDestroy()
	if IsServer() then
		for _, ally in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_warm_fire_debuff")
		end
	end
end

function modifier_item_warm_fire:IsAura()
	return true
end

function modifier_item_warm_fire:GetModifierAura()
	return "modifier_warm_fire_debuff"
end

function modifier_item_warm_fire:GetAuraRadius()
	return self.radius
end

function modifier_item_warm_fire:GetAuraDuration()
	return 0.5
end

function modifier_item_warm_fire:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_warm_fire:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_warm_fire:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

LinkLuaModifier( "modifier_warm_fire_debuff", "items/item_warm_fire.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_warm_fire_debuff = class({})

function modifier_warm_fire_debuff:OnCreated()
	if IsServer() then
		if not self:GetAbility() or self:GetAbility():IsNull() then
			self:GetCaster():RemoveModifierByName("modifier_item_warm_fire")
			return
		end
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self:StartIntervalThink(1)
	end
end

function modifier_warm_fire_debuff:OnRefresh()
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
	end
end

function modifier_warm_fire_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_warm_fire_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end