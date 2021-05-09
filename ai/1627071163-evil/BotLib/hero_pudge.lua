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

tOutFitList['outfit_tank'] = {

	"item_tank_outfit",
	"item_crimson_guard",
	"item_aghanims_shard",
	"item_heavens_halberd",
--	"item_lotus_orb",
	"item_assault",
	"item_travel_boots",
	"item_greater_crit",
	"item_heart",
	"item_moon_shard",
	"item_travel_boots_2",
--	"item_ultimate_scepter_2",

}

tOutFitList['outfit_carry'] = tOutFitList['outfit_tank']

tOutFitList['outfit_mid'] = tOutFitList['outfit_tank']

tOutFitList['outfit_priest'] = tOutFitList['outfit_tank']

tOutFitList['outfit_mage'] = tOutFitList['outfit_tank']



X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_travel_boots",
	"item_quelling_blade",

	"item_black_king_bar",
	"item_magic_wand",
	
	"item_travel_boots",
	"item_magic_wand",
	
	"item_assault",
	"item_ancient_janggo",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_heavens_halberd", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.SkillsComplement()
end

return X