local lmb,rmb = '|t16:16:AlphaGear/lmb.dds|t','|t16:16:AlphaGear/rmb.dds|t'
AG = {
de = {
	Copy = 'Kopieren',
	Paste = 'Einfügen',
	Clear = 'Leeren',
	Insert = 'Aktuell Ausgerüstete einfügen',
	Icon = lmb..'Bild manuell auswählen',
	Set = lmb..' Set anlegen\n'..rmb..' Set bearbeiten',
	NotFound = '<<1>> |cFF0000konnte nicht gefunden werden...|r',
	NotEnoughSpace = '|cFFAA33AlphaGear|r |cFF0000Nicht genügend Taschenplatz...|r',
	SoulgemUsed = '<<C:1>> |cFFAA33wurde neu aufgeladen.|r',
	SetPart = '\n|cFFAA33Teil vom Set: <<C:1>>|r',
	Lock = 'Ist das Set gesperrt, werden leere Plätze ausgezogen.\nIst das Set entsperrt, werden leere Plätze ignoriert.\n\n'..lmb..' Sperren/Entsperren',
	Unequip = 'Rüstung ausziehen',
	UnequipAll = 'Alles ausziehen',
	SetConnector = {
		lmb..' Ausrüstung mit Set verbinden\n'..rmb..' Verbindung entfernen',
		lmb..' Aktionsleiste 1 mit Set verbinden\n'..rmb..' Verbindung entfernen',
		lmb..' Aktionsleiste 2 mit Set verbinden\n'..rmb..' Verbindung entfernen'
	},
	Head = {
		Gear = 'Ausrüstung ',
		Skill = 'Fähigkeiten '
	},
	Button = {
		Gear = '\n'..lmb..' Gegenstand anlegen\n'..rmb..' Gegenstand entfernen',
		Skill = '\n'..lmb..' Fähigkeit ausrüsten\n'..rmb..' Fähigkeit entfernen'
	},
	Selector = {
		Gear = lmb..' Gesamte Ausrüstung anlegen\n'..rmb..' Weitere Optionen',
		Skill = lmb..' Alle Fähigkeiten ausrüsten\n'..rmb..' Weitere Optionen'
	},
	OptionWidth = 310,
	Options = {
		'UI-Button anzeigen',
		'UI-Set-Buttons anzeigen',
		'Reparatur-Icon anzeigen',
		'Reparatur-Kosten anzeigen',
		'Waffen-Ladung-Icon(s) anzeigen',
		'Waffenwechsel-Meldung anzeigen',
		'Angelegtes Set anzeigen',
		'Set-Items im Inventar markieren',
		'Item-Zustand in Prozent anzeigen',
		'Item-Qualität als Farbe anzeigen',
		'Fenster bei Bewegung schließen',
		'Alle AlphaGear-Elemente sperren',
		'Waffen automatisch aufladen'
	}
},
en = {
	Copy = 'Copy',
	Paste = 'Paste',
	Clear = 'Clear',
	Insert = 'Insert currently equipped',
	Icon = lmb..'Choose icon',
	Set = lmb..' Equip set\n'..rmb..' Edit set',
	NotFound = '<<1>> |cFF0000was not found...|r',
	NotEnoughSpace = '|cFFAA33AlphaGear|r |cFF0000Not enough bag-space...|r',
	SoulgemUsed = '<<C:1>> |cFFAA33was recharged.|r',
	SetPart = '\n|cFFAA33Part of Set: <<C:1>>|r',
	Lock = 'If the set is locked, all empty slots will be unequipped.\nIf the set is unlocked, all empty slots will be ignored.\n\n'..lmb..' Lock/unlock',
	Unequip = 'Unequip armor',
	UnequipAll = 'Unequip entire gear',
	SetConnector = {
		lmb..' Connect gear with set\n'..rmb..' Remove connection',
		lmb..' Connect actionbar 1 with set\n'..rmb..' Remove connection',
		lmb..' Connect actionbar 2 with set\n'..rmb..' Remove connection'
	},
	Head = {
		Gear = 'Gear ',
		Skill = 'Skills '
	},
	Button = {
		Gear = lmb..' Equip item\n'..rmb..' Remove item',
		Skill = lmb..' Equip skill\n'..rmb..' Remove skill'
	},
	Selector = {
		Gear = lmb..' Equip entire gear\n'..rmb..' More options',
		Skill = lmb..' Equip all skills\n'..rmb..' More options'
	},
	OptionWidth = 300,
	Options = {
		'Show UI-button',
		'Show UI-set-buttons',
		'Show repair icon',
		'Show repair cost',
		'Show weapon charge icon(s)',
		'Show weapon swap message',
		'Show equipped set',
		'Mark set items in inventory',
		'Show item condition in percent',
		'Show item quality as color',
		'Close window on movement',
		'Lock all AlphaGear elements',
		'Automatic weapon charge'
	}
},
fr = {
	Copy = 'Copy',
	Paste = 'Paste',
	Clear = 'Clear',
	Insert = 'Placez actuellement équipé',
	Icon = lmb..'Sélectionnez l\'icône',
	Set = lmb..' Équiper l\'ensemble\n'..rmb..' Modifier l\'ensemble',
	NotFound = '<<1>> |cFF0000n\'a pas été trouvé...|r',
	NotEnoughSpace = '|cFFAA33AlphaGear|r |cFF0000Pas assez d\'espace d\'inventaire...|r',
	SoulgemUsed = '<<C:1>> |cFFAA33a été rechargé.|r',
	SetPart = '\n|cFFAA33Élément de l\'ensemble: <<C:1>>|r',
	Lock = 'Si l\'ensemble est verrouillé, tous les slots vides seront déséquipés.\nSi l\'ensemble est déverrouillé, tous les slots vides seront ignorés.\n\n'..lmb..' Verrouiller/Déverrouiller',
	Unequip = 'Enlever l\'armure',
	UnequipAll = 'Enlever tous les équipements',
	SetConnector = {
		lmb..' Linker l\'équipement avec l\'ensemble\n'..rmb..' Supprimer le lien',
		lmb..' Linker la barre d\'action principale avec l\'ensemble\n'..rmb..' Supprimer le lien',
		lmb..' Linker la barre d\'action secondaire avec l\'ensemble\n'..rmb..' Supprimer le lien'
	},
	Head = {
		Gear = 'Équipement ',
		Skill = 'Compétences '
	},
	Button = {
		Gear = lmb..' Équiper l\'objet\n'..rmb..' Supprimer l\'objet',
		Skill = lmb..' Placer la compétence\n'..rmb..' Supprimer la compétence'
	},
	Selector = {
		Gear = lmb..' Équiper tout l\'équipement\n'..rmb..' plus d\'options',
		Skill = lmb..' Placer toutes les compétences\n'..rmb..' plus d\'options'
	},
	OptionWidth = 400,
	Options = {
		'Afficher le bouton de l\'interface',
		'Afficher les boutons d\'ensembles',
		'Afficher l\'icône de réparation',
		'Afficher le coup de réparation',
		'Afficher les icônes de charge d\'arme',
		'Afficher le message de switch d\'arme',
		'Afficher l\'ensemble porté',
		'Marquer les objets de set dans l\'inventaire',
		'Afficher le taux d\'usure en pourcentage',
		'Afficher la qualité de l\'objet en tant que couleur',
		'Fermer la fenêtre au déplacement du personnage',
		'Verrouiller les éléments AlphaGear',
		'Rechargement automatique de l\'arme'
	}
}
}