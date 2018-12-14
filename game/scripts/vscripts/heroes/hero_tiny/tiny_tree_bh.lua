tiny_tree_bh = class({})
LinkLuaModifier("modifier_tiny_tree_bh", "heroes/hero_tiny/tiny_tree_bh", LUA_MODIFIER_MOTION_NONE)

function tiny_tree_bh:IsStealable()
    return false
end

function tiny_tree_bh:IsHiddenWhenStolen()
    return false
end

function tiny_tree_bh:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_tiny_tree_bh_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_tiny_tree_bh_1") end
    return cooldown
end

function tiny_tree_bh:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_tiny_tree_bh") then
		return "tiny_toss_tree"
	end
	return "tiny_craggy_exterior"
end

function tiny_tree_bh:GetBehavior()
	if self:GetCaster():HasModifier("modifier_tiny_tree_bh") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function tiny_tree_bh:GetAbilityTargetTeam()
	if self:GetCaster():HasModifier("modifier_tiny_tree_bh") then
		return DOTA_UNIT_TARGET_TEAM_ENEMY
	end
	return DOTA_UNIT_TARGET_TEAM_NONE
end

function tiny_tree_bh:GetAbilityTargetType()
	if self:GetCaster():HasModifier("modifier_tiny_tree_bh") then
		return DOTA_UNIT_TARGET_ALL
	end
	return DOTA_UNIT_TARGET_TREE
end

function tiny_tree_bh:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_tiny_tree_bh") then
		return self:GetSpecialValueFor("range")
	end
	return self:GetCaster():GetAttackRange()
end

function tiny_tree_bh:OnAbilityPhaseStart()
	if self:GetCaster():HasModifier("modifier_tiny_tree_bh") then
		--StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_4, rate=1, translate="tree"})
	end
	return true
end

function tiny_tree_bh:OnSpellStart()
    local caster = self:GetCaster()

    if caster:HasModifier("modifier_tiny_tree_bh") then
    	EmitSoundOn("Hero_Tiny.Tree.Throw", caster)
    	local point = self:GetCursorPosition()

    	local direction = CalculateDirection(point, caster:GetAbsOrigin())
    	local distance = self:GetSpecialValueFor("range")
    	local speed = self:GetSpecialValueFor("speed")
    	local velocity = direction * speed
    	local width = self:GetSpecialValueFor("width")

    	self:FireLinearProjectile("particles/units/heroes/hero_tiny/tiny_tree_linear_proj.vpcf", velocity, distance, width, {}, true, true, 300)
    	caster:RemoveModifierByName("modifier_tiny_tree_bh")
    	self:RefundManaCost()
    else
	    local target = self:GetCursorTarget()
	    EmitSoundOn("Hero_Tiny.Tree.Grab", caster)

	    caster:AddNewModifier(caster, self, "modifier_tiny_tree_bh", {})
	    target:CutDown(caster:GetTeam())

	    self:EndCooldown()
	end
end

function tiny_tree_bh:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
	local caster = self:GetCaster()

	if hTarget then
		EmitSoundOn("Hero_Tiny.Tree.Target", hTarget)
		local damage = caster:GetAttackDamage() * self:GetSpecialValueFor("toss_splash_damage")/100
		if caster:HasTalent("special_bonus_unique_tiny_tree_bh_2") then
			damage = damage + caster:GetPhysicalArmorValue() * caster:FindTalentValue("special_bonus_unique_tiny_tree_bh_2")/100
		end
		local enemies = caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), self:GetSpecialValueFor("splash_radius"))
		for _,enemy in pairs(enemies) do
			caster:PerformAttack(enemy, true, true, true, true, false, true, true)
			self:DealDamage(caster, enemy, damage, {}, 0)
		end
		ProjectileManager:DestroyLinearProjectile(iProjectileHandle)
	else
		if caster:HasScepter() then
			CreateTempTree(vLocation, 10)
		end
		EmitSoundOnLocationWithCaster(vLocation, "Hero_Tiny.Tree.Target", caster)
	end
end

modifier_tiny_tree_bh = class({})
function modifier_tiny_tree_bh:OnCreated()
	if IsServer() then
		self.tree = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_01/tiny_01_tree.vmdl"})
		self.tree:FollowEntity(self:GetParent(), true)
		AddAnimationTranslate(self:GetParent(), "tree")
	end
end

function modifier_tiny_tree_bh:GetTexture()
	return "tiny_craggy_exterior"
end

function modifier_tiny_tree_bh:OnDestroy()
	if IsServer() then
		RemoveAnimationTranslate(self:GetParent())
		UTIL_Remove(self.tree)
	end
end

function modifier_tiny_tree_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_tiny_tree_bh:OnAttackLanded(params)
	if IsServer() then
		local caster = params.attacker
		if caster == self:GetCaster() then
			EmitSoundOn("Hero_Tiny.Tree.Target", caster)
			--DoCleaveAttack(caster, params.target, self:GetAbility(), self:GetSpecialValueFor("splash_pct"), self:GetSpecialValueFor("splash_width"), self:GetSpecialValueFor("splash_range"), self:GetCaster():GetAttackRange(), "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf")
			local hitTargets = {}
			local endPos = caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetSpecialValueFor("splash_range")
			local damage = caster:GetAttackDamage() * self:GetSpecialValueFor("splash_pct")/100
			local i = 0
			local enemies = caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), endPos, self:GetSpecialValueFor("splash_width"), {})
			for _,enemy in pairs(enemies) do
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_craggy_cleave.vpcf", PATTACH_POINT, caster)
							ParticleManager:SetParticleControl(nfx, 0, enemy:GetAbsOrigin())
							ParticleManager:SetParticleControl(nfx, 1, enemy:GetAbsOrigin())
							ParticleManager:SetParticleControlForward(nfx, 2, caster:GetForwardVector())
							ParticleManager:ReleaseParticleIndex(nfx)
				hitTargets[i] = enemy
				self:GetAbility():DealDamage(caster, enemy, damage, {}, 0)
			end
			local enemies = caster:FindEnemyUnitsInRadius(endPos, self:GetSpecialValueFor("splash_width"))
			for _,enemy in pairs(enemies) do
				for _,enemy2 in pairs(hitTargets) do
					if enemy ~= enemy2 then
						local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_craggy_cleave.vpcf", PATTACH_POINT, caster)
							ParticleManager:SetParticleControl(nfx, 0, enemy:GetAbsOrigin())
							ParticleManager:SetParticleControl(nfx, 1, enemy:GetAbsOrigin())
							ParticleManager:SetParticleControlForward(nfx, 2, caster:GetForwardVector())
							ParticleManager:ReleaseParticleIndex(nfx)
						self:GetAbility():DealDamage(caster, enemy, damage, {}, 0)
					end
				end
			end
		end
	end
end


function modifier_tiny_tree_bh:GetModifierAttackRangeBonus()
	return self:GetSpecialValueFor("attack_range")
end

function modifier_tiny_tree_bh:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetSpecialValueFor("bonus_damage")
end