local Azurah			= _G['Azurah'] -- grab addon table from global [French (fr) - Translations provided by Ykses (http://www.esoui.com/forums/member.php?u=1521)]

local L = {}

L.Azurah				= '|c67b1e9A|c4779cezurah|r'
L.Usage					= '|c67b1e9A|c4779cezurah|r - Utilisation : taper \"/azurah lock\" ou \"unlock\" pour verrouiller ou déverrouiller la possibilité de déplacer les éléments de l\'interface.'

-- L.ThousandsSeperator	= ',' -- used to seperator large numbers in overlays

-- move window names
L.Health				= 'Santé du personnage'
L.HealthSiege			= 'Arme de siège'
L.Magicka				= 'Magie du personnage'
L.Werewolf				= 'Compteur Loup-Garou'
L.Stamina				= 'Vigueur du personnage'
L.StaminaMount			= 'Vigueur de la monture'
L.Experience			= 'Barre d\'expérience'
L.EquipmentStatus		= 'Équipement Statut'
L.Synergy				= 'Synergie'
L.Compass				= 'Boussole'
L.ReticleOver			= 'Santé de la cible'
L.ActionBar				= 'Barre de compétences'
L.Group					= 'Membres du groupe'
L.Raid1					= 'Groupe de Raid 1'
L.Raid2					= 'Groupe de Raid 2'
L.Raid3					= 'Groupe de Raid 3'
L.Raid4					= 'Groupe de Raid 4'
L.Raid5					= 'Groupe de Raid 5'
L.Raid6					= 'Groupe de Raid 6'
L.FocusedQuest			= 'Suivi de quête'
L.PlayerPrompt			= 'Message d\'interaction'
L.AlertText				= 'Notifications et alertes'
L.CenterAnnounce		= 'Notifications à l\'écran'
L.InfamyMeter			= 'Affichage de primes'
L.TelVarMeter			= 'Affichage de Tel Var'
L.ActiveCombatTips		= 'Aide au combat'
L.Tutorial				= 'Didacticiels'
L.CaptureMeter			= 'AvA capture compteur'



-- --------------------------------------------
-- SETTINGS -----------------------------------
-- --------------------------------------------

-- dropdown menus
L.DropOverlay1			= 'Ne rien afficher'
L.DropOverlay2			= 'Tout afficher'
L.DropOverlay3			= 'Valeur & Max'
L.DropOverlay4			= 'Valeur & Pourcentage'
L.DropOverlay5			= 'Valeur uniquement'
L.DropOverlay6			= 'Pourcentage uniquement'
L.DropColourBy1			= 'Par défaut'
L.DropColourBy2			= 'Selon le danger'
L.DropColourBy3			= 'Selon le niveau'
L.DropExpBarStyle1		= 'Par défaut'
L.DropExpBarStyle2		= 'Toujours affichée'
L.DropExpBarStyle3		= 'Toujours masquée'
-- tabs
L.TabButton1			= 'Général'
L.TabButton2			= 'Caractéristiques'
L.TabButton3			= 'Cible'
L.TabButton4			= 'Barre d\'actions'
L.TabButton5			= 'Expérience'


L.TabButton8			= 'Profils'
L.TabHeader1			= 'Réglages généraux'
L.TabHeader2			= 'Réglages des caractéristiques'
L.TabHeader3			= 'Réglages de la cible'
L.TabHeader4			= 'Réglages de la barre d\'actions'
L.TabHeader5			= 'Réglages de la barre d\'XP'


L.TabHeader8			= 'Réglage du profil'
-- unlock window
L.UnlockHeader			= 'Interface déverrouillée'
L.UnlockGridEnable		= 'Activer l\'alignement'
L.UnlockGridDisable		= 'Désactiver l\'alignement'
L.UnlockLockFrames		= 'Verrouiller l\'IU'
L.UnlockReset			= 'Positions par défaut'
L.UnlockResetConfirm	= 'Confirmer la réinitialisation'
-- settings: generic
L.SettingOverlayFormat = 'Format de l\'affichage'
L.SettingOverlayFancy = 'Distinguer les milliers'
L.SettingOverlayFancyTip = 'Par exemple \"10000\" deviendra \"10,000\".'



-- settings: general tab (1)
L.GeneralAnchorDesc = 'Déverrouiller l\'interface permet de déplacer librement les fenêtres et de régler la taille de celles-ci en utilisant la roulette de la souris. Un cadre est affiché pour chaque fenêtre permettant ainsi de les déplacer même si elles ne sont pas actuellement affichées en jeu (ex : la santé de la cible ou la vigueur de la monture).'
L.GeneralAnchorUnlock = 'Déverrouiller l\'IU'

L.GeneralPinScale = 'Taille des icones de la boussole'
L.GeneralPinScaleTip = 'Permet de définir la taille des icones affichés sur la boussole. Ce réglage est indépendant de la taille de la boussole (qui peut être réglée en déverouillant l\'interface).\n\nUne valeur de 100 correspond à 100% (ce qui est la taille par défaut).'
L.GeneralPinLabel = 'Masquer le texte de la boussole'
L.GeneralPinLabelTip = 'Permet de masquer le texte des icones sur la boussole (par exemple, l\'objectif de la quête que vous suivez actuellement).\n\nLe réglage par défaut est \"NON\" (le texte est affiché).'






-- settings: attributes tab (2)
L.AttributesFadeMin = 'Visibilité : Si remplies'
L.AttributesFadeMinTip = 'Permet de définir la façon dont s\'affichent les barres de caractéristiques de votre personnage quand elles sont pleines. A 100% les barres sont complètement affichées, à 0% les barres sont invisibles.\n\nLe réglage par défaut est 0% (les barres sont masquées lorsqu\'elles sont remplies).'
L.AttributesFadeMax = 'Visibilité : Si non remplies'
L.AttributesFadeMaxTip = 'Permet de définir la façon dont s\'affichent les barres de caractéristiques de votre personnage quand elles ne sont pas pleines. A 100% les barres sont complètement affichées, à 0% les barres sont invisibles.\n\nLe réglage par défaut est 100% (les barres sont pleinement affichées lorsqu\'elles ne sont pas remplies).'
L.AttributesLockSize = 'Verrouiller la taille des barres'
L.AttributesLockSizeTip = 'Permet de verrouiller la taille des barres de caractéristiques afin qu\'elles ne s\'aggrandissent pas lorsqu\'un buff est actif (avec une extension de vie, de magie ou de vigueur).'
L.AttributesLockSizeWarn = 'Nécessite un rechargement de l\'interface si cette option est modifiée alors qu\'un buff (d\'augmentation de la santé, magie ou vigueur) est actif.'
L.AttributesCombatBars = 'Visibilité: En Combat'
L.AttributesCombatBarsTip = 'Toujours utiliser \'Si non remplies\' visibilité en combat.'
L.AttributesOverlayHealth = 'Affichage du texte : Santé'
L.AttributesOverlayMagicka = 'Affichage du texte : Magie'
L.AttributesOverlayStamina = 'Affichage du texte : Vigueur'
L.AttributesOverlayFormatTip = 'Permet de définir la façon dont le texte est affiché sur les barres de caractéristiques.\n\nLe réglage par défaut est \"Ne rien afficher\".'
-- settings: target tab (3)
L.TargetLockSize = 'Verrouiller la taille de la cible'
L.TargetLockSizeTip = 'Permet de verrouiller la taille de la barre de santé de la cible afin qu\'elle ne s\'aggrandisse pas lorsqu\'un buff (d\'augmentation de la santé) est actif.'
L.TargetColourByBar = 'Colorer la santé de la cible'
L.TargetColourByBarTip = 'Permet de définir si la barre de santé de la cible est colorée selon le danger que représente cette cible (hostile, neutre, amicale) ou selon le niveau de celle-ci.'
L.TargetColourByName = 'Colorer le nom de la cible'
L.TargetColourByNameTip = 'Permet de définir si le nom de la cible est coloré selon le danger que représente cette cible (hostile, neutre, amicale) ou selon le niveau de celle-ci.'
L.TargetColourByLevel = 'Colorer le niveau de la cible'
L.TargetColourByLevelTip = 'Permet de définir si le niveau de la cible est coloré en fonction de la difficulté (différence de niveau avec le joueur).'
L.TargetIconClassShow = 'Afficher l\'icone de classe'
L.TargetIconClassShowTip = 'Permet d\'afficher (à côté du nom ou de la barre de santé) l\'icone correspondant à la classe du joueur ciblé.'
L.TargetIconClassByName = 'Icone de classe à côté du nom'
L.TargetIconClassByNameTip = 'Permet d\'afficher l\'icone de classe à côté du nom de la cible au lieu de l\'afficher à côté de la barre de santé.'
L.TargetIconAllianceShow = 'Afficher l\'icone d\'Alliance'
L.TargetIconAllianceShowTip = 'Permet d\'afficher (à côté du nom ou de la barre de santé) l\'icone de l\'Alliance du joueur ciblé.'
L.TargetIconAllianceByName = 'Icone d\'Alliance à côté du nom'
L.TargetIconAllianceByNameTip = 'Permet d\'afficher l\'icone de l\'Alliance à côté du nom de la cible au lieu de l\'afficher à côté de la barre de santé.'
L.TargetOverlayFormatTip = 'Permet de définir la façon dont le texte est affiché sur la barre de santé de la cible.\n\nLe réglage par défaut est \"Ne rien afficher\".'
L.BossbarHeader = 'Réglages Barre de Boss'
L.BossbarOverlayFormatTip = 'Permet de définir comment est affiché le texte sur la barre de santé des Boss (boussole). Cette dernière affiche un résumé de la santé de tous les Boss actifs.\n\nLe réglage par défaut est \"Ne rien afficher\".'
-- settings: action bar tab (4)
L.ActionBarHideBindBG = 'Cacher le fond des raccourcis'
L.ActionBarHideBindBGTip = 'Permet de masquer l\'arrière plan noir qui est affiché derrière les raccourcis claviers de la barre de compétences.'
L.ActionBarHideBindText = 'Cacher les raccourcis clavier'
L.ActionBarHideBindTextTip = 'Permet de masquer les raccourcis claviers qui sont affichés sous la barre de compétences.'
L.ActionBarHideWeaponSwap = 'Cacher l\'icone de changement d\'arme'
L.ActionBarHideWeaponSwapTip = 'Permet de masquer l\'icone de changement d\'arme qui est affiché dans la barre de compétences.'
L.ActionBarOverlayShow = 'Afficher le texte'
L.ActionBarOverlayUltValue = 'Charge Ultime : Valeur'
L.ActionBarOverlayUltValueShowTip = 'Permet de définir si la valeur de la charge Ultime est affichée en texte juste au-dessus du bouton de la Compétence Ultime.'
L.ActionBarOverlayUltValueShowCost = 'Afficher le cout de l\'Ultime'
L.ActionBarOverlayUltValueShowCostTip = 'Définit si l\'affichage montre uniquement votre quantité d\'Ultime actuel ou alors votre quantité d\'ultime disponible par rapport au cout de l\'ultime slot.\n\n Points d\'ultime disponible / Cout de l\'ultime.'
L.ActionBarOverlayUltPercent = 'Charge Ultime : Pourcentage'
L.ActionBarOverlayUltPercentShowTip = 'Permet de définir si le pourcentage de la charge Ultime est affichée sur le bouton de la Compétence Ultime.'
L.ActionBarOverlayUltPercentRelative = 'Charge Ultime : Pourcentage relatif'
L.ActionBarOverlayUltPercentRelativeTip = 'Permet de définir si le pourcentage affiché sur le bouton de la Compétence Ultime est relatif à la compétence actuelle ou relatif au maximum de charge possible (1000 points).\n\n\"OUI\" : relatif à la compétence actuelle.\n\"NON\" : relatif au maximum possible.'
-- settings: experience bar tab (5)
L.ExperienceDisplayStyle = 'Style de l\'affichage'
L.ExperienceDisplayStyleTip = 'Permet de définir la façon dont la barre d\'expérience s\'affiche.\n\nNote : Même avec l\'option \"Toujours affichée\", la barre sera masquée lors de l\'artisanat ou quand la carte du monde est ouverte, afin de ne pas se superposer à l\'affichage d\'autres informations.'
L.ExperienceOverlayFormatTip = 'Permet de définir la façon dont le texte est affiché sur la barre d\'expérience.\n\nLe réglage par défaut est \"Ne rien afficher\".'
-- settings: bag watcher tab (6)








-- settings: werewolf tab (7)






-- settings: profiles tab (8)












if (GetCVar('language.2') == 'fr') then -- overwrite GetLocale for new language
	for k, v in pairs(Azurah:GetLocale()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function Azurah:GetLocale() -- set new locale return
		return L
	end
end
