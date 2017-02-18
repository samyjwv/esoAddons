--[[
esoui/art/characterwindow/equipmentbonusicon_empty.dds
esoui/art/characterwindow/equipmentbonusicon_full.dds
esoui/art/characterwindow/equipmentbonusicon_full_gold.dds
--]]

local lmb,rmb,mmb = '|t16:16:CraftStoreFixedAndImproved/DDS/lmb.dds|t','|t16:16:CraftStoreFixedAndImproved/DDS/rmb.dds|t','|t16:16:CraftStoreFixedAndImproved/DDS/mmb.dds|t'
local i,o = GetString('SI_ITEMTRAITTYPE',ITEM_TRAIT_TYPE_ARMOR_INTRICATE),GetString('SI_ITEMTRAITTYPE',ITEM_TRAIT_TYPE_ARMOR_ORNATE)
local CS = CraftStoreFixedAndImprovedLongClassName
CS.Lang = {}
CS.Lang.de = {
  option = {
    'CraftStore-Button anzeigen',--1
    'CraftStore-Elemente fixieren',--2
    'CraftStore-Fenster bei Bewegung schließen',--3
    'CraftStoreArtisan benutzen (fehlt)',--4
    'CraftStoreFlask benutzen (fehlt)',--5
    'CraftStoreQuest anzeigen',--6
    'CraftStoreCook benutzen',--7
    'CraftStoreRune benutzen',--8
    'Itemstil im Tooltip anzeigen',--9
    'Bedarf-Markierungen anzeigen',--10
    i..'/'..o..'-Symbole anzeigen',--11
    'Alarm für Forschung/Mount/Timer anzeigen',--12
    'Runen-Stimmen abspielen',--13
    'Sets für Forschung markieren',--14
    'Lagerbestand im Tooltip anzeigen',--15
    'Vorauswahl der Stapelaufteilung',--16
  },
  optionwidth = 380,
  TT = {
    '|cFFFFFF<<C:1>>|r\n|cE8DFAF'..lmb..' Forschung an- oder abwählen\n\n|t20:20:<<2>>|t|r |cFFFFFFGesamte <<C:3>>|r\n|cE8DFAF'..rmb..' Forschung an- oder abwählen|r', --1
    '|cE8DFAF'..lmb..' <<1>> x herstellen|r', --2
    '|cE8DFAF'..rmb..' <<1>> x herstellen|r', --3
    '|cE8DFAF'..mmb..' Zum Favoriten |r|t16:16:esoui/art/characterwindow/equipmentbonusicon_full.dds|t', --4
    '|cE8DFAF'..lmb..' Auswählen|r', --5
    '|cE8DFAF'..rmb..' Im Chat verlinken|r', --6
    '|cE8DFAF'..lmb..' Zutaten markieren|r', --7
    '|cE8DFAF'..lmb..' Glyphe zerlegen|r', --8
    '|cE8DFAF'..lmb..' Alle nicht hergestellen Glyphen zerlegen\n'..rmb..' Alle verfügbaren Glyphen zerlegen|r', --9
    '|cE8DFAF'..lmb..' Charakter auswählen\n'..rmb..' Als Hauptcharakter setzen\n'..mmb..' Charakter löschen!|r', --10
    'Favoriten', --11
    'Runen-Modus-Herstellung', --12
    'Verfolgt bekannte Stile', --13
    'Verfolgt bekannte Rezepte', --14
    'Zeige CraftStore', --15
    'Verfügbare Hehler-Aktionen und heutige Goldeinnahmen', --16
    'Magiergilde - Augvea - benutze ein Portal im Gebäude der Magiergilde', --17
    'Kriegergilde - Erdschmiede - benutze ein Portal im Gebäude der Kriegergilde', --18
    'Klicken, um zum nächsten Wegschrein der Set-Schmiede zu reisen', --19
    '|cFFFFFFReitfertigkeiten|r\nNutzlast und Ausdauer\nTempo und Trainigszeit', --20
    {'Jedes Gewässer','Trübes Wasser','Fluss','See','Ozean'}, --21
    'Alle Glyphen zerlegen', --22
    'Writ', --23
  },
  nobagspace = '|cFFAA33CraftStore:|r |cFF0000Nicht genügend Platz im Inventar!|r',
  noSlot = '|cFFAA33CraftStore:|r |cFF0000Kein freier Forschungsplatz!|r',
  searchfor = 'Suche nach: ',
  finished = 'fertig',
  level = 'Stufe',
  rank = 'Rang',
  bank = 'Bank',
  guildbank = 'Gildenbank',
  craftbag = 'Handwerksbeutel',
  chars = 'Charakter-Übersicht',
  set = 'Wähle ein Set aus...',
  unknown = 'unbekannt',
  knownStyles = 'Bekannte Stile',
  finishResearch = '<<C:1>> hat |c00FF00<<C:2>>|r |c00FF88(<<C:3>>)|r fertig erforscht.',
  finishMount = '<<C:1>> hat die Reitausbildung abgeschlossen.',
  finish12 = 'Der 12-Stunden-Countdown ist abgelaufen.',
  finish24 = 'Der 24-Stunden-Countdown ist abgelaufen.',
  itemsearch = 'Suche: <<C:1>> | <<c:2>> ... Angebote?',
  hideStyles = 'Einfache Stile ausblenden',
  hidePerfectedStyles = 'Bekannte Stile ausblenden',
  previewType = {"Schwer", "Mittel", "Leicht + Robe", "Leicht + Jacke"},
}
CS.Lang.en = {
  option = {
    'Show CraftStore-button',
    'Lock CraftStore-elements',
    'Close CraftStore-window on movement',
    'Use CraftStoreArtisan (not ready)',
    'Use CraftStoreFlask (not ready)',
    'Use CraftStoreQuest',
    'Use CraftStoreCook',
    'Use CraftStoreRune',
    'Display itemstyle in tooltips',
    'Mark needed items',
    'Show '..i..'/'..o..'-symbols',
    'Display alarm for research/mount/timer',
    'Play enchanting rune voices',
    'Mark set-items for research',
    'Show item-stock in tooltip',
    'Preselect stack-split',--16
  },
  optionwidth = 380,
  TT = {
    '|cFFFFFF<<C:1>>|r\n'..lmb..' Select/deselect research\n\n|t20:20:<<2>>|t |cFFFFFFEntire <<C:3>>|r\n'..rmb..' Select/deselect research',
    '|cE8DFAF'..lmb..' Craft x <<1>>|r',
    '|cE8DFAF'..rmb..' Craft x <<1>>|r',
    '|cE8DFAF'..mmb..' Mark as favorite |r|t16:16:esoui/art/characterwindow/equipmentbonusicon_full.dds|t',
    '|cE8DFAF'..lmb..' Select|r',
    '|cE8DFAF'..rmb..' Link in chat|r',
    '|cE8DFAF'..lmb..' Mark ingredients|r',
    '|cE8DFAF'..lmb..' Refine glyph|r',
    '|cE8DFAF'..lmb..' Refine all not crafted glyphs\n'..rmb..' Refine all aviable glyphs|r',
    '|cE8DFAF'..lmb..' Select this character\n'..rmb..' Set this character as maincharacter\n'..mmb..' Delete this character!',
    'Favorites',
    'Rune-Mode-Crafting',
    'Tracks known styles',
    'Tracks known recipes',
    'Show CraftStore',
    'Aviable fence transactions and today\'s income',
    'Mage Guild - Eyevea - use portal in the nearest Mage Guild building',
    'Fighters Guild - The Earth Forge - use portal in the nearest Fighters Guild building',
    'Click to travel to the nearest wayshrine of the set-crafting-station',
    '|cFFFFFFMount-Skills|r\nCapacity and stamina\nSpeed and training',
    {'Any Water','Foul Water','River','Lake','Ocean'},
    'Refine all glyphs',
    'Writ',
  },
  nobagspace = '|cFFAA33CraftStore:|r |cFF0000Not enough bagspace!|r',
  noSlot = '|cFFAA33CraftStore:|r |cFF0000No free research slot!|r',
  searchfor = 'Search for: ',
  finished = 'finished',
  level = 'Level',
  rank = 'Rank',
  bank = 'Bank',
  guildbank = 'Guildbank',
  craftbag = 'Craft Bag',
  chars = 'Character-Overview',
  set = 'Choose a set...',
  unknown = 'unknown',
  knownStyles = 'Known styles',
  finishResearch = '<<C:1>> has finished |c00FF00<<C:2>>|r |c00FF88(<<C:3>>)|r research.',
  finishMount = '<<C:1>> has completed the mount training.',
  finish12 = 'The 12-hour-countdown has expired.',
  finish24 = 'The 24-hour-countdown has expired.',
  itemsearch = 'Looking for: <<C:1>> | <<c:2>> ... Offers?',
  hideStyles = 'Hide simple styles',
  hidePerfectedStyles = 'Hide known styles',
  previewType = {"Heavy", "Medium", "Light + Robe", "Light + Jack"},
}
CS.Lang.fr = {
  option = {
    'Afficher CraftStore-button',
    'Verrouiller les éléments CraftStore',
    'Fermer la fenêtre au déplacement du personnage',
    'Utiliser CraftStoreArtisan (pas finalisé)',
    'Utiliser CraftStoreFlask (pas finalisé)',
    'Utiliser CraftStoreQuest',
    'Utiliser CraftStoreCook',
    'Utiliser CraftStoreRune',
    'Afficher le style racial dans le tooltip',
    'Marquer les matériaux requis',
    'Marquer les équipements '..i..'/'..o..' dans l\'inventaire',
    'Afficher l\'alarme pour les recherches/monture/minuteur',
    'Jouer voix runiques enchanteur',
    'Marquer set-éléments pour la recherche',
    'Afficher le stock dans le tooltip',
    'Preselect stack-split',--16
  },
  optionwidth = 400,
  TT = {
    '|cFFFFFF<<C:1>>|r\n'..lmb..' Sélectionner/désélectionner les recherches\n\n|t20:20:<<2>>|t |cFFFFFFToute la <<C:3>>|r\n'..rmb..' Sélectionner/désélectionner les recherches',
    '|cE8DFAF'..lmb..' Créer x <<1>>|r',
    '|cE8DFAF'..rmb..' Créer x <<1>>|r',
    '|cE8DFAF'..mmb..' Marquer comme favoris |r|t16:16:esoui/art/characterwindow/equipmentbonusicon_full.dds|t',
    '|cE8DFAF'..lmb..' Sélectionner',
    '|cE8DFAF'..rmb..' Créer un lien dans le chat|r',
    '|cE8DFAF'..lmb..' Marquer les ingrédients|r',
    '|cE8DFAF'..lmb..' Affiner la glyphe|r',
    '|cE8DFAF'..lmb..' Affiner tous les glyphes pas fabriqués\n'..rmb..' Affiner les glyphes tous disponibles|r',
    '|cE8DFAF'..lmb..' Sélectionner ce personnage\n'..rmb..'Choisir ce personnage comme personnage principal\n'..mmb..' Supprimer ce personnage!',
    'Favoris',
    'Rune-Mode-Crafting',
    'Rechercher les styles connus',
    'Rechercher les recettes connus',
    'Afficher CraftStore',
    'Transactions disponibles avec le receleur et gains du jour',
    'Eyévéa - Utiliser le portail du bâtiment de la Guilde des Mages le plus proche',
    'Forgeterre - Utiliser le portail du bâtiment de la Guilde des Guerriers le plus proche',
    'Voyager vers l\'Oratoire le plus proche de la station de fabrication du Set',
    '|cFFFFFFCompétence de monture|r\nCapacité et endurance\nVitesse et entrainement',
    {'Chaque Eaux','Eaux Usées','Débit','Lac','Ocean'},
    'Affiner les glyphes',
    'Writ',
  },
  nobagspace = '|cFFAA33CraftStore:|r |cFF0000Pas assez d\'espace d\'inventaire!|r',
  noSlot = '|cFFAA33CraftStore:|r |cFF0000No free research slot!|r',
  searchfor = 'Rechercher: ',
  finished = 'complété',
  level = 'Niveau',
  rank = 'Rang',
  bank = 'Banque',
  guildbank = 'Banque de guilde',
  craftbag = 'Sac d\'artisanat',
  chars = 'Vue d\'ensemble des personnage',
  set = 'Sélectionner un Set...',
  unknown = 'inconnu',
  knownStyles = 'Styles connus',
  finishResearch = '<<C:1>> a terminé la recherche de |c00FF00<<C:2>>|r |c00FF88(<<C:3>>)|r.',
  finishMount = '<<C:1>> a fini l\'entrainement de sa monture.',
  finish12 = 'Le compte à rebours de 12 heures a expiré.',
  finish24 = 'Le compte à rebours de 24 heures a expiré.',
  itemsearch = 'Recherche: <<C:1>> | <<c:2>> ... Offres?',
  hideStyles = 'Masquer les styles simples',
  hidePerfectedStyles = 'Masquer les styles connus',
  previewType = {"Lourde", "Moyenne", "Legere + Robe", "Legere + Pourpoint"}, --TODO: French translations
}