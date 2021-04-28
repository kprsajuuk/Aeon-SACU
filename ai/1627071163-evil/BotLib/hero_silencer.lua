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
						{1,2,1,3,1,6,1,3,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_crystal_maiden_outfit",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_force_staff",
	"item_rod_of_atos",
	"item_hurricane_pike",
	"item_sheepstick",
	"item_gungir",
	"item_bloodthorn",
	"item_moon_shard",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = {

	"item_priest_outfit",
	"item_urn_of_shadows",
	"item_mekansm",
	"item_glimmer_cape",
	"item_aghanims_shard",
	"item_guardian_greaves",
	"item_spirit_vessel",
	"item_vladmir",
	"item_shivas_guard",
	"item_sheepstick",
	"item_moon_shard",

}

tOutFitList['outfit_mage'] = {

	"item_mage_outfit",
	"item_glimmer_cape",
	"item_pipe",
	"item_aghanims_shard",
	"item_veil_of_discord",
	"item_cyclone",
	"item_sheepstick",
	"item_wind_waker",
	"item_moon_shard",

}

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
	"item_shivas_guard",
	"item_magic_wand",

	"item_sheepstick",
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

npc_dota_hero_silencer

"Ability1"		"silencer_curse_of_the_silent"
"Ability2"		"silencer_glaives_of_wisdom"
"Ability3"		"silencer_last_word"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"silencer_global_silence"
"Ability10"		"special_bonus_armor_6"
"Ability11"		"special_bonus_attack_speed_25"
"Ability12"		"special_bonus_gold_income_20"
"Ability13"		"special_bonus_unique_silencer_2"
"Ability14"		"special_bonus_attack_range_125"
"Ability15"		"special_bonus_unique_silencer"
"Ability16"		"special_bonus_unique_silencer_3"
"Ability17"		"special_bonus_unique_silencer_4"

modifier_silencer_int_steal
modifier_silencer_curse_of_the_silent
modifier_silencer_glaives_of_wisdom
modifier_silencer_last_word
modifier_silencer_last_word_disarm
modifier_silencer_global_silence

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQLocation = 0
local castWDesire, castWTarget = 0
local castEDesire, castETarget = 0
local castRDesire = 0

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList
local aetherRange = 0


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 300
	aetherRange = 0
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	nLV = bot:GetLevel()
	hEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )

	--计算天赋可能带来的变化
	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end


	castRDesire			 = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityR )
		return

	end

	castQDesire, castQLocation = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return
	end

	castEDesire, castETarget = X.ConsiderE()
	if ( castEDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		-- bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		if bot:HasScepter()
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityE, castETarget:GetLocation() )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		end

		return
	end

	castWDesire, castWTarget = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end


end

function X.ConsiderQ()

	if ( not abilityQ:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = abilityQ:GetSpecialValueInt( 'radius' )
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( "duration" ) * abilityQ:GetSpecialValueInt( "damage" )
	local nSkillLV = abilityQ:GetLevel()							 

	local nEnemysHeroesInRange = bot:GetNearbyHeroes( nCastRange + nRadius, true, BOT_MODE_NONE )
	local nEnemysHeroesInBonus = bot:GetNearbyHeroes( nCastRange + nRadius + 80, true, BOT_MODE_NONE )
	local nEnemysHeroesInView = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	local nWeakestEnemyHeroInRange, nWeakestEnemyHeroInRangeHealth = X.sil_GetWeakestUnit( nEnemysHeroesInRange )
	local nWeakestEnemyHeroInBonus, nWeakestEnemyHeroInBonusHealth = X.sil_GetWeakestUnit( nEnemysHeroesInBonus )

	local nEnemysLaneCreepsInRange = bot:GetNearbyLaneCreeps( nCastRange + nRadius, true )
	local nEnemysLaneCreepsInBonus = bot:GetNearbyLaneCreeps( nCastRange + nRadius + 80, true )
	local nEnemysWeakestLaneCreepsInRange, nEnemysWeakestLaneCreepsInRangeHealth = X.sil_GetWeakestUnit( nEnemysLaneCreepsInRange )
	local nEnemysWeakestLaneCreepsInBonus, nEnemysWeakestLaneCreepsInBonusHealth = X.sil_GetWeakestUnit( nEnemysLaneCreepsInBonus )

	local nTowers = bot:GetNearbyTowers( 1000, true )

	local nCanKillHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0, 0.7 * nDamage )
	local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0, 0 )
	local nCanKillCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage )
	local nCanHurtCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )


	if nCanHurtCreepsLocationAoE == nil
		or J.GetInLocLaneCreepCount( bot, 1600, nRadius, nCanHurtCreepsLocationAoE.targetloc ) <= 2
	then
		 nCanHurtCreepsLocationAoE.count = 0
	end


	if nCanKillHeroLocationAoE.count ~= nil
		and nCanKillHeroLocationAoE.count >= 1
	then
		if J.IsValidHero( nWeakestEnemyHeroInBonus )
			and J.CanCastOnNonMagicImmune( nWeakestEnemyHeroInBonus )
		then
			local nTargetLocation = J.GetCastLocation( bot, nWeakestEnemyHeroInBonus, nCastRange, nRadius )
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end
		end
	end


	if bot:GetActiveMode() == BOT_MODE_LANING
		and nHP >= 0.4
	then
		if nCanHurtHeroLocationAoE.count >= 2
			and J.IsValidHero( nWeakestEnemyHeroInBonus )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc
		end
	end


	if bot:GetActiveMode() == BOT_MODE_RETREAT
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 300, nRadius, 0.8, 0 )
		if nCanHurtHeroLocationAoENearby.count >= 1
			and J.IsValidHero( nWeakestEnemyHeroInBonus )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc
		end
	end


	if J.IsGoingOnSomeone( bot )
	then

		if nCanHurtHeroLocationAoE.count >= 2
			and GetUnitToLocationDistance( bot, nCanHurtHeroLocationAoE.targetloc ) <= nCastRange
			and J.IsValidHero( nWeakestEnemyHeroInBonus )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc
		end

		local npcEnemy = J.GetProperTarget( bot )
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
		then

			if nMP > 0.8
				or bot:GetMana() > nKeepMana * 2
			then
				local nTargetLocation = J.GetCastLocation( bot, npcEnemy, nCastRange, nRadius )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation
				end
			end

			if ( npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.4 )
				and GetUnitToUnitDistance( npcEnemy, bot ) <= nRadius + nCastRange
			then
				local nTargetLocation = J.GetCastLocation( bot, npcEnemy, nCastRange, nRadius )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation
				end
			end

		end

		npcEnemy = nWeakestEnemyHeroInRange
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.4 )
			and GetUnitToUnitDistance( npcEnemy, bot ) <= nRadius + nCastRange
		then
			local nTargetLocation = J.GetCastLocation( bot, npcEnemy, nCastRange, nRadius )
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end
		end

		if nCanHurtCreepsLocationAoE.count >= 5
			and nEnemysWeakestLaneCreepsInBonus ~= nil
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
			and DotaTime() >= 10 * 60
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc
		end

		if nCanKillCreepsLocationAoE.count >= 3
			and ( nEnemysWeakestLaneCreepsInRange ~= nil or nLV == 25 )
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
			and DotaTime() >= 10 * 60
		then
			return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc
		end
	end


	if bot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		if J.IsValidHero( nWeakestEnemyHeroInBonus )
		then

			if nCanHurtHeroLocationAoE.count >= 3
				and GetUnitToLocationDistance( bot, nCanHurtHeroLocationAoE.targetloc ) <= nCastRange
			then
				return BOT_ACTION_DESIRE_VERYHIGH, nCanHurtHeroLocationAoE.targetloc
			end

			if nCanHurtHeroLocationAoE.count >= 2
				and GetUnitToLocationDistance( bot, nCanHurtHeroLocationAoE.targetloc ) <= nCastRange
				and bot:GetMana() > nKeepMana
			then
				return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc
			end

			if J.IsValidHero( nWeakestEnemyHeroInBonus )
			then
				if nMP > 0.8
					or bot:GetMana() > nKeepMana * 2
				then
					local nTargetLocation = J.GetCastLocation( bot, nWeakestEnemyHeroInBonus, nCastRange, nRadius )
					if nTargetLocation ~= nil
					then
						return BOT_ACTION_DESIRE_HIGH, nTargetLocation
					end
				end

				if ( nWeakestEnemyHeroInBonus:GetHealth()/nWeakestEnemyHeroInBonus:GetMaxHealth() <= 0.4 )
					and GetUnitToUnitDistance( nWeakestEnemyHeroInBonus, bot ) <= nRadius + nCastRange
				then
					local nTargetLocation = J.GetCastLocation( bot, nWeakestEnemyHeroInBonus, nCastRange, nRadius )
					if nTargetLocation ~= nil
					then
						return BOT_ACTION_DESIRE_HIGH, nTargetLocation
					end
				end
			end
		end
	end


	if bot:GetActiveMode() == BOT_MODE_FARM
		and nSkillLV >= 3
	then

		if nCanKillCreepsLocationAoE.count >= 3
			and nEnemysWeakestLaneCreepsInRange ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc
		end

		if nCanHurtCreepsLocationAoE.count >= 5
			and nEnemysWeakestLaneCreepsInRange ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc
		end

	end


	if ( bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT )
		and nSkillLV >= 3
		and DotaTime() >= 10 * 60
	then

		if nCanHurtCreepsLocationAoE.count >= 5
			and nEnemysWeakestLaneCreepsInRange ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc
		end

		if nCanKillCreepsLocationAoE.count >= 3
			and nEnemysWeakestLaneCreepsInRange ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc
		end
	end


	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
		and bot:GetMana() >= 600
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsRoshan( npcTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
		end
	end


	if #nEnemysHeroesInView == 0
		and DotaTime() > 9 * 60
		and bot:GetActiveMode() ~= BOT_MODE_ATTACK
		and nSkillLV > 2
	then

		if nCanKillCreepsLocationAoE.count >= 3
			and ( nEnemysWeakestLaneCreepsInBonus ~= nil or nLV >= 20 )
		then
			return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc
		end

		if nCanHurtCreepsLocationAoE.count >= 5
			and nEnemysWeakestLaneCreepsInBonus ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc
		end

	end

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() or bot:IsDisarmed() then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nAttackRange = bot:GetAttackRange() + 50
	local nAttackDamage = bot:GetAttackDamage()
	local nAbilityDamage = abilityW:GetSpecialValueInt( "intellect_damage_pct" )/100 * bot:GetAttributeValue( ATTRIBUTE_INTELLECT ) * ( 1 + bot:GetSpellAmp() )
	local nCastRange = nAttackRange

	local nTowers = bot:GetNearbyTowers( 900, true )
	local nEnemysLaneCreepsInRange = bot:GetNearbyLaneCreeps( nAttackRange + 100, true )
	local nEnemysLaneCreepsInBonus = bot:GetNearbyLaneCreeps( 400, true )
	local nEnemysWeakestLaneCreepsInRange = J.GetVulnerableWeakestUnit( bot, false, true, nAttackRange + 100 )

	local nEnemysHerosInAttackRange = bot:GetNearbyHeroes( nAttackRange, true, BOT_MODE_NONE )
	local nEnemysWeakestHerosInAttackRange = J.GetVulnerableWeakestUnit( bot, true, true, nAttackRange )
	local nEnemysWeakestHero = J.GetVulnerableWeakestUnit( bot, true, true, nAttackRange + 40 )

	local nAllyLaneCreeps = bot:GetNearbyLaneCreeps( 350, false )

	local npcTarget = J.GetProperTarget( bot )

	if( bot:GetActiveMode() ~= BOT_MODE_RETREAT or bot:GetActiveModeDesire() < 0.6 )
	then
		if J.IsValidHero( nEnemysWeakestHerosInAttackRange )
		then
			if nEnemysWeakestHerosInAttackRange:GetHealth() <= X.sil_RealDamage( nAttackDamage, nAbilityDamage, nEnemysWeakestHerosInAttackRange )
			then
				return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
			end
		end
	end


	if nLV > 9
	then
		if not abilityW:GetAutoCastState()
		then
			abilityW:ToggleAutoCast()
		end
	else
		if abilityW:GetAutoCastState()
		then
			abilityW:ToggleAutoCast()
		end
	end

	if nLV <= 9 and nHP > 0.55
		and J.IsValidHero( npcTarget )
		and ( not J.IsRunning( bot ) or J.IsInRange( bot, npcTarget, nAttackRange + 29 ) )
	then
		if not npcTarget:IsAttackImmune()
			and GetUnitToUnitDistance( bot, npcTarget ) < nAttackRange + 99
		then
			nTargetUint = npcTarget
			return BOT_ACTION_DESIRE_HIGH, nTargetUint
		end
	end


	if ( bot:GetActiveMode() == BOT_MODE_LANING and #nTowers == 0 )
	then
		if J.IsValid( nEnemysWeakestHero )
		then
			if nHP >= 0.62
				and #nEnemysLaneCreepsInBonus <= 6
				and #nAllyLaneCreeps >= 2
				and not bot:WasRecentlyDamagedByCreep( 1.5 )
				and not bot:WasRecentlyDamagedByAnyHero( 1.5 )
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysWeakestHero
			end


			if J.GetAllyUnitCountAroundEnemyTarget( bot, nEnemysWeakestHero, 500 ) >= 3
				and nHP >= 0.6
				and not bot:WasRecentlyDamagedByCreep( 1.5 )
				and not bot:WasRecentlyDamagedByAnyHero( 1.5 )
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysWeakestHero
			end

		end
	end


	if J.IsValidHero( npcTarget )
		and GetUnitToUnitDistance( npcTarget, bot ) > nAttackRange + 200
		and J.IsValidHero( nEnemysHerosInAttackRange[1] )
		and J.CanBeAttacked( nEnemysHerosInAttackRange[1] )
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		return BOT_ACTION_DESIRE_HIGH, nEnemysHerosInAttackRange[1]
	end


	if npcTarget == nil
		and  bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and  bot:GetActiveMode() ~= BOT_MODE_ATTACK
		and  bot:GetActiveMode() ~= BOT_MODE_ASSEMBLE
		and  J.GetTeamFightAlliesCount( bot ) <= 2
	then

		if J.IsValid( nEnemysWeakestLaneCreepsInRange )
			and not J.IsOtherAllysTarget( nEnemysWeakestLaneCreepsInRange )
		then
			local nCreep = nEnemysWeakestLaneCreepsInRange
			local nAttackProDelayTime = J.GetAttackProDelayTime( bot, nCreep )

			local otherAttackRealDamage = J.GetTotalAttackWillRealDamage( nCreep, nAttackProDelayTime )
			local silRealDamage = X.sil_RealDamage( nAttackDamage, nAbilityDamage, nCreep )

			if otherAttackRealDamage + silRealDamage > nCreep:GetHealth() + 1
				and not J.CanKillTarget( nCreep, nAttackDamage, DAMAGE_TYPE_PHYSICAL )
			then
				--[[
				local nTime = nAttackProDelayTime
				local rMessage = "生命:"..tostring( nCreep:GetHealth() ).."增益:"..tostring( J.GetOne( nAbilityDamage ) ).."额外:"..tostring( J.GetOne( otherAttackRealDamage ) ).."总共:"
				rMessage = rMessage..tostring( otherAttackRealDamage + silRealDamage )
				J.SetBotPrint( rMessage, nCreep:GetLocation(), true, true )
				--]]
				return BOT_ACTION_DESIRE_HIGH, nCreep
			end

		end

		if ( bot:HasScepter() or nAttackDamage > 160 )
			and #hEnemyHeroList == 0
		then
			local nEnemysCreeps = bot:GetNearbyCreeps( 800, true )
			if J.IsValid( nEnemysCreeps[1] )
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysCreeps[1]
			end
		end


		local nNeutrals = bot:GetNearbyNeutralCreeps( 800 )
		if DotaTime()%60>52 and DotaTime()%60 < 54.5
			and  J.IsValid( nNeutrals[1] )
			and not nNeutrals[1]:WasRecentlyDamagedByAnyHero( 3.0 )
		then
			return BOT_ACTION_DESIRE_HIGH, nNeutrals[1]
		end


		local nNeutralCreeps = bot:GetNearbyNeutralCreeps( 1600 )
		local botMode = bot:GetActiveMode()
		if botMode ~= BOT_MODE_LANING
			and botMode ~= BOT_MODE_FARM
			and botMode ~= BOT_MODE_RUNE
			and botMode ~= BOT_MODE_ASSEMBLE
			and botMode ~= BOT_MODE_SECRET_SHOP
			and botMode ~= BOT_MODE_SIDE_SHOP
			and botMode ~= BOT_MODE_WARD
			and GetRoshanDesire() < BOT_MODE_DESIRE_HIGH
			and not bot:WasRecentlyDamagedByAnyHero( 2.0 )
			and #hEnemyHeroList == 0
			and nAttackDamage > 140
			and J.IsValid( nNeutralCreeps[1] )
			and not J.IsRoshan( nNeutralCreeps[1] )
			and ( not nNeutralCreeps[1]:IsAncientCreep() or nAttackDamage > 180 )
		then
			nTargetUint = nNeutralCreeps[1]
			return BOT_ACTION_DESIRE_HIGH, nTargetUint
		end

	end

	if J.IsGoingOnSomeone( bot ) and not abilityW:GetAutoCastState()
	then
		if J.IsValidHero( npcTarget )
			and not npcTarget:IsAttackImmune()
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, nAttackRange + 80 )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget
		end
	end


	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and not abilityW:GetAutoCastState() )
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsRoshan( npcTarget )
			and J.IsInRange( npcTarget, bot, nAttackRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil

end

function X.ConsiderE()

	if ( not abilityE:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE, 0
	end


	local nCastRange = abilityE:GetCastRange() + aetherRange
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nSkillLV = abilityE:GetLevel()
	local nDamage = nSkillLV * 75 * ( 1 + bot:GetSpellAmp() )

	local nAllies =  bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )

	local nEnemysHeroesInRange = bot:GetNearbyHeroes( nCastRange + 50, true, BOT_MODE_NONE )
	local nEnemysHeroesInBonus = bot:GetNearbyHeroes( nCastRange + 150, true, BOT_MODE_NONE )
	local nWeakestEnemyHeroInRange, nWeakestEnemyHeroInRangeHealth = X.sil_GetWeakestUnit( nEnemysHeroesInRange )
	local nWeakestEnemyHeroInBonus, nWeakestEnemyHeroInBonusHealth = X.sil_GetWeakestUnit( nEnemysHeroesInBonus )

	local nTowers = bot:GetNearbyTowers( 900, true )

	if J.IsValid( nWeakestEnemyHeroInRange )
	then
		if nWeakestEnemyHeroInRangeHealth <= nWeakestEnemyHeroInRange:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL )
		then
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange
		end
	end
	if J.IsValid( nWeakestEnemyHeroInBonus )
	then
		if nWeakestEnemyHeroInBonusHealth <= nWeakestEnemyHeroInBonus:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL )
			and nWeakestEnemyHeroInBonus:GetCurrentMovementSpeed() < bot:GetCurrentMovementSpeed() * 0.8
		then
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInBonus
		end
	end


	if J.IsInTeamFight( bot, 1200 )
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL )
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage
					npcMostDangerousEnemy = npcEnemy
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy
		end

	end


	if bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and nEnemysHeroesInRange[1] ~= nil
		and #nEnemysHeroesInRange >= 1
	then
		for _, npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsIllusion()
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 30 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end


	if ( bot:GetActiveMode() == BOT_MODE_LANING and #nTowers == 0 ) or DotaTime() > 12 * 60
	then
		if( nMP > 0.7 or bot:GetMana()> nKeepMana * ( 3 - nSkillLV ) )
		then
			if J.IsValid( nWeakestEnemyHeroInRange )
			then
				if not J.IsDisabled( nWeakestEnemyHeroInRange )
				then
					return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange
				end
			end
		end

		if( nMP > 0.88 or bot:GetMana()> nKeepMana * 3 )
		then
			local nEnemysCreeps = bot:GetNearbyCreeps( 1400, true )
			if J.IsValidHero( nWeakestEnemyHeroInBonus )
				and nHP > 0.6
				and #nTowers == 0
				and ( ( #nEnemysCreeps + #nEnemysHeroesInBonus ) <= 5 or DotaTime() > 12 * 60 )
			then
				if not J.IsDisabled( nWeakestEnemyHeroInBonus )
				then
					return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInBonus
				end
			end
		end

		if J.IsValid( nWeakestEnemyHeroInRange )
		then
			if nWeakestEnemyHeroInRange:GetHealth()/nWeakestEnemyHeroInRange:GetMaxHealth() < 0.4
			then
				return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange
			end
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.CanCastOnTargetAdvanced( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 150 )
			and not J.IsDisabled( npcTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end


	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.1 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and J.IsInRange( npcEnemy, bot, nCastRange )
				and ( not J.IsInRange( npcEnemy, bot, 450 ) or bot:IsFacingLocation( npcEnemy:GetLocation(), 45 ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end


	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 600
		and abilityE:GetLevel() >= 3
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsRoshan( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderR()


	if ( not abilityR:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE )
	local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 800, false, BOT_MODE_NONE )


	for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if J.IsValid( npcEnemy )
			and npcEnemy:IsChanneling()
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and not npcEnemy:HasModifier( "modifier_teleporting" )
			and npcEnemy:GetHealth() > 500
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating( bot )
	then
		if #tableNearbyEnemyHeroes >= 2
			and #tableNearbyAllyHeroes > 2
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	local numPlayer =  GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		then
			if J.IsInTeamFight( member, 1200 )
			then
				local locationAoE = member:FindAoELocation( true, true, member:GetLocation(), 1400, 600, 0, 0 )
				if ( locationAoE.count >= 2 ) then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = bot:GetTarget()
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, 1200 )
			and not J.IsDisabled( npcTarget )
		then
			local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, false, BOT_MODE_NONE )
			if #tableNearbyEnemyHeroes >= 2
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.sil_GetWeakestUnit( nEnemyUnits )

	local nWeakestUnit = nil
	local nWeakestUnitLowestHealth = 10000
	for _, unit in pairs( nEnemyUnits )
	do
		if 	unit:IsAlive()
			and J.CanCastOnNonMagicImmune( unit )
			and J.CanCastOnTargetAdvanced( unit )
		then
			if unit:GetHealth() < nWeakestUnitLowestHealth
			then
				nWeakestUnitLowestHealth = unit:GetHealth()
				nWeakestUnit = unit
			end
		end
	end

	return nWeakestUnit, nWeakestUnitLowestHealth
end

function X.sil_RealDamage( nAttackDamage, nAbilityDamage, unit )

	local RealDamage = unit:GetActualIncomingDamage( nAttackDamage, DAMAGE_TYPE_PHYSICAL ) + unit:GetActualIncomingDamage( nAbilityDamage, DAMAGE_TYPE_PURE )

	return RealDamage
end


return X
-- dota2jmz@163.com QQ:2462331592.
