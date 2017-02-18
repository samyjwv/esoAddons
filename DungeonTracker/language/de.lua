local DTAddon = _G['DTAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German (Thanks to ESOUI.com user Baertram for the translation!)
------------------------------------------------------------------------------------------------------------------

-- General Strings.
	L.DTAddon_Title		= 'Dungeon Tracker'
	L.DTAddon_CNorm		= 'Abgeschlossen Normal:'
	L.DTAddon_CVet		= 'Abgeschlossener Veteran:'
	L.DTAddon_CNormI	= 'Abgeschlossen Normal I:'
	L.DTAddon_CNormII	= 'Abgeschlossen Normal II:'
	L.DTAddon_CVetI		= 'Abgeschlossener Veteran I:'
	L.DTAddon_CVetII	= 'Abgeschlossener Veteran II:'
	L.DTAddon_CGChal	= 'Abgeschlossene Gruppen Herausforderung:'
	L.DTAddon_CDBoss	= 'Alle Bosse Besiegt:'

-- Panel Strings.
	L.DTAddon_MAPOpt	= 'Karten Optionen'
	L.DTAddon_SLFGt		= 'Dungeon Info in Gruppensuche'
	L.DTAddon_SLFGtD	= 'Zeigt eine Liste der Charaktere im Gruppensuche Tooltip der Dungeons an, welche diese Dungeon bereits abgeschlossen haben.'
	L.DTAddon_SNComp	= 'Normaler Dungeon-Abschluss'
	L.DTAddon_SNCompD	= 'Zeigt eine Liste der Charaktere im Tooltip der Dungeons auf der Karte an, die den Dungeon oder Trial im Normalmodus beendet haben.'
	L.DTAddon_SVComp	= 'Veteranen Dungeon-Abschluss'
	L.DTAddon_SVCompD	= 'Zeigt eine Liste der Charaktere im Tooltip der Dungeon auf der Karte an, die den Dungeon oder Trial im Veteranenmodus beendet haben.'
	L.DTAddon_SGFComp	= 'Fraktion - Dungeon Fertigstellungsgrad'
	L.DTAddon_SGFCompD	= 'Zeigt den aktuellen Charakterfortschritt für den Abschluss aller Gruppen-Dungeons in der Fraktion des hervorgehobenen Dungeons an.\n\nErfordert "Charakterverfolgung"'
	L.DTAddon_SGCComp	= 'Gruppen Herausforderung - Verlies Fertigstellungsgrad'
	L.DTAddon_SGCCompD	= 'Zeigt eine Liste der Charaktere im Tooltip an, welche die Gruppen Herausforderung abgeschlossen haben.'
	L.DTAddon_SDBComp	= 'Boss-Abschluss'
	L.DTAddon_SDBCompD	= 'Zeige eine Liste der Charaktere im Tooltip an, welche alle Bosse besiegt haben.'
	L.DTAddon_SDFComp	= 'Fraktion - Verlies Fertigstellungsgrad'
	L.DTAddon_SDFCompD	= 'Zeigt den aktuellen Charakterfortschritt für den Abschluss aller Verliese in der Fraktion des hervorgehobenen Verlieses an.\n\nErfordert "Charakterverfolgung"'
	L.DTAddon_CNColor	= 'Name - Abgeschlossen Farbe:'
	L.DTAddon_CNColorD	= 'Wählen Sie die Farbe für die Namen der Charaktere aus, welche eine bestimmte Leistung abgeschlossen haben.'
	L.DTAddon_NNColor	= 'Name - Unvollständig Farbe:'
	L.DTAddon_NNColorD	= 'Wählen Sie die Farbe für die Namen der Charaktere aus, welche eine bestimmte Leistung NICHT abgeschlossen haben.'
	L.DTAddon_CTrack	= 'Charakterverfolgung'
	L.DTAddon_CTrackD	= 'Verfolgen Sie diesen Charakter in der Liste der Namen, die eine ausgewählte Leistung abgeschlossen haben oder nicht.'
	L.DTAddon_DBReset	= 'Setzen Sie die Verfolgungs-Datenbank zurück'
	L.DTAddon_DBResetB	= 'RESET'
	L.DTAddon_DBResetD	= 'Löscht alle Namen aus der Datenbank. Melden Sie sich bei jedem Charakter erneut an, um die Daten neu zu erstellen.\nWird verwendet, um Charaktere zu entfernen, die Sie gelöscht haben: Mit diesen können Sie sich nicht erneut anmelden, um die Charakterverfolgung zu deaktivieren.'
	L.DTAddon_GOpts		= 'Globale Optionen'
	L.DTAddon_COpts		= 'Charakter Optionen'

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(DTAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DTAddon:GetLanguage() -- set new language return
		return L
	end
end
