----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sOutfitType = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,1,3,2,6,1,1,3,3,6,2,2,2,6},
						{1,3,1,3,2,6,3,3,1,1,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_crystal_maiden_outfit",
	"item_force_staff",
	"item_hand_of_midas",
	"item_aghanims_shard",
	"item_orchid",
	"item_ultimate_scepter",
	"item_black_king_bar",
	"item_hurricane_pike",
	"item_bloodthorn",
	"item_mystic_staff",
	"item_ultimate_scepter_2",
	"item_sheepstick",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = {

	'item_priest_outfit',
	"item_urn_of_shadows",
	"item_hand_of_midas",
	"item_mekansm",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
	--"item_holy_locket",
	"item_ultimate_scepter",
	"item_sheepstick",
	"item_mystic_staff",
	"item_ultimate_scepter_2",
	"item_shivas_guard",

}

tOutFitList['outfit_mage'] = {

	"item_mage_outfit",
	"item_hand_of_midas",
	"item_glimmer_cape",
	"item_pipe",
	"item_aghanims_shard",
	--"item_holy_locket",
	"item_veil_of_discord",
	"item_ultimate_scepter",
	"item_mystic_staff",
	"item_ultimate_scepter_2",
	"item_sheepstick",

}

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_ultimate_scepter",
	"item_magic_wand",

}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_dazzle

"Ability1"		"dazzle_poison_touch"
"Ability2"		"dazzle_shallow_grave"
"Ability3"		"dazzle_shadow_wave"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"dazzle_bad_juju"
"Ability10"		"special_bonus_attack_damage_75"
"Ability11"		"special_bonus_hp_200"
"Ability12"		"special_bonus_cast_range_125"
"Ability13"		"special_bonus_unique_dazzle_2"
"Ability14"		"special_bonus_movement_speed_40"
"Ability15"		"special_bonus_unique_dazzle_3"
"Ability16"		"special_bonus_unique_dazzle_1"
"Ability17"		"special_bonus_unique_dazzle_4"

modifier_dazzle_poison_touch
modifier_dazzle_shallow_grave
modifier_dazzle_weave_armor
modifier_dazzle_bad_juju
modifier_dazzle_bad_juju_armor

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent3 = bot:GetAbilityByName( sTalentList[3] )
local talent4 = bot:GetAbilityByName( sTalentList[4] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local talent4Damage = 0


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end
--	if talent3:IsTrained() then aetherRange = aetherRange + talent3:GetSpecialValueInt( "value" ) end
--	if talent4:IsTrained() then talent4Damage = talent4:GetSpecialValueInt( "value" ) end


	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end


	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end


	castEDesire, castETarget, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange()
	local nRadius = 600
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nPerDamage = abilityQ:GetSpecialValueInt( "damage" )

	if talent6:IsTrained() then nPerDamage = nPerDamage + talent6:GetSpecialValueInt( "value" ) end

	local nDuration = abilityQ:GetSpecialValueInt( "duration" )

	local nDamage = nPerDamage * nDuration

	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil

	--击杀
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage, nDamageType )
		then
			hCastTarget = npcEnemy
			sCastMotive = 'Q-击杀:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end



	--团战中对血量最低的敌人使用
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				if ( npcEnemyHealth < npcWeakestEnemyHealth )
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = npcEnemy
				end
			end
		end

		if npcWeakestEnemy ~= nil
			and J.IsInRange( bot, npcWeakestEnemy, nCastRange + 100 )
		then
			hCastTarget = npcWeakestEnemy
			sCastMotive = 'Q-团战:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 50 )
			and J.CanCastOnTargetAdvanced( botTarget )
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHP( botTarget ) < 0.43 or nHP <= 0.4
			then
				hCastTarget = botTarget
				sCastMotive = 'Q-进攻:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-撤退时减速:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	--打野
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and #hAllyList <= 1
		and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		local nCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 200 )

		local targetCreep = J.GetMostHpUnit( nCreeps )

		if J.IsValid( targetCreep )
			and not J.IsRoshan( targetCreep )
			and #nCreeps >= 3
			and bot:IsFacingLocation( targetCreep:GetLocation(), 40 )
			and ( targetCreep:GetMagicResist() < 0.3 or nMP > 0.9 )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 1.88, DAMAGE_TYPE_PHYSICAL )
		then
			hCastTarget = targetCreep
			sCastMotive = 'Q-打野'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--推线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and nSkillLV >= 3 and DotaTime() > 6 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 300, true )
		local targetCreep = nLaneCreeps[3]

		if #nLaneCreeps >= 4
			and J.IsValid( targetCreep )
			and not targetCreep:HasModifier( "modifier_fountain_glyph" )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 1.88, DAMAGE_TYPE_PHYSICAL )
		then
			hCastTarget = targetCreep
			sCastMotive = 'Q-推线'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--肉山
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 400
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange - 200 )
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-肉山'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--常规
	if ( #hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nSkillLV >= 4
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-常规:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end



	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + aetherRange
	local nRadius = 600
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil


	for _, npcAlly in pairs( hAllyList )
	do
		if J.IsValidHero( npcAlly )
			and J.IsInRange( bot, npcAlly, nCastRange + 600 )
			and not npcAlly:HasModifier( 'modifier_dazzle_shallow_grave' )
			and J.GetHP( npcAlly ) < 0.4
			and npcAlly:WasRecentlyDamagedByAnyHero( 3.5 )
		then
			local nCastDelay = X.GetCastAbilityWDelay( npcAlly, nCastRange ) * 1.1
			if X.GetEnemyFacingAllyDamage( npcAlly, 1100, nCastDelay ) > npcAlly:GetHealth()
			then
				hCastTarget = npcAlly
				sCastMotive = "W-保护可能被击杀的队友:"..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end

			if npcAlly:GetHealth() < 200
			then

				if npcAlly:HasModifier( 'modifier_sniper_assassinate' )
				then
					hCastTarget = npcAlly
					sCastMotive = "W-保护被暗杀的队友:"..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end

				if npcAlly:HasModifier( 'modifier_huskar_burning_spear_counter' )
					or npcAlly:HasModifier( 'modifier_jakiro_macropyre_burn' )
					or npcAlly:HasModifier( 'modifier_necrolyte_reapers_scythe' )
					or npcAlly:HasModifier( 'modifier_viper_viper_strike_slow' )
					or npcAlly:HasModifier( 'modifier_viper_nethertoxin' )
					or npcAlly:HasModifier( 'modifier_viper_poison_attack_slow' )
					or npcAlly:HasModifier( 'modifier_maledict' )
				then
					hCastTarget = npcAlly
					sCastMotive = "W-防止队友被Debuff击杀:"..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end

			end

			if J.GetHP( npcAlly ) < 0.13
				and J.IsInRange( bot, npcAlly, nCastRange + 200 )
				and J.GetEnemyCount( npcAlly, 600 ) >= 1
			then
				hCastTarget = npcAlly
				sCastMotive = "W-防止低血量队友被击杀:"..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end

		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nSkillLV = abilityE:GetLevel()
	local nCastRange = abilityE:GetCastRange() + aetherRange
	local nRadius = abilityE:GetSpecialValueInt( 'damage_radius' )
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nDamage = abilityE:GetSpecialValueInt( 'damage' ) + talent4Damage
	local nMaxHealCount = abilityE:GetSpecialValueInt( 'tooltip_max_targets_inc_dazzle' )
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nInRangeAllyList = J.GetAlliesNearLoc( bot:GetLocation(), nCastRange + 300 )
	local hCastTarget = nil
	local sCastMotive = nil

	local nWeakestAlly = J.GetLeastHpUnit( nInRangeAllyList )


	--治疗队友
	local nNeedHealHeroCount = 0
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly:GetMaxHealth() - npcAlly:GetHealth() > nDamage
		then
			nNeedHealHeroCount = nNeedHealHeroCount + 1
		end
	end
	if nWeakestAlly ~= nil
	then
		if J.GetHP( nWeakestAlly ) < 0.8
			and ( nNeedHealHeroCount >= nMaxHealCount - 2 or nNeedHealHeroCount >= 4 )
		then
			hCastTarget = nWeakestAlly
			sCastMotive = "E-治疗多个队友:"..J.Chat.GetNormName( hCastTarget )
			return 	BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end

		if J.GetHP( nWeakestAlly ) < 0.6
			and ( nMP > 0.9
					or nNeedHealHeroCount >= nMaxHealCount - 3
					or nNeedHealHeroCount >= 3 )
		then
			hCastTarget = nWeakestAlly
			sCastMotive = "E-治疗半血队友:"..J.Chat.GetNormName( hCastTarget )
			return 	BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end

		if J.GetHP( nWeakestAlly ) < 0.35
			or ( J.GetHP( nWeakestAlly ) < 0.5 and nNeedHealHeroCount >= 2 )
		then
			hCastTarget = nWeakestAlly
			sCastMotive = "E-紧急治疗队友:"..J.Chat.GetNormName( hCastTarget )
			return 	BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end

	end


	--治疗小兵
	if #hAllyList <= 2
		and #hEnemyList == 0
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, 90 )
	then
		local allyCreepList = bot:GetNearbyLaneCreeps( 1400, false )
		local needHealCreepCount = 0
		for _, creep in pairs( allyCreepList )
		do
			if creep:GetMaxHealth() - creep:GetHealth() > nDamage
			then
				needHealCreepCount = needHealCreepCount + 1
			elseif creep:GetMaxHealth() - creep:GetHealth() > nDamage * 0.6
			then
				needHealCreepCount = needHealCreepCount + 0.6
			end
		end
		if needHealCreepCount >= nMaxHealCount - 1
		then
			local nWeakestCreep = J.GetLeastHpUnit( allyCreepList )
			if nWeakestCreep ~= nil
			then
				hCastTarget = nWeakestCreep
				sCastMotive = "E-治疗兵线:"..needHealCreepCount
				return 	BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--伤害敌人
	local abilityETotalDamage = 0
	for _, npcEnemy in pairs( hEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.IsInRange( bot, npcEnemy, nCastRange + 300 )
			and J.CanCastOnMagicImmune( npcEnemy )
		then
			local allyUnitCount = J.GetUnitAllyCountAroundEnemyTarget( npcEnemy, nRadius )
			if J.CanKillTarget( npcEnemy, allyUnitCount * nDamage, nDamageType )
			then
				hCastTarget = X.GetBestHealTarget( npcEnemy, nRadius )
				if hCastTarget ~= nil
				then
					sCastMotive = "E-击杀敌人:"..J.Chat.GetNormName( npcEnemy )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end

			--Aoe效果
			if allyUnitCount >= 1 and nSkillLV >= 3
			then
				abilityETotalDamage = abilityETotalDamage + allyUnitCount * nDamage
			end
			if abilityETotalDamage >= 800
				and nWeakestAlly ~= nil
				and J.IsInRange( bot, nWeakestAlly, nCastRange + 50 )
			then
				hCastTarget = nWeakestAlly
				sCastMotive = "E-Aoe伤害:"..abilityETotalDamage
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--攻击敌人
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 200 )
			and J.CanCastOnMagicImmune( botTarget )
		then
			local allyUnitCount = J.GetUnitAllyCountAroundEnemyTarget( botTarget, nRadius )
			if allyUnitCount >= nMaxHealCount - 2
				or allyUnitCount >= 4
			then
				hCastTarget = X.GetBestHealTarget( botTarget, nRadius )
				if hCastTarget ~= nil
				then
					sCastMotive = "E-伤害目标:"..J.Chat.GetNormName( botTarget )
					return 	BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.GetBestHealTarget( npcEnemy, nRadius )

	local bestTarget = nil
	local maxLostHealth = -1

	local allyCreepList = bot:GetNearbyCreeps( 1600, false )
	local allyHeroList = bot:GetNearbyHeroes( 1600, false, BOT_MODE_NONE )
	local allyUnit = J.CombineTwoTable( allyCreepList, allyHeroList )


	for _, unit in pairs( allyUnit )
	do 
		if J.IsInRange( npcEnemy, unit, nRadius + 9 )
			and unit:GetMaxHealth() - unit:GetHealth() > maxLostHealth
		then
			maxLostHealth = unit:GetMaxHealth() - unit:GetHealth()
			bestTarget = unit
		end
	end

	return bestTarget

end


function X.GetCastAbilityWDelay( npcAlly, nCastRange )

	if not J.IsInRange( bot, npcAlly, nCastRange )
	then
		local nDistance = GetUnitToUnitDistance( bot, npcAlly ) - nCastRange
		local moveDelay = nDistance/bot:GetCurrentMovementSpeed()

		return 0.4 + moveDelay + 1.3
	end

	return 0.4 + 1.1

end


function X.GetAbilityEMaxDamage( npcEnemy )

	local nRadius = abilityE:GetSpecialValueInt( 'damage_radius' )

	local allyUnitCount = J.GetUnitAllyCountAroundEnemyTarget( npcEnemy, nRadius )

	local abilityEDamge = abilityE:GetSpecialValueInt( 'damage' ) + talent4Damage

	return allyUnitCount * nDamage

end


function X.GetEnemyFacingAllyDamage( npcAlly, nRadius, nDelay )

	local enemyList = J.GetEnemyList( npcAlly, nRadius )
	local totalDamage = 0

	for _, npcEnemy in pairs( enemyList )
	do
		if npcEnemy:IsFacingLocation( npcAlly:GetLocation(), 15 )
			or npcEnemy:GetAttackTarget() == npcAlly
		then
			local enemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcAlly, nDelay, DAMAGE_TYPE_ALL )
			totalDamage = totalDamage + enemyDamage
		end
	end

	return totalDamage

end


return X
-- dota2jmz@163.com QQ:2462331592.
