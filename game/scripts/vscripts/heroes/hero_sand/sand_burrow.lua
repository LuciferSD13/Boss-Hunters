sand_burrow = class({})
LinkLuaModifier( "modifier_caustics_enemy", "heroes/hero_sand/sand_caustics.lua" ,LUA_MODIFIER_MOTION_NONE )

function sand_burrow:IsStealable()
    return true
end

function sand_burrow:IsHiddenWhenStolen()
    return false
end

function sand_burrow:GetCastRange(vLocation, hTarget)
    return self:GetTalentSpecialValueFor("range")
end

function sand_burrow:PiercesDisableResistance()
    return true
end

function sand_burrow:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_burrowstrike.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, point)
    ParticleManager:ReleaseParticleIndex(particle)

    local enemies = caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), point, self:GetTalentSpecialValueFor("width"), {})
    for _,enemy in pairs(enemies) do
        if enemy and enemy:IsAlive() and not enemy:IsKnockedBack() and not enemy:TriggerSpellAbsorb( self ) then
            enemy:ApplyKnockBack(enemy:GetAbsOrigin(), 0.5, 0.5, 0, 350, caster, self)

            Timers:CreateTimer(0.5,function()
                self:Stun(enemy, self:GetTalentSpecialValueFor("duration"), false)
                self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)

                if caster:HasTalent("special_bonus_unique_sand_burrow_1") then
                    local ability = caster:FindAbilityByName("sand_caustics")
                    enemy:AddNewModifier(caster, ability, "modifier_caustics_enemy", {Duration = ability:GetTalentSpecialValueFor("duration")})
                end
            end)
        end
    end

    caster:EmitSound("Ability.SandKing_BurrowStrike")
    FindClearSpaceForUnit(caster, point, true)

    GridNav:DestroyTreesAroundPoint(point, self:GetTalentSpecialValueFor("width"), false)

    caster:StartGesture(ACT_DOTA_SAND_KING_BURROW_OUT)
end