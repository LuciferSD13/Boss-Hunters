HP_PER_STR = 18
MR_PER_STR = 0.4
HP_REGEN_PER_STR = 0.025
MANA_PER_INT = 10
MANA_REGEN_PER_INT = 0.035
ARMOR_PER_AGI = 0.07
ATKSPD_PER_AGI = 0.08
DMG_PER_AGI = 0.5
CDR_PER_INT = 0.385
SPELL_AMP_PER_INT = 0.0075

require("templates/relic_base_class")
require("templates/persistent_modifier")
require("templates/item_basic_base_class")
require("templates/item_aura_base_class")
require("templates/toggle_modifier_base_class")
require("templates/talent_base_class")
require("templates/rune_base_class")
require("templates/talent_base_class")


LinkLuaModifier( "modifier_generic_attack_bonus", "libraries/modifiers/modifier_generic_attack_bonus.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_attack_bonus_pct", "libraries/modifiers/modifier_generic_attack_bonus_pct.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_sleep_generic", "libraries/modifiers/modifier_sleep_generic.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_charm_generic", "libraries/modifiers/modifier_charm_generic.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stun_immunity", "libraries/modifiers/modifier_stun_immunity.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_restoration_disable", "libraries/modifiers/modifier_restoration_disable.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_ascension", "libraries/modifiers/modifier_boss_ascension.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_illusion_bonuses", "libraries/modifiers/illusions/modifier_illusion_bonuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_blind_generic", "libraries/modifiers/modifier_blind_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_wearable", "libraries/modifiers/modifier_wearable.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_status_immunity", "libraries/modifiers/modifier_status_immunity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_paralyze", "libraries/modifiers/modifier_paralyze.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_in_water", "libraries/modifiers/modifier_in_water.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_bh_heal_disable", "libraries/modifiers/modifier_bh_heal_disable.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_summon_handler", "libraries/modifiers/modifier_summon_handler.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_stunned_generic", "libraries/modifiers/modifier_stunned_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_silence_generic", "libraries/modifiers/modifier_silence_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_disarm_generic", "libraries/modifiers/modifier_disarm_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_break_generic", "libraries/modifiers/modifier_break_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_daze_generic", "libraries/modifiers/modifier_daze_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_root_generic", "libraries/modifiers/modifier_root_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_talent_barrier", "libraries/modifiers/modifier_talent_barrier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_taunt_generic", "libraries/modifiers/modifier_taunt_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_fear_generic", "libraries/modifiers/modifier_fear_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_chill_generic", "libraries/modifiers/modifier_chill_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_frozen_generic", "libraries/modifiers/modifier_frozen_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_hidden_generic", "libraries/modifiers/modifier_hidden_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_boss_attackspeed", "libraries/modifiers/modifier_boss_attackspeed.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_spawn_immunity", "libraries/modifiers/modifier_spawn_immunity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_tombstone_respawn_immunity", "libraries/modifiers/modifier_tombstone_respawn_immunity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_talent_attack_bonus", "libraries/modifiers/modifier_talent_attack_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_talent_attack_bonus_pct", "libraries/modifiers/modifier_talent_attack_bonus_pct.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_power_scaling", "libraries/modifiers/modifier_power_scaling.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_boss_evasion", "libraries/modifiers/modifier_boss_evasion.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_boss_hard_enrage", "libraries/modifiers/modifier_boss_hard_enrage.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier( "modifier_stats_system_handler", "libraries/handlers/modifier_stats_system_handler.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_lives_handler", "libraries/handlers/modifier_lives_handler.lua", LUA_MODIFIER_MOTION_NONE)

-- PERKS 
LinkLuaModifier( "modifier_talent_evasion", "libraries/modifiers/talents/modifier_talent_evasion.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_area_damage", "libraries/modifiers/talents/modifier_talent_area_damage.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_threat_amp", "libraries/modifiers/talents/modifier_talent_threat_amp.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_threat_down", "libraries/modifiers/talents/modifier_talent_threat_down.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_armor", "libraries/modifiers/talents/modifier_talent_armor.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_magic_resist", "libraries/modifiers/talents/modifier_talent_magic_resist.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_health", "libraries/modifiers/talents/modifier_talent_health.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_health_regen", "libraries/modifiers/talents/modifier_talent_health_regen.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_attack_damage", "libraries/modifiers/talents/modifier_talent_attack_damage.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_attack_speed", "libraries/modifiers/talents/modifier_talent_attack_speed.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_spell_amp", "libraries/modifiers/talents/modifier_talent_spell_amp.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_status_amp", "libraries/modifiers/talents/modifier_talent_status_amp.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_heal_amp", "libraries/modifiers/talents/modifier_talent_heal_amp.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_mana", "libraries/modifiers/talents/modifier_talent_mana.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_mana_regen", "libraries/modifiers/talents/modifier_talent_mana_regen.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_movespeed", "libraries/modifiers/talents/modifier_talent_movespeed.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_strength", "libraries/modifiers/talents/modifier_talent_strength.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_agility", "libraries/modifiers/talents/modifier_talent_agility.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_intelligence", "libraries/modifiers/talents/modifier_talent_intelligence.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_all_stats", "libraries/modifiers/talents/modifier_talent_all_stats.lua", LUA_MODIFIER_MOTION_NONE )
----------------------------------------
----------------------------------------

LinkLuaModifier( "modifier_typing_tag", "libraries/modifiers/tags/modifier_typing_tag.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_illusion_tag", "libraries/modifiers/illusions/modifier_illusion_tag.lua", LUA_MODIFIER_MOTION_NONE)

if IsClient() then -- Load clientside utility lib
	print("client-side has been initialized")
	require("libraries/client_util")
	require("talentmanager")
	-- TalentManager:StartTalentManager()
	
	-- if GameRules == nil then
		-- GameRules = class({})
	-- end
	-- GameRules.IsDaytime = function()
		-- local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
		-- return tonumber(timeofday["timeofday"]) == 1
	-- end
	
	-- GameRules.IsTemporaryNight = function()
		-- local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
		-- return tonumber(timeofday["timeofday"]) == 2
	-- end
	
	-- GameRules.IsNightstalkerNight = function()
		-- local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
		-- return tonumber(timeofday["timeofday"]) == 3
	-- end
	-- print( "initialized gamerules", GameRules, GameRules.IsDaytime )
	Convars:RegisterCommand( "cl_deepdebugging", function()
													if not GameRules.DebugCalls then
														print("Starting DebugCalls")
														GameRules.DebugCalls = true

														debug.sethook(function(...)
															local info = debug.getinfo(2)
															local src = tostring(info.short_src)
															local name = tostring(info.name)
															if name ~= "__index" then
																print("Call: ".. src .. " -- " .. name)
															end
														end, "c")
													else
														print("Stopped DebugCalls")
														GameRules.DebugCalls = false
														debug.sethook(nil, "c")
													end
												end, "fixing bug",0)
end