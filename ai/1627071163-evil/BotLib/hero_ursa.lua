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
    ['t20'] = {0, 10},
    ['t15'] = {10, 0},
    ['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
    {1,3,2,1,2,6,1,1,2,2,6,3,3,3,6},
    {1,3,1,2,1,6,1,2,2,2,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_ranged_carry_outfit",
	"item_yasha",
	"item_mask_of_madness",
	"item_aghanims_shard",
	"item_sange_and_yasha",
	"item_ultimate_scepter",
	"item_black_king_bar",
	"item_travel_boots",
	"item_broken_satanic",
	"item_bloodthorn",
	"item_moon_shard",
	"item_travel_boots_2",
	"item_eagle",
	"item_ultimate_scepter_2",
	"item_butterfly",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']
tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']



X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_ultimate_scepter",
    "item_urn_of_shadows",

    "item_satanic",
    "item_magic_wand",

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

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList

function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end


	nKeepMana = 160
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )


end

return X