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
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{3,1,3,2,3,6,3,1,1,1,6,2,2,2,6},
						{3,1,3,2,3,6,3,2,2,2,6,1,1,1,6},
						{1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_bristleback_outfit",
	"item_bracer",
	"item_point_booster",
	"item_blink",
	"item_ultimate_scepter",
	"item_aghanims_shard",
	"item_black_king_bar",	
	"item_travel_boots",
	"item_skadi",
	"item_satanic",
	"item_overwhelming_blink",	
	"item_ultimate_scepter_2",
	"item_greater_crit",
	"item_moon_shard",
	"item_travel_boots_2",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_echo_sabre",
	"item_quelling_blade",

	"item_black_king_bar",
	"item_magic_wand",

	"item_greater_crit",
	"item_hand_of_midas",

	"item_abyssal_blade",
	"item_blight_stone",

}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_heavens_halberd", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_tidehunter

"Ability1"		"tidehunter_gush"
"Ability2"		"tidehunter_kraken_shell"
"Ability3"		"tidehunter_anchor_smash"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"tidehunter_ravage"
"Ability10"		"special_bonus_movement_speed_15"
"Ability11"		"special_bonus_unique_tidehunter_2"
"Ability12"		"special_bonus_mp_regen_3"
"Ability13"		"special_bonus_unique_tidehunter_3"
"Ability14"		"special_bonus_unique_tidehunter_4"
"Ability15"		"special_bonus_unique_tidehunter"
"Ability16"		"special_bonus_cooldown_reduction_20"
"Ability17"		"special_bonus_attack_damage_200"

modifier_tidehunter_gush
modifier_tidehunter_kraken_shell
modifier_tidehunter_anchor_smash_caster
modifier_tidehunter_anchor_smash
modifier_tidehunter_ravage


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent3 = bot:GetAbilityByName( sTalentList[3] )


local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


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


	--计算天赋可能带来的通用变化
	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end

	
	castRDesire, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityR )
		return
	end
	

	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )
		
		if bot:HasScepter()
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQTarget:GetLocation() )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		end
		return
	end


	castEDesire, sMotive = X.ConsiderE()
	if castEDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		--J.SetQueuePtToINT( bot, true )

		bot:Action_UseAbility( abilityE )
		return
	end

end



function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	
	if bot:HasScepter() then nCastRange = 1400 end
	
	local nRadius = 600
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	
	local nDamage = abilityQ:GetSpecialValueInt( 'gush_damage' )
	if talent3:IsTrained() then nDamage = nDamage + talent3:GetSpecialValueInt( 'value' ) end
	
	local nDamageType = DAMAGE_TYPE_MAGICAL 
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil

	--击杀敌人
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do 
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage , nCastPoint )
		then
			hCastTarget = npcEnemy
			sCastMotive = 'Q-击杀'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	
	end
	
	
	--打架先手
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )			
			and J.CanCastOnTargetAdvanced( botTarget )
		then			
			hCastTarget = botTarget
			sCastMotive = 'Q-先手'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	
	--撤退时保护自己
	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 5.0 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-撤退'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	
	--对线期间补刀
	if bot:GetActiveMode() == BOT_MODE_LANING or ( nLV <= 7 and #hAllyList <= 2 )
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nCastRange + 200, true )
		local keyWord = "ranged"
		for _, creep in pairs( laneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and not J.IsOtherAllysTarget( creep )
				and J.IsKeyWordUnit( keyWord, creep )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				and GetUnitToUnitDistance( creep, bot ) > 280
			then
				hCastTarget = creep
				sCastMotive = 'Q-补远'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end

		if nSkillLV >= 2
			and ( bot:GetMana() > nKeepMana or nMP > 0.9 )
		then
			local keyWord = "melee"
			for _, creep in pairs( laneCreepList )
			do
				if J.IsValid( creep )
					and not creep:HasModifier( "modifier_fountain_glyph" )
					and not J.IsOtherAllysTarget( creep )
					and J.IsKeyWordUnit( keyWord, creep )
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
					and GetUnitToUnitDistance( creep, bot ) > 350
				then
					hCastTarget = creep
					sCastMotive = 'Q-补近'
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end
	
	
	--带线补远程
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nCastRange, true )
		local keyWord = "ranged"
		for _, creep in pairs( laneCreepList )
		do
			if J.IsValid( creep )
			    and ( J.IsKeyWordUnit( keyWord, creep ) or nMP > 0.8 )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				and not J.CanKillTarget( creep, bot:GetAttackDamage() * 1.38, DAMAGE_TYPE_PHYSICAL )
			then
				hCastTarget = creep
				sCastMotive = 'Q-带线'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	
	--打野削护甲
	if J.IsFarming( bot )
		and DotaTime() > 6 * 60
		and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		local targetCreep = bot:GetAttackTarget()

		if J.IsValid( targetCreep )
			and targetCreep:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, targetCreep, nCastRange )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 2.2, DAMAGE_TYPE_PHYSICAL )
		then
			hCastTarget = targetCreep
			sCastMotive = 'Q-打野'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
	    end
	end
	
	
	--辅助打肉山
	if J.IsDoingRoshan( bot )
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-肉山'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end	
	end


	return BOT_ACTION_DESIRE_NONE


end



function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nSkillLV = abilityE:GetLevel()
	local nRadius = abilityE:GetSpecialValueInt( 'radius' )
	local nCastRange = nRadius	
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nDamage = abilityE:GetSpecialValueInt( 'attack_damage' ) + bot:GetAttackDamage()
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange - 40 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil
	
	
	--击杀敌人
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do 
		if J.IsValid( npcEnemy )
			and J.CanCastOnMagicImmune( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage, nDamageType )
		then
			hCastTarget = npcEnemy
			sCastMotive = 'E-击杀'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	
	end
		
	
	--打架攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nRadius - 50 )
			and J.CanCastOnMagicImmune( botTarget )			
		then			
			hCastTarget = botTarget
			sCastMotive = 'E-攻击'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end
	
	
	--团战AOE
	if J.IsInTeamFight( bot, 1000 )
	then
		local nAoeCount = 0
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do 
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
			then
				nAoeCount = nAoeCount + 1	
			end
		end

		if nAoeCount >= 2
		then
			hCastTarget = botTarget
			sCastMotive = 'E-团战AOE'..nAoeCount
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end
	
	
	--撤退时保护自己
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				hCastTarget = npcEnemy
				sCastMotive = 'E-撤退'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, sCastMotive
			end
		end
	end
	
	
	--对线期间消耗收兵
	if J.IsLaning( bot )
	then
		local nCanKillMeleeCount = 0
		local nCanKillRangedCount = 0
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nCastRange, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				--and not J.IsOtherAllysTarget( creep )
			then
				local lastHitDamage = nDamage
				if J.IsItemAvailable( "item_quelling_blade" ) then lastHitDamage = lastHitDamage + 12 end
				
				if J.WillKillTarget( creep, lastHitDamage, nDamageType, nCastPoint )
				then
					if J.IsKeyWordUnit( 'ranged', creep )
					then
						nCanKillRangedCount = nCanKillRangedCount + 1
					end

					if J.IsKeyWordUnit( 'melee', creep )
					then
						nCanKillMeleeCount = nCanKillMeleeCount + 1
					end

				end
			end
		end

		if nCanKillMeleeCount + nCanKillRangedCount >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, 'E对线1'
		end

		if nCanKillRangedCount >= 1 and nCanKillMeleeCount >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, 'E对线2'
		end

		if #hLaneCreepList == 0
			and #nInRangeEnemyList >= 1
			and nMP > 0.6
		then
			return BOT_ACTION_DESIRE_HIGH, 'E消耗'	
		end
	end
	
	
	--带线AOE
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and #hAllyList <= 3
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nCastRange , true )
		if ( #laneCreepList >= 3 or ( #laneCreepList >= 2 and nMP > 0.82 ) )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			
			hCastTarget = creep
			sCastMotive = 'E-带线AOE'..(#laneCreepList)
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end
	
	
	
	--打野AOE
	if J.IsFarming( bot )
		and DotaTime() > 6 * 60
		and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nRadius )

		if #creepList >= 2
			and J.IsValid( botTarget )
		then
			hCastTarget = botTarget
			sCastMotive = 'E-打野AOE'..(#creepList)
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
	    end
	end


	return BOT_ACTION_DESIRE_NONE


end



function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetSpecialValueInt( 'radius' )
	local nRadius = abilityR:GetSpecialValueInt( 'radius' )
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange - 80 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange - 260 )
	local hCastTarget = nil
	local sCastMotive = nil
	
	
	--打断敌人施法
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do 
		if npcEnemy:IsChanneling()
			and not npcEnemy:IsMagicImmune()
		then
			hCastTarget = npcEnemy
			sCastMotive = 'R-打断'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, sCastMotive		
		end
	end
	
	
	--打架时先手
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, 600 )
			and J.CanCastOnNonMagicImmune( botTarget )			
			and not J.IsDisabled( botTarget )
		then			
			hCastTarget = botTarget
			sCastMotive = 'R-先手'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end
	
	
	
	--团战AOE
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeCount = 0
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do 
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and not J.IsDisabled( npcEnemy )
			then
				nAoeCount = nAoeCount + 1	
			end
		end

		if nAoeCount >= 2
		then
			hCastTarget = botTarget
			sCastMotive = 'R-团战AOE'..nAoeCount
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end

	
	
	--撤退时保护队友
	if J.IsRetreating( bot )
		and #nInBonusEnemyList >= 1
		and #hAllyList >= 2
	then
		local nAoeCount = 0
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do 
			if J.IsValidHero( npcEnemy )
				and J.IsInRange( bot, npcEnemy, 450 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 )
			then
				nAoeCount = nAoeCount + 1
			end
		end

		if nAoeCount >= 1
		then
			hCastTarget = botTarget
			sCastMotive = 'R-撤退AOE'..nAoeCount
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end		
	end

	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592.

