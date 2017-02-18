local DTAddon = _G['DTAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French (No line indent means bad Google language translation.)
------------------------------------------------------------------------------------------------------------------

-- General Strings.
L.DTAddon_Title		= 'Dungeon Tracker'
L.DTAddon_CNorm		= 'Terminé Normal:'
L.DTAddon_CVet		= 'Vétéran Terminé:'
L.DTAddon_CNormI	= 'Terminé Normal I:'
L.DTAddon_CNormII	= 'Terminé Normal II:'
L.DTAddon_CVetI		= 'Vétéran Terminé I:'
L.DTAddon_CVetII	= 'Vétéran Terminé II:'
L.DTAddon_CGChal	= 'Défi Groupe Complété:'
L.DTAddon_CDBoss	= 'Tous les Patrons Défait:'

-- Panel Strings.
L.DTAddon_MAPOpt	= 'Options de Carte'
L.DTAddon_SLFGt		= 'Salon LFG Donjon.'
L.DTAddon_SLFGtD	= 'Afficher la liste des personnages qui ont terminé un donjon dans l\'infobulle Group Finder.'
L.DTAddon_SNComp	= 'Terminaison normale du donjon'
L.DTAddon_SNCompD	= 'Afficher la liste des personnages ayant complété le Dungeon ou Trial en mode Normal dans l\'info-bulle.'
L.DTAddon_SVComp	= 'Achèvement du donjon vétéran'
L.DTAddon_SVCompD	= 'Afficher la liste des personnages ayant complété le Dungeon ou Trial en mode Vétéran dans l\'info-bulle.'
L.DTAddon_SGFComp	= 'Achèvement de la faction Dungeon'
L.DTAddon_SGFCompD	= 'Affiche la progression actuelle du personnage pour compléter tous les Dungeons du groupe dans la faction du donjon en surbrillance. Nécessite un caractère de piste.'
L.DTAddon_SGCComp	= 'Compléter le défi de groupe de Delve'
L.DTAddon_SGCCompD	= 'Afficher la liste des personnages ayant complété le point de compétence Delve Challenge de groupe dans l\'info-bulle.'
L.DTAddon_SDBComp	= 'Complétez le boss'
L.DTAddon_SDBCompD	= 'Affiche la liste des personnages qui ont vaincu tous les boss de l\'exploration dans l\'info-bulle.'
L.DTAddon_SDFComp	= 'Compléter la faction de Delve'
L.DTAddon_SDFCompD	= 'Afficher la progression actuelle du personnage vers la fin de toutes les plongées dans la faction de la plongée en surbrillance. Nécessite un caractère de piste.'
L.DTAddon_CNColor	= 'Nom complet couleur:'
L.DTAddon_CNColorD	= 'Sélectionnez la couleur des noms des personnages qui ont terminé une réalisation donnée.'
L.DTAddon_NNColor	= 'Incomplet Nom Couleur:'
L.DTAddon_NNColorD	= 'Sélectionnez la couleur pour les noms des caractères qui n\'ont PAS terminé une réalisation donnée.'
L.DTAddon_CTrack	= 'Suivre le caractère'
L.DTAddon_CTrackD	= 'Suivez ce personnage dans la liste des noms qui ont terminé (ou non) une réussite sélectionnée.'
L.DTAddon_DBReset	= 'Réinitialiser la base de données de suivi'
L.DTAddon_DBResetB	= 'RÉINITIALISER'
L.DTAddon_DBResetD	= 'Efface tous les noms de la base de données. Re-log dans chaque caractère pour reconstruire les données. Permet de supprimer les caractères que vous avez supprimés et qui ne peuvent pas être supprimés en désactivant le suivi lorsqu\'ils sont connectés.'
L.DTAddon_GOpts		= 'Options globales'
L.DTAddon_COpts		= 'Options de personnage'

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(DTAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DTAddon:GetLanguage() -- set new language return
		return L
	end
end
