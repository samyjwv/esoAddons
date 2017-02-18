local DTAddon = _G['DTAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian (No line indent means bad Google language translation.)
------------------------------------------------------------------------------------------------------------------

-- General Strings.
L.DTAddon_Title		= 'Dungeon Tracker'
L.DTAddon_CNorm		= 'Completato Normale:'
L.DTAddon_CVet		= 'Veteran Completato:'
L.DTAddon_CNormI	= 'Completato Normale I:'
L.DTAddon_CNormII	= 'Completato Normale II:'
L.DTAddon_CVetI		= 'Veteran Completato I:'
L.DTAddon_CVetII	= 'Veteran Completato II:'
L.DTAddon_CGChal	= 'Completato Sfida Gruppo:'
L.DTAddon_CDBoss	= 'Tutti i Boss Sconfitti:'

-- Panel Strings.
L.DTAddon_MAPOpt	= 'Opzioni Mappa'
L.DTAddon_SLFGt		= 'Mostra LFG Informazioni Dungeon.'
L.DTAddon_SLFGtD	= 'Visualizza l\'elenco di caratteri thathave completato un dungeon nella descrizione del Gruppo Finder.'
L.DTAddon_SNComp	= 'Normal Dungeon Completamento'
L.DTAddon_SNCompD	= 'Mostra l\'elenco di caratteri che hanno completato il Dungeon o di prova in modalità Normale nel suggerimento.'
L.DTAddon_SVComp	= 'Veterano Dungeon Completamento'
L.DTAddon_SVCompD	= 'Mostra l\'elenco di caratteri che hanno completato il Dungeon o di prova in modalità Veterano nella descrizione comandi.'
L.DTAddon_SGFComp	= 'Dungeon Faction Completamento'
L.DTAddon_SGFCompD	= 'Mostra i progressi carattere corrente verso il completamento tutto il gruppo Dungeons nella fazione del dungeon evidenziato. Richiede carattere Track.'
L.DTAddon_SGCComp	= 'Un tuffo Gruppo sfida Completamento'
L.DTAddon_SGCCompD	= 'Mostra lista dei personaggi che hanno completato il punto Gruppo Delve abilità Sfida nella descrizione comandi.'
L.DTAddon_SDBComp	= 'Approfondire il completamento capo'
L.DTAddon_SDBCompD	= 'Mostra lista dei personaggi che hanno sconfitto tutti i boss del Delve nel tooltip.'
L.DTAddon_SDFComp	= 'Approfondire il completamento fazione'
L.DTAddon_SDFCompD	= 'Mostra i progressi carattere corrente verso il completamento tutti scava nella fazione del Delve evidenziato. Richiede carattere Track.'
L.DTAddon_CNColor	= 'Completato colore Nome:'
L.DTAddon_CNColorD	= 'Selezionare colore per i nomi dei personaggi che hanno completato un determinato risultato.'
L.DTAddon_NNColor	= 'Incompleto Nome Colore:'
L.DTAddon_NNColorD	= 'Selezionare colore per i nomi dei personaggi che non hanno completato un determinato risultato.'
L.DTAddon_CTrack	= 'Traccia Carattere'
L.DTAddon_CTrackD	= 'Traccia questo personaggio nella lista dei nomi che hanno completato (o meno) un risultato selezionato.'
L.DTAddon_DBReset	= 'Ripristinare database di rilevamento'
L.DTAddon_DBResetB	= 'RESET'
L.DTAddon_DBResetD	= 'Cancella tutti i nomi dal database. Ri-accedere a ogni personaggio per ricostruire i dati. Usato per rimuovere i caratteri che avete cancellato e non può altrimenti rimuovere disabilitando inseguimento quando si è connessi come loro.'
L.DTAddon_GOpts		= 'Opzioni Globali'
L.DTAddon_COpts		= 'Opzioni di Carattere'

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(DTAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DTAddon:GetLanguage() -- set new language return
		return L
	end
end
