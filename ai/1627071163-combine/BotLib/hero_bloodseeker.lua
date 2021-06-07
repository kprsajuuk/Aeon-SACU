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
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,2,3,1,6,1,1,3,3,6,2,2,2,6},
						{1,3,2,3,3,6,3,1,1,1,6,2,2,2,6},
						{1,3,2,2,2,6,2,3,3,3,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRandomItem_1 = RandomInt( 1, 9 ) > 6 and "item_monkey_king_bar" or "item_butterfly"

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_melee_carry_outfit",
	"item_yasha",
	"item_aghanims_shard",
	"item_diffusal_blade",
	"item_sange_and_yasha",
	"item_black_king_bar",
	"item_travel_boots",
	"item_abyssal_blade",
	sRandomItem_1,
	"item_moon_shard",
	"item_travel_boots_2",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_power_treads",
	"item_quelling_blade",

	"item_abyssal_blade",
	"item_magic_wand",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_melee_carry' }, {"item_power_treads", 'item_quelling_blade'} end

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

npc_dota_hero_bloodseeker

"Ability1"		"bloodseeker_bloodrage"
"Ability2"		"bloodseeker_blood_bath"
"Ability3"		"bloodseeker_thirst"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"bloodseeker_rupture"
"Ability10"		"special_bonus_attack_speed_25"
"Ability11"		"special_bonus_armor_6"
"Ability12"		"special_bonus_hp_275"
"Ability13"		"special_bonus_unique_bloodseeker_2"
"Ability14"		"special_bonus_unique_bloodseeker_3"
"Ability15"		"special_bonus_lifesteal_25"
"Ability16"		"special_bonus_unique_bloodseeker"
"Ability17"		"special_bonus_unique_bloodseeker_4"

modifier_bloodseeker_bloodrage
modifier_bloodseeker_bloodbath_thinker
modifier_bloodseeker_thirst
modifier_bloodseeker_thirst_vision
modifier_bloodseeker_thirst_speed
modifier_bloodseeker_rupture_charge_counter
modifier_bloodseeker_rupture

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castQDesire, castQTarget = 0
local castWDesire, castWLocation = 0
local castRDesire, castRTarget = 0

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList


function X.SkillsComplement()



	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end



	nKeepMana = 300
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	nLV = bot:GetLevel()
	hEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )




	castRDesire, castRTarget = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return

	end

	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		bot:Action_ClearActions( false )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return

	end

	castWDesire, castWLocation = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
	end


end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end

	local nCastRange = abilityQ:GetCastRange()
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = bot:GetAttackDamage()

	local npcTarget = J.GetProperTarget( bot )


	
	--团战时辅助
	if J.IsInTeamFight( bot, 1200 ) or J.IsPushing( bot ) or J.IsDefending( bot )
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )

		if #tableNearbyEnemyHeroes >= 1 then
			local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nCastRange + 200, false, BOT_MODE_NONE )
			local highesAD = 0
			local highesADUnit = nil

			for _, npcAlly in pairs( tableNearbyAllyHeroes )
			do
				local AllyAD = npcAlly:GetAttackDamage()
				if ( J.IsValid( npcAlly )
					and npcAlly:GetAttackTarget() ~= nil
					and J.CanCastOnNonMagicImmune( npcAlly )
					and ( J.GetHP( npcAlly ) > 0.18 or J.GetHP( npcAlly:GetAttackTarget() ) < 0.18 )
					and not npcAlly:HasModifier( 'modifier_bloodseeker_bloodrage' )
					and AllyAD > highesAD )
				then
					highesAD = AllyAD
					highesADUnit = npcAlly
				end
			end

			if highesADUnit ~= nil then
				return BOT_ACTION_DESIRE_HIGH, highesADUnit
			end

		end

	end

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, 600 )
		then
			if not bot:HasModifier( 'modifier_bloodseeker_bloodrage' )
			then
				return BOT_ACTION_DESIRE_HIGH, bot
			end
		end
	end
	
	--打野时加速
	if J.IsValid( npcTarget ) and npcTarget:GetTeam() == TEAM_NEUTRAL
		and not bot:HasModifier( 'modifier_bloodseeker_bloodrage' )
	then
		local tableNearbyCreeps = bot:GetNearbyCreeps( 1000, true )
		for _, ECreep in pairs( tableNearbyCreeps )
		do
			if J.IsValid( ECreep ) and not J.CanKillTarget( ECreep, nDamage, DAMAGE_TYPE_PHYSICAL ) 
			then
				return BOT_ACTION_DESIRE_HIGH, bot
			end
		end
	end


	--打肉时加速
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		if not bot:HasModifier( 'modifier_bloodseeker_bloodrage' )
			and bot:GetAttackTarget() ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end


	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderW()

	if not abilityW:IsFullyCastable()  then return 0 end

	local nRadius = 600
	local nCastRange = abilityW:GetCastRange()
	local nCastPoint = abilityW:GetCastPoint()
	local nDelay = abilityW:GetSpecialValueFloat( 'delay' )
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetSpecialValueInt( 'damage' )

	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 800, false, BOT_MODE_NONE )

	for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if J.IsValid( npcEnemy ) and J.CanCastOnNonMagicImmune( npcEnemy ) and J.CanKillTarget( npcEnemy, nDamage, DAMAGE_TYPE_PURE )
		then
			if npcEnemy:GetMovementDirectionStability() >= 0.75 then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation( nDelay )
			else
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
			end
		end
	end

	--对线期补兵
	if bot:GetActiveMode() == BOT_MODE_LANING and J.IsAllowedToSpam( bot, nManaCost )
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage )
		if ( locationAoE.count >= 4 )
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	--推进带线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) ) and J.IsAllowedToSpam( bot, nManaCost )
		and tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0
		and #tableNearbyAllyHeroes <= 2
	then
		local lanecreeps = bot:GetNearbyLaneCreeps( 1000, true )
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage )
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 )
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid( npcEnemy ) and bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		end
	end

	--团战
	if J.IsInTeamFight( bot, 1200 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 200, nRadius/2, nCastPoint, 0 )
		if ( locationAoE.count >= 2 )
		then
			local nInvUnit = J.GetInvUnitInLocCount( bot, nCastRange, nRadius/2, locationAoE.targetloc, false )
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + nRadius )
		then
			local nCastLoc = J.GetDelayCastLocation( bot, npcTarget, nCastRange, nRadius, 2.0 )
			if nCastLoc ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nCastLoc
			end
		end
	end

	--特殊用法
	local skThere, skLoc = J.IsSandKingThere( bot, nCastRange, 2.0 )
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc
	end

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then 	return 0 end

	local nCastRange = abilityR:GetCastRange()
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()

	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE )

	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_bloodseeker_bloodrage' )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy
			end
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and J.Role.IsCarry( npcEnemy:GetUnitName() )
				and not npcEnemy:HasModifier( 'modifier_bloodseeker_bloodrage' )
				and not J.IsDisabled( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.CanCastOnTargetAdvanced( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 100 )
			and not npcTarget:HasModifier( 'modifier_bloodseeker_bloodrage' )
			and not J.IsDisabled( npcTarget )
		then
			local allies = npcTarget:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
			if ( allies ~= nil and #allies >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end


return X
-- dota2jmz@163.com QQ:2462331592.
