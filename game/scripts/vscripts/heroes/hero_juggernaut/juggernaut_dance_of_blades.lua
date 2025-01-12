juggernaut_dance_of_blades = class({})

function juggernaut_dance_of_blades:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	
	caster:AddNewModifier(caster, self, "modifier_juggernaut_dance_of_blades", {duration = duration + 0.1})
	self:Bounce(target)
	if caster:HasTalent("special_bonus_unique_juggernaut_dance_of_blades_1") then
		local radius = self:GetTalentSpecialValueFor("radius") + caster:GetAttackRange()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius) ) do
			if enemy ~= target then
				self:Bounce(enemy)
				break
			end
		end
	end
end

function juggernaut_dance_of_blades:Bounce(target)
	local caster = self:GetCaster()
	
	if not target:TriggerSpellAbsorb( self ) then
		caster:PerformAbilityAttack(target, true, self, nil, nil, true)
	end
	local direction = CalculateDirection(target, caster)
	local distance = CalculateDistance(target, caster)
	local position = target:GetAbsOrigin() + direction * RandomInt(150, caster:GetAttackRange())
	
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_POINT_FOLLOW, target, {[0]="attach_hitloc"})
	caster:SetAbsOrigin( position )
	ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf", PATTACH_POINT, caster, {[0]="attach_hitloc", [1]=position})
	EmitSoundOn("Hero_Juggernaut.OmniSlash", caster)
	EmitSoundOn("Hero_Juggernaut.OmniSlash.Damage", target)
	
	caster:SetForwardVector( CalculateDirection( target, caster ) )
	caster:FaceTowards( target:GetAbsOrigin() )
end

modifier_juggernaut_dance_of_blades = class({})
LinkLuaModifier("modifier_juggernaut_dance_of_blades", "heroes/hero_juggernaut/juggernaut_dance_of_blades", LUA_MODIFIER_MOTION_NONE)


function modifier_juggernaut_dance_of_blades:OnCreated()
	local caster = self:GetCaster()
	self.bonus_damage = self:GetTalentSpecialValueFor("bonus_damage")
	self.cleave = caster:FindTalentValue("special_bonus_unique_juggernaut_dance_of_blades_1")
	self.talent1 = caster:HasTalent("special_bonus_unique_juggernaut_dance_of_blades_1")
	self.radius = self:GetTalentSpecialValueFor("radius") + caster:GetAttackRange()
	self:GetParent():HookInModifier( "GetModifierAreaDamage", self )
	if IsServer() then
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		self.rate = self:GetTalentSpecialValueFor("bounce_rate")
		self.tick = caster:GetSecondsPerAttack() / self.rate
		caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_4, 0.5/self.tick)
		self:StartIntervalThink( self.tick )
	end
end

function modifier_juggernaut_dance_of_blades:OnRefresh()
	self:OnCreated()
end

function modifier_juggernaut_dance_of_blades:OnDestroy()
	local caster = self:GetCaster()
	self:GetParent():HookOutModifier( "GetModifierAreaDamage", self )
	if IsServer() then
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
		if caster:HasModifier("modifier_juggernaut_mirror_blades") then
			caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		end
		ResolveNPCPositions( caster:GetAbsOrigin(), caster:GetHullRadius() + caster:GetCollisionPadding() )
	end
end

function modifier_juggernaut_dance_of_blades:OnIntervalThink(ignoreTarget)
	local caster = self:GetCaster()
	local oldTick = self.tick
	self.tick = caster:GetSecondsPerAttack() / self.rate
	local target
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius) ) do
		if enemy ~= ignoreTarget then
			target = enemy
			break
		end
	end
	if target then
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_4, 0.5/self.tick)
		self:GetAbility():Bounce(target)
	elseif ( not target or target:IsNull() or not target:IsAlive() ) and not self.talent1 then
		self:Destroy()
	end
	if not ignoreTarget then
		if target then
			if self.freezeDuration then
				self:SetDuration( self.freezeDuration, true )
				self.freezeDuration = nil
			end
			if self.talent1 then
				self:OnIntervalThink(target)
			end
			self.disableBlocking = false
		else
			dance = caster:FindModifierByName("modifier_juggernaut_dance_of_blades")
			self.disableBlocking = true
			self:OnDestroy()
			self.freezeDuration = self.freezeDuration or self:GetRemainingTime()
			self:SetDuration( -1, true )
		end
		self:StartIntervalThink(self.tick)
	end
end

function modifier_juggernaut_dance_of_blades:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_juggernaut_dance_of_blades:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_juggernaut_dance_of_blades:CheckState()
	if self.disableBlocking then
		return {[MODIFIER_STATE_INVULNERABLE] = true,
				[MODIFIER_STATE_UNSELECTABLE] = true,
				[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
				[MODIFIER_STATE_NO_HEALTH_BAR] = true}
	else
		return {[MODIFIER_STATE_INVULNERABLE] = true,
				[MODIFIER_STATE_UNSELECTABLE] = true,
				[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
				[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
				[MODIFIER_STATE_NO_HEALTH_BAR] = true,
				[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
				[MODIFIER_STATE_NO_TEAM_SELECT] = true,
				[MODIFIER_STATE_DISARMED] = true,}
	end
end

function modifier_juggernaut_dance_of_blades:GetStatusEffectName()
	return "particles/status_fx/status_effect_omnislash.vpcf"
end

function modifier_juggernaut_dance_of_blades:StatusEffectPriority()
	return 20
end