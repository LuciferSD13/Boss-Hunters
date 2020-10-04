boss_sloth_demon_slime_trail = class({})

function boss_sloth_demon_slime_trail:GetIntrinsicModifierName()
	return "modifier_boss_sloth_demon_slime_trail"
end

boss_lesser_sloth_demon_slime_trail = class(boss_sloth_demon_slime_trail)

modifier_boss_sloth_demon_slime_trail = class({})
LinkLuaModifier( "modifier_boss_sloth_demon_slime_trail", "bosses/boss_sloth_demon/boss_sloth_demon_slime_trail", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_sloth_demon_slime_trail:OnCreated()
		self:GetAbility().slimePoolTable = {}
		self:StartIntervalThink(0.2)
	end
	
	function modifier_boss_sloth_demon_slime_trail:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:PassivesDisabled() then return end
		for _, pool in ipairs( self:GetAbility().slimePoolTable ) do
			if CalculateDistance( pool, caster ) < pool.radius * 0.9 then
				return
			end
		end
		CreateModifierThinker(caster, self:GetAbility(), "modifier_boss_sloth_demon_slime_trail_pool", {}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	end
end

function modifier_boss_sloth_demon_slime_trail:IsHidden()
	return true
end

modifier_boss_sloth_demon_slime_trail_pool = class({})
LinkLuaModifier( "modifier_boss_sloth_demon_slime_trail_pool", "bosses/boss_sloth_demon/boss_sloth_demon_slime_trail", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_sloth_demon_slime_trail_pool:OnCreated()
	self.min_radius = self:GetSpecialValueFor("min_radius")
	self.max_radius = self:GetSpecialValueFor("max_radius")
	self.duration = self:GetSpecialValueFor("duration")
	self.growth = ( ( self.max_radius - self.min_radius ) / self.duration ) * FrameTime()
	self:GetParent().radius = self.min_radius
	if IsServer() then
		table.insert( self:GetAbility().slimePoolTable, self:GetParent() )
		self:StartIntervalThink( 0 )
		self.trailFX = ParticleManager:CreateParticle("particles/bosses/boss_sloth_demon/boss_sloth_demon_slime_trail.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( self.trailFX, 1, Vector( self:GetParent().radius, 0, 0 ) )
		ParticleManager:SetParticleControl( self.trailFX, 15, Vector( 0, 175, 75 ) )
		self:AddEffect( self.trailFX )
	end
end

function modifier_boss_sloth_demon_slime_trail_pool:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	if not caster or caster:IsNull() then
		self:Destroy()
		if parent and not parent:IsNull() then
			parent:ForceKill(false)
		end
		return
	end
	if parent.radius < self.max_radius and CalculateDistance( parent, self:GetCaster() ) <= parent.radius and caster:IsAlive() then
		parent.radius = math.min(parent.radius + self.growth, self.max_radius)
	elseif parent.radius >= self.min_radius and CalculateDistance( parent, self:GetCaster() ) > parent.radius or not caster:IsAlive() then
		parent.radius = parent.radius - self.growth
	elseif parent.radius < self.min_radius and self:GetElapsedTime() > 5 then
		for id, pool in ipairs( self:GetAbility().slimePoolTable ) do
			if pool == self:GetParent() then
				table.remove( self:GetAbility().slimePoolTable, id)
			end
		end
		self:Destroy()
		self:GetParent():ForceKill(false)
	end
	ParticleManager:SetParticleControl( self.trailFX, 1, Vector( parent.radius, 0, 0 ) )
end

function modifier_boss_sloth_demon_slime_trail_pool:IsAura()
	return true
end

function modifier_boss_sloth_demon_slime_trail_pool:GetModifierAura()
	return "modifier_boss_sloth_demon_slime_trail_debuff"
end

function modifier_boss_sloth_demon_slime_trail_pool:GetAuraRadius()
	return self:GetParent().radius
end

function modifier_boss_sloth_demon_slime_trail_pool:GetAuraDuration()
	return 0.5
end

function modifier_boss_sloth_demon_slime_trail_pool:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_sloth_demon_slime_trail_pool:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_sloth_demon_slime_trail_pool:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_boss_sloth_demon_slime_trail_debuff = class({})
LinkLuaModifier( "modifier_boss_sloth_demon_slime_trail_debuff", "bosses/boss_sloth_demon/boss_sloth_demon_slime_trail", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_sloth_demon_slime_trail_debuff:OnCreated()
		self.base = self:GetSpecialValueFor("base_damage")
		self.stack = self:GetSpecialValueFor("stack_damage")
		self:StartIntervalThink(1)
	end
	
	function modifier_boss_sloth_demon_slime_trail_debuff:OnIntervalThink()
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.base + self.stack * self:GetStackCount() )
		self:IncrementStackCount()
	end
end