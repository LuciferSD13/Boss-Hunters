boss_necro_guillotine = class({})

function boss_necro_guillotine:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Necrolyte.ReapersScythe.Cast.ti7", caster)
	local bonusTargets = 5 - math.ceil(caster:GetHealthPercent() / 20)
	
	
	self:CreateGuillotine( target )
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 , {type = DOTA_UNIT_TARGET_HERO} ) ) do
		if enemy ~= target then
			if bonusTargets <= 0 then return end
			self:CreateGuillotine( enemy )
			bonusTargets = bonusTargets - 1
		end
	end
	
end

function boss_necro_guillotine:CreateGuillotine( enemy )
	local caster = self:GetCaster()
	local position = enemy:GetAbsOrigin()

	local damage = (100 - self:GetSpecialValueFor("hp_set")) / 100
	local radius = self:GetSpecialValueFor("radius")
	local kill_threshold = self:GetSpecialValueFor("kill_threshold")
	local duration = self:GetSpecialValueFor("duration")
	
	ParticleManager:FireParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_WORLDORIGIN, caster, {[1] = position})

	ParticleManager:FireWarningParticle(position, radius)
	
	Timers:CreateTimer(1.5, function()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius, {type = DOTA_UNIT_TARGET_HERO} ) ) do
			if not enemy:TriggerSpellAbsorb(self) then
				if enemy:GetHealthPercent() <= kill_threshold then
					enemy.tombstoneDisabled = true
					enemy:AttemptKill(self, caster)
				else
					self:DealDamage( caster, enemy, enemy:GetHealth() * damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
					enemy:DisableHealing( duration )
				end
			end
		end
	end)
end