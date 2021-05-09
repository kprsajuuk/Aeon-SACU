----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------


local X = {}
local bot = GetBot()
local bDebugMode = ( 1 == 10 )

if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() or bot:GetUnitName() == "npc_dota_hero_techies"
then return end

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local BotBuild = dofile( GetScriptDirectory().."/BotLib/"..string.gsub( bot:GetUnitName(), "npc_dota_", "" ) )

if BotBuild == nil then return end

if GetTeam() ~= TEAM_DIRE
then
	print( '&&&&&&&&&&&&&&&&&&&&&&'..J.Chat.GetNormName( bot )..': Hello, Dota2 World!' )
end

local bDeafaultAbilityHero = BotBuild['bDeafaultAbility']
local bDeafaultItemHero = BotBuild['bDeafaultItem']
local sAbilityLevelUpList = BotBuild['sSkillList']

local function AbilityLevelUpComplement()

	if GetGameState() ~= GAME_STATE_PRE_GAME
		and GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS
	then
		return
	end

	if not bot:IsAlive() and bot:NumQueuedActions() > 0
	then
		 bot:Action_ClearActions( false )
		 return
	end

	if DotaTime() < 15
	then
		bot.theRole = J.Role.GetCurrentSuitableRole( bot, bot:GetUnitName() )
	end

	local botLoc = bot:GetLocation()
	if bot:IsAlive()
		and DotaTime() > 20
		and bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO
		and not IsLocationPassable( botLoc )
	then
		if bot.stuckLoc == nil
		then
			bot.stuckLoc = botLoc
			bot.stuckTime = DotaTime()
		elseif bot.stuckLoc ~= botLoc
		then
			bot.stuckLoc = botLoc
			bot.stuckTime = DotaTime()
		end
	else
		bot.stuckTime = nil
		bot.stuckLoc = nil
	end

	if bot:GetAbilityPoints() > 0
		and #sAbilityLevelUpList >= 1
	then
		local abilityToLevelup = bot:GetAbilityByName( sAbilityLevelUpList[1] )
		if abilityToLevelup ~= nil
			and not abilityToLevelup:IsHidden() --fix kunkka bug
			and abilityToLevelup:CanAbilityBeUpgraded()
			and abilityToLevelup:GetLevel() < abilityToLevelup:GetMaxLevel()
		then
			bot:ActionImmediate_LevelAbility( sAbilityLevelUpList[1] )
			table.remove( sAbilityLevelUpList, 1 )
			return
		end
	end

end


function X.GetNumEnemyNearby( building )

	local nearbynum = 0
	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil
			then
				local dInfo = info[1]
				if dInfo ~= nil
					and GetUnitToLocationDistance( building, dInfo.location ) <= 3000
					and dInfo.time_since_seen < 1.0
				then
					nearbynum = nearbynum + 1
				end
			end
		end
	end

	return nearbynum

end

local fDeathTime = 0
function X.GetRemainingRespawnTime()

	if fDeathTime == 0
	then
		return 0
	else
		return bot:GetRespawnTime() - ( DotaTime() - fDeathTime )
	end

end

local nJiDiCount = RandomInt( 14, 20 )
local nTalkDelay = RandomFloat( 1.9, 5.6 )
local nDeathReplyTime = -999
local nLastGold = 9999
local nLastKillCount = 999
local nLastDeathCount = 0
local nContinueKillCount = 0
local nReplyHumanCount = 0
local nMaxReplyCount = RandomInt( 5, 9 )
local bInstallChatCallbackDone = false
local nReplyHumanTime = nil
local sHumanString = nil
local bAllChat = false
function X.SetTalkMessage()

	local nBotID = bot:GetPlayerID()
	local nCurrentGold = bot:GetGold()
	local nCurrentKills = GetHeroKills( nBotID )
	local nCurrentDeaths = GetHeroDeaths( nBotID )
	local nRate = GetGameMode() == 23 and 2.0 or 1.0

	--回复玩家的对话
	if nBotID == J.Role.GetReplyMemberID()
		and nReplyHumanCount <= nMaxReplyCount
	then
		if not bInstallChatCallbackDone
		then
			bInstallChatCallbackDone = true
			InstallChatCallback( function( tChat ) X.SetReplyHumanTime( tChat ) end )
		end

		if sHumanString ~= nil
			and nReplyHumanTime ~= nil
			and DotaTime() > nReplyHumanTime + nTalkDelay
		then
			local chatString = J.Chat.GetReplyString( sHumanString, bAllChat )
			if chatString ~= nil
			then
				if nReplyHumanCount == nMaxReplyCount
				then chatString = J.Chat.GetStopReplyString() end

				bot:ActionImmediate_Chat( chatString, bAllChat )

				nReplyHumanCount = nReplyHumanCount + 1
				nTalkDelay = RandomFloat( 0.6, 3.0 )
				if nTalkDelay > 2.0 then nTalkDelay = RandomFloat( 0.6, 3.0 ) end
			end
			sHumanString = nil
			nReplyHumanTime = nil
		end
	end

	--发问号
	if bot:IsAlive()
		and nCurrentGold > nLastGold + 600 * nRate
		and nCurrentKills > nLastKillCount
		and RandomInt( 1, 9 ) > 4
	then
		local sTauntMark = "?"
		if nCurrentGold > nLastGold + 800 * nRate then sTauntMark = "??" end
		if nCurrentGold > nLastGold + 1000 * nRate then sTauntMark = "???" end
		if nCurrentGold > nLastGold + 1500 * nRate then sTauntMark = "??????" end
		bot:ActionImmediate_Chat( sTauntMark, true )
	end

	--发省略号
	if not bot:IsAlive()
	then
		if nContinueKillCount >= 8
			and nDeathReplyTime == -999
		then
			nDeathReplyTime = DotaTime()
			nContinueKillCount = 0
		end

		if nDeathReplyTime ~= -999
			and nDeathReplyTime < DotaTime() - nTalkDelay
		then
			bot:ActionImmediate_Chat( "...", true )
			nDeathReplyTime = -999
			nTalkDelay = RandomFloat( 3.6, 4.9 )
		end
	end

	--发"jidi, xiayiba"
	if nCurrentKills == 0
		and nCurrentDeaths >= nJiDiCount
		and J.Role.NotSayJiDi()
	then
		local sJiDi = RandomInt( 1, 9 ) >= 3 and "jidi, xiayiba" or "jidi, gkd"
		bot:ActionImmediate_Chat( sJiDi, true )
		J.Role['sayJiDi'] = true
	end

	--计算连杀数量
	if nLastDeathCount == nCurrentDeaths
	then
		if nCurrentKills >= nLastKillCount + 1
		then
			nContinueKillCount = nContinueKillCount + 1
		end
	else
		nContinueKillCount = 0
	end

	nLastKillCount = GetHeroKills( nBotID )
	nLastDeathCount = GetHeroDeaths( nBotID )
	nLastGold = bot:GetGold()

end


function X.SetReplyHumanTime( tChat )

	local sChatString = tChat.string
	local nChatID = tChat.player_id

	if sChatString ~= "-都来守家" or J.Role.IsAllyMemberID( nChatID )
	then
		J.Role.SetLastChatString( sChatString )
	end
		
	if not IsPlayerBot( nChatID )
		and ( tChat.team_only or J.Role.IsEnemyMemberID( nChatID ) )
	then
		sHumanString = sChatString
		nReplyHumanTime = DotaTime()
		bAllChat = not tChat.team_only
	end


end


local function BuybackUsageComplement()

	X.SetTalkMessage()

	if bot:GetLevel() <= 15
		or bot:HasModifier( 'modifier_arc_warden_tempest_double' )
		or not J.Role.ShouldBuyBack()
	then
		return
	end

	if bot:IsAlive() and fDeathTime ~= 0
	then
		fDeathTime = 0
	end

	if not bot:IsAlive()
	then
		if fDeathTime == 0 then fDeathTime = DotaTime() end
	end

	if not bot:HasBuyback() then return end

	if bot:GetRespawnTime() < 60 then
		return
	end

	local nRespawnTime = X.GetRemainingRespawnTime()

	if bot:GetLevel() > 24
		and nRespawnTime > 80
	then
		local nTeamFightLocation = J.GetTeamFightLocation( bot )
		if nTeamFightLocation ~= nil
		then
			J.Role['lastbbtime'] = DotaTime()
			bot:ActionImmediate_Buyback()
			return
		end
	end

	if nRespawnTime < 50
	then
		return
	end

	local ancient = GetAncient( GetTeam() )

	if ancient ~= nil
	then
		local nEnemyCount = X.GetNumEnemyNearby( ancient )
		local nAllyCount = J.GetNumOfAliveHeroes( false )
		if nEnemyCount > 0 and nEnemyCount >= nAllyCount
		then
			J.Role['lastbbtime'] = DotaTime()
			bot:ActionImmediate_Buyback()
			return
		end
	end

end


local courierTime = -90
local cState = -1
bot.SShopUser = false
local nReturnTime = -90
local function CourierUsageComplement()

	if GetGameMode() == 23
		or DotaTime() < -56
		or bot:HasModifier( "modifier_arc_warden_tempest_double" )
		or nReturnTime + 5.0 > DotaTime()
	then
		return
	end

	if bot.theCourier == nil
	then
		bot.theCourier = X.GetBotCourier( bot )
		return
	end

	--------* * * * * * * ----------------* * * * * * * ----------------* * * * * * * --------
	local bDebugCourier = ( 1 == 10 )
	local npcCourier = bot.theCourier
	local cState = GetCourierState( npcCourier )
	local courierHP = npcCourier:GetHealth() / npcCourier:GetMaxHealth()
	local currentTime = DotaTime()
	local bAliveBot = bot:IsAlive()
	local botLV = bot:GetLevel()
	local useCourierCD = 2.3
	local protectCourierCD = 5.0
	--------* * * * * * * ----------------* * * * * * * ----------------* * * * * * * --------


	if cState == COURIER_STATE_DEAD then return	end

	if X.IsCourierTargetedByUnit( npcCourier )
	then
		if currentTime > nReturnTime + protectCourierCD
		then
			nReturnTime = currentTime

			J.SetReportMotive( bDebugCourier, "信使可能会被攻击" )

			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS )

			local abilityBurst = npcCourier:GetAbilityByName( 'courier_burst' )
			if botLV >= 10 and abilityBurst:IsFullyCastable()
			then
				bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_BURST )
			end

			return
		end
	end


	if bot.SShopUser
		and ( not bAliveBot or bot:GetActiveMode() == BOT_MODE_SECRET_SHOP or not bot.SecretShop )
	then
		bot.SShopUser = false
		J.SetReportMotive( bDebugCourier, "让信使返回基地避免被卡住" )
		bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS )
		return
	end


	if ( cState == COURIER_STATE_RETURNING_TO_BASE
		or cState == COURIER_STATE_AT_BASE
		or cState == COURIER_STATE_IDLE )
		and currentTime > nReturnTime + protectCourierCD
	then

		if cState == COURIER_STATE_AT_BASE and courierHP < 0.8 
		then return	end

		if cState == COURIER_STATE_IDLE and npcCourier:DistanceFromFountain() > 800
		then
			J.SetReportMotive( bDebugCourier, "让空闲的信使返回" )
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS )
			return
		end

		if bAliveBot
			and ( not X.IsInvFull( bot ) 
					or currentTime <= 5 * 60
					or ( bot.currListItemToBuy ~= nil and #bot.currListItemToBuy == 0 and bot.currentItemToBuy ~= 'item_travel_boots' ) )
			and ( cState == COURIER_STATE_AT_BASE
					or ( cState == COURIER_STATE_IDLE and npcCourier:DistanceFromFountain() < 800 ) )
		then
			local nMSlot = X.GetNumStashItem( bot )
			if nMSlot > 0
			then
				if ( bot.currListItemToBuy ~= nil and #bot.currListItemToBuy == 0 )
					or ( bot.currentComponentToBuy ~= nil
							and ( IsItemPurchasedFromSecretShop( bot.currentComponentToBuy )
									or X.GetNumStashItem( bot ) == 6
									or bot:GetGold() + 80 < GetItemCost( bot.currentComponentToBuy ) ) )
				then
					J.SetReportMotive( bDebugCourier, "信使取出物品并开始运输" )
					bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TAKE_STASH_ITEMS )
					courierTime = currentTime
				end
			end
		end

		if bAliveBot and bot.SecretShop
			and npcCourier:DistanceFromFountain() < 7000
			and J.Item.GetEmptyInventoryAmount( npcCourier ) >= 2
			and not X.IsEnemyHeroAroundSecretShop() -- 商店附近没有敌人
			and currentTime > courierTime + useCourierCD
		then
			J.SetReportMotive( bDebugCourier, "信使前往神秘商店购物" )
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_SECRET_SHOP )
			bot.SShopUser = true
			courierTime = currentTime
			return
		end

		if bAliveBot
			and bot:GetCourierValue() > 0
			and bot:GetStashValue() < 100
			and ( not X.IsInvFull( bot ) or ( X.GetNumStashItem( bot ) == 0 and bot.currListItemToBuy ~= nil and #bot.currListItemToBuy == 0 ) )
			and ( npcCourier:DistanceFromFountain() < 4000 + botLV * 200 or GetUnitToUnitDistance( bot, npcCourier ) < 1800 )
			and currentTime > courierTime + useCourierCD
		then
			J.SetReportMotive( bDebugCourier, "信使运输背包中的东西" )
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TRANSFER_ITEMS )
			courierTime = currentTime
			return
		end


	end

end


function X.GetBotCourier( bot )

	local nPlayerID = bot:GetPlayerID()

	for nCourierID = 0, 4
	do
		local courier = GetCourier( nCourierID )
		if courier:GetPlayerID() == nPlayerID
		then
			return courier
		end
	end

end


function X.GetNumStashItem( unit )

	local amount = 0
	for i = 9, 14
	do
		if unit:GetItemInSlot( i ) ~= nil
		then
			amount = amount + 1
		end
	end

	return amount

end


function X.IsCourierTargetedByUnit( courier )

	local botLV = bot:GetLevel()

	if J.GetHP( courier ) < 0.9
	then
		return true
	end

	if courier:DistanceFromFountain() < 900 then return false end

	for i = 0, 10
	do
		local tower = GetTower( GetOpposingTeam(), i )
		if tower ~= nil
		then
			local towerTarget = tower:GetAttackTarget()

			if towerTarget == courier
			then
				return true
			end

			if towerTarget == nil
				and GetUnitToUnitDistance( courier, tower ) < 999
			then
				return true
			end

		end
	end

	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil
			then
				local dInfo = info[1]
				if dInfo ~= nil
					and GetUnitToLocationDistance( courier, dInfo.location ) <= 800
					and dInfo.time_since_seen < 1.8
				then
					return true
				end
			end
		end
	end

	local nEnemysHeroesCanSeen = GetUnitList( UNIT_LIST_ENEMY_HEROES )
	for _, enemy in pairs( nEnemysHeroesCanSeen )
	do
		if GetUnitToUnitDistance( enemy, courier ) <= 700 + botLV * 15
		then
			local nNearCourierAllyList = J.GetAlliesNearLoc( enemy:GetLocation(), 600 )
			if #nNearCourierAllyList == 0
				or enemy:GetAttackTarget() == courier
			then
				return true
			end
		end

		if enemy:GetUnitName() == 'npc_dota_hero_sniper'
			and GetUnitToUnitDistance( enemy, courier ) <= 1100 + botLV * 30
		then
			return true
		end

		if GetUnitToUnitDistance( enemy, courier ) <= enemy:GetAttackRange() + 88
		then
			return true
		end
	end

	local nEnemysHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemysHeroes )
	do
		if GetUnitToUnitDistance( enemy, courier ) <= 700 + botLV * 15
		then
			local nNearCourierAllyList = J.GetAlliesNearLoc( enemy:GetLocation(), 800 )
			if #nNearCourierAllyList == 0
				or enemy:GetAttackTarget() == courier
			then
				return true
			end
		end

		if GetUnitToUnitDistance( enemy, courier ) <= enemy:GetAttackRange() + 100
		then
			return true
		end
	end

	local nAllEnemyCreeps = GetUnitList( UNIT_LIST_ENEMY_CREEPS )
	local nNearCourierAllyList = J.GetAlliesNearLoc( courier:GetLocation(), 1500 )
	local nNearCourierAllyCount = #nNearCourierAllyList
	for _, creep in pairs( nAllEnemyCreeps )
	do
		if GetUnitToUnitDistance( courier, creep ) <= 800
			and ( creep:GetAttackTarget() == courier or botLV > 10 )
			and ( nNearCourierAllyCount == 0 or creep:GetAttackTarget() == courier )
		then
			return true
		end
	end

	return false

end


function X.IsInvFull( bot )

	for i = 0, 8
	do
		if bot:GetItemInSlot( i ) == nil
		then
			return false
		end
	end

	return true

end


function X.IsEnemyHeroAroundSecretShop()

	local vRadiantShop = GetShopLocation( GetTeam(), SHOP_SECRET )
	local vDireShop = GetShopLocation( GetTeam(), SHOP_SECRET2 )
	local vTeamSecretShop = GetTeam() == TEAM_DIRE and vDireShop or vRadiantShop

	local vCenterLocation = ( vTeamSecretShop + GetAncient( GetTeam() ):GetLocation() ) * 0.5

	if J.IsEnemyHeroAroundLocation( vCenterLocation, 2000 )
	then
		return true
	end

	return false

end




local fLastStashItemTimeList = {}
local aetherRange = 0
local lastAmuletTime = 0
local thereBeMonkey = false
local lastSwitchPtTime = -90
local hNearbyEnemyHeroList = {}
local hNearbyEnemyTowerList = {}
local botTarget = nil
local nMode = -1
local function ItemUsageComplement()

	X.SetStashItemTimeUpdate()

	if not bot:IsAlive()
		or bot:IsMuted()
		or bot:IsHexed()
		or bot:IsStunned()
		or bot:IsChanneling()
		or bot:IsInvulnerable()
		or bot:IsUsingAbility()
		or bot:IsCastingAbility()
		or bot:NumQueuedActions() > 0
		or bot:HasModifier( 'modifier_teleporting' )
		or bot:HasModifier( 'modifier_doom_bringer_doom' )
		or bot:HasModifier( 'modifier_phantom_lancer_phantom_edge_boost' )
		or X.WillBreakInvisible( bot )
	then return	BOT_ACTION_DESIRE_NONE end

	hNearbyEnemyHeroList = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
	hNearbyEnemyTowerList = bot:GetNearbyTowers( 888, true )
	botTarget = J.GetProperTarget( bot )
	nMode = bot:GetActiveMode()

	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 else aetherRange = 0 end

	local nItemSlot = { 5, 4, 3, 2, 1, 0, 15, 16 }

	for _, nSlot in pairs( nItemSlot )
	do
		local hItem = bot:GetItemInSlot( nSlot )
		if hItem ~= nil
			and hItem:IsFullyCastable()
		then
			local sItemName = hItem:GetName()
			if	X.ConsiderItemDesire[sItemName] ~= nil
				and not X.IsItemInStash( sItemName )
			then
				local nItemDesire, hItemTarget, sCastType, sMotive = X.ConsiderItemDesire[sItemName]( hItem )

				if nItemDesire > 0
				then
					if bDebugMode
						and sMotive ~= nil
					--	and J.Item.IsDebugItem( sItemName )
						and J.Item.IsSpecifiedItem( sItemName )
					then
						local sReportItemName = J.Chat.GetItemCnName( sItemName )
						J.SetReportMotive( bDebugMode, sReportItemName..'→'..sMotive )
					end

					X.SetUseItem( hItem, hItemTarget, sCastType )

					return nSlot + 1
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.SetUseItem( hItem, hItemTarget, sCastType )

	if sCastType == 'none'
	then
		bot:Action_UseAbility( hItem )
		return
	elseif sCastType == 'unit'
	then
		bot:Action_UseAbilityOnEntity( hItem, hItemTarget )
		return
	elseif sCastType == 'ground'
	then
		bot:Action_UseAbilityOnLocation( hItem, hItemTarget )
		return
	elseif sCastType == 'tree'
	then
		bot:Action_UseAbilityOnTree( hItem, hItemTarget )
		return
	elseif sCastType == 'twice'
	then
		bot:Action_UseAbility( hItem )
		bot:ActionQueue_UseAbility( hItem )
		return
	end

end


function X.IsWithoutSpellShield( npcEnemy )

	return not npcEnemy:HasModifier( "modifier_item_sphere_target" )
			and not npcEnemy:HasModifier( "modifier_antimage_spell_shield" )
			and not npcEnemy:HasModifier( "modifier_item_lotus_orb_active" )

end


local lastDeleteTime = -90
function X.SetStashItemTimeUpdate()

	local currentTime = DotaTime()

	for i = 6, 8
	do
		local hItem = bot:GetItemInSlot( i )
		if hItem ~= nil
		then
			fLastStashItemTimeList[hItem:GetName()] = currentTime
		end
	end

	if currentTime > lastDeleteTime + 7.0
	then
		lastDeleteTime = currentTime
		for k, v in pairs( fLastStashItemTimeList )
		do
			if v ~= nil
				and v < currentTime - 7.0
			then
				fLastStashItemTimeList[k] = nil
			end
		end
	end

end


function X.IsItemInStash( sItemName )

	if fLastStashItemTimeList[sItemName] ~= nil
		and DotaTime() < fLastStashItemTimeList[sItemName] + 6.05
	then
		return true
	end

	return false

end


function X.WillBreakInvisible( bot )

	local botName = bot:GetUnitName()

	if bot:IsInvisible()
	then
		if not bot:HasModifier( "modifier_phantom_assassin_blur_active" )
			and botName ~= "npc_dota_hero_riki"
		then
			return true
		end
	end

	return false

end


X.ConsiderItemDesire = {}

--深渊
X.ConsiderItemDesire["item_abyssal_blade"] = function( hItem )

	local nCastRange = 620 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil

	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	for _, npcEnemy in pairs( nInRangeEnmyList )
	do

		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and X.IsWithoutSpellShield( npcEnemy )
		then
			--打断
			if npcEnemy:IsChanneling() or npcEnemy:IsCastingAbility()
			then
				hEffectTarget = npcEnemy
				sCastMotive = "打断:"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			--撤退
			if 	nMode == BOT_MODE_RETREAT
				and not J.IsDisabled( npcEnemy )
			then
				hEffectTarget = npcEnemy
				sCastMotive = "撤退:"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

	end

	--进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 50 )
			and J.CanCastOnNonMagicImmune( botTarget ) --bug
			and X.IsWithoutSpellShield( botTarget )
			and not J.IsDisabled( botTarget )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--战鼓
X.ConsiderItemDesire["item_ancient_janggo"] = function( hItem )

	if hItem:GetCurrentCharges() <= 0 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 680
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--秘法
X.ConsiderItemDesire["item_arcane_boots"] = function( hItem )

	if bot:DistanceFromFountain() < 800 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1200
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	local hNearbyAllyList = J.GetAllyList( bot, nCastRange )

	if #hNearbyAllyList >= 2
		and bot:GetHealth() <= 120
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		sCastMotive = '死前为队友用'
		return BOT_ACTION_DESIRE_HIGH, hNearbyAllyList[2], sCastType, sCastMotive
	end

	local nNeedMPCount = 0
	for _, npcAlly in pairs( hNearbyAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and npcAlly:GetMaxMana()- npcAlly:GetMana() > 180
		then
			nNeedMPCount = nNeedMPCount + 1
		end

		if nNeedMPCount >= 2
		then
			sCastMotive = '团队回蓝'
			return BOT_ACTION_DESIRE_HIGH, hNearbyAllyList[2], sCastType, sCastMotive
		end
	end

	if bot:GetMana() / bot:GetMaxMana() < 0.58
	then
		sCastMotive = '自己补蓝'
		return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
	end


	return BOT_ACTION_DESIRE_NONE

end


--臂章
local nLastActiveArmletTime = -90
X.ConsiderItemDesire["item_armlet"] = function( hItem )

	if bDeafaultItemHero then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	local bActive = hItem:GetToggleState()

	if ( J.IsValid( botTarget ) or J.IsValidBuilding( botTarget ) )
		and not botTarget:IsAttackImmune()
		and not botTarget:IsInvulnerable()
		and ( not botTarget:IsBuilding() or not J.IsKeyWordUnit( "OutpostName", botTarget ) )
		and not J.HasForbiddenModifier( botTarget )
		and J.IsInRange( bot, botTarget, bot:GetAttackRange() + 180 )
		and not bot:IsDisarmed()
	then
		nLastActiveArmletTime = DotaTime()
		if not bActive
		then
			hEffectTarget = botTarget
			sCastMotive = '激活臂章攻击'..( hEffectTarget:IsHero() and J.Chat.GetNormName( hEffectTarget ) or "非英雄" )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	if bot:GetHealth() <= 600
		and ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) or J.IsAttackProjectileIncoming( bot, 1600 ) )
	then
		nLastActiveArmletTime = DotaTime()
		if not bActive
		then
			hEffectTarget = bot
			sCastMotive = '激活临时血量'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	if bActive
		and DotaTime() > nLastActiveArmletTime + 0.9
		and ( #nInRangeEnmyList == 0 or bot:GetHealth() > 990 )
	then
		hEffectTarget = bot
		sCastMotive = '关闭臂章'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType --, '关闭臂章'
	end

	return BOT_ACTION_DESIRE_NONE

end


--狂战
X.ConsiderItemDesire["item_bfury"] = function( hItem )

	return X.ConsiderItemDesire["item_quelling_blade"]( hItem )

end


--BKB
X.ConsiderItemDesire["item_black_king_bar"] = function( hItem )

	local nCastRange = 1300
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if #nInRangeEnmyList > 0
		and not bot:IsMagicImmune()
		and not bot:IsInvulnerable()
		and not bot:HasModifier( 'modifier_item_lotus_orb_active' )
		and not bot:HasModifier( 'modifier_antimage_spell_shield' )
		and ( J.IsGoingOnSomeone( bot ) or J.IsRetreating( bot ) )
	then
		if bot:IsRooted()
		then
			sCastMotive = '解缠绕'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if bot:IsSilenced()
			and bot:GetMana() > 100
			and not bot:HasModifier( "modifier_item_mask_of_madness_berserk" )
			and J.GetEnemyCount( bot, 600 ) >= 2
		then
			sCastMotive = '解沉默'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if J.IsNotAttackProjectileIncoming( bot, 350 )
		then
			sCastMotive = '防御弹道'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if J.IsWillBeCastUnitTargetSpell( bot, nCastRange )
		then
			sCastMotive = '防御指向技能'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if J.IsWillBeCastPointSpell( bot, nCastRange )
		then
			sCastMotive = '防御地点技能'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if J.GetEnemyCount( bot, 800 ) >= 3
		then
			sCastMotive = '先开BKB切入'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

	end

	return BOT_ACTION_DESIRE_NONE

end


--刃甲
X.ConsiderItemDesire["item_blade_mail"] = function( hItem )

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsNotAttackProjectileIncoming( bot, 366 )
		and #nInRangeEnmyList >= 1
	then
		hEffectTarget = bot
		sCastMotive = '反弹弹道'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	for _, npcEnemy in pairs( hNearbyEnemyHeroList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and npcEnemy:GetAttackTarget() == bot
			and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				 or J.IsAttackProjectileIncoming( bot, 1000 ) )
		then
			hEffectTarget = npcEnemy
			sCastMotive = '反弹敌人伤害:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--跳刀
X.ConsiderItemDesire["item_blink"] = function( hItem )

	local nCastRange = 1200 + aetherRange
	local sCastType = 'ground'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	if bot:IsRooted() then return BOT_ACTION_DESIRE_NONE end

	if J.IsStuck( bot )
	then
		hEffectTarget = J.GetLocationTowardDistanceLocation( bot, GetAncient( GetTeam() ):GetLocation(), 1100 )
		sCastMotive = '卡住了'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	--撤退跑路
	if nMode == BOT_MODE_RETREAT
		and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
	then
		local bLocation = J.GetLocationTowardDistanceLocation( bot, GetAncient( GetTeam() ):GetLocation(), 1199 )
		local nAttackAllyList = bot:GetNearbyHeroes( 660, false, BOT_MODE_ATTACK )
		if bot:DistanceFromFountain() > 800
			and IsLocationPassable( bLocation )
			and ( #nAttackAllyList == 0 or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH * 0.9 )
			and #hNearbyEnemyHeroList >= 1
		then
			hEffectTarget = bLocation
			sCastMotive = "撤退"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	--打钱
	local nEnemyHeroInView = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	local nAttackAllyList = bot:GetNearbyHeroes( 1600, false, BOT_MODE_ATTACK )
	if #nEnemyHeroInView == 0 and not bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and #nAttackAllyList == 0 and ( botTarget == nil or not botTarget:IsHero() )
	then
		local nAOELocation = bot:FindAoELocation( true, false, bot:GetLocation(), 1600, 400, 0, 0 )
		local laneCreepList = bot:GetNearbyLaneCreeps( 1600, true )
		if nAOELocation.count >= 4
			and #laneCreepList >= 4
		then
			local bCenter = J.GetCenterOfUnits( laneCreepList )
			local bDist = GetUnitToLocationDistance( bot, bCenter )
			local vLocation = J.GetLocationTowardDistanceLocation( bot, bCenter, bDist + 550 )
			local bLocation = J.GetLocationTowardDistanceLocation( bot, bCenter, bDist - 300 )
			if bDist >= 1500 then bLocation = J.GetLocationTowardDistanceLocation( bot, bCenter, 1199 ) end

			if IsLocationPassable( bLocation )
				and GetUnitToLocationDistance( bot, bLocation ) > 600
				and IsLocationVisible( vLocation )
			then
				hEffectTarget = bLocation
				sCastMotive = '去刷小兵, 数量:'..#laneCreepList
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	--躲避技能
	if J.IsProjectileIncoming( bot, 1400 )
		and ( botTarget == nil
			or not botTarget:IsHero()
			or not J.IsInRange( bot, botTarget, bot:GetAttackRange() + 100 ) )
	then
		hEffectTarget = J.GetLocationTowardDistanceLocation( bot, GetAncient( GetTeam() ):GetLocation(), 1199 )
		sCastMotive = '躲避弹道'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end


	--先手进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 400 )
			and J.CanCastOnMagicImmune( botTarget )
			and not J.IsInRange( bot, botTarget, bot:GetAttackRange() + 150 )
		then
			if bot:GetStunDuration( true ) > 0.8
				or J.GetAllyCount( bot, 1200 ) >= J.GetEnemyCount( bot, 1600 )
			then

				local nDistance = GetUnitToUnitDistance( bot, botTarget )
				if nDistance >= 1200
				then
					nDistance = 1199
				end

				hEffectTarget = J.GetUnitTowardDistanceLocation( bot, botTarget, nDistance )
				sCastMotive = '闪烁进攻:'..J.Chat.GetNormName( botTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end


	--Shopping



	return BOT_ACTION_DESIRE_NONE

end


--盛世闪光
X.ConsiderItemDesire["item_overwhelming_blink"] = function( hItem )

	return X.ConsiderItemDesire["item_blink"]( hItem )

end

--迅疾闪光
X.ConsiderItemDesire["item_swift_blink"] = function( hItem )

	return X.ConsiderItemDesire["item_blink"]( hItem )

end

--秘奥闪光
X.ConsiderItemDesire["item_arcane_blink"] = function( hItem )

	return X.ConsiderItemDesire["item_blink"]( hItem )

end


--奶酪
X.ConsiderItemDesire["item_cheese"] = function( hItem )

	if bot:DistanceFromFountain() < 1200 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	local nLostHealth = bot:GetMaxHealth() - bot:GetHealth()
	local botHP = bot:GetHealth() / bot:GetMaxHealth()
	local nLostMana = bot:GetMaxMana() - bot:GetMana()
	local botMP = bot:GetMana() / bot:GetMaxMana()


	if ( nLostHealth > 2500 and nLostMana > 1500 )
		or ( nLostHealth > 2000 and nLostHealth + nLostMana > 3000 )
		or ( botHP < 0.4 and botMP < 0.4 )
		or ( botHP < 0.2 )
		or ( botMP < 0.06 )
	then
		if J.IsGoingOnSomeone( bot )
		then
			if J.IsValidHero( botTarget )
				and J.IsInRange( bot, botTarget, 2000 )
				and J.CanCastOnMagicImmune( botTarget )
			then
				hEffectTarget = bot
				sCastMotive = "进攻"
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

		if J.IsRetreating( bot )
			and bot:WasRecentlyDamagedByAnyHero( 4.0 )
		then
			hEffectTarget = bot
			sCastMotive = "撤退"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--血精石
X.ConsiderItemDesire["item_bloodstone"] = function( hItem )

	if bot:DistanceFromFountain() < 1200 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.GetHP( bot ) < 0.35
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and #hNearbyEnemyHeroList >= 1
	then
		hEffectTarget = bot
		sCastMotive = "撤退"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end


--血棘
X.ConsiderItemDesire["item_bloodthorn"] = function( hItem )

	return X.ConsiderItemDesire["item_orchid"]( hItem )

end

--魔瓶
X.ConsiderItemDesire["item_bottle"] = function( hItem )

	if hItem:GetCurrentCharges() == 0
		or bot:HasModifier( "modifier_bottle_regeneration" )
	then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 400 + aetherRange
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nLostMana = bot:GetMaxMana() - bot:GetMana()
	local nLostHealth = bot:GetMaxHealth() - bot:GetHealth()


	--泉水喝
	if bot:HasModifier( "modifier_fountain_aura" )
	then
		hEffectTarget = bot
		sCastMotive = "在泉水里喝"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	--自己喝
	if not bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		if nLostHealth > 150 and nLostMana > 90
		then
			hEffectTarget = bot
			sCastMotive = "补血补篮"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if nLostHealth > 500 and J.GetHP( bot ) < 0.5
		then
			hEffectTarget = bot
			sCastMotive = "只补血"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if nLostMana > 280 and J.GetMP( bot ) < 0.4
		then
			hEffectTarget = bot
			sCastMotive = "只补篮"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	return BOT_ACTION_DESIRE_NONE

end


--小净化
X.ConsiderItemDesire["item_clarity"] = function( hItem )

	if bot:DistanceFromFountain() < 2000 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 800 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.GetMP( bot ) < 0.35
		and not bot:HasModifier( "modifier_clarity_potion" )
		and #nInRangeEnmyList == 0
		and not bot:WasRecentlyDamagedByAnyHero( 4.0 )
	then
		hEffectTarget = bot
		sCastMotive = '净化自己'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if #nInRangeEnmyList == 0 
	then
		local hAllyList = bot:GetNearbyHeroes( 600, false, BOT_MODE_NONE )
		local hNeedManaAlly = nil
		local nNeedManaAllyMana = 99999
		for _, npcAlly in pairs( hAllyList )
		do
			if J.IsValid( npcAlly )
				and npcAlly ~= bot
				and not npcAlly:IsIllusion()
				and not npcAlly:IsChanneling()
				and not npcAlly:HasModifier( "modifier_clarity_potion" )
				and not npcAlly:WasRecentlyDamagedByAnyHero( 4.0 )
				and npcAlly:GetMaxMana() - npcAlly:GetMana() > 350 
			then
				if( npcAlly:GetMana() < nNeedManaAllyMana )
				then
					hNeedManaAlly = npcAlly
					nNeedManaAllyMana = npcAlly:GetMana()
				end
			end
		end
		if( hNeedManaAlly ~= nil )
		then
			hEffectTarget = hNeedManaAlly
			sCastMotive = '净化队友:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--赤红甲
X.ConsiderItemDesire["item_crimson_guard"] = function( hItem )

	if bot:DistanceFromFountain() < 400 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1200
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	local hNearbyAllyList = J.GetAllyList( bot, nCastRange )

	for _, npcAlly in pairs( hNearbyAllyList )
	do
		if J.IsValid( npcAlly )
			and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.8
			and npcAlly:WasRecentlyDamagedByAnyHero( 2.0 )
			and not npcAlly:HasModifier( "modifier_item_crimson_guard_nostack" )
			and #hNearbyEnemyHeroList > 0
		then
			hEffectTarget = npcAlly
			sCastMotive = '救救队友:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	local nNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
	local nNearbyEnemyTowers = bot:GetNearbyTowers( 800, true )
	if #hNearbyAllyList >= 2
		and ( #nNearbyEnemyHeroes + #nNearbyEnemyTowers >= 2 or #nNearbyEnemyHeroes >= 2 )
	then
		for _, npcAlly in pairs( hNearbyAllyList )
		do
			if npcAlly:WasRecentlyDamagedByAnyHero( 2.0 )
				and not npcAlly:HasModifier( "modifier_item_crimson_guard_nostack" )
			then
				hEffectTarget = npcAlly
				sCastMotive = '保护队友:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE

end


--吹风
X.ConsiderItemDesire["item_cyclone"] = function( hItem )

	local nCastRange = 650 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsValid( botTarget )
		and J.CanCastOnNonMagicImmune( botTarget )
		and X.IsWithoutSpellShield( botTarget )
		and J.IsInRange( bot, botTarget, nCastRange + 200 )
	then
		if botTarget:HasModifier( 'modifier_teleporting' )
			 or botTarget:HasModifier( 'modifier_abaddon_borrowed_time' )
			 or botTarget:HasModifier( "modifier_ursa_enrage" )
			 or botTarget:HasModifier( "modifier_item_satanic_unholy" )
			 or botTarget:IsChanneling()
		then
			hEffectTarget = botTarget
			sCastMotive = '驱散Buff:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.GetHP( botTarget ) > 0.49 and J.IsCastingUltimateAbility( botTarget )
		then
			hEffectTarget = botTarget
			sCastMotive = '打断大招:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.IsRunning( botTarget ) and botTarget:GetCurrentMovementSpeed() > 440
		then
			hEffectTarget = botTarget
			sCastMotive = '阻止逃跑:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if J.CanCastOnNonMagicImmune( bot )
		and #hNearbyEnemyHeroList > 0
	then
		if bot:GetHealth() < 216 and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		then
			hEffectTarget = bot
			sCastMotive = '撤退:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if bot:IsRooted()
			or ( bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT and bot:IsSilenced() )
		then
			hEffectTarget = bot
			sCastMotive = '解缠绕:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.IsUnitTargetProjectileIncoming( bot, 800 )
		then
			hEffectTarget = bot
			sCastMotive = '防御弹道:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--风之杖
X.ConsiderItemDesire["item_wind_waker"] = function( hItem )

	return X.ConsiderItemDesire["item_cyclone"]( hItem )

end


--大根
X.ConsiderItemDesire["item_dagon"] = function( hItem )

	local nCastRange = hItem:GetCastRange() + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE )
	local nDamage = hItem:GetSpecialValueInt( "damage" )


	--击杀
	for _, npcEnemy in pairs( nInRangeEnmyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and X.IsWithoutSpellShield( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL )
		then
			hEffectTarget = npcEnemy
			sCastMotive = "击杀:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and X.IsWithoutSpellShield( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

X.ConsiderItemDesire["item_dagon_2"] = function( hItem )

	return X.ConsiderItemDesire["item_dagon"]( hItem )

end

X.ConsiderItemDesire["item_dagon_3"] = function( hItem )

	return X.ConsiderItemDesire["item_dagon"]( hItem )

end

X.ConsiderItemDesire["item_dagon_4"] = function( hItem )

	return X.ConsiderItemDesire["item_dagon"]( hItem )

end

X.ConsiderItemDesire["item_dagon_5"] = function( hItem )

	return X.ConsiderItemDesire["item_dagon"]( hItem )

end

--散失
X.ConsiderItemDesire["item_diffusal_blade"] = function( hItem )

	local nCastRange = 630 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if( nMode == BOT_MODE_RETREAT )
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if J.IsValid( npcEnemy )
				and J.IsMoving( npcEnemy )
				and J.IsInRange( npcEnemy, bot, nCastRange )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
				and npcEnemy:GetCurrentMovementSpeed() > 200
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and X.IsWithoutSpellShield( npcEnemy )
				and not J.IsDisabled( npcEnemy ) 
			then
				hEffectTarget = npcEnemy
				sCastMotive = "撤退:"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsMoving( botTarget )
			and botTarget:GetCurrentMovementSpeed() > 200
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and X.IsWithoutSpellShield( botTarget )
			and not J.IsDisabled( botTarget ) 
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	local npcEnemy = hNearbyEnemyHeroList[1]
	if J.IsValidHero( npcEnemy )
		and J.IsInRange( bot, npcEnemy, nCastRange - 100 )
		and J.CanCastOnNonMagicImmune( npcEnemy )
		and X.IsWithoutSpellShield( npcEnemy )
		and not J.IsDisabled( npcEnemy )
		and J.IsMoving( npcEnemy )
		and J.IsRunning( npcEnemy )
		and npcEnemy:GetCurrentMovementSpeed() > bot:GetCurrentMovementSpeed() * 0.8
	then
		hEffectTarget = npcEnemy
		sCastMotive = '减速:'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end


--芒果
X.ConsiderItemDesire["item_enchanted_mango"] = function( hItem )

	local nCastRange = 300 + aetherRange
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
		and bot:GetMana() < 100 + bot:GetLevel() * 6
		and J.IsValidHero( botTarget )
		and J.IsInRange( bot, botTarget, 1000 )
	then
		hEffectTarget = bot
		sCastMotive = '自己吃'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end


--虚灵
X.ConsiderItemDesire["item_ethereal_blade"] = function( hItem )

	local nCastRange = 800 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--心火
X.ConsiderItemDesire["item_faerie_fire"] = function( hItem )

	if bot:DistanceFromFountain() < 1800 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 300 + aetherRange
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if ( nMode == BOT_MODE_RETREAT
		 and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH
		 and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		 and ( bot:GetHealth() / bot:GetMaxHealth() ) < 0.2 )
	then
		hEffectTarget = bot
		sCastMotive = "撤退"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	--攻击
	if J.IsGoingOnSomeone( bot )
		and J.GetHP( bot ) < 0.3
		and J.IsValidHero( botTarget )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		hEffectTarget = bot
		sCastMotive = "进攻"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	--自己吃
	if DotaTime() > 10 * 60
		and hItem:GetName() == "item_faerie_fire"
		and bot:GetItemInSlot( 6 ) ~= nil
		and bot:GetMaxHealth() - bot:GetHealth() > 200
	then
		hEffectTarget = bot
		sCastMotive = '自己吃'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--大药
X.ConsiderItemDesire["item_flask"] = function( hItem )

	if bot:DistanceFromFountain() < 3000 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 900
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if bot:GetMaxHealth() - bot:GetHealth() > 500
		and #nInRangeEnmyList == 0
		and not bot:WasRecentlyDamagedByAnyHero( 3.2 )
		and not bot:HasModifier( "modifier_filler_heal" )
		and not bot:HasModifier( "modifier_elixer_healing" )
		and not bot:HasModifier( "modifier_flask_healing" )
		and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
	then
		hEffectTarget = bot
		sCastMotive = '自己吃'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	local hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 700 )
	local hNeedHealAlly = nil
	local nNeedHealAllyHealth = 99999
	for _, npcAlly in pairs( hAllyList )
	do
		if J.IsValid( npcAlly ) and npcAlly ~= bot
			and not npcAlly:HasModifier( "modifier_filler_heal" )
			and not npcAlly:HasModifier( "modifier_elixer_healing" )
			and not npcAlly:HasModifier( "modifier_flask_healing" )
			and not npcAlly:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and not npcAlly:WasRecentlyDamagedByAnyHero( 4.0 )
			and not npcAlly:IsIllusion()
			and not npcAlly:IsChanneling()
			and npcAlly:GetMaxHealth() - npcAlly:GetHealth() > 550 
		then
			if( npcAlly:GetHealth() < nNeedHealAllyHealth )
			then
				hNeedHealAlly = npcAlly
				nNeedHealAllyHealth = npcAlly:GetHealth()
			end
		end
	end
	if hNeedHealAlly ~= nil and #hNearbyEnemyHeroList == 0
	then
		hEffectTarget = hNeedHealAlly
		sCastMotive = '给队友贴:'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--推推
X.ConsiderItemDesire["item_force_staff"] = function( hItem )

	local nCastRange = 550 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	local hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 600 )
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and J.CanCastOnNonMagicImmune( npcAlly )
		then
			local nNearAllysEnemyList = npcAlly:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
			if #nNearAllysEnemyList >= 1
				and not npcAlly:IsInvisible()
				and npcAlly:GetActiveMode() == BOT_MODE_RETREAT
				and npcAlly:IsFacingLocation( GetAncient( GetTeam() ):GetLocation(), 30 )
				and npcAlly:DistanceFromFountain() > 600
				and npcAlly:WasRecentlyDamagedByAnyHero( 4.0 )
			then
				hEffectTarget = npcAlly
				sCastMotive = '帮队友撤退'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if J.IsGoingOnSomeone( npcAlly )
			then
				local hAllyTarget = J.GetProperTarget( npcAlly )
				if J.IsValidHero( hAllyTarget )
					and npcAlly:IsFacingLocation( hAllyTarget:GetLocation(), 15 )
					and J.CanCastOnNonMagicImmune( hAllyTarget )
					and GetUnitToUnitDistance( hAllyTarget, npcAlly ) > npcAlly:GetAttackRange() + 50
					and GetUnitToUnitDistance( hAllyTarget, npcAlly ) < npcAlly:GetAttackRange() + 700
					and not hAllyTarget:IsFacingLocation( npcAlly:GetLocation(), 40 )
					and J.GetEnemyCount( npcAlly, 1600 ) <= 3
				then
					hEffectTarget = npcAlly
					sCastMotive = '帮队友进攻'..J.Chat.GetNormName( hEffectTarget )
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end

			if J.IsStuck( npcAlly )
			then
				hEffectTarget = npcAlly
				sCastMotive = '队友卡地形了'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

	end

	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and npcAlly:GetUnitName() == "npc_dota_hero_crystal_maiden"
			and J.CanCastOnNonMagicImmune( npcAlly )
			and ( npcAlly:IsInvisible() or npcAlly:GetHealth() / npcAlly:GetMaxHealth() > 0.8 )
			and ( npcAlly:IsChanneling() and not npcAlly:HasModifier( "modifier_teleporting" ) )
		then
			local enemyHeroesNearbyCM = npcAlly:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
			for _, npcEnemy in pairs( enemyHeroesNearbyCM )
			do
				if npcEnemy ~= nil and npcEnemy:IsAlive()
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and GetUnitToUnitDistance( npcEnemy, npcAlly ) > 835
					and npcAlly:IsFacingLocation( npcEnemy:GetLocation(), 30 )
				then
					hEffectTarget = npcAlly
					sCastMotive = '推冰女'
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end
	end

	if bot:DistanceFromFountain() < 2600
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
				and npcEnemy:IsFacingLocation( GetAncient( GetTeam() ):GetLocation(), 40 )
				and GetUnitToLocationDistance( npcEnemy, GetAncient( GetTeam() ):GetLocation() ) < 1200
			then
				hEffectTarget = npcEnemy
				sCastMotive = '推人入泉'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end
	
	
	--推敌人靠近自己
	if J.IsGoingOnSomeone(bot) and #hAllyList >= 2
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and X.IsWithoutSpellShield( botTarget )
		then
			local allyCenterLocation = J.GetCenterOfUnits( hAllyList )
			if botTarget:IsFacingLocation( allyCenterLocation, 28 )
				and GetUnitToLocationDistance( bot, allyCenterLocation ) >= 500
			then
				hEffectTarget = botTarget
				sCastMotive = '推敌人靠近自己'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end			
		end
	end	

	return BOT_ACTION_DESIRE_NONE

end

--绿杖
X.ConsiderItemDesire["item_ghost"] = function( hItem )

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if bot:GetAttackTarget() == nil
		or bot:GetHealth() < 500
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
				and J.IsInRange( bot, npcEnemy, npcEnemy:GetAttackRange() + 100 )
				and npcEnemy:GetAttackTarget() == bot
				and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )
				and npcEnemy:GetAttackDamage() > bot:GetAttackDamage()
			then
				hEffectTarget = npcEnemy
				sCastMotive = "撤退"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--微光
X.ConsiderItemDesire["item_glimmer_cape"] = function( hItem )

	local nCastRange = 800 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil


	if	bot:DistanceFromFountain() > 600
		and #hNearbyEnemyTowerList == 0
		and not bot:HasModifier( 'modifier_item_dustofappearance' )
		and not bot:HasModifier( 'modifier_slardar_amplify_damage' )
		and not bot:HasModifier( 'modifier_item_glimmer_cape' )
		and not bot:IsInvulnerable()
		and not bot:IsMagicImmune()
	then

		if bot:IsSilenced() or bot:IsRooted() or J.IsStunProjectileIncoming( bot, 1000 )
		then
			hEffectTarget = bot
			sCastMotive = '自己被缠绕或沉默了'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if ( J.IsRetreating( bot ) 
				and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYHIGH 
				and not bot:HasModifier("modifier_fountain_aura") )
			 or ( botTarget == nil 
					and #hNearbyEnemyHeroList > 0 
					and J.GetHP( bot ) < 0.36 + ( 0.09 * #hNearbyEnemyHeroList ) )
		then
			hEffectTarget = bot
			sCastMotive = '自己撤退'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		--------------------
		--use at npcAlly target
		--------------------
		local hAllyList = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE )
		for _, npcAlly in pairs( hAllyList )
		do
			if J.IsValid( npcAlly )
				and not npcAlly:IsIllusion()
				and not npcAlly:IsMagicImmune()
				and not npcAlly:IsInvulnerable()
				and not npcAlly:IsInvisible()
				and npcAlly:DistanceFromFountain() > 600
				and not npcAlly:HasModifier( 'modifier_item_glimmer_cape' )
				and not npcAlly:HasModifier( 'modifier_item_dustofappearance' )
				and not npcAlly:HasModifier( 'modifier_slardar_amplify_damage' )
				and not npcAlly:HasModifier( 'modifier_arc_warden_tempest_double' )
			then
				local nNearbyAllyEnemyTowers = npcAlly:GetNearbyTowers( 888, true )
				if #nNearbyAllyEnemyTowers == 0
				then
					--retreat
					if J.GetHP( npcAlly ) < 0.35 + ( 0.05 * #hNearbyEnemyHeroList )
						and J.IsRetreating( npcAlly )
						and npcAlly:WasRecentlyDamagedByAnyHero( 4.0 )
					then
						hEffectTarget = npcAlly
						sCastMotive = '保护队友撤退:'..J.Chat.GetNormName( hEffectTarget )
						return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
					end

					--Disable
					if J.IsDisabled( npcAlly ) --debug
						or J.IsStunProjectileIncoming( npcAlly, 1000 )
					then
						hEffectTarget = npcAlly
						sCastMotive = '保护被控队友:'..J.Chat.GetNormName( hEffectTarget )
						return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
					end
				end
			end
		end

	end

	return BOT_ACTION_DESIRE_NONE

end

--大鞋
X.ConsiderItemDesire["item_guardian_greaves"] = function( hItem )

	local nCastRange = 1200
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil


	local hAllyList = J.GetAllyList( bot, nCastRange )
	for _, npcAlly in pairs( hAllyList ) 
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and J.GetHP( npcAlly ) < 0.45
			and #hNearbyEnemyHeroList > 0
		then
			hEffectTarget = npcAlly
			sCastMotive = '治疗队友'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	local needHPCount = 0
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil
			and npcAlly:GetMaxHealth()- npcAlly:GetHealth() > 400
		then
			needHPCount = needHPCount + 1

			if needHPCount >= 2 and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.55
			then
				hEffectTarget = npcAlly
				sCastMotive = '治疗二队友:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if needHPCount >= 3
			then
				hEffectTarget = npcAlly
				sCastMotive = '治疗多个队友:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if bot:GetHealth() / bot:GetMaxHealth() < 0.5
		or bot:IsSilenced()
		or bot:IsRooted()
		or bot:HasModifier( "modifier_item_urn_damage" )
		or bot:HasModifier( "modifier_item_spirit_vessel_damage" )
	then
		hEffectTarget = bot
		sCastMotive = '治疗自己:'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	local nNeedMPCount = 0
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil
			and npcAlly:GetMaxMana()- npcAlly:GetMana() > 400
		then
			nNeedMPCount = nNeedMPCount + 1
		end

		if nNeedMPCount >= 2 and bot:GetMana() / bot:GetMaxMana() < 0.2
		then
			hEffectTarget = npcAlly
			sCastMotive = '回蓝二队友:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if nNeedMPCount >= 3
		then
			hEffectTarget = npcAlly
			sCastMotive = '回蓝多个队友:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

	end

	local laneCreepList = bot:GetNearbyLaneCreeps( 1200, false )
	if #laneCreepList >= 9
	then
		local nAOELocation = bot:FindAoELocation( false, false, bot:GetLocation(), 100, 1100 , 0, 200 )
		if nAOELocation.count >= 6
			and GetUnitToLocationDistance( bot, nAOELocation.targetloc ) <= 200
		then
			hEffectTarget = bot
			sCastMotive = '治疗小兵们:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--点金
X.ConsiderItemDesire["item_hand_of_midas"] = function( hItem )

	local nCastRange = 990 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil


	if #hNearbyEnemyHeroList >= 1 then nCastRange = 628 end
	local hNearbyCreepList = bot:GetNearbyCreeps( nCastRange, true )
	local targetCreep = nil
	local targetCreepLV = 0

	for _, creep in pairs( hNearbyCreepList )
	do
		if J.IsValid( creep )
		 and not creep:IsMagicImmune()
		 and not creep:IsAncientCreep()
		then
			if creep:GetLevel() > targetCreepLV
			then
				targetCreepLV = creep:GetLevel()
				targetCreep = creep
			end
		end

	end

	if targetCreep ~= nil
	then
		hEffectTarget = targetCreep
		sCastMotive = '点金小兵:'..hEffectTarget:GetUnitName()
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--天堂
X.ConsiderItemDesire["item_heavens_halberd"] = function( hItem )

	local nCastRange = 700 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	local targetHero = nil
	local targetHeroDamage = 0
	for _, npcEnemy in pairs( nInRangeEnmyList )
	do
		if J.IsValidHero( npcEnemy )
			and not npcEnemy:IsDisarmed()
			and not J.IsDisabled( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and X.IsWithoutSpellShield( npcEnemy )
			and npcEnemy:GetAttackTarget() ~= nil
			and ( npcEnemy:GetPrimaryAttribute() ~= ATTRIBUTE_INTELLECT or npcEnemy:GetAttackDamage() > 180 )
		then
			local nEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL )
			if ( nEnemyDamage > targetHeroDamage )
			then
				targetHeroDamage = nEnemyDamage
				targetHero = npcEnemy
			end
		end
	end
	if targetHero ~= nil
	then
		hEffectTarget = targetHero
		sCastMotive = '缴械敌人:'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		local botTarget = bot:GetAttackTarget()
		if J.IsRoshan( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
		then
			hEffectTarget = botTarget
			sCastMotive = '缴械肉山'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--支配
X.ConsiderItemDesire["item_helm_of_the_dominator"] = function( hItem )

	local nCastRange = 1000 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil

	local maxHP = 0
	local hCreep = nil
	local hNearbyCreepList = bot:GetNearbyCreeps( nCastRange, true )
	if #hNearbyCreepList >= 2
	then
		for _, creep in pairs( hNearbyCreepList )
		do
			if J.IsValid( creep )
			then
				local nCreepHP = creep:GetHealth()
				if nCreepHP > maxHP
					and ( creep:GetHealth() / creep:GetMaxHealth() ) > 0.75
					and ( not creep:IsAncientCreep() or hItem:GetName() == "item_helm_of_the_dominator_2" )
					and not J.IsKeyWordUnit( "siege", creep )
				then
					hCreep = creep
					maxHP = nCreepHP
				end
			end
		end
	end
	if hCreep ~= nil
	then
		hEffectTarget = hCreep
		sCastMotive = '支配:'..hEffectTarget:GetUnitName()
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end


--大支配
X.ConsiderItemDesire["item_helm_of_the_dominator_2"] = function( hItem )

	return X.ConsiderItemDesire["item_helm_of_the_dominator"]( hItem )

end


--挑战
X.ConsiderItemDesire["item_hood_of_defiance"] = function( hItem )

	if bot:HasModifier( 'modifier_item_pipe_barrier' )
		or J.GetHP( bot ) > 0.88
	then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if #nInRangeEnmyList > 0
	then
		hEffectTarget = bot
		sCastMotive = '套盾'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--永世法衣
X.ConsiderItemDesire["item_eternal_shroud"] = function( hItem )

	return X.ConsiderItemDesire["item_hood_of_defiance"]( hItem )

end

--圣洁吊坠
X.ConsiderItemDesire["item_holy_locket"] = function( hItem )

	--给队友

	return X.ConsiderItemDesire["item_magic_wand"]( hItem )

end

--大推推
X.ConsiderItemDesire["item_hurricane_pike"] = function( hItem )

	local nCastRange = 800 + aetherRange
	local nNearRange = 400 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nNearRange, true, BOT_MODE_NONE )


	if ( nMode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH )
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if ( J.IsInRange( bot, npcEnemy, nNearRange ) 
				and J.CanCastOnNonMagicImmune( npcEnemy ) )
			then
				hEffectTarget = npcEnemy
				sCastMotive = '撤退了推敌人'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

		if bot:IsFacingLocation( GetAncient( GetTeam() ):GetLocation(), 20 )
			and bot:DistanceFromFountain() > 600
			and #hNearbyEnemyHeroList >= 1
		then
			hEffectTarget = bot
			sCastMotive = '撤退了推自己'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and GetUnitToUnitDistance( botTarget, bot ) > bot:GetAttackRange() + 100
			and GetUnitToUnitDistance( botTarget, bot ) < bot:GetAttackRange() + 700
			and GetUnitToUnitDistance( botTarget, bot ) < GetUnitToLocationDistance( bot, J.GetCorrectLoc( botTarget, 1.0 ) ) - 100
			and bot:IsFacingLocation( botTarget:GetLocation(), 20 )
			and not botTarget:IsFacingLocation( bot:GetLocation(), 120 )
			and J.GetEnemyCount( bot, 1600 ) <= 2
		then
			hEffectTarget = bot
			sCastMotive = "进攻"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if bot:GetUnitName() == "npc_dota_hero_drow_ranger"
		or bot:GetUnitName() == "npc_dota_hero_sniper"
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if npcEnemy ~= nil
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and GetUnitToUnitDistance( npcEnemy, bot ) <= nNearRange
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				bot:SetTarget( npcEnemy )
				hEffectTarget = npcEnemy
				sCastMotive = '推开'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	local hAllyList = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE )
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and npcAlly:GetUnitName() == "npc_dota_hero_crystal_maiden"
			and J.CanCastOnNonMagicImmune( npcAlly )
			and X.IsWithoutSpellShield( npcAlly )
			and ( npcAlly:IsInvisible() or npcAlly:GetHealth() / npcAlly:GetMaxHealth() > 0.8 )
			and ( npcAlly:IsChanneling() and not npcAlly:HasModifier( "modifier_teleporting" ) )
		then
			local enemyHeroesNearbyCM = npcAlly:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
			for _, npcEnemy in pairs( enemyHeroesNearbyCM )
			do
				if npcEnemy ~= nil and npcEnemy:IsAlive()
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and GetUnitToUnitDistance( npcEnemy, npcAlly ) > 835
					and npcAlly:IsFacingLocation( npcEnemy:GetLocation(), 30 )
				then
					hEffectTarget = npcAlly
					sCastMotive = '推CM'
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--隐刀
X.ConsiderItemDesire["item_invis_sword"] = function( hItem )

	if bot:IsInvisible()
		or #hNearbyEnemyTowerList > 0
		or bot:HasModifier( "modifier_item_dustofappearance" )
		or bot:HasModifier( "modifier_slardar_amplify_damage" )
	then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsRetreating( bot )
		and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
		and #hNearbyEnemyHeroList > 0
	then
		hEffectTarget = bot
		sCastMotive = '撤退了'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if J.GetHP( bot ) < 0.166
		and ( #hNearbyEnemyHeroList > 0 or bot:WasRecentlyDamagedByAnyHero( 5.0 ) )
	then
		hEffectTarget = bot
		sCastMotive = '残血了'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if J.IsGoingOnSomeone( bot )
	then
		if 	J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and not J.IsInRange( bot, botTarget, botTarget:GetCurrentVisionRange() )
			and J.IsInRange( bot, botTarget, 2600 )
		then
			local hEnemyCreepList = bot:GetNearbyLaneCreeps( 800, true )
			if #hEnemyCreepList == 0 and #hNearbyEnemyHeroList == 0
			then
				hEffectTarget = botTarget
				sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--莲花
X.ConsiderItemDesire["item_lotus_orb"] = function( hItem )

	local nCastRange = 1000 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nNearAllyList = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE )


	for _, npcAlly in pairs( nNearAllyList )
	do
		if J.IsValid( npcAlly )
			and not npcAlly:IsIllusion()
			and not npcAlly:IsMagicImmune()
			and not npcAlly:IsInvulnerable()
			and not npcAlly:HasModifier( 'modifier_item_lotus_orb_active' )
			and not npcAlly:HasModifier( 'modifier_antimage_spell_shield' )
		then

			if J.IsUnitTargetProjectileIncoming( npcAlly, 800 )
			then
				hEffectTarget = npcAlly
				sCastMotive = '反弹弹道'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if npcAlly:IsRooted()
				or ( npcAlly:IsSilenced() and not npcAlly:HasModifier( "modifier_item_mask_of_madness_berserk" ) )
				or ( npcAlly:IsDisarmed() and not npcAlly:HasModifier( "modifier_oracle_fates_edict" ) )
			then
				hEffectTarget = npcAlly
				sCastMotive = '驱散队友:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if J.IsWillBeCastUnitTargetSpell( npcAlly, 1200 )
			then
				hEffectTarget = npcAlly
				sCastMotive = '给队友反弹技能:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--魔棒
X.ConsiderItemDesire["item_magic_stick"] = function( hItem )

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	local nEnemyCount = #nInRangeEnmyList
	local nHPrate = bot:GetHealth() / bot:GetMaxHealth()
	local nMPrate = bot:GetMana() / bot:GetMaxMana()
	local nCharges = hItem:GetCurrentCharges()

	if ( nHPrate < 0.5 or nMPrate < 0.3 ) and nEnemyCount >= 1 and nCharges >= 1
	then
		hEffectTarget = bot
		sCastMotive = '用途1'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nHPrate + nMPrate < 1.1 and nCharges >= 7 and nEnemyCount >= 1 )
	then
		hEffectTarget = bot
		sCastMotive = '用途2'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nCharges >= 9 and bot:GetItemInSlot( 6 ) ~= nil and ( nHPrate <= 0.7 or nMPrate <= 0.6 ) )
	then
		hEffectTarget = bot
		sCastMotive = '用途3'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--魔杖
X.ConsiderItemDesire["item_magic_wand"] = function( hItem )

	if hItem:GetCurrentCharges() <= 0 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1000
	local sCastType = 'none'
	if hItem:GetName() == 'item_holy_locket' then sCastType = 'unit' end
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	local nEnemyCount = #nInRangeEnmyList
	local nHPrate = bot:GetHealth() / bot:GetMaxHealth()
	local nMPrate = bot:GetMana() / bot:GetMaxMana()
	local nLostHP = bot:GetMaxHealth() - bot:GetHealth()
	local nLostMP = bot:GetMaxMana() - bot:GetMana()
	local nCharges = hItem:GetCurrentCharges()

	if ( ( nHPrate < 0.4 or nMPrate < 0.3 ) and nEnemyCount >= 1 and nCharges >= 1 )
	then
		hEffectTarget = bot
		sCastMotive = '用途1'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nHPrate < 0.7 and nMPrate < 0.7 and nCharges >= 12 and nEnemyCount >= 1 ) 
	then
		hEffectTarget = bot
		sCastMotive = '用途2'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nCharges >= 19 and bot:GetItemInSlot( 6 ) ~= nil and ( nHPrate <= 0.6 or nMPrate <= 0.5 ) ) 
	then
		hEffectTarget = bot
		sCastMotive = '用途3'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nCharges == 20 and nEnemyCount >= 1 and nLostHP > 350 and nLostMP > 350 ) 
	then
		hEffectTarget = bot
		sCastMotive = '用途4'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--分身
X.ConsiderItemDesire["item_manta"] = function( hItem )

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	local nNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK )
	local nNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
	local nNearbyEnemyTowers = bot:GetNearbyTowers( 800, true )
	local nNearbyEnemyBarracks = bot:GetNearbyBarracks( 600, true )
	local nNearbyAlliedCreeps = bot:GetNearbyLaneCreeps( 1000, false )
	local nNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( 800, true )

	if J.IsPushing( bot )
	then
		if ( #nNearbyEnemyTowers >= 1 or #nNearbyEnemyBarracks >= 1 )
			and #nNearbyAlliedCreeps >= 1
		then
			hEffectTarget = bot
			sCastMotive = '推进'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if J.IsGoingOnSomeone( bot )
		and J.IsValidHero( botTarget )
		and J.CanCastOnMagicImmune( botTarget )
		and J.IsInRange( bot, botTarget, bot:GetAttackRange() + 80 )
	then
		hEffectTarget = botTarget
		sCastMotive = '进攻:'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if bot:IsRooted()
		or ( bot:IsSilenced() and not bot:HasModifier( "modifier_item_mask_of_madness_berserk" ) )
		or bot:HasModifier( 'modifier_item_solar_crest_armor_reduction' )
		or bot:HasModifier( 'modifier_item_medallion_of_courage_armor_reduction' )
		or bot:HasModifier( 'modifier_item_spirit_vessel_damage' )
		or bot:HasModifier( 'modifier_dragonknight_breathefire_reduction' )
		or bot:HasModifier( 'modifier_slardar_amplify_damage' )
		or bot:HasModifier( 'modifier_item_dustofappearance' )
	then
		hEffectTarget = bot
		sCastMotive = '解Buff'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if not bot:IsMagicImmune()
		and not bot:HasModifier( "modifier_antimage_spell_shield" )
		and not bot:HasModifier( "modifier_item_sphere_target" )
		and not bot:HasModifier( "modifier_item_lotus_orb_active" )
		and J.IsNotAttackProjectileIncoming( bot, 70 )
	then
		hEffectTarget = bot
		sCastMotive = '躲弹道'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if J.IsRetreating( bot )
		and nNearbyEnemyHeroes[1] ~= nil
		and bot:DistanceFromFountain() > 600
	then
		hEffectTarget = bot
		sCastMotive = '撤退了'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if #nNearbyEnemyCreeps >= 8
	then
		hEffectTarget = bot
		sCastMotive = '刷小兵'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if bot:WasRecentlyDamagedByAnyHero( 5.0 )
		and bot:GetHealth() / bot:GetMaxHealth() < 0.18
		and bot:DistanceFromFountain() > 800
	then
		hEffectTarget = bot
		sCastMotive = '残血了'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--大电锤
X.ConsiderItemDesire["item_mjollnir"] = function( hItem )

	local nCastRange = 800 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	local nNearbyAllyList = bot:GetNearbyHeroes( nCastRange + 100, false, BOT_MODE_NONE);

	--团战中对被攻击频率最高的用
	if J.IsInTeamFight( bot, 800 )
	then
		local targetAlly = nil
		local maxTargetCount = 1
		for _, npcAlly in pairs(nNearbyAllyList)
		do
			if J.IsValid( npcAlly )
				and not npcAlly:IsIllusion()
				and not npcAlly:HasModifier( "modifier_item_mjollnir_static" )
			then
				local nAllyCount = 0 ;
				local nEnemyHeroes = npcAlly:GetNearbyHeroes(1400, true, BOT_MODE_NONE);
				local nEnemyCreeps = npcAlly:GetNearbyCreeps(1000, true);
				for _, unit in pairs(nEnemyHeroes)
				do
					if unit ~= nil and unit:IsAlive()
						and unit:GetAttackTarget() == npcAlly
					then
						nAllyCount = nAllyCount + 1
					end
				end
				for _, unit in pairs(nEnemyCreeps)
				do
					if unit ~= nil and unit:IsAlive()
						and unit:GetAttackTarget() == npcAlly
					then
						nAllyCount = nAllyCount + 1
					end
				end
				if nAllyCount > maxTargetCount
				then
					maxTargetCount = nAllyCount
					targetAlly = npcAlly
				end
			end
		end

		if targetAlly ~= nil
		then
			hEffectTarget = targetAlly
			sCastMotive = '团战中套电锤给队友:'..J.Chat.GetNormName(hEffectTarget)
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if J.IsValidHero(botTarget)
	then
		local nAllies = J.GetAlliesNearLoc(botTarget:GetLocation(),1400)
		if J.IsValid(nAllies[1])
		then
			local targetAlly = nil
			local targetDis = 9999
			for _, npcAlly in pairs(nAllies)
			do
				if J.IsValid( npcAlly )
					and GetUnitToUnitDistance( bot, npcAlly ) < nCastRange + 200
					and GetUnitToUnitDistance( botTarget, npcAlly ) < targetDis
					and not npcAlly:HasModifier( "modifier_item_mjollnir_static" )
				then
					targetAlly = npcAlly
					targetDis = GetUnitToUnitDistance( botTarget, npcAlly )
				end
			end
			if targetAlly ~= nil
			then
				hEffectTarget = targetAlly
				sCastMotive = '攻击前套电锤给队友:'..J.Chat.GetNormName(hEffectTarget)
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if hNearbyEnemyHeroList[1] == nil
	then
		local nAllyCreeps = bot:GetNearbyLaneCreeps(1000,false);
		local nEnemyCreeps = bot:GetNearbyLaneCreeps(1000,true);
		if #nAllyCreeps >= 1 and #nEnemyCreeps == 0
		then
			local targetCreep = nil
			local targetDis = 0
			for _, creep in pairs(nAllyCreeps)
			do
				if J.IsValid(creep)
					and J.GetHP(creep) > 0.6
					and creep:DistanceFromFountain() > targetDis
				then
					targetCreep = creep;
					targetDis = creep:DistanceFromFountain();
				end
			end
			if targetCreep ~= nil
			then
				hEffectTarget = targetCreep
				sCastMotive = '给前排小兵套上'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end


	if J.IsValidHero(hNearbyEnemyHeroList[1])
	   and hNearbyEnemyHeroList[1]:GetAttackTarget() == bot
	then
		if not bot:HasModifier("modifier_item_mjollnir_static")
		then
			hEffectTarget = bot
			sCastMotive = '给自己套上'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end



--疯脸
X.ConsiderItemDesire["item_mask_of_madness"] = function( hItem )

	if bot:GetUnitName() == 'npc_dota_hero_drow_ranger' then return BOT_ACTION_DESIRE_NONE end

	local nAttackTarget = bot:GetAttackTarget()
	local nCastRange = bot:GetAttackRange() + 100
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if ( J.IsValid( nAttackTarget ) or J.IsValidBuilding( nAttackTarget ) )
		and J.CanBeAttacked( nAttackTarget )
		and J.IsInRange( bot, nAttackTarget, nCastRange )
		and ( not J.CanKillTarget( nAttackTarget, bot:GetAttackDamage() * 2, DAMAGE_TYPE_PHYSICAL )
			 or J.GetAroundTargetEnemyUnitCount( bot, nCastRange ) >= 2 )
	then
		local nEnemyHeroInView = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
		if nAttackTarget:IsHero()
			or ( #nEnemyHeroInView == 0 and not bot:WasRecentlyDamagedByAnyHero( 2.0 ) )
		then
			if ( #nEnemyHeroInView == 0 )
				 or ( bot:GetUnitName() ~= "npc_dota_hero_sniper"
					 and bot:GetUnitName() ~= "npc_dota_hero_medusa" )
			then
				bot:SetTarget( nAttackTarget )
				hEffectTarget = nAttackTarget
				sCastMotive = '启动'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--勋章
X.ConsiderItemDesire["item_medallion_of_courage"] = function( hItem )

	local nCastRange = 900 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and not botTarget:HasModifier( 'modifier_item_solar_crest_armor_reduction' )
			and not botTarget:HasModifier( 'modifier_item_medallion_of_courage_armor_reduction' )
			and J.CanCastOnNonMagicImmune( botTarget )
			and not botTarget:IsAncientCreep()
			and ( J.IsInRange( bot, botTarget, bot:GetAttackRange() + 150 )
				or ( J.IsInRange( bot, botTarget, 1000 )
					and J.GetAroundTargetOtherAllyHeroCount( bot, botTarget, 600 ) >= 1 ) )
		then
			hEffectTarget = botTarget
			sCastMotive = '进攻:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if #hNearbyEnemyHeroList == 0
	then
		if J.IsValid( botTarget )
			and not botTarget:HasModifier( 'modifier_item_solar_crest_armor_reduction' )
			and not botTarget:HasModifier( 'modifier_item_medallion_of_courage_armor_reduction' )
			and not botTarget:HasModifier( "modifier_fountain_glyph" )
			and not J.CanKillTarget( botTarget, bot:GetAttackDamage() * 2.38, DAMAGE_TYPE_PHYSICAL )
			and J.IsInRange( bot, botTarget, bot:GetAttackRange() + 150 )
		then
			hEffectTarget = botTarget
			sCastMotive = '刷小兵:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	--------
	local hAllyList = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE )
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= bot
			and J.IsValidHero( npcAlly )
			and not npcAlly:IsIllusion()
			and J.CanCastOnNonMagicImmune( npcAlly )
			and not npcAlly:HasModifier( 'modifier_item_solar_crest_armor_addition' )
			and not npcAlly:HasModifier( 'modifier_item_medallion_of_courage_armor_addition' )
			and not npcAlly:HasModifier( "modifier_arc_warden_tempest_double" )
			and ( ( J.IsDisabled( npcAlly ) )
				or ( J.GetHP( npcAlly ) < 0.35 and #hNearbyEnemyHeroList > 0 and npcAlly:WasRecentlyDamagedByAnyHero( 2.0 ) )
				or ( J.IsValidHero( npcAlly:GetAttackTarget() ) and GetUnitToUnitDistance( npcAlly, npcAlly:GetAttackTarget() ) <= npcAlly:GetAttackRange() and #hNearbyEnemyHeroList == 0 ) )
		then
			hEffectTarget = npcAlly
			sCastMotive = '救队友:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--银月
local moonSharedTime = nil --添加使用延迟避免吃得过快以为没出
X.ConsiderItemDesire["item_moon_shard"] = function( hItem )

	if bot:GetNetWorth() < 18000
		or ( bot:GetItemInSlot( 6 ) == nil and bot:GetItemInSlot( 7 ) == nil )
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = 2000
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil


	if not bot:HasModifier( "modifier_item_moon_shard_consumed" )
	then
		if moonSharedTime == nil
		then
			moonSharedTime = DotaTime()
		elseif moonSharedTime < DotaTime() - 3.0
		then
			moonSharedTime = nil
			hEffectTarget = bot
			sCastMotive = "自己吃"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	local targetMember = nil
	local targetDamage = 0
	for i = 1, 5
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		 and member:GetAttackDamage() > targetDamage
		 and not member:HasModifier( "modifier_item_moon_shard_consumed" )
		then
			targetMember = member
			targetDamage = member:GetAttackDamage()
		end
	end
	if targetMember ~= nil
	then
		if moonSharedTime == nil
		then
			moonSharedTime = DotaTime()
		elseif moonSharedTime < DotaTime() - 4.0
		then
			moonSharedTime = nil
			hEffectTarget = targetMember
			sCastMotive = "给队友"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

--死灵书
X.ConsiderItemDesire["item_necronomicon"] = function( hItem )

	local nCastRange = 750
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if botTarget ~= nil and botTarget:IsAlive()
		and J.IsInRange( bot, botTarget, 700 )
	then
		hEffectTarget = botTarget
		sCastMotive = "进攻"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

X.ConsiderItemDesire["item_necronomicon_2"] = function( hItem )

	return X.ConsiderItemDesire["item_necronomicon"]( hItem )

end

X.ConsiderItemDesire["item_necronomicon_3"] = function( hItem )

	return X.ConsiderItemDesire["item_necronomicon"]( hItem )

end

--否决
X.ConsiderItemDesire["item_nullifier"] = function( hItem )

	local nCastRange = 800 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and not botTarget:HasModifier( "modifier_item_nullifier_mute" )
		then
			hEffectTarget = botTarget
			sCastMotive = '进攻:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--紫苑
X.ConsiderItemDesire["item_orchid"] = function( hItem )

	local nCastRange = 900 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	for _, npcEnemy in pairs( nInRangeEnmyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and X.IsWithoutSpellShield( npcEnemy )
		then
			if ( npcEnemy:IsChanneling() or npcEnemy:IsCastingAbility() )
			then
				hEffectTarget = npcEnemy
				sCastMotive = "打断:"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if J.IsRetreating( bot )
			then
				if not J.IsDisabled( npcEnemy )
				then
					hEffectTarget = npcEnemy
					sCastMotive = "撤退:"..J.Chat.GetNormName( hEffectTarget )
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsDisabled( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and X.IsWithoutSpellShield( botTarget )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--相位
X.ConsiderItemDesire["item_phase_boots"] = function( hItem )

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsRunning( bot )
	then
		hEffectTarget = bot
		sCastMotive = '跑起来'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--笛子
X.ConsiderItemDesire["item_pipe"] = function( hItem )

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local hNearbyAllyList = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )

	for _, npcAlly in pairs( hNearbyAllyList )
	do
		if J.IsValid( npcAlly )
			and not npcAlly:IsIllusion()
			and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.4
			and #hNearbyEnemyHeroList > 0
		then
			hEffectTarget = npcAlly
			sCastMotive = '保护队友:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	local nNearbyAllyHeroes = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )
	local nNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	local nNearbyAllyTowers = bot:GetNearbyTowers( 1200, true )
	if ( #nNearbyAllyHeroes >= 2 and #nNearbyEnemyHeroes >= 2 )
		or ( #nNearbyEnemyHeroes >= 2 and #nNearbyAllyHeroes + #nNearbyAllyTowers >= 2 )
	then
		hEffectTarget = bot
		sCastMotive = '保护团队'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--假腿
X.ConsiderItemDesire["item_power_treads"] = function( hItem )

	if bDeafaultItemHero then return 0 end

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	local nPtStat = hItem:GetPowerTreadsStat()
	if nPtStat == ATTRIBUTE_INTELLECT
	then
		nPtStat = ATTRIBUTE_AGILITY
	elseif nPtStat == ATTRIBUTE_AGILITY
	then
		nPtStat = ATTRIBUTE_INTELLECT
	end

	if ( bot:HasModifier( "modifier_flask_healing" )
		 or bot:HasModifier( "modifier_clarity_potion" )
		 or bot:HasModifier( "modifier_item_urn_heal" )
		 or bot:HasModifier( "modifier_item_spirit_vessel_heal" )
		 or bot:HasModifier( "modifier_bottle_regeneration" ) )
		and nMode ~= BOT_MODE_ATTACK
		and nMode ~= BOT_MODE_RETREAT
	then
		if nPtStat ~= ATTRIBUTE_AGILITY
		then
			--切换敏捷腿回复
			lastSwitchPtTime = DotaTime()
			if nPtStat == ATTRIBUTE_STRENGTH
			then
				sCastMotive = '力量腿切敏捷回复'
				return BOT_ACTION_DESIRE_HIGH, bot, 'twice', sCastMotive
			else
				sCastMotive = '智力腿切敏捷回复'
				return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
			end

		end
	elseif ( nMode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE )
			or nMode == BOT_MODE_EVASIVE_MANEUVERS
			or ( J.IsNotAttackProjectileIncoming( bot, 1200 ) )
			or ( bot:HasModifier( "modifier_sniper_assassinate" ) )
			or ( bot:GetHealth() / bot:GetMaxHealth() < 0.2 )
			or ( nPtStat == ATTRIBUTE_STRENGTH and bot:GetHealth() / bot:GetMaxHealth() < 0.3 )
			or ( nMode ~= BOT_MODE_LANING and bot:GetLevel() <= 10 and J.IsEnemyFacingUnit( bot, 800, 20 ) )
		then
			if nPtStat ~= ATTRIBUTE_STRENGTH
			then
				--切换力量腿吃伤害
				lastSwitchPtTime = DotaTime()
				if nPtStat == ATTRIBUTE_AGILITY
				then
					sCastMotive = '敏捷腿切换力量吃伤害'
					return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
				else
					sCastMotive = '智力腿切换力量吃伤害'
					return BOT_ACTION_DESIRE_HIGH, bot, 'twice', sCastMotive
				end

			end
	elseif nMode == BOT_MODE_ATTACK
			or nMode == BOT_MODE_TEAM_ROAM
		then
			if J.ShouldSwitchPTStat( bot, hItem )
				and lastSwitchPtTime < DotaTime() - 0.2
			then
				--切换主属性腿攻击
				sCastMotive = '切换主属性腿攻击'
				return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
			end
	elseif J.ShouldSwitchPTStat( bot, hItem )
			and lastSwitchPtTime < DotaTime() - 0.2
		then
			--默认为主属性腿
			sCastMotive = '默认为主属性腿'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
	end


	return BOT_ACTION_DESIRE_NONE

end

--补刀斧
local lastQuellingBladeUseTime = 0
X.ConsiderItemDesire["item_quelling_blade"] = function( hItem )

	local nCastRange = 450 + aetherRange
	local sCastType = 'tree'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if DotaTime() < 0 and not thereBeMonkey
	then
		for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
		do
			if GetSelectedHeroName( id ) == 'npc_dota_hero_monkey_king'
			then
				thereBeMonkey = true
			end
		end
	end

	if thereBeMonkey
	then
		local theMonkeyKing = nil
		for _, enemy in pairs( hNearbyEnemyHeroList )
		do
			if enemy:IsAlive()
				and enemy:GetUnitName() == "npc_dota_hero_monkey_king"
			then
				theMonkeyKing = enemy
				break
			end
		end

		if theMonkeyKing ~= nil
			and J.IsInRange( bot, theMonkeyKing, nCastRange )
		then
			local nTrees = bot:GetNearbyTrees( nCastRange )
			for _, tree in pairs( nTrees )
			do
				local treeLoc = GetTreeLocation( tree )
				if GetUnitToLocationDistance( theMonkeyKing, treeLoc ) < 30
				then
					sCastMotive = '砍大圣的树'
					return BOT_ACTION_DESIRE_HIGH, tree, sCastType, sCastMotive
				end
			end
		end
	end

	--开视野
	if DotaTime() > lastQuellingBladeUseTime + 0.8
		and ( J.IsGoingOnSomeone( bot ) or J.IsFarming( bot ) or J.IsRetreating( bot ) )
	then
		lastQuellingBladeUseTime = DotaTime()

		local nBladeRange = 350
		local nTrees = bot:GetNearbyTrees( nBladeRange )
		local nTreeCount = #nTrees
		if nTreeCount >= 1
		then
			for treeID = 1, nTreeCount
			do
				local tree = nTrees[treeID]
				if bot:IsFacingLocation( GetTreeLocation( tree ), 7 )
				then
					sCastMotive = '开视野'
					return BOT_ACTION_DESIRE_HIGH, tree, sCastType, sCastMotive
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--刷新球
X.ConsiderItemDesire["item_refresher"] = function( hItem )

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
		and J.CanUseRefresherShard( bot )
	then
		hEffectTarget = bot
		sCastMotive = '进攻'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--刷新碎片
X.ConsiderItemDesire["item_refresher_shard"] = function( hItem )

	return X.ConsiderItemDesire["item_refresher"]( hItem )

end


--肉山A杖
X.ConsiderItemDesire["item_ultimate_scepter_roshan"] = function( hItem )

	local nCastRange = 300
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	if hItem:IsFullyCastable()
	then
		hEffectTarget = bot
		sCastMotive = '吃A杖'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--肉山魔晶
X.ConsiderItemDesire["item_aghanims_shard_roshan"] = function( hItem )

	local nCastRange = 300
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	if hItem:IsFullyCastable()
	then
		hEffectTarget = bot
		sCastMotive = '吃魔晶'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end


--阿托斯
X.ConsiderItemDesire["item_rod_of_atos"] = function( hItem )

	local nCastRange = 1100 + aetherRange
	local sCastType = 'unit'
	if hItem:GetName() == "item_gungir" then sCastType = 'ground' end
	local hEffectTarget = nil
	local sCastMotive = nil
	local nEnemysHerosInCastRange = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	for _, npcEnemy in pairs( nEnemysHerosInCastRange )
	do
		if J.IsValid( npcEnemy )
			and npcEnemy:IsChanneling()
			and npcEnemy:HasModifier( "modifier_teleporting" )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			hEffectTarget = npcEnemy
			sCastMotive = '打断:'..J.Chat.GetNormName( hEffectTarget )
			
			if hItem:GetName() == "item_gungir" then hEffectTarget = hEffectTarget:GetLocation() end
			
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if nMode == BOT_MODE_RETREAT
		and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
		and	J.IsValid( nEnemysHerosInCastRange[1] )
		and J.CanCastOnNonMagicImmune( nEnemysHerosInCastRange[1] )
		and J.CanCastOnTargetAdvanced( nEnemysHerosInCastRange[1] )
		and not J.IsDisabled( nEnemysHerosInCastRange[1] )
	then
		hEffectTarget = nEnemysHerosInCastRange[1]
		sCastMotive = '撤退了'
		
		if hItem:GetName() == "item_gungir" then hEffectTarget = hEffectTarget:GetLocation() end
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and not J.IsDisabled( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and GetUnitToUnitDistance( botTarget, bot ) <= nCastRange
			and J.IsMoving( botTarget )
		then
			hEffectTarget = botTarget
			sCastMotive = '进攻:'..J.Chat.GetNormName( hEffectTarget )
			if hItem:GetName() == "item_gungir" then hEffectTarget = hEffectTarget:GetLocation() end
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--撒旦
X.ConsiderItemDesire["item_satanic"] = function( hItem )

	local nCastRange = bot:GetAttackRange() + 150
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if bot:GetHealth() / bot:GetMaxHealth() < 0.62
		and #hNearbyEnemyHeroList > 0
		and ( J.IsValidHero( botTarget ) and J.IsInRange( bot, botTarget, nCastRange )
			 or ( J.IsValidHero( hNearbyEnemyHeroList[1] ) and J.IsInRange( bot, hNearbyEnemyHeroList[1], nCastRange - 200 ) ) )
	then
		hEffectTarget = botTarget
		sCastMotive = '进攻'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--护符
X.ConsiderItemDesire["item_shadow_amulet"] = function( hItem )

	local nCastRange = 600 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if not bot:HasModifier( 'modifier_invisible' )
		and not bot:HasModifier( 'modifier_item_glimmer_cape' )
		and not bot:HasModifier( 'modifier_item_shadow_amulet_fade' )
		and not bot:HasModifier( 'modifier_slardar_amplify_damage' )
		and not bot:HasModifier( 'modifier_item_dustofappearance' )
	then
		local nEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
		for _, enemy in pairs( nEnemyList )
		do
			if enemy:IsAlive()
				and ( enemy:GetAttackTarget() == bot or enemy:IsFacingLocation( bot:GetLocation(), 16 ) )
			then
				local nNearbyEnemyTowers = bot:GetNearbyTowers( 888, true )
				if #nNearbyEnemyTowers == 0
					and lastAmuletTime < DotaTime() - 1.28
					and not J.IsGoingOnSomeone(bot)
				then
					lastAmuletTime = DotaTime()
					hEffectTarget = bot
					sCastMotive = '自己用'
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end

		if bot:IsRooted()
			or J.IsStunProjectileIncoming( bot, 1000 )
		then
			local nNearbyEnemyTowers = bot:GetNearbyTowers( 888, true )
			if #nNearbyEnemyTowers == 0
				and lastAmuletTime < DotaTime() - 1.28
			then
				lastAmuletTime = DotaTime()
				hEffectTarget = bot
				sCastMotive = '撤退了'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	local nNearAllyList = bot:GetNearbyHeroes( 849, false, BOT_MODE_NONE )
	for _, npcAlly in pairs( nNearAllyList )
	do
		if J.IsValid( npcAlly )
			and npcAlly ~= bot
			and not npcAlly:IsIllusion()
			and not npcAlly:IsMagicImmune()
			and not npcAlly:IsInvisible()
			and not npcAlly:HasModifier( 'modifier_invisible' )
			and not npcAlly:HasModifier( 'modifier_item_glimmer_cape' )
			and not npcAlly:HasModifier( 'modifier_item_shadow_amulet_fade' )
			and not npcAlly:HasModifier( 'modifier_slardar_amplify_damage' )
			and not npcAlly:HasModifier( 'modifier_item_dustofappearance' )
			and ( npcAlly:IsStunned()
					or npcAlly:IsRooted()
					or J.IsStunProjectileIncoming( npcAlly, 1000 ) )
		then
			local nNearbyAllyEnemyTowers = npcAlly:GetNearbyTowers( 888, true )
			if #nNearbyAllyEnemyTowers == 0
			then
				hEffectTarget = npcAlly
				sCastMotive = '帮助队友隐身'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--羊刀
X.ConsiderItemDesire["item_sheepstick"] = function( hItem )

	local nCastRange = 700 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	for _, npcEnemy in pairs( nInRangeEnmyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and X.IsWithoutSpellShield( npcEnemy )
		then
			if ( npcEnemy:IsChanneling() or npcEnemy:IsCastingAbility() )
			then
				hEffectTarget = npcEnemy
				sCastMotive = "打断:"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if J.IsRetreating( bot )
			then
				if not J.IsDisabled( npcEnemy )
					and not npcEnemy:IsDisarmed()
				then
					hEffectTarget = npcEnemy
					sCastMotive = "撤退:"..J.Chat.GetNormName( hEffectTarget )
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if	J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsDisabled( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and X.IsWithoutSpellShield( botTarget )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--希瓦
X.ConsiderItemDesire["item_shivas_guard"] = function( hItem )

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange + 50, true, BOT_MODE_NONE )


	local hNearbyCreepList = bot:GetNearbyCreeps( nCastRange, true )
	if #hNearbyCreepList >= 6
		or #nInRangeEnmyList >= 1
	then
		hEffectTarget = bot
		sCastMotive = '启动希瓦'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--大隐刀
X.ConsiderItemDesire["item_silver_edge"] = function( hItem )

	local nCastRange = 1600
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	--破被动
	if J.IsGoingOnSomeone( bot )
		and not bot:HasModifier( 'modifier_slardar_amplify_damage' )
		and not bot:HasModifier( 'modifier_item_dustofappearance' )
		and #hNearbyEnemyTowerList == 0
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, 2400 )
			and J.CanCastOnMagicImmune( botTarget )
		then
			local nearTargetTower = botTarget:GetNearbyTowers( 888, false )
			if #nearTargetTower == 0
			then
				hEffectTarget = botTarget
				sCastMotive = '破坏被动:'..J.Chat.GetNormName( botTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return X.ConsiderItemDesire["item_invis_sword"]( hItem )

end

--大勋章
X.ConsiderItemDesire["item_solar_crest"] = function( hItem )

	return X.ConsiderItemDesire["item_medallion_of_courage"]( hItem )

end

--林肯
X.ConsiderItemDesire["item_sphere"] = function( hItem )

	local nCastRange = 700 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local nNearAllyList = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE )


	--对可能被作为敌方目标的队友使用
	for _, npcAlly in pairs( nNearAllyList )
	do
		if J.IsValidHero( npcAlly )
			and npcAlly ~= bot
			and not npcAlly:IsMagicImmune()
			and not npcAlly:IsInvulnerable()
			and not npcAlly:IsIllusion()
			and not npcAlly:HasModifier( "modifier_item_sphere_target" )
			and not npcAlly:HasModifier( 'modifier_antimage_spell_shield' )
			and ( J.IsUnitTargetProjectileIncoming( npcAlly, 800 )
				 or J.IsWillBeCastUnitTargetSpell( npcAlly, 1200 )
				 or bot:GetHealth() < 150 )
		then
			hEffectTarget = npcAlly
			sCastMotive = '帮助队友'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	if J.IsValidHero( botTarget )
		and J.IsInRange( bot, botTarget, 2400 )
		and not J.IsInRange( bot, botTarget, 800 )
	then
		if #nNearAllyList >= 2
		then
			local targetAlly = nil
			local targetDistance = 9999
			for _, npcAlly in pairs( nNearAllyList )
			do
				if npcAlly ~= bot
					and not npcAlly:IsIllusion()
					and J.IsInRange( npcAlly, botTarget, targetDistance )
					and not npcAlly:HasModifier( "modifier_item_sphere_target" )
					and not npcAlly:HasModifier( 'modifier_antimage_spell_shield' )
				then
					targetAlly = npcAlly
					targetDistance = GetUnitToUnitDistance( botTarget, npcAlly )
					if J.IsHumanPlayer( npcAlly ) then break end
				end
			end
			if targetAlly ~= nil
			then
				hEffectTarget = targetAlly
				sCastMotive = '先给前排套上'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--大骨灰
X.ConsiderItemDesire["item_spirit_vessel"] = function( hItem )

	return X.ConsiderItemDesire["item_urn_of_shadows"]( hItem )

end


--吃树
X.ConsiderItemDesire["item_tango"] = function( hItem )

	local nCastRange = 300 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil


	--share tango
	local tCharge = hItem:GetCurrentCharges()
	if	bot:GetLevel() <= 12
			and ( #hNearbyEnemyHeroList == 0 or nMode == BOT_MODE_LANING )
			and tCharge >= 1
			and DotaTime() > 10
			and DotaTime() > J.Role['fLastGiveTangoTime'] + 40.0
		then
			local hAllyList = bot:GetNearbyHeroes( 800, false, BOT_MODE_NONE )
			for _, npcAlly in pairs( hAllyList )
			do
				if npcAlly ~= bot
				then
					local tangoSlot = npcAlly:FindItemSlot( 'item_tango' )
					if tangoSlot == -1
						and not npcAlly:IsIllusion()
						and npcAlly:GetMaxHealth() - npcAlly:GetHealth() > 200
						and not npcAlly:HasModifier( "modifier_tango_heal" )
						and not npcAlly:HasModifier( "modifier_arc_warden_tempest_double" )
						and npcAlly:GetUnitName() ~= "npc_dota_hero_meepo"
						and J.Item.GetItemCount( npcAlly, "item_tango_single" ) == 0
						and J.Item.GetEmptyInventoryAmount( npcAlly ) >= 4
					then
						J.Role['fLastGiveTangoTime'] = DotaTime()
						hEffectTarget = npcAlly
						sCastMotive = '分享队友吃树'
						return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
					end
				end
			end
	end

	local hTangoSingle = J.IsItemAvailable( 'item_tango_single' )
	if hTangoSingle ~= nil and hTangoSingle:IsFullyCastable() then return 0 end

	return X.ConsiderItemDesire["item_tango_single"]( hItem )

end

X.ConsiderItemDesire["item_tango_single"] = function( hItem )

	if bot:DistanceFromFountain() < 3300 or bot:HasModifier( "modifier_tango_heal" ) then return 0 end

	local nCastRange = 300 + aetherRange
	local sCastType = 'tree'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nUseTangoLostHealth = ( hItem:GetName() == 'item_tango' ) and 200 or 160
	local nLostHealth = bot:GetMaxHealth() - bot:GetHealth()

	if J.IsWithoutTarget( bot )
		and not bot:HasModifier( "modifier_flask_healing" )
		and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
	then
		local trees = bot:GetNearbyTrees( 800 )
		local targetTree = trees[1]
		local nearEnemyList = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
		local nearestEnemy = nearEnemyList[1]
		local nearTowerList = bot:GetNearbyTowers( 1400, true )
		local nearestTower = nearTowerList[1]


		--常规吃树
		if targetTree ~= nil
		then
			local targetTreeLoc = GetTreeLocation( targetTree )
			if nLostHealth > nUseTangoLostHealth
				and IsLocationVisible( targetTreeLoc )
				and IsLocationPassable( targetTreeLoc )
				and ( #nearEnemyList == 0 or not J.IsInRange( bot, nearestEnemy, 800 ) )
				and ( #nearEnemyList == 0 or GetUnitToLocationDistance( bot, targetTreeLoc ) * 1.6 < GetUnitToUnitDistance( bot, nearestEnemy ) )
				and ( #nearTowerList == 0 or GetUnitToLocationDistance( nearestTower, targetTreeLoc ) > 920 )
			then
				hEffectTarget = targetTree
				sCastMotive = '800码内的树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end


		--塔下吃树
		local nAllyTowerList = bot:GetNearbyTowers( 1100, false )
		if #nAllyTowerList >= 1
			and nLostHealth > nUseTangoLostHealth + 20
		then
			local nAllyTower = nAllyTowerList[1]
			if nAllyTower ~= nil
			then
				local nFindTreeDistance = 1100 - GetUnitToUnitDistance( bot, nAllyTower )
				local nearTowerTrees = bot:GetNearbyTrees( nFindTreeDistance )
				local targetTree = nearTowerTrees[1]

				if targetTree ~= nil
				then
					local targetTreeLoc = GetTreeLocation( targetTree )
					if IsLocationVisible( targetTreeLoc )
						and IsLocationPassable( targetTreeLoc )
					then
						hEffectTarget = targetTree
						sCastMotive = '吃塔下的树'
						return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
					end
				end
			end
		end


		--吃近处的树
		local nearbyTrees = bot:GetNearbyTrees( 280 )
		if nearbyTrees[1] ~= nil
			and IsLocationVisible( GetTreeLocation( nearbyTrees[1] ) )
			and IsLocationPassable( GetTreeLocation( nearbyTrees[1] ) )
		then
			if nLostHealth > nUseTangoLostHealth
			then
				hEffectTarget = nearbyTrees[1]
				sCastMotive = '近处的树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if nLostHealth > nUseTangoLostHealth * 0.38
				and bot:WasRecentlyDamagedByAnyHero( 2.0 )
				and ( bot:GetActiveMode() == BOT_MODE_ATTACK
					 or ( bot:GetActiveMode() == BOT_MODE_RETREAT
						 and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH ) )
			then
				hEffectTarget = nearbyTrees[1]
				sCastMotive = '提前吃树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if DotaTime() > 4 * 60 + 30 and botTarget == nil
		and hItem:GetName() == 'item_tango_single'
		and bot:DistanceFromFountain() > 3000
		and nMode ~= BOT_MODE_RUNE
	then
		local tCount = J.Item.GetItemCount( bot, "item_tango_single" )
		local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
		if tCount >= 2
		then
			local trees = bot:GetNearbyTrees( 1200 )
			if trees[1] ~= nil
				and IsLocationVisible( GetTreeLocation( trees[1] ) )
				and IsLocationPassable( GetTreeLocation( trees[1] ) )
				and #hNearbyEnemyHeroList == 0
			then
				hEffectTarget = trees[1]
				sCastMotive = '消耗共享吃树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

		if DotaTime() > 7 * 60 + 30
		then
			local trees = bot:GetNearbyTrees( 1200 )
			if trees[1] ~= nil
				and IsLocationVisible( GetTreeLocation( trees[1] ) )
				and IsLocationPassable( GetTreeLocation( trees[1] ) )
				and nLostHealth > 60
				and #hNearbyEnemyHeroList == 0
			then
				hEffectTarget = trees[1]
				sCastMotive = '用掉共享吃树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

	end

	return BOT_ACTION_DESIRE_NONE

end

--经验书
X.ConsiderItemDesire["item_tome_of_knowledge"] = function( hItem )

	local nCastRange = 300
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	if hItem:IsFullyCastable()
	then
		hEffectTarget = bot
		sCastMotive = '读书'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end


function X.GetLaningTPLocation( nLane )

	if nLane == LANE_TOP
	then
		return J.Site.GetTowerLocation( GetTeam(), TOWER_TOP_1 )
	elseif nLane == LANE_BOT then
		return J.Site.GetTowerLocation( GetTeam(), TOWER_BOT_1 )
	end

	return J.Site.GetTowerLocation( GetTeam(), TOWER_MID_1 )

end

function X.GetDefendTPLocation( nLane )

	return GetLaneFrontLocation( GetTeam(), nLane, -950 )

end

function X.GetPushTPLocation( nLane )

	local laneFront = GetLaneFrontLocation( GetTeam(), nLane, 0 )
	local bestTpLoc = J.GetNearbyLocationToTp( laneFront )
	if J.GetLocationToLocationDistance( laneFront, bestTpLoc ) < 2000
	then
		return bestTpLoc
	end

end


function X.CanJuke()

	local allyTowers = bot:GetNearbyTowers( 350, false )

	if allyTowers[1] ~= nil
		and allyTowers[1]:DistanceFromFountain() > bot:DistanceFromFountain() + 100
		and J.GetEnemyCount( bot, 700 ) == 0
	then return true end

	if J.GetModifierTime(bot, 'modifier_dazzle_shallow_grave') > 3.0
		or J.GetModifierTime(bot, 'modifier_oracle_false_promise_timer') > 3.0
	then return true end

	local enemyPids = GetTeamPlayers( GetOpposingTeam() )

	local heroHG = GetHeightLevel( bot:GetLocation() )
	for i = 1, #enemyPids
	do
		local info = GetHeroLastSeenInfo( enemyPids[i] )
		if info ~= nil then
			local dInfo = info[1]
			if dInfo ~= nil
				and dInfo.time_since_seen < 2.0
			then
				if GetUnitToLocationDistance( bot, dInfo.location ) < 1300
					and GetHeightLevel( dInfo.location ) < heroHG
				then
					return false
				end

				if GetUnitToLocationDistance( bot, dInfo.location ) < 600
				then
					local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 600, true, BOT_MODE_NONE )
					if #hNearbyEnemyHeroList == 0
					then
						return false
					end
				end
			end
		end
	end

	local totalDamage = 0
	local nEnemies = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemies )
	do
		local enemyDamage = enemy:GetEstimatedDamageToTarget( true, bot, 4.0, DAMAGE_TYPE_ALL )
		totalDamage = totalDamage + enemyDamage
		if bot:GetHealth() <= totalDamage
		then
			return false
		end
	end

	return true

end


function X.GetNumHeroWithinRange( nRange )

	local enemyPids = GetTeamPlayers( GetOpposingTeam() )

	local cHeroes = 0
	for i = 1, #enemyPids
	do
		local info = GetHeroLastSeenInfo( enemyPids[i] )
		if info ~= nil then
			local dInfo = info[1]
			if dInfo ~= nil and dInfo.time_since_seen < 2.0
				and GetUnitToLocationDistance( bot, dInfo.location ) < nRange
			then
				cHeroes = cHeroes + 1
			end
		end
	end

	return cHeroes

end


function X.IsFarmingAlways( bot )

	local nTarget = bot:GetAttackTarget()
	if J.IsValid( nTarget )
		and nTarget:GetTeam() == TEAM_NEUTRAL
		and not J.IsRoshan( nTarget )
		and not J.IsKeyWordUnit( "warlock", nTarget )
		and X.GetNumEnemyNearby( GetAncient( GetTeam() ) ) >= 2
	then
		return true
	end

	local nNearAllyList = bot:GetNearbyHeroes( 800, false, BOT_MODE_NONE )
	if J.IsValid( nTarget )
		and nTarget:IsAncientCreep()
		and not J.IsRoshan( nTarget )
		and not J.IsKeyWordUnit( "warlock", nTarget )
		and bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
		and bot:GetUnitName() ~= 'npc_dota_hero_ogre_magi'
		and #nNearAllyList < 2
	then
		return true
	end

	if X.GetNumEnemyNearby( GetAncient( GetTeam() ) ) >= 4
		and bot:DistanceFromFountain() >= 4800
		and #nNearAllyList < 2
	then
		return true
	end

	return false
end

--TP
X.ConsiderItemDesire["item_tpscroll"] = function( hItem )

	if nMode == BOT_MODE_RUNE
		or ( bot:IsRooted() )
		or ( bot:HasModifier( "modifier_item_armlet_unholy_strength" ) )
		or ( bot:HasModifier( "modifier_kunkka_x_marks_the_spot" ) )
		or ( bot:HasModifier( "modifier_sniper_assassinate" ) )
		or ( bot:HasModifier( "modifier_viper_nethertoxin" ) )
		or ( bot:HasModifier( "modifier_oracle_false_promise_timer" ) and J.GetModifierTime( bot, "modifier_oracle_false_promise_timer" ) <= 3.2 )
		or ( bot:HasModifier( "modifier_jakiro_macropyre_burn" ) and J.GetModifierTime( bot, "modifier_jakiro_macropyre_burn" ) >= 1.4 )
		or ( bot:HasModifier( "modifier_arc_warden_tempest_double" ) and bot:GetRemainingLifespan() < 3.3 )
	then return BOT_ACTION_DESIRE_NONE end

	if bot:GetHealth() < 240
	then
		local nProDamage = J.GetAttackProjectileDamageByRange( bot, 1600 ) * 2
		if bot:GetHealth() < bot:GetActualIncomingDamage( nProDamage, DAMAGE_TYPE_PHYSICAL )
		then return BOT_ACTION_DESIRE_NONE end
	end


	local nNearbyEnemyTowers = bot:GetNearbyTowers( 888, true )
	if #nNearbyEnemyTowers > 0 then return BOT_ACTION_DESIRE_NONE end

	local tpLoc = nil
	local sCastType = 'ground'
	local hEffectTarget = nil
	local sCastMotive = nil


	local nMinTPDistance = 5500
	local nMode = bot:GetActiveMode()
	local nModeDesire = bot:GetActiveModeDesire()
	local botLocation = bot:GetLocation()
	local botHP = J.GetHP( bot )
	local botMP = J.GetMP( bot )
	local nEnemyCount = X.GetNumHeroWithinRange( 1600 )
	local nAllyCount = J.GetAllyCount( bot, 1600 )
	local itemFlask = J.IsItemAvailable( "item_flask" )

	if bot:GetLevel() > 12 and bot:DistanceFromFountain() < 600 then nMinTPDistance = nMinTPDistance + 600 end

	--对线
	if nMode == BOT_MODE_LANING
		and nEnemyCount == 0
		and bot:GetLevel() <= 10
		and DotaTime() < 11 * 60
	then
		local assignedLane = bot:GetAssignedLane()
		local botAmount = GetAmountAlongLane( assignedLane, botLocation )
		local laneFront = GetLaneFrontAmount( GetTeam(), assignedLane, false )
		if botAmount.distance > nMinTPDistance - 500
			or botAmount.amount < laneFront / 5
		then
			tpLoc = X.GetLaningTPLocation( assignedLane )
		end

		if tpLoc ~= nil
		then
			hEffectTarget = tpLoc
			sCastMotive = '前往对线'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	--守塔
	if J.IsDefending( bot )
		and nModeDesire >= BOT_MODE_DESIRE_MODERATE
		and nEnemyCount == 0
	then
		local nDefendLane, sLane = LANE_MID, 'tower_mid'
		if nMode == BOT_MODE_DEFEND_TOWER_TOP then nDefendLane, sLane = LANE_TOP, 'tower_top' end
		if nMode == BOT_MODE_DEFEND_TOWER_BOT then nDefendLane, sLane = LANE_BOT, 'tower_bot' end

		local botAmount = GetAmountAlongLane( nDefendLane, botLocation )
		local laneFront = GetLaneFrontAmount( GetTeam(), nDefendLane, false )
		if botAmount.distance > nMinTPDistance
			or botAmount.amount < laneFront / 5
		then
			tpLoc = X.GetDefendTPLocation( nDefendLane )
		end

		if tpLoc ~= nil
			and GetUnitToLocationDistance( bot, tpLoc ) > nMinTPDistance - 500
		then
			hEffectTarget = tpLoc
			sCastMotive = '前往守塔:'..sLane
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	--推塔
	if J.IsPushing( bot )
		and nModeDesire >= BOT_MODE_DESIRE_MODERATE
		and nEnemyCount == 0
	then
		local nPushLane, sLane = LANE_MID, 'tower_mid'
		if nMode == BOT_MODE_PUSH_TOWER_TOP then nPushLane, sLane = LANE_TOP, 'tower_top' end
		if nMode == BOT_MODE_PUSH_TOWER_BOT then nPushLane, sLane = LANE_BOT, 'tower_bot' end

		local botAmount = GetAmountAlongLane( nPushLane, botLocation )
		local laneFront = GetLaneFrontAmount( GetTeam(), nPushLane, false )
		if botAmount.distance > nMinTPDistance
			or botAmount.amount < laneFront / 5
		then
			tpLoc = X.GetPushTPLocation( nPushLane )
		end

		if tpLoc ~= nil
			and GetUnitToLocationDistance( bot, tpLoc ) > nMinTPDistance - 600
		then
			hEffectTarget = tpLoc
			sCastMotive = '前往推塔:'..sLane
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	--保人
	if nMode == BOT_MODE_DEFEND_ALLY
		and nModeDesire >= BOT_MODE_DESIRE_MODERATE
		and J.Role.CanBeSupport( bot:GetUnitName() )
		and nEnemyCount == 0
	then
		local target = bot:GetTarget()
		if target ~= nil
			and target:IsHero()
			and GetUnitToUnitDistance( bot, target ) > nMinTPDistance
		then
			local bestTpLoc = J.GetNearbyLocationToTp( target:GetLocation() )
			if bestTpLoc ~= nil
				and GetUnitToLocationDistance( bot, bestTpLoc ) > nMinTPDistance - 800
			then
				tpLoc = bestTpLoc
			end
		end

		if tpLoc ~= nil
		then
			hEffectTarget = tpLoc
			sCastMotive = '支援队友:'..J.Chat.GetNormName( target )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	--塔下保人



	--撤退
	if nMode == BOT_MODE_RETREAT
		and nModeDesire >= BOT_MODE_DESIRE_MODERATE
		and bot:GetLevel() >= 3
		and not bot:HasModifier( "modifier_arc_warden_tempest_double" )
	then

		--第一种情况:无敌人无大药回家恢复
		if botHP < 0.19
			and ( bot:WasRecentlyDamagedByAnyHero( 8.0 ) or botHP < 0.12 )
			and bot:GetUnitName() ~= 'npc_dota_hero_huskar'
			and ( bot:GetUnitName() ~= 'npc_dota_hero_slark' or bot:GetLevel() <= 5 )
			and nEnemyCount == 0
			and itemFlask == nil
			and not bot:HasModifier( "modifier_tango_heal" )
			and not bot:HasModifier( "modifier_flask_healing" )
			and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and not bot:HasModifier( "modifier_item_urn_heal" )
			and not bot:HasModifier( "modifier_item_spirit_vessel_heal" )
			and bot:DistanceFromFountain() > nMinTPDistance
		then
			tpLoc = J.GetTeamFountain()
			sCastMotive = '撤退:1'
			return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
		end


		--第二种情况:有多个敌人但可以卡视野TP
		local nAttackAllyList = bot:GetNearbyHeroes( 1500, false, BOT_MODE_ATTACK )
		if botHP < ( 0.15 + 0.24 * nEnemyCount )
			and #nAttackAllyList == 0
			and bot:WasRecentlyDamagedByAnyHero( 6.0 )
			and X.CanJuke()
			and nEnemyCount <= ( botHP < 0.4 and 2 or 3 )
			and nAllyCount <= 2
			and itemFlask == nil
			and not bot:HasModifier( "modifier_tango_heal" )
			and not bot:HasModifier( "modifier_flask_healing" )
			and not bot:HasModifier( "modifier_item_urn_heal" )
			and not bot:HasModifier( "modifier_item_spirit_vessel_heal" )
			and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and bot:DistanceFromFountain() > nMinTPDistance - 600
		then
			tpLoc = J.GetTeamFountain()
			sCastMotive = '撤退:2'
			return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
		end


		--第三种情况:只有一个敌人直接T回家
		if ( botHP < 0.34 or botHP + botMP < 0.43 )
			and #nAttackAllyList == 0
			and bot:GetLevel() >= 9
			and X.CanJuke()
			and nEnemyCount <= 1
			and nAllyCount <= 2
			and itemFlask == nil
			and bot:GetAttackTarget() == nil
			and bot:GetUnitName() ~= 'npc_dota_hero_huskar'
			and bot:GetUnitName() ~= 'npc_dota_hero_slark'
			and not bot:HasModifier( "modifier_flask_healing" )
			and not bot:HasModifier( "modifier_clarity_potion" )
			and not bot:HasModifier( "modifier_filler_heal" )
			and not bot:HasModifier( "modifier_item_urn_heal" )
			and not bot:HasModifier( "modifier_item_spirit_vessel_heal" )
			and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and not bot:HasModifier( "modifier_bottle_regeneration" )
			and not bot:HasModifier( "modifier_tango_heal" )
			and bot:DistanceFromFountain() > nMinTPDistance - 600
		then
			tpLoc = J.GetTeamFountain()
			sCastMotive = '撤退:3'
			return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
		end
	end


	--TP出去发育
	if nMode == BOT_MODE_FARM
		and bot:DistanceFromFountain() < 800
		and botHP > 0.9
		and botMP > 0.8
	then
		local mostFarmDesireLane, mostFarmDesire = J.GetMostFarmLaneDesire()

		if mostFarmDesire > BOT_MODE_DESIRE_HIGH
		then
			farmTpLoc = GetLaneFrontLocation( GetTeam(), mostFarmDesireLane, 0 )
			local bestTpLoc = J.GetNearbyLocationToTp( farmTpLoc )
			if bestTpLoc ~= nil and farmTpLoc ~= nil
				and J.IsLocHaveTower( 2000, false, farmTpLoc )
				and GetUnitToLocationDistance( bot, bestTpLoc ) > nMinTPDistance
			then
				tpLoc = farmTpLoc
			end
		end

		if tpLoc ~= nil
		then
			hEffectTarget = tpLoc
			sCastMotive = '出去发育'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

	end


	--TP发育带线
	if bot:GetLevel() >= 10
		and nMode ~= BOT_MODE_ROSHAN
		and J.GetAllyCount( bot, 1600 ) <= 2
		and J.Role.ShouldTpToFarm()
		and not J.Role.IsAllyHaveAegis()
		and not J.Role.CanBeSupport( bot:GetUnitName() )
		and not J.IsEnemyHeroAroundLocation( GetAncient( GetTeam() ):GetLocation(), 3300 )
	then
		local nAttackAllyList = bot:GetNearbyHeroes( 1600, false, BOT_MODE_ATTACK )
		local nNearEnemyList = bot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE )
		local nCreeps= bot:GetNearbyCreeps( 1600, true )
		local mostFarmDesireLane, mostFarmDesire = J.GetMostFarmLaneDesire()
		
		local isTravelBootsAvailable = false
		if J.IsItemAvailable( "item_travel_boots" )
			or J.IsItemAvailable( "item_travel_boots_2" )
		then
			isTravelBootsAvailable = true
		end

		if mostFarmDesire > ( isTravelBootsAvailable and 0.7 or 0.8 )
			and #nNearEnemyList == 0
			and #nCreeps == 0
			and #nAttackAllyList == 0
		then

			if isTravelBootsAvailable
			then
				tpLoc = GetLaneFrontLocation( GetTeam(), mostFarmDesireLane, - 600 )
				local nNearAllyList = J.GetAlliesNearLoc( tpLoc, 1600 )
				if GetUnitToLocationDistance( bot, tpLoc ) > nMinTPDistance - 1500
					and #nNearAllyList == 0
				then
					J.Role['lastFarmTpTime'] = DotaTime()
					sCastMotive = '飞鞋带线'
					return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
				end
			end

			tpLoc = GetLaneFrontLocation( GetTeam(), mostFarmDesireLane, 0 )
			local bestTpLoc = J.GetNearbyLocationToTp( tpLoc )
			local nNearAllyList = J.GetAlliesNearLoc( tpLoc, 1600 )
			if bestTpLoc ~= nil
				and J.IsLocHaveTower( 1850, false, tpLoc )
				and GetUnitToLocationDistance( bot, bestTpLoc ) > nMinTPDistance - 800
				and #nNearAllyList == 0
			then
				J.Role['lastFarmTpTime'] = DotaTime()
				sCastMotive = '线上打钱'
				return BOT_ACTION_DESIRE_HIGH, bestTpLoc, sCastType, sCastMotive
			end
		end
	end


	--支援团战和守家
	if bot:GetLevel() > 10
		and nMode ~= BOT_MODE_SECRET_SHOP
		and nMode ~= BOT_MODE_ROSHAN
		and nMode ~= BOT_MODE_ATTACK
		and ( botTarget == nil or not botTarget:IsHero() )
		--and J.GetAllyCount( bot, 1600 ) <= 3 --守护遗迹bug
	then
		local nNearEnemyList = bot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE )
		local nTeamFightLocation = J.GetTeamFightLocation( bot )
		local isTravelBootsAvailable = false
		if J.IsItemAvailable( "item_travel_boots" )
			or J.IsItemAvailable( "item_travel_boots_2" )
		then
			isTravelBootsAvailable = true
		end
		
		
		if #nNearEnemyList == 0
			and nTeamFightLocation ~= nil
			and GetUnitToLocationDistance( bot, nTeamFightLocation ) > nMinTPDistance - 1200
		then

			if isTravelBootsAvailable
			then
				sCastMotive = '飞鞋支援团战距离:'..GetUnitToLocationDistance( bot, nTeamFightLocation )
				return BOT_ACTION_DESIRE_HIGH, nTeamFightLocation, sCastType, sCastMotive
			end

			local bestTpLoc = J.GetNearbyLocationToTp( nTeamFightLocation )
			if bestTpLoc ~= nil
				and J.GetLocationToLocationDistance( bestTpLoc, nTeamFightLocation ) < 1800
				and GetUnitToLocationDistance( bot, bestTpLoc ) > nMinTPDistance - 1200
			then
				sCastMotive = '支援团战:'..GetUnitToLocationDistance( bot, nTeamFightLocation )
				return BOT_ACTION_DESIRE_HIGH, bestTpLoc, sCastType, sCastMotive
			end
		end

		--守护遗迹
		local nAncient = GetAncient( GetTeam() )
		if bot:GetLevel() >= 18	
			and #nNearEnemyList == 0
			and J.Role.ShouldTpToFarm()
			and bot:DistanceFromFountain() > 2000
			and GetUnitToUnitDistance( bot, nAncient ) > nMinTPDistance - 200
			and J.GetAroundTargetAllyHeroCount( nAncient, 1400 ) == 0
		then
			local nEnemyLaneFront = J.GetNearestLaneFrontLocation( nAncient:GetLocation(), true, 400 )
			if nEnemyLaneFront ~= nil
				and GetUnitToLocationDistance( nAncient, nEnemyLaneFront ) <= 1600
			then

				J.Role['lastFarmTpTime'] = DotaTime()
				sCastMotive = '守护遗迹'
				return BOT_ACTION_DESIRE_HIGH, nAncient:GetLocation(), sCastType, sCastMotive
			end
			
			local ancientTower1 = GetTower(GetTeam(), 9)
			local ancientTower2 = GetTower(GetTeam(), 10)
			if ancientTower1 == nil and ancientTower2 == nil
--				and nAncient:WasRecentlyDamagedByCreep( 5.0 )
			then
				local nAllEnemyCreeps = GetUnitList( UNIT_LIST_ENEMY_CREEPS )
				for _, creep in pairs( nAllEnemyCreeps )
				do
					if GetUnitToUnitDistance( nAncient, creep ) <= 800
						and ( creep:GetAttackTarget() == nAncient or botLV >= 18 )
					then
						J.Role['lastFarmTpTime'] = DotaTime()
						sCastMotive = '保护遗迹'
						return BOT_ACTION_DESIRE_HIGH, nAncient:GetLocation(), sCastType, sCastMotive
					end
				end
			end
			
		end

	end

	--回复状态
	if ( botHP + botMP < 0.3 or botHP < 0.2 )
		and bot:GetLevel() >= 6
		and bot:GetUnitName() ~= 'npc_dota_hero_huskar'
		and bot:GetUnitName() ~= 'npc_dota_hero_slark'
		and not bot:HasModifier( "modifier_arc_warden_tempest_double" )
	then
		if	X.CanJuke()
			and bot:DistanceFromFountain() > nMinTPDistance + 200
			and nEnemyCount <= 1 and nAllyCount <= 1
			and J.GetProperTarget( bot ) == nil
			and itemFlask == nil
			and bot:GetAttackTarget() == nil
			and not bot:HasModifier( "modifier_flask_healing" )
			and not bot:HasModifier( "modifier_clarity_potion" )
			and not bot:HasModifier( "modifier_filler_heal" )
			and not bot:HasModifier( "modifier_item_urn_heal" )
			and not bot:HasModifier( "modifier_item_spirit_vessel_heal" )
			and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and not bot:HasModifier( "modifier_bottle_regeneration" )
			and not bot:HasModifier( "modifier_tango_heal" )
		then
			tpLoc = J.GetTeamFountain()
		end

		if tpLoc ~= nil
		then
			hEffectTarget = tpLoc
			sCastMotive = '回复状态'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	--血魔大
	if bot:HasModifier( 'modifier_bloodseeker_rupture' ) and nEnemyCount <= 1
		and J.GetModifierTime( bot, "modifier_bloodseeker_rupture" ) >= 3.1
	then
		local nAllyCount = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE )
		if #nAllyCount <= 1 and X.CanJuke()
		then
			tpLoc = J.GetTeamFountain()
		end

		if tpLoc ~= nil
		then
			hEffectTarget = tpLoc
			sCastMotive = '躲血魔大'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	--处理特殊情况一
	if X.IsFarmingAlways( bot )
	then
		tpLoc = GetAncient( GetTeam() ):GetLocation()
		sCastMotive = '处理特殊情况一'
		return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
	end

	--处理特殊情况二
	if J.IsStuck( bot ) --and nEnemyCount == 0
	then
		tpLoc = GetAncient( GetTeam() ):GetLocation()
		sCastMotive = '处理特殊情况二'
		return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
	end
	
	if J.Role.ShouldTpToDefend()
		and bot:DistanceFromFountain() > 3800
	then
		tpLoc = GetAncient( GetTeam() ):GetLocation()
		sCastMotive = '立即TP守家'
		return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end


--骨灰
X.ConsiderItemDesire["item_urn_of_shadows"] = function( hItem )

	if hItem:GetCurrentCharges() == 0 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 950 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not botTarget:HasModifier( "modifier_item_urn_damage" )
			and not botTarget:HasModifier( "modifier_item_spirit_vessel_damage" )
			and not botTarget:HasModifier( "modifier_arc_warden_tempest_double" )
			and ( J.GetHP( botTarget ) < 0.95 or J.IsInRange( bot, botTarget, 700 ) )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if bot:GetActiveMode() ~= BOT_MODE_ROSHAN
	then
		local hAllyList = bot:GetNearbyHeroes( nCastRange + 80, false, BOT_MODE_NONE )
		local hNeedHealAlly = nil
		local nNeedHealAllyHealth = 99999
		for _, npcAlly in pairs( hAllyList )
		do
			if J.IsValid( npcAlly )
				and not npcAlly:IsIllusion()
				and npcAlly:DistanceFromFountain() > 800
				and J.CanCastOnNonMagicImmune( npcAlly )
				and not npcAlly:WasRecentlyDamagedByAnyHero( 3.1 )
				and not npcAlly:HasModifier( "modifier_item_spirit_vessel_heal" )
				and not npcAlly:HasModifier( "modifier_item_urn_heal" )
				and not npcAlly:HasModifier( "modifier_fountain_aura" )
				and not npcAlly:HasModifier( "modifier_arc_warden_tempest_double" )
				and npcAlly:GetMaxHealth() - npcAlly:GetHealth() > 450
				and #hNearbyEnemyHeroList == 0 
			then
				if( npcAlly:GetHealth() < nNeedHealAllyHealth )
				then
					hNeedHealAlly = npcAlly
					nNeedHealAllyHealth = npcAlly:GetHealth()
				end
			end
		end

		if( hNeedHealAlly ~= nil )
		then
			hEffectTarget = hNeedHealAlly
			sCastMotive = '治疗:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--纷争
X.ConsiderItemDesire["item_veil_of_discord"] = function( hItem )

	local nCastRange = 1000 + aetherRange
	local sCastType = 'ground'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	local hEnemyList= bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	if hEnemyList ~= nil and #hEnemyList > 0
	then
		local nAOELocation = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, 500 , 0, 0 )
		if nAOELocation.count >= 2
			and GetUnitToLocationDistance( bot, nAOELocation.targetloc ) <= nCastRange
		then
			hEffectTarget = nAOELocation.targetloc
			sCastMotive = 'Aoe远处敌人'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	hEnemyList = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
	if hEnemyList ~= nil and #hEnemyList > 0
	then
		local nAOELocation = bot:FindAoELocation( true, true, bot:GetLocation(), 800, 400 , 0, 0 )
		if nAOELocation.count >= 1
			and GetUnitToLocationDistance( bot, nAOELocation.targetloc ) <= 1000
		then
			hEffectTarget = nAOELocation.targetloc
			sCastMotive = 'Aoe近处敌人'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	local LaneCreeps=bot:GetNearbyLaneCreeps( 1500, true )
	if LaneCreeps ~= nil and #LaneCreeps >= 6 then
		local nAOELocation = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, 400 , 0, 0 )
		if nAOELocation.count >= 8
			and GetUnitToLocationDistance( bot, nAOELocation.targetloc ) <= nCastRange
		then
			hEffectTarget = nAOELocation.targetloc
			sCastMotive = 'Aoe小兵'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end



--真眼
local nLastCheckSentryTime = 0
X.ConsiderItemDesire["item_ward_sentry"] = function( hItem )

	local nCastRange = 500 + aetherRange
	local sCastType = 'ground'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
	local nAllyTowerList = bot:GetNearbyTowers( 1200, false )


	--进攻时对拥有隐身能力的敌人使用
	if J.IsGoingOnSomeone( bot )
		and #nInRangeEnmyList >= 1
	then
		local targetHero = nil
		for _, npcEnemy in pairs( nInRangeEnmyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.IsInRange( bot, npcEnemy, 900 )
				and J.CanCastOnMagicImmune( npcEnemy )
				and X.HasInvisibilityOrItem( npcEnemy )
				and not npcEnemy:HasModifier( "modifier_slardar_amplify_damage" )
				and not npcEnemy:HasModifier( "modifier_item_dustofappearance" )
				and not J.Site.IsLocationHaveTrueSight( npcEnemy:GetLocation() )
			then
				hEffectTarget = J.GetUnitTowardDistanceLocation( bot, npcEnemy, nCastRange )
				sCastMotive = '插真眼针对:'..J.Chat.GetNormName( npcEnemy )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

	end


	--路过丢掉的友方二三塔基时使用
	if #nAllyTowerList == 0
		and DotaTime() > nLastCheckSentryTime + 2.0
	then
		nLastCheckSentryTime = DotaTime()
		local nTowerNumberList = {1, 4, 7, 2, 5, 8}
		for _, i in pairs( nTowerNumberList )
		do
			local tower = GetTower( GetTeam(), i )
			if tower == nil
			then
				local vTowerLocation = J.Site.GetTowerLocation( GetTeam(), i )
				if GetUnitToLocationDistance( bot, vTowerLocation ) <= 800
					and not J.Site.IsLocationHaveTrueSight( vTowerLocation )
				then
					hEffectTarget = vTowerLocation
					sCastMotive = '插真眼针补塔基'
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE

end


function X.HasInvisibilityOrItem( npcEnemy )

	if npcEnemy:HasInvisibility( false )
		or J.HasItem( npcEnemy, "item_shadow_amulet" )
		or J.HasItem( npcEnemy, "item_glimmer_cape" )
		or J.HasItem( npcEnemy, "item_invis_sword" )
		or J.HasItem( npcEnemy, "item_silver_edge" )
	then
		return true
	end

	return false

end



--GG树
local lastKACount = -1
X.ConsiderItemDesire["item_ironwood_tree"] = function( hItem )

	local nCastRange = 600
	local sCastType = 'ground'
	local hEffectTarget = nil
	local sCastMotive = nil

	if lastKACount == -1 then lastKACount = GetHeroKills( bot:GetPlayerID() ) + GetHeroAssists( bot:GetPlayerID() ) end

	if lastKACount < GetHeroKills( bot:GetPlayerID() ) + GetHeroAssists( bot:GetPlayerID() )
	then
		lastKACount = -1
		hEffectTarget = J.GetFaceTowardDistanceLocation( bot, nCastRange )
		sCastMotive = 'GG'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end



--奥术指环
X.ConsiderItemDesire["item_arcane_ring"] = function( hItem )

	return X.ConsiderItemDesire["item_arcane_boots"]( hItem )

end


--蜂王浆
local royalJellyTime = nil
X.ConsiderItemDesire["item_royal_jelly"] = function( hItem )

	local nCastRange = 800
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 800 )
	local nMaxNetworth = 0

	if royalJellyTime == nil
	then
		royalJellyTime = DotaTime()
	else
		if royalJellyTime < DotaTime() - 2.0
		then
			for i = 1, 5
			do
				local npcAlly = GetTeamMember( i )
				if J.IsValidHero( npcAlly )
					and not npcAlly:HasModifier( "modifier_royal_jelly" )
					and npcAlly:GetNetWorth() > nMaxNetworth
				then
					hEffectTarget = npcAlly
					nMaxNetworth = npcAlly:GetNetWorth()
				end
			end

			if hEffectTarget ~= nil
			then
				royalJellyTime = nil
				sCastMotive = '给队友吃:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE

end


--可靠铁铲
X.ConsiderItemDesire["item_trusty_shovel"] = function( hItem )

	if GetTeamMember( 1 ):IsBot() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 800
	local sCastType = 'ground'
	local hEffectTarget = nil
	local sCastMotive = nil

	if #hNearbyEnemyHeroList == 0
	then
		hEffectTarget = bot:GetLocation()
		sCastMotive = '挖一下'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end



--精华指环
X.ConsiderItemDesire["item_essence_ring"] = function( hItem )

	if bot:DistanceFromFountain() < 1000 then return 0 end

	local nCastRange = 600
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE )

	if bot:GetMaxHealth() - bot:GetHealth() > 600
		and J.IsAllowedToSpam( bot, 200 )
	then
		hEffectTarget = bot
		sCastMotive = '治疗自己'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return X.ConsiderItemDesire["item_faerie_fire"]( hItem )

end


--网虫腿
X.ConsiderItemDesire["item_spider_legs"] = function( hItem )

	return X.ConsiderItemDesire["item_phase_boots"]( hItem )

end


--闪灵
X.ConsiderItemDesire["item_flicker"] = function( hItem )

	if bot:DistanceFromFountain() < 600 or bot:IsRooted() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 600
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE )

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and ( bot:IsSilenced() or bot:IsRooted() )
		then
			hEffectTarget = bot
			sCastMotive = '驱散沉默或缠绕'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and #nInRangeEnmyList >= 1
	then
		hEffectTarget = bot
		sCastMotive = "撤退"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end


	return BOT_ACTION_DESIRE_NONE

end

--忍者用具
X.ConsiderItemDesire["item_ninja_gear"] = function( hItem )

	local nCastRange = 1600
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and not J.IsInRange( bot, botTarget, botTarget:GetCurrentVisionRange() )
			and J.IsInRange( bot, botTarget, 2800 )
		then
			local hEnemyCreepList = bot:GetNearbyLaneCreeps( 800, true )
			if #hEnemyCreepList == 0 and #hNearbyEnemyHeroList == 0
			then
				hEffectTarget = botTarget
				sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

--幻术师披风
X.ConsiderItemDesire["item_illusionsts_cape"] = function( hItem )

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil

	if J.IsValid( botTarget )
		and J.IsInRange( bot, botTarget, nCastRange )
	then
		hEffectTarget = botTarget
		sCastMotive = "辅助攻击"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return X.ConsiderItemDesire["item_manta"]( hItem )

end



--灵犀角
X.ConsiderItemDesire["item_minotaur_horn"] = function( hItem )

	return X.ConsiderItemDesire["item_black_king_bar"]( hItem )

end

--原力靴
X.ConsiderItemDesire["item_force_boots"] = function( hItem )

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nEnemyCount = J.GetEnemyCount( bot, 1600 )


	if J.IsRetreating( bot )
		and nEnemyCount >= 1
	then
		if bot:IsFacingLocation( GetAncient( GetTeam() ):GetLocation(), 30 )
			and bot:DistanceFromFountain() > 600
		then
			hEffectTarget = bot
			sCastMotive = '撤退'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and GetUnitToUnitDistance( botTarget, bot ) > bot:GetAttackRange() + 50
			and GetUnitToUnitDistance( botTarget, bot ) < bot:GetAttackRange() + 850
			and bot:IsFacingLocation( botTarget:GetLocation(), 20 )
			and not botTarget:IsFacingLocation( bot:GetLocation(), 100 )
			and nEnemyCount <= 2
		then
			hEffectTarget = bot
			sCastMotive = "进攻"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--林地神行靴
X.ConsiderItemDesire["item_woodland_striders"] = function( hItem )

	if bot:DistanceFromFountain() < 600 then return 0 end

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil

	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 4.0 )
	then
		hEffectTarget = bot
		sCastMotive = "撤退"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

--亡者之书
X.ConsiderItemDesire["item_demonicon"] = function( hItem )

	return X.ConsiderItemDesire["item_necronomicon"]( hItem )

end

--堕天斧
X.ConsiderItemDesire["item_fallen_sky"] = function( hItem )

	local nCastRange = 1600
	local sCastType = 'ground'
	local nRadius = 315
	local nCastDelay = 0.5
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		local nAoeLocation = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLocation ~= nil
		then
			hEffectTarget = nAoeLocation
			sCastMotive = 'Aoe'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
		then
			local nCastLocation = J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius, nCastDelay )
			if nCastLocation ~= nil
			then
				hEffectTarget = nCastLocation
				sCastMotive = "进攻"
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		local bLocation = J.GetLocationTowardDistanceLocation( bot, GetAncient( GetTeam() ):GetLocation(), 1600 )
		local nAttackAllyList = bot:GetNearbyHeroes( 800, false, BOT_MODE_ATTACK )
		if bot:DistanceFromFountain() > 800
			and IsLocationPassable( bLocation )
			and ( #nAttackAllyList == 0 or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH * 0.9 )
			and #nInRangeEnmyList >= 1
		then
			hEffectTarget = bLocation
			sCastMotive = "撤退"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--机械之心
X.ConsiderItemDesire["item_ex_machina"] = function( hItem )

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
		then
			local nSoltList = { 0, 1, 2, 3, 4, 5 }
			local nRemainTime = 0
			for _, nSlot in pairs( nSoltList )
			do
				local hItem = bot:GetItemInSlot( nSlot )
				if hItem ~= nil and hItem:GetName() ~= 'item_refresher'
				then
					local nCooldownTime = hItem:GetCooldownTimeRemaining()
					nRemainTime = nRemainTime + nCooldownTime
				end
			end

			if nRemainTime >= 30
			then
				hEffectTarget = botTarget
				sCastMotive = "刷新CD"
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--暗影邪典
X.ConsiderItemDesire["item_book_of_shadows"] = function( hItem )

	local nCastRange = 700 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	
	--帮队友撤退
	local hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), nCastRange )
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and J.CanCastOnNonMagicImmune( npcAlly )
			and npcAlly:WasRecentlyDamagedByAnyHero( 3.0 )
		then
			local nNearAllysEnemyList = npcAlly:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
			if #nNearAllysEnemyList >= 1
				and not npcAlly:IsInvisible()
				and not J.IsDisabled(npcAlly)
				and npcAlly:GetActiveMode() == BOT_MODE_RETREAT
				and npcAlly:DistanceFromFountain() > 1200
			then
				hEffectTarget = npcAlly
				sCastMotive = '帮队友撤退'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--风暴宝器
X.ConsiderItemDesire["item_stormcrafter"] = function( hItem )

	local nCastRange = 300 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )


	if J.CanCastOnNonMagicImmune( bot )
		and #nInRangeEnmyList > 0
	then
		if bot:IsRooted()
			or ( bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT and bot:IsSilenced() )
		then
			hEffectTarget = bot
			sCastMotive = '解缠绕:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.IsUnitTargetProjectileIncoming( bot, 400 )
		then
			hEffectTarget = bot
			sCastMotive = '防御弹道:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--欺诈师斗篷
X.ConsiderItemDesire["item_trickster_cloak"] = function( hItem )

	return X.ConsiderItemDesire["item_invis_sword"]( hItem )

end

--通灵头带
X.ConsiderItemDesire["item_psychic_headband"] = function( hItem )

	local nCastRange = 800 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if bot:GetActiveMode() == BOT_MODE_RETREAT
	then	
		if J.IsValidHero( nInRangeEnmyList[1] )
			and J.CanCastOnNonMagicImmune( nInRangeEnmyList[1] )
		then
			hEffectTarget = nInRangeEnmyList[1]
			sCastMotive = "撤退了推敌人:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

--凌厉长靴
X.ConsiderItemDesire["item_bullwhip"] = function( hItem )

	local nCastRange = 850 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	
	--追击减速
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and not J.IsDisabled( botTarget )
			and J.IsChasingTarget( bot, botTarget )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( botTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end
	
	
	--帮队友撤退
	local hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), nCastRange )
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and J.CanCastOnNonMagicImmune( npcAlly )
		then
			local nNearAllysEnemyList = npcAlly:GetNearbyHeroes( 1200, true, BOT_MODE_NONE )
			if #nNearAllysEnemyList >= 1
				and not npcAlly:IsInvisible()
				and not J.IsDisabled(npcAlly)
				and npcAlly:GetActiveMode() == BOT_MODE_RETREAT
				and npcAlly:DistanceFromFountain() > 1200
			then
				hEffectTarget = npcAlly
				sCastMotive = '帮队友撤退'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


--缚灵索
X.ConsiderItemDesire["item_gungir"] = function( hItem )

	return X.ConsiderItemDesire["item_rod_of_atos"]( hItem )

end




--新物品
X.ConsiderItemDesire["item_new"] = function( hItem )

	local nCastRange = 300 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( botTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end



function X.IsTargetedByEnemy( building )

	local heroList = GetUnitList( UNIT_LIST_ENEMY_HEROES )
	for _, hero in pairs( heroList )
	do
		if ( GetUnitToUnitDistance( building, hero ) <= hero:GetAttackRange() + 200
			and hero:GetAttackTarget() == building )
		then
			return true
		end
	end

	return false

end

local function UseGlyph()

	if GetGlyphCooldown( ) > 0
		or DotaTime() < 60
		or bot ~= GetTeamMember( 1 )
	then
		return
	end

	local T1 = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
		TOWER_TOP_3,
		TOWER_MID_3,
		TOWER_BOT_3,
		TOWER_BASE_1,
		TOWER_BASE_2
	}

	for _, t in pairs( T1 )
	do
		local tower = GetTower( GetTeam(), t )
		if tower ~= nil and tower:GetHealth() > 0
			and tower:GetHealth() / tower:GetMaxHealth() < 0.36
			and tower:GetAttackTarget() ~= nil
		then
			bot:ActionImmediate_Glyph( )
			return
		end
	end


	local MeleeBarrack = {
		BARRACKS_TOP_MELEE,
		BARRACKS_MID_MELEE,
		BARRACKS_BOT_MELEE
	}

	for _, b in pairs( MeleeBarrack )
	do
		local barrack = GetBarracks( GetTeam(), b )
		if barrack ~= nil and barrack:GetHealth() > 0
			and barrack:GetHealth() / barrack:GetMaxHealth() < 0.5
			and X.IsTargetedByEnemy( barrack )
		then
			bot:ActionImmediate_Glyph( )
			return
		end
	end

	local Ancient = GetAncient( GetTeam() )
	if Ancient ~= nil and Ancient:GetHealth() > 0
		and Ancient:GetHealth() / Ancient:GetMaxHealth() < 0.5
		and X.IsTargetedByEnemy( Ancient )
	then
		bot:ActionImmediate_Glyph( )
		return
	end

end



if not bDeafaultItemHero
then

function ItemUsageThink()

end

end

if not bDeafaultAbilityHero
then

function AbilityUsageThink()

end

end


function BuybackUsageThink()

	BotBuild.SkillsComplement()

	ItemUsageComplement()

	BuybackUsageComplement()

	UseGlyph()

end

function CourierUsageThink()

	CourierUsageComplement()

end

function AbilityLevelUpThink()

	AbilityLevelUpComplement()

end
-- dota2jmz@163.com QQ:2462331592.