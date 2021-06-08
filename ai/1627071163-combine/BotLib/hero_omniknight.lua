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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,1,2,2,2,6,3,3,3,6},
						{1,2,2,1,1,6,1,2,2,3,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_bristleback_outfit",
	"item_soul_ring",
	"item_echo_sabre",
	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_lotus_orb",
	"item_black_king_bar",
	"item_travel_boots",
	"item_abyssal_blade",
	"item_heart",
	"item_moon_shard",
	"item_travel_boots_2",
	"item_ultimate_scepter_2",
	"item_sheepstick",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = {
	
	"item_tank_outfit",
	"item_echo_sabre",
	"item_aghanims_shard",
	"item_crimson_guard",
	"item_ultimate_scepter",
	"item_heavens_halberd",
	"item_travel_boots",
	"item_assault",
	"item_refresher",
	"item_moon_shard",
	"item_travel_boots_2",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	

}

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_power_treads",
	"item_quelling_blade",

	"item_black_king_bar",
	"item_magic_wand",
	
	"item_ultimate_scepter",
	"item_echo_sabre",

	"item_travel_boots",
	"item_magic_wand",

	"item_assault",
	"item_ancient_janggo",

}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

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

npc_dota_hero_omniknight

"Ability1"		"omniknight_purification"
"Ability2"		"omniknight_repel"
"Ability3"		"omniknight_degen_aura"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"omniknight_guardian_angel"
"Ability10"		"special_bonus_unique_omniknight_5"
"Ability11"		"special_bonus_movement_speed_20"
"Ability12"		"special_bonus_unique_omniknight_6"
"Ability13"		"special_bonus_attack_damage_70"
"Ability14"		"special_bonus_unique_omniknight_2"
"Ability15"		"special_bonus_mp_regen_3"
"Ability16"		"special_bonus_unique_omniknight_1"
"Ability17"		"special_bonus_unique_omniknight_3"

modifier_omniknight_pacify
modifier_omniknight_repel
modifier_omniknight_degen_aura
modifier_omniknight_degen_aura_effect


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )
local talent7 = bot:GetAbilityByName( sTalentList[7] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget
local castASDesire, castASTarget

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

	
	castRDesire, castRTarget, sMotive = X.ConsiderR()
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

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if castWDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end

	castASDesire, castASTarget, sMotive = X.ConsiderAS()
	if castASDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		bot:Action_ClearActions( false )

		bot:Action_UseAbilityOnEntity( abilityAS, castASTarget )
		return
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nRadius = abilityQ:GetSpecialValueInt( 'radius' )
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( 'heal' )
	
	if talent7:IsTrained() then nDamage = nDamage + talent7:GetSpecialValueInt( 'value' ) end
	
	local nDamageType = DAMAGE_TYPE_PURE
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + nRadius )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 + nRadius )
	
	local nInRangeAllyHeroList = bot:GetNearbyHeroes( nCastRange + 350, false, BOT_MODE_NONE )
	local nInRangeAllyCreepList = bot:GetNearbyCreeps( nCastRange + 200, false )
	
	local hCastTarget = nil
	local sCastMotive = nil

	
	--击杀低血量敌人
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do 
		if J.IsValid( npcEnemy )
			and J.CanCastOnMagicImmune( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage , nDamageType )
		then
			local bestTarget = nil
			local bestTargetHP = 9
			
			--优先通过治疗队友来击杀
			for _, npcAlly in pairs( nInRangeAllyHeroList )
			do 
				if J.IsInRange( npcAlly, npcEnemy, nRadius )
					and J.GetHP( npcAlly ) < bestTargetHP
				then
					bestTarget = npcAlly
					bestTargetHP = J.GetHP( npcAlly )				
				end
			end		
			if bestTarget ~= nil
			then		
				hCastTarget = bestTarget
				sCastMotive = 'Q-击杀1'..J.Chat.GetNormName( npcEnemy )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
			
			--通过治疗小兵击杀敌人
			for _, creep in pairs( nInRangeAllyCreepList )
			do 
				if J.IsInRange( creep, npcEnemy, nRadius )
					and J.GetHP( creep ) < bestTargetHP
				then
					bestTarget = creep
					bestTargetHP = J.GetHP( creep )				
				end
			end		
			if bestTarget ~= nil
			then		
				hCastTarget = bestTarget
				sCastMotive = 'Q-击杀2'..J.Chat.GetNormName( npcEnemy )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end			
		end
	end
	
	
	--攻击和撤退
	if J.IsGoingOnSomeone( bot ) 
		or J.IsRetreating( bot ) 
	then
		
		local bestTarget = nil
		local bestAoeCount = 0
	
		for _, npcAlly in pairs( hAllyList )
		do 
			if J.IsInRange( bot, npcAlly, nCastRange )
				and npcAlly:GetMaxHealth() - npcAlly:GetHealth() > nDamage + 50
			then
				local nearbyEnemyList = npcAlly:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
				if #nearbyEnemyList > bestAoeCount
				then
					bestAoeCount = #nearbyEnemyList 
					bestTarget = npcAlly
				end		
			end
		end
		
		if bestTarget ~= nil
		then
			local nearbyEnemyList = bestTarget:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE)
			for _, npcEnemy in pairs( nearbyEnemyList )
			do 
				if J.CanCastOnMagicImmune( npcEnemy )
				then
					hCastTarget = bestTarget
					sCastMotive = 'Q-AOE:'..J.Chat.GetNormName( bestTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
		
		
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nRadius )
			and J.CanCastOnMagicImmune( botTarget )
			and	bot:GetMaxHealth() - bot:GetHealth() > nDamage
		then
			hCastTarget = bot
			sCastMotive = 'Q-攻击时奶自己'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	
	--奶队友
	for i = 1, 5
	do 
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and not npcAlly:HasModifier( 'modifier_fountain_aura' )
			and J.IsInRange( bot, npcAlly, nCastRange )
			and ( J.GetHP( npcAlly ) < 0.15 
					or ( J.GetHP( npcAlly ) < 0.3 and npcAlly:WasRecentlyDamagedByAnyHero( 3.0 ) ) )
		then
			hCastTarget = npcAlly
			sCastMotive = 'Q-奶队友:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive		
		end	
	end
	
	
	--对线
	if J.IsLaning( bot )
	then
		for _, npcAlly in pairs( nInRangeAllyHeroList )
		do 
			if npcAlly:GetMaxHealth() - npcAlly:GetHealth() > nDamage * 1.2
			then
				local nearbyEnemyList = npcAlly:GetNearbyHeroes( nRadius - 20, true, BOT_MODE_NONE )
				if J.IsValidHero( nearbyEnemyList[1] )
					and J.CanCastOnMagicImmune(  nearbyEnemyList[1]  )
				then
					hCastTarget = npcAlly
					sCastMotive = 'Q-对线治疗'..J.Chat.GetNormName( npcAlly )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end
	
	
	--推线
	local enemyLaneCreepList = bot:GetNearbyLaneCreeps( 1600, true )
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and #hAllyList <= 3 and #enemyLaneCreepList >= 3
	then
		--以自己为Aoe中心
		local laneCreepList = bot:GetNearbyLaneCreeps( nRadius , true )
		if ( #laneCreepList >= 4 or ( #laneCreepList >= 3 and nMP > 0.82 ) )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then			
			hCastTarget = bot
			sCastMotive = 'Q-带线AOE'..(#laneCreepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
		
		--以小兵为中心
		if enemyLaneCreepList[1] ~= nil 
			and not enemyLaneCreepList[1]:HasModifier('modifier_fountain_glyph')
		then
		
			local bestTarget = nil
			local bestAoeCount = 0
			
			for _, creep in pairs( nInRangeAllyCreepList )
			do 	
				local creepCount = 0
				for i = 1, #enemyLaneCreepList
				do 
					if enemyLaneCreepList[i]:GetHealth() < nDamage
					then
						creepCount = creepCount + 1
					end
				end
				
				if creepCount > bestAoeCount
				then
					bestTarget = creep
					bestAoeCount = creepCount
				end
				
			end
			
			if bestTarget ~= nil and bestAoeCount >= 3 
			then
				hCastTarget = bestTarget
				sCastMotive = 'Q-清兵AOE'..(bestAoeCount)
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive			
			end
		end
	end
	
	
	--打钱
	if J.IsFarming( bot )
		and J.IsAllowedToSpam( bot, nManaCost )
		and ( bot:GetMaxHealth() - bot:GetHealth() > nDamage or nMP > 0.85 )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nRadius - 20 )

		if ( #creepList >= 3 or ( #creepList >= 2 and nMP > 0.88 ) )
		then
			hCastTarget = bot
			sCastMotive = 'E-打野AOE'..(#creepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
	    end	
	end

	
	--肉山
	if J.IsDoingRoshan( bot ) and bot:GetMana() > 660
	then
		for _, npcAlly in pairs( hAllyList )
		do 
			if npcAlly:GetMaxHealth() - npcAlly:GetHealth() > nDamage
			then
				local allyTarget = npcAlly:GetAttackTarget()
				if J.IsRoshan( allyTarget )
					and J.IsInRange( npcAlly, allyTarget, nRadius )
				then
					hCastTarget = npcAlly
					sCastMotive = 'Q-肉山'..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
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
	local nDamage = 0
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nDuration = abilityW:GetSpecialValueInt( "duration" )
	local nHealHealth = abilityW:GetSpecialValueInt( "hp_regen" ) * nDuration
--	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
--	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil

	for _, npcAlly in pairs( hAllyList )
	do 
		if J.IsValidHero( npcAlly )
			and J.IsInRange( bot, npcAlly, nCastRange + 300 )
			and not npcAlly:HasModifier( 'modifier_omniknight_repel' )
			and not npcAlly:IsMagicImmune()
			and not npcAlly:IsInvulnerable()
			and not npcAlly:IsIllusion()
		then
		
		
			--为加状态抗性
			if not npcAlly:IsBot()
				and npcAlly:GetLevel() >= 6
				and npcAlly:GetAttackTarget() ~= nil
				and npcAlly:GetAttackTarget():IsHero()
				and npcAlly:GetMaxHealth() - npcAlly:GetHealth() >= nHealHealth * 0.8
			then
				hCastTarget = npcAlly
				sCastMotive = 'W-加状态抗性:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive	
			end
		
			--为被控制队友解状态
			if J.IsDisabled( npcAlly )
			then
				hCastTarget = npcAlly
				sCastMotive = 'W-解状态:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive			
			end

			--为撤退中的队友加血
			if J.IsRetreating( npcAlly )
				and not npcAlly:HasModifier( 'modifier_fountain_aura' )
				and npcAlly:GetMaxHealth() - npcAlly:GetHealth() >= nHealHealth * 0.7
				and npcAlly:WasRecentlyDamagedByAnyHero( 3.0 )
			then
				hCastTarget = npcAlly
				sCastMotive = 'W-加撤退中的队友:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
			
			
			--为准备打架的力量队友辅助
			if J.IsGoingOnSomeone( npcAlly )
				and npcAlly:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH
			then
				local allyTarget = J.GetProperTarget( npcAlly )
				if J.IsValidHero( allyTarget )
					and npcAlly:IsFacingLocation( allyTarget:GetLocation(), 20 )
					and J.IsInRange( npcAlly, allyTarget, npcAlly:GetAttackRange() + 60 )
				then
					hCastTarget = npcAlly
					sCastMotive = 'W-进攻辅助力量队友:'..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
			
			--为残血队友buff
			if J.GetHP( npcAlly ) < 0.5
				and ( npcAlly:WasRecentlyDamagedByAnyHero( 5.0 ) or J.GetHP( npcAlly ) < 0.25 ) 
				and not npcAlly:HasModifier( 'modifier_fountain_aura' )
			then
				hCastTarget = npcAlly
				sCastMotive = 'W-为队友回血:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive			
			end			
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


local lastAutoTime = -90
function X.ConsiderAS()


	if not abilityAS:IsTrained()
		or not abilityAS:IsFullyCastable() 
		or bot:IsDisarmed()
	then return 0 end
	


	if ( hEnemyList[1] ~= nil or nMP > 0.7 )
		and not abilityAS:GetAutoCastState()
	then
		lastAutoTime = DotaTime()
		abilityAS:ToggleAutoCast()
	else
		if ( hEnemyList[1] == nil and nMP < 0.7 )
			and lastAutoTime + 2.0 < DotaTime()
			and abilityAS:GetAutoCastState()
		then
			abilityAS:ToggleAutoCast()
		end
	end
	
	if J.IsFarming( bot )
		and nMP > 0.6
		and not abilityAS:GetAutoCastState()
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, 1000 )
			and botTarget:GetHealth() > bot:GetAttackDamage() * 2.5
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "AS-打野"
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nRadius = abilityR:GetSpecialValueInt( 'radius' )	
	local nCastRange = nRadius
	
	if bot:HasScepter() then nCastRange = 1600 end
	
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = 0
	local nDamageType = DAMAGE_TYPE_MAGICAL
--	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
--	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil

	
	if J.IsGoingOnSomeone( bot ) 
		and nHP < ( #hEnemyList >= 3 and 0.65 or 0.45 )
		and bot:WasRecentlyDamagedByAnyHero( 4.0 )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, 500 )
			and J.CanCastOnMagicImmune( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
			and botTarget:GetAttackTarget() ~= nil
		then
			hCastTarget = bot
			sCastMotive = 'R-辅助攻击:'..J.Chat.GetNormName( botTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive					
		end
	end
	
	
	
	for i = 1, 5
	do 
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and ( bot:HasScepter() or J.IsInRange( bot, npcAlly, 700 ) )
		then
		
			--团战时辅助进攻
			if J.IsInTeamFight( npcAlly, 1300 )
			then
				local allyList = J.GetAlliesNearLoc( npcAlly:GetLocation(), nCastRange )
				local enemyList = npcAlly:GetNearbyHeroes( 1400, true, BOT_MODE_NONE )
				if #enemyList >= 2 
					and ( #enemyList >= #allyList or #enemyList >= 3 )
				then
					local guardianCount = 0
					for _, allyHero in pairs(allyList)
					do 
						if allyHero:WasRecentlyDamagedByAnyHero(3.0)
							and J.GetHP( allyHero ) < 0.8
						then
						
							guardianCount = guardianCount + 1
							
							if J.GetHP( allyHero ) < 0.4 then guardianCount = guardianCount + 1 end
						
						end
					end
					
					if guardianCount >= 2
					then
						hCastTarget = npcAlly
						sCastMotive = 'R-攻击时辅助防御:'..J.Chat.GetNormName( hCastTarget )
						return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive	
					end
				end
			end
					
			
			--逃跑时辅助攻击
			if J.IsRetreating( npcAlly )
				and npcAlly:WasRecentlyDamagedByAnyHero( 5.0 )
			then
				local attackModeAlly = npcAlly:GetNearbyHeroes( nRadius, false, BOT_MODE_ATTACK )
				local retreatModeAlly = npcAlly:GetNearbyHeroes( nRadius, false, BOT_MODE_RETREAT )
				if ( #attackModeAlly >= 2 or ( #attackModeAlly >= 1 and #retreatModeAlly >= 2 ) )
				then
					hCastTarget = npcAlly
					sCastMotive = 'R-逃跑时辅助攻击:'..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive	
				end
			end		
			
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592

