-- MasterMerchant Namespace Setup
-- Last Updated September 15, 2014
-- Written July 2014 by Dan Stone (@khaibit) - dankitymao@gmail.com
-- Extended Feb 2015 - Oct 2016 by (@Philgo68) - Philgo68@gmail.com
-- Released under terms in license accompanying this file.
-- Distribution without license is prohibited!

MMScrollList = ZO_SortFilterList:Subclass()
MMScrollList.defaults = {}
-- Sort keys for the scroll lists
MMScrollList.SORT_KEYS = {
  ['price'] = {isNumeric = true},
  ['time'] = {isNumeric = true},
  ['rank'] = {isNumeric = true},
  ['sales'] = {isNumeric = true},
  ['tax'] = {isNumeric = true},
  ['count'] = {isNumeric = true},
  ['name'] = {isNumeric = false},
  ['itemGuildName'] = {isNumeric = false},
  ['guildName'] = {isNumeric = false}
  }

MasterMerchant = {}
MasterMerchant.name = 'MasterMerchant'
MasterMerchant.version = '1.9.5'
MasterMerchant.locale = 'en'
MasterMerchant.viewMode = 'self'
MasterMerchant.isScanning = false
MasterMerchant.checkingForMissingSales = false
MasterMerchant.salesData = {}

-- We do 'lazy' updates on the scroll lists, this is used to
-- mark whether we need to RefreshData() before showing
MasterMerchant.listIsDirty = {['full'] = false, ['guild'] = false, ['listing'] = false}
MasterMerchant.scrollList = nil
MasterMerchant.guildScrollList = nil
MasterMerchant.listingsScrollList = nil
MasterMerchant.calcInput = nil

MasterMerchant.guildSales = nil
MasterMerchant.guildPurchases = nil
MasterMerchant.guildItems = nil
MasterMerchant.guildColor = {}

-- SR/SSIndex are inverted indexes of the ScanResults table
-- Each key is a word found in one of the sales items' searched
-- fields (buyer, guild, item name) and a table of the SalesData
-- indexes that contain that word.  SSIndex is the SelfSales index,
-- SRIndex is everything.
MasterMerchant.SRIndex = {}
MasterMerchant.SSIndex = {}
MasterMerchant.numEvents = {}
MasterMerchant.alertQueue = {}
MasterMerchant.curSort = {'time', 'desc'}
MasterMerchant.curGuildSort = {'rank', 'asc'}
MasterMerchant.uiFragment = {}
MasterMerchant.guildUiFragment = {}
MasterMerchant.statsFragment = {}
MasterMerchant.activeTip = nil
MasterMerchant.tippingControl = nil
MasterMerchant.isShiftPressed = nil
MasterMerchant.isCtrlPressed = nil

MasterMerchant.originalSetupCallback = nil
MasterMerchant.originalSellingSetupCallback = nil
MasterMerchant.originalRosterStatsCallback = nil
MasterMerchant.originalRosterBuildMasterList = nil

-- Gap values for Shell sort, good through a history size of
-- roughly 400k
MasterMerchant.shellGaps = { 198768, 86961, 33936, 13776, 4592,
                        1968, 861, 336, 112, 48, 21, 7, 3, 1 }

-- Sound table for mapping readable names to sound names
MasterMerchant.alertSounds = {
  [1] = {name = "None", sound = 'No_Sound'},
  [2] = {name = "Add Guild Member", sound = 'GuildRoster_Added'},
  [3] = {name = "Armor Glyph", sound = 'Enchanting_ArmorGlyph_Placed'},
  [4] = {name = "Book Acquired", sound = 'Book_Acquired'},
  [5] = {name = "Book Collection Completed", sound = 'Book_Collection_Completed'},
  [6] = {name = "Boss Killed", sound = 'SkillXP_BossKilled'},
  [7] = {name = "Charge Item", sound = 'InventoryItem_ApplyCharge'},
  [8] = {name = "Completed Event", sound = 'ScriptedEvent_Completion'},
  [9] = {name = "Dark Fissure Closed", sound = 'SkillXP_DarkFissureClosed'},
  [10] = {name = "Emperor Coronated", sound = 'Emperor_Coronated_Ebonheart'},
  [11] = {name = "Gate Closed", sound = 'AvA_Gate_Closed'},
  [12] = {name = "Lockpicking Stress", sound = 'Lockpicking_chamber_stress'},
  [13] = {name = "Mail Attachment", sound = 'Mail_ItemSelected'},
  [14] = {name = "Mail Sent", sound = 'Mail_Sent'},
  [15] = {name = "Money", sound = 'Money_Transact'},
  [16] = {name = "Morph Ability", sound = 'Ability_MorphPurchased'},
  [17] = {name = "Not Enough Gold", sound = 'PlayerAction_NotEnoughMoney'},
  [18] = {name = "Not Junk", sound = 'InventoryItem_NotJunk'},
  [19] = {name = "Not Ready", sound = 'Ability_NotReady'},
  [20] = {name = "Objective Complete", sound = 'Objective_Complete'},
  [21] = {name = "Open System Menu", sound = 'System_Open'},
  [22] = {name = "Quest Abandoned", sound = 'Quest_Abandon'},
  [23] = {name = "Quest Complete", sound = 'Quest_Complete'},
  [24] = {name = "Quickslot Empty", sound = 'Quickslot_Use_Empty'},
  [25] = {name = "Quickslot Open", sound = 'Quickslot_Open'},
  [26] = {name = "Raid Life", sound = 'Raid_Life_Display_Shown'},
  [27] = {name = "Remove Guild Member", sound = 'GuildRoster_Removed'},
  [28] = {name = "Repair Item", sound = 'InventoryItem_Repair'},
  [29] = {name = "Rune Removed", sound = 'Enchanting_PotencyRune_Removed'},
  [30] = {name = "Skill Added", sound = 'SkillLine_Added'},
  [31] = {name = "Skill Leveled", sound = 'SkillLine_Leveled'},
  [32] = {name = "Stat Purchase", sound = 'Stats_Purchase'},
  [33] = {name = "Synergy Ready", sound = 'Ability_Synergy_Ready_Sound'},
}


