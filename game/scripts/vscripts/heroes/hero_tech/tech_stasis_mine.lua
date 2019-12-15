tech_stasis_mine = class({})
LinkLuaModifier( "modifier_stasis_mine", "heroes/hero_tech/tech_stasis_mine.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stasis_mine_mr", "heroes/hero_tech/tech_stasis_mine.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stasis_mine_root", "heroes/hero_tech/tech_stasis_mine.lua", LUA_MODIFIER_MOTION_NONE )

function tech_stasis_mine:IsStealable()
	return true
end

function tech_stasis_mine:IsHiddenWhenStolen()
	return false
end

function tech_stasis_mine:PiercesDisableResistance()
    return true
end

function tech_stasis_mine:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Techies.StasisTrap.Plant", caster)
	local mine = CreateUnitByName("npc_dota_techies_stasis_trap", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
	mine:AddNewModifier(caster, self, "modifier_stasis_mine", {})
	mine:AddNewModifier(caster, self, "modifier_kill", {duration = 120})
end

modifier_stasis_mine_root = class({})

function modifier_stasis_mine_root:GetStatusEffectName()
	return "particles/status_fx/status_effect_techies_stasis.vpcf"
end

function modifier_stasis_mine_root:StatusEffectPriority()
	return 5
end


function modifier_stasis_mine_root:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_INVISIBLE] = false}
	return state
end

function modifier_stasis_mine_root:IsPurgable()
	return true
end

modifier_stasis_mine = ({})
function modifier_stasis_mine:OnCreated(table)
	if IsServer() then
		Timers:CreateTimer(self:GetTalentSpecialValueFor("active_delay"), function()
			self:StartIntervalThink(FrameTime())
		end)
	end
end

function modifier_stasis_mine:OnIntervalThink()
	local radius = self:GetTalentSpecialValueFor("stun_radius")
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})
	if #enemies > 0 then
		Timers:CreateTimer( 0.3, function()
			for _,enemy in pairs(self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})) do
				if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
					StopSoundOn("Hero_Techies.StasisTrap.Plant", self:GetCaster())
					EmitSoundOn("Hero_Techies.StasisTrap.Stun", self:GetParent())

					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stasis_mine_root", {Duration = self:GetTalentSpecialValueFor("stun_duration")})

					if self:GetCaster():HasTalent("special_bonus_unique_tech_stasis_mine_1") then
						enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stasis_mine_mr", {Duration = self:GetTalentSpecialValueFor("stun_duration")})
					end
				end
				triggered = true
			end
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_POINT, self:GetCaster())
				ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
				ParticleManager:SetParticleControl(nfx, 3, self:GetParent():GetAbsOrigin())
				Timers:CreateTimer(1, function()
					ParticleManager:DestroyParticle(nfx, false)
				end)
			self:GetParent():ForceKill(false)
			self:Destroy()
		end)
		self:StartIntervalThink(-1)
	end
end


function modifier_stasis_mine:CheckState()
	local state = { [MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end

modifier_stasis_mine_mr = ({})
function modifier_stasis_mine_mr:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifier_stasis_mine_mr:GetModifierMagicalResistanceBonus()
	return self:GetTalentSpecialValueFor("magic_resist")	
end

function modifier_stasis_mine_mr:IsDebuff()
	return true	
end