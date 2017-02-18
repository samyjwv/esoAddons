local DTAddon = _G['DTAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- General Strings.
	L.DTAddon_Title		= 'Dungeon Tracker'
	L.DTAddon_CNorm		= 'Completed Normal:'
	L.DTAddon_CVet		= 'Completed Veteran:'
	L.DTAddon_CNormI	= 'Completed Normal I:'
	L.DTAddon_CNormII	= 'Completed Normal II:'
	L.DTAddon_CVetI		= 'Completed Veteran I:'
	L.DTAddon_CVetII	= 'Completed Veteran II:'
	L.DTAddon_CGChal	= 'Completed Group Challenge:'
	L.DTAddon_CDBoss	= 'All Bosses Defeated:'

-- Panel Strings.
	L.DTAddon_MAPOpt	= 'Map Options'
	L.DTAddon_SLFGt		= 'Show LFG Dungeon Info'
	L.DTAddon_SLFGtD	= 'Show list of characters that have completed a Dungeon in the Group Finder tooltip.'
	L.DTAddon_SNComp	= 'Normal Dungeon Completion'
	L.DTAddon_SNCompD	= 'Show list of characters that have completed the Dungeon or Trial on Normal mode in the tooltip.'
	L.DTAddon_SVComp	= 'Veteran Dungeon Completion'
	L.DTAddon_SVCompD	= 'Show list of characters that have completed the Dungeon or Trial on Veteran mode in the tooltip.'
	L.DTAddon_SGFComp	= 'Dungeon Faction Completion'
	L.DTAddon_SGFCompD	= 'Show current character progress towards completing all Group Dungeons in the faction of the highlighted dungeon. Requires Track Character.'
	L.DTAddon_SGCComp	= 'Delve Group Challenge Completion'
	L.DTAddon_SGCCompD	= 'Show list of characters that have completed the delve skillpoint Group Challenge in the tooltip.'
	L.DTAddon_SDBComp	= 'Delve Boss Completion'
	L.DTAddon_SDBCompD	= 'Show list of characters that have defeated all the delve\'s bosses in the tooltip.'
	L.DTAddon_SDFComp	= 'Delve Faction Completion'
	L.DTAddon_SDFCompD	= 'Show current character progress towards completing all delves in the faction of the highlighted delve. Requires Track Character.'
	L.DTAddon_CNColor	= 'Completed Name Color:'
	L.DTAddon_CNColorD	= 'Select color for the names of characters that have completed a given achievement.'
	L.DTAddon_NNColor	= 'Incomplete Name Color:'
	L.DTAddon_NNColorD	= 'Select color for the names of characters that have NOT completed a given achievement.'
	L.DTAddon_CTrack	= 'Track Character'
	L.DTAddon_CTrackD	= 'Track this character in the list of names that have completed (or not) a selected achievement.'
	L.DTAddon_DBReset	= 'Reset Tracking Database'
	L.DTAddon_DBResetB	= 'RESET'
	L.DTAddon_DBResetD	= 'Clears all names from the database. Re-log into each character to rebuild data. Used to remove characters you have deleted and can\'t otherwise remove by disabling tracking when logged in as them.'
	L.DTAddon_GOpts		= 'Global options'
	L.DTAddon_COpts		= 'Character options'

------------------------------------------------------------------------------------------------------------------

function DTAddon:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
