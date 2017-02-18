--[[
Author: Ayantir
Filename: fr.lua
Version: 5
]]--

pChat = pChat or {}
pChat.lang = {}
PCHAT_CHANNEL_NONE = 99

-- Vars with -H are headers, -TT are tooltips

-- Messages settings

pChat.lang.optionsH = "Personnalisation des discussions"

pChat.lang.guildnumbers = "Numéros de Guilde"
pChat.lang.guildnumbersTT = "Affiche le numéro de la Guilde à côté de son tag"

pChat.lang.allGuildsSameColour = "Même couleur pour toutes les guildes"
pChat.lang.allGuildsSameColourTT = "Utiliser la couleur de la Guilde 1 pour toutes les guildes"

pChat.lang.allZonesSameColour = "Même couleur pour toutes les zones"
pChat.lang.allZonesSameColourTT = "Utiliser la couleur de zone pour les canaux de zone localisées"

pChat.lang.allNPCSameColour = "Même couleurs pour les PNJ"
pChat.lang.allNPCSameColourTT = "Utiliser uniquement la couleur de base pour tous les discours de PNJ"

pChat.lang.delzonetags = "Supprimer les tags de zone"
pChat.lang.delzonetagsTT = "Supprime les tags de zone tel que [Parler] ou [Zone] en début de message"

pChat.lang.zonetagsay = "dit"
pChat.lang.zonetagyell = "crie"
pChat.lang.zonetagparty = "Groupe"
pChat.lang.zonetagzone = "zone"

pChat.lang.carriageReturn = "Retour à la ligne avant le message"
pChat.lang.carriageReturnTT = "Ajouter un retour à la ligne entre le nom du joueur et son message"

pChat.lang.useESOcolors = "Utiliser les couleurs ESO"
pChat.lang.useESOcolorsTT = "Utiliser les couleurs définies dans les options Sociales"

pChat.lang.diffforESOcolors = "Différence entre couleurs ESO"
pChat.lang.diffforESOcolorsTT = "En utilisant les couleurs ESO et l'option Utiliser plusieurs couleurs, plus la différence sera grande, plus les couleurs tireront sur le clair / sombre"

pChat.lang.removecolorsfrommessages = "Désactiver les couleurs dans les canaux"
pChat.lang.removecolorsfrommessagesTT = "Empêche les joueurs d'utiliser les couleurs dans les messages"

pChat.lang.preventchattextfading = "Désactiver la disparition graduelle des messages"
pChat.lang.preventchattextfadingTT = "Désactive la disparition graduelle des messages (Vous pouvez désactiver la disparition de l'interface dans les options sociales)"

pChat.lang.augmentHistoryBuffer = "Augmenter le # de lignes affichées dans le Chat"
pChat.lang.augmentHistoryBufferTT = "Par défaut, seules les 200 dernières lignes sont affichées dans le Chat. Cette option monte cette valeur à 1000 lignes"

pChat.lang.useonecolorforlines = "Utiliser une seule couleur"
pChat.lang.useonecolorforlinesTT = "Utiliser uniquement la couleur du joueur à la place des couleurs joueur/message"

pChat.lang.guildtagsnexttoentrybox = "Acronyme dans la zone de saisie"
pChat.lang.guildtagsnexttoentryboxTT = "Affiche l'acronyme de guilde à la place de son nom dans la zone de saisie"

pChat.lang.disableBrackets = "Supprimer les crochets autour des noms"
pChat.lang.disableBracketsTT = "Supprime les crochets [] autour des noms de joueur"

pChat.lang.defaultchannel = "Canal par défaut"
pChat.lang.defaultchannelTT = "Sélectionner le canal à utiliser à la connexion"

pChat.lang.defaultchannelchoice = {}
pChat.lang.defaultchannelchoice[PCHAT_CHANNEL_NONE] = "Ne pas modifier"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_ZONE] = "/zone"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_SAY] = "/parler"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_1] = "/guild1"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_2] = "/guild2"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_3] = "/guild3"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_4] = "/guild4"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_GUILD_5] = "/guild5"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_1] = "/officer1"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_2] = "/officer2"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_3] = "/officer3"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_4] = "/officer4"
pChat.lang.defaultchannelchoice[CHAT_CHANNEL_OFFICER_5] = "/officer5"

pChat.lang.geoChannelsFormat = "Format des noms"
pChat.lang.geoChannelsFormatTT = "Format des noms pour les canaux régionaux (dire, zone, tell)"

pChat.lang.defaultTab = "Onglet par défaut"
pChat.lang.defaultTabTT = "Sélectionner l'onglet par défaut au lancement du jeu"

pChat.lang.addChannelAndTargetToHistory = "Switcher de canal avec l'historique"
pChat.lang.addChannelAndTargetToHistoryTT = "Switcher de canal automatiquement lors de l'utilisation des flèches haut/bas du clavier pour faire correspondre les messages au canal précédemment utilisé."

pChat.lang.urlHandling = "Détecter et rendre les URL cliquables"
pChat.lang.urlHandlingTT = "Si une URL commençant par http(s):// est linkée dans le Chat, pChat la détectera et cliquer sur celle-ci lancera votre navigateur internet sur la page en question"

pChat.lang.enablecopy = "Activer la copie"
pChat.lang.enablecopyTT = "Active la copie du chat par clic droit sur le texte - Active également le changement d'un canal en cliquant sur le message. Vous pouvez désactiver cette option si vous rencontrez des problèmes pour afficher les liens dans le chat"

-- Group Settings

pChat.lang.groupH = "Option de canal de groupe"

pChat.lang.enablepartyswitch = "Canal de groupe automatique"
pChat.lang.enablepartyswitchTT = "Activer le canal de groupe automatique changera votre canal à celui du groupe lorsque vous rejoignez un groupe et repasse au canal par défaut lorsque vous quittez un groupe"

pChat.lang.groupLeader = "Couleurs des messages du chef de groupe"
pChat.lang.groupLeaderTT = "Activer cette option vous permettra de personnaliser la couleur des message du chef de groupe à celle définie ci-dessous"

pChat.lang.groupLeaderColor = "Couleur du chef de groupe"
pChat.lang.groupLeaderColorTT = "Couleur des messages du chef de groupe. La 2nde couleur à définir n'est utile que si l'option \"Utiliser les couleurs ESO\" est désactivée"

pChat.lang.groupLeaderColor1 = "Couleur des messages du chef de groupe"
pChat.lang.groupLeaderColor1TT = "Couleur des messages du chef de groupe. Si \"Utiliser les couleurs ESO\" est désactivée cette option sera disponible. La couleur du nom du chef sera celle définie ci-dessus et celle des messages sera celle-ci."

pChat.lang.groupNames = "Format des noms pour le groupe"
pChat.lang.groupNamesTT = "Format des noms des membres de votre groupe sur le canal groupe"

pChat.lang.groupNamesChoice = {}
pChat.lang.groupNamesChoice[1] = "@UserID"
pChat.lang.groupNamesChoice[2] = "Nom du personnage"
pChat.lang.groupNamesChoice[3] = "Nom du personnage@UserID"

-- Sync settings

pChat.lang.SyncH = "Synchronisation des paramètres"

pChat.lang.chatSyncConfig = "Synchroniser les paramètres du chat"
pChat.lang.chatSyncConfigTT = "Si la synchronisation est activée, tous vos personnages auront la même configuration de chat (couleurs, position, taille de la fenêtre, onglets)\nPS: Activez cette option une fois votre chat correctement configuré !"

pChat.lang.chatSyncConfigImportFrom = "Importer les paramètres du Chat de"
pChat.lang.chatSyncConfigImportFromTT = "Vous pouvez à tout moment importer les paramètres de Chat d'un autre personnage (couleurs, position, taille de la fenêtre, onglets)"

-- Apparence

pChat.lang.ApparenceMH = "Apparence de la fenêtre de chat"

pChat.lang.windowDarkness = "Transparence de la fenêtre de chat"
pChat.lang.windowDarknessTT = "Augmenter l'assombrissement de la fenêtre de chat"

pChat.lang.chatMinimizedAtLaunch = "Minimiser le chat au lancement du jeu"
pChat.lang.chatMinimizedAtLaunchTT = "Minimiser la fenêtre de chat sur la gauche au lancement du jeu"

pChat.lang.chatMinimizedInMenus = "Minimiser le chat dans les menus"
pChat.lang.chatMinimizedInMenusTT = "Minimiser la fenêtre de chat sur la gauche lorsque vous entrez dans les menus (Guilde, Stats, Artisanat, etc)"

pChat.lang.chatMaximizedAfterMenus = "Rétablir le chat en sortant des menus"
pChat.lang.chatMaximizedAfterMenusTT = "Toujours rétablir la fenêtre de chat après avoir quitté les menus"

pChat.lang.fontChange = "Police du Chat"
pChat.lang.fontChangeTT = "Définir la police du Chat"

pChat.lang.tabwarning = "Avertissement nouveau message"
pChat.lang.tabwarningTT = "Définir la couleur de l'avertissement de nouveau message dans le nom de l'onglet"

-- Whisper settings

pChat.lang.IMH = "Chuchotements"

pChat.lang.soundforincwhisps = "Son pour les chuchotements reçus"
pChat.lang.soundforincwhispsTT = "Choisir le son qui sera joué lors des chuchotements reçus"

pChat.lang.soundforincwhispschoice = {}
pChat.lang.soundforincwhispschoice[SOUNDS.NONE] = "Aucun"
pChat.lang.soundforincwhispschoice[SOUNDS.NEW_NOTIFICATION] = "Notification"
pChat.lang.soundforincwhispschoice[SOUNDS.DEFAULT_CLICK] = "Clic"
pChat.lang.soundforincwhispschoice[SOUNDS.EDIT_CLICK] = "Ecriture"

pChat.lang.notifyIM = "Notifier visuellement"
pChat.lang.notifyIMTT = "Si vous manquez un chuchottement, une notification apparaitra dans le coin supérieur droit du chat vous permettant d'accéder rapidement à celui-ci. De plus si votre chat est minimisé à ce moment, une notification dans la barre réduite apparaîtra"

-- Restore chat settings

pChat.lang.restoreChatH = "Restaurer le chat"

pChat.lang.restoreOnReloadUI = "Après un ReloadUI"
pChat.lang.restoreOnReloadUITT = "Après avoir rechargé le jeu par la commande ReloadUI(), pChat restaurera le chat et son historique"

pChat.lang.restoreOnLogOut = "Après une déconnexion"
pChat.lang.restoreOnLogOutTT = "Après avoir déconnecté son personnage, pChat restaurera le chat et son historique"

pChat.lang.restoreOnAFK = "Après un éjection du jeu"
pChat.lang.restoreOnAFKTT = "Après avoir été déconnecté suite à une inactivité, pChat restaurera le chat et son historique si vous vous reconnectez dans le laps de temps défini ci-dessous"

pChat.lang.restoreOnQuit = "Après avoir quitté le jeu"
pChat.lang.restoreOnQuitTT = "Après avoir quitté le jeu, pChat restaurera le chat et son historique"

pChat.lang.timeBeforeRestore = "Temps maximum pour la restauration du chat"
pChat.lang.timeBeforeRestoreTT = "Passé ce délai (en heures), pChat ne tentera pas de restaurer le chat"

pChat.lang.restoreSystem = "Restaurer les messages système"
pChat.lang.restoreSystemTT = "Restaurer les msssages système (notifications de connexions et messages d'addon) lorsque le chat est rechargé"

pChat.lang.restoreSystemOnly = "Restaurer les messages système uniquement"
pChat.lang.restoreSystemOnlyTT = "Restaurer les msssages système uniquement (notifications de connexions et messages d'addon) lorsque le chat est rechargé"

pChat.lang.restoreWhisps = "Restaurer les Chuchotements"
pChat.lang.restoreWhispsTT = "Restaurer les chuchotements reçus et envoyés lors d'un changement de personnage, d'une deconnexion ou après avoir quitté le jeu. Les chuchotements sont toujuors restaurés après un ReloadUI()"

pChat.lang.restoreTextEntryHistoryAtLogOutQuit  = "Restaurer l'historique de saisie"
pChat.lang.restoreTextEntryHistoryAtLogOutQuitTT  = "Restaurer l'historique disponible avec les flèches directionelles haut et bas après un changement de personnage, d'une deconnexion ou après avoir quitté le jeu. L'historique est toujours restauré après un ReloadUI()"

-- Anti Spam settings

pChat.lang.antispamH = "Anti-Spam"

pChat.lang.floodProtect = "Activer l'anti-flood"
pChat.lang.floodProtectTT = "Empêche les joueurs proches de vous de vous inonder de messages identiques et répétés"
pChat.lang.floodProtectDD = "Cette option est désactivée car l'option \"Activer l'anti-flood\" est actuellement désactivée"

pChat.lang.floodGracePeriod = "Durée du bannissement anti-flood"
pChat.lang.floodGracePeriodTT = "Nombre de secondes pendant lesquelles tout message identique au précédent sera ignoré"

pChat.lang.lookingForProtect = "Ignorer les messages de groupage"
pChat.lang.lookingForProtectTT = "Ignorer les messages des joueurs cherchant à constituer / rejoindre un groupe"

pChat.lang.wantToProtect = "Ignorer les messages de commerce"
pChat.lang.wantToProtectTT = "Ignorer les messages de joueurs cherchant à acheter, vendre ou échanger"

pChat.lang.spamGracePeriod = "Arrêt temporaire de l'anti-spam"
pChat.lang.spamGracePeriodTT = "Lorsque vous effectuez vous-même un message de recherche de groupe, ou de commerce, l'anti-spam désactive temporairement la fonction que vous avez outrepassée le temps d'avoir une réponse. Il se réactive automatiquement au bout d'un délai que vous pouvez fixer (en minutes)"

-- Nicknames settings

pChat.lang.nicknamesH = "Surnoms"
pChat.lang.nicknamesD = "Vous pouvez ajouter des surnoms aux personnes que vous voulez. Saisissez simplement Ancien Nom = Nouveau Nom"

pChat.lang.nicknames = "Liste de surnoms"
pChat.lang.nicknamesTT = "Vous pouvez ajouter des surnoms aux personnes que vous voulez. Saisissez simplement Ancien Nom = Nouveau Nom,\n\nEx : @Ayantir = Petite Blonde\n\nCela modifiera tous les noms des personnages de la personne si l'ancien nom est un @UserID ou simpement le personnage indiqué si l'ancien nom est un nom de personnage."

-- Timestamp settings

pChat.lang.timestampH = "Horodatage"

pChat.lang.enabletimestamp = "Activer l'horodatage"
pChat.lang.enabletimestampTT = "Ajoute un horodatage aux messages"
pChat.lang.enabletimestampDD = "Cette option est désactivée car l'option \"Activer l'horodatage\" est actuellement désactivée"

pChat.lang.timestampcolorislcol = "Même couleur que le nom du joueur"
pChat.lang.timestampcolorislcolTT = "Ignore la couleur de l'horodatage et colorie celui-ci de la même couleur que le nom du joueur / NPC"

pChat.lang.timestampformat = "Format de l'horodatage"
pChat.lang.timestampformatTT = "FORMAT:\nHH: 24h\nhh: 12h\nH: 24h, sans les zéros initiaux\nh: 12h, sans les zéros initiaux\nA: AM/PM\na: am/pm\nm: minutes\ns: secondes"

pChat.lang.timestamp = "Horodatage"
pChat.lang.timestampTT = "Définir les couleurs pour l'horodatage"

-- Guild settings

pChat.lang.nicknamefor = "Acronyme"
pChat.lang.nicknameforTT = "Acronyme pour"

pChat.lang.officertag = "Tag du canal officiers"
pChat.lang.officertagTT = "Préfixe ajouté au canal officier des guildes"

pChat.lang.switchFor = "Commutateur pour le canal"
pChat.lang.switchForTT = "Nouveau commutateur pour le canal. Ex: /maguilde"

pChat.lang.officerSwitchFor = "Commutateur pour le canal officier"
pChat.lang.officerSwitchForTT = "Nouveau commutateur pour le canal officier. Ex: /offs"

pChat.lang.nameformat = "Format du nom"
pChat.lang.nameformatTT = "Sélectionnez de quelle manière sont formatés les noms"

pChat.lang.formatchoice1 = "@UserID"
pChat.lang.formatchoice2 = "Nom du personnage"
pChat.lang.formatchoice3 = "Nom du personnage@UserID"

pChat.lang.setcolorsforTT = "Définir les couleurs pour les membres de "
pChat.lang.setcolorsforchatTT = "Définir les couleurs pour les messages de "

pChat.lang.setcolorsforofficiersTT = "Définir les couleurs pour les membres du canal Officier de "
pChat.lang.setcolorsforofficierschatTT = "Définir les couleurs pour les messages du canal Officier de "

pChat.lang.members = " - Joueurs"
pChat.lang.chat = " - Messages"

pChat.lang.officersTT = " Officiers"

-- Channel colors settings

pChat.lang.chatcolorsH = "Couleurs des canaux"

pChat.lang.say = "Dire - Joueur"
pChat.lang.sayTT = "Définir la couleur du joueur pour le canal dire"

pChat.lang.saychat = "Dire - Message"
pChat.lang.saychatTT = "Définir la couleur du message pour le canal dire"

pChat.lang.zone = "Zone - Joueur"
pChat.lang.zoneTT = "Définir la couleur du joueur pour le canal zone"

pChat.lang.zonechat = "Zone - Message"
pChat.lang.zonechatTT = "Définir la couleur du message pour le canal zone"

pChat.lang.yell = "Crier - Joueur"
pChat.lang.yellTT = "Définir la couleur du joueur pour le canal crier"

pChat.lang.yellchat = "Crier - Message"
pChat.lang.yellchatTT = "Définir la couleur du message pour le canal crier"

pChat.lang.incomingwhispers = "Chuchotements reçus - Joueur"
pChat.lang.incomingwhispersTT = "Définir la couleur du joueur pour les messages privés reçus"

pChat.lang.incomingwhisperschat = "Chuchotements reçus - Message"
pChat.lang.incomingwhisperschatTT = "Définir la couleur du message pour les messages privés reçus"

pChat.lang.outgoingwhispers = "Chuchotements envoyés - Joueur"
pChat.lang.outgoingwhispersTT = "Définir la couleur du joueur pour les messages privés envoyés"

pChat.lang.outgoingwhisperschat = "Chuchotements envoyés - Message"
pChat.lang.outgoingwhisperschatTT = "Définir la couleur du message pour les messages privés envoyés"

pChat.lang.group = "Groupe - Joueur"
pChat.lang.groupTT = "Définir la couleur du joueur pour le canal groupe"

pChat.lang.groupchat = "Groupe - Message"
pChat.lang.groupchatTT = "Définir la couleur du message pour le canal groupe"

-- Other colors

pChat.lang.othercolorsH = "Autres couleurs"

pChat.lang.emotes = "Emotes - Joueur"
pChat.lang.emotesTT = "Définir la couleur du joueur pour les emotes"

pChat.lang.emoteschat = "Emotes - Message"
pChat.lang.emoteschatTT = "Définir la couleur du message pour les emotes"

pChat.lang.enzone = "EN Zone - Joueur"
pChat.lang.enzoneTT = "Définir la couleur du joueur pour le canal de zone Anglais"

pChat.lang.enzonechat = "EN Zone - Message"
pChat.lang.enzonechatTT = "Définir la couleur du message pour le canal de zone Anglais"

pChat.lang.frzone = "FR Zone - Joueur"
pChat.lang.frzoneTT = "Définir la couleur du joueur pour le canal de zone Français"

pChat.lang.frzonechat = "FR Zone - Message"
pChat.lang.frzonechatTT = "Définir la couleur du message pour le canal de zone Français"

pChat.lang.dezone = "DE Zone - Joueur"
pChat.lang.dezoneTT = "Définir la couleur du joueur couleurs pour le canal de zone Allemand"

pChat.lang.dezonechat = "DE Zone - Message"
pChat.lang.dezonechatTT = "Définir la couleur du message pour le canal de zone Allemand"

pChat.lang.jpzone = "JP Zone - Joueur"
pChat.lang.jpzoneTT = "Définir la couleur du joueur couleurs pour le canal de zone Japonais"

pChat.lang.jpzonechat = "JP Zone - Message"
pChat.lang.jpzonechatTT = "Définir la couleur du message pour le canal de zone Japonais"

pChat.lang.npcsay = "Discussions de PNJ - PNJ"
pChat.lang.npcsayTT = "Définir la couleur du PNJ pour les discussions de PNJ"

pChat.lang.npcsaychat = "Discussions de PNJ - Message"
pChat.lang.npcsaychatTT = "Définir la couleur du message pour les discussions de PNJ"

pChat.lang.npcyell = "Cris de PNJ - PNJ"
pChat.lang.npcyellTT = "Définir la couleur du PNJ pour les cris de PNJ"

pChat.lang.npcyellchat = "Cris de PNJ - Message"
pChat.lang.npcyellchatTT = "Définir la couleur du message pour les cris de PNJ"

pChat.lang.npcwhisper = "Chuchotements de PNJ - PNJ"
pChat.lang.npcwhisperTT = "Définir la couleur du PNJ pour les chuchotements de PNJ"

pChat.lang.npcwhisperchat = "Chuchotements de PNJ - Message"
pChat.lang.npcwhisperchatTT = "Définir la couleur du message pour les chuchotements de PNJ"

pChat.lang.npcemotes = "Emotes de PNJ - PNJ"
pChat.lang.npcemotesTT = "Définir la couleur du PNJ pour les emotes de PNJ"

pChat.lang.npcemoteschat = "Emotes de PNJ - Message"
pChat.lang.npcemoteschatTT = "Définir la couleur du message pour les emotes de PNJ"

-- Debug settings

pChat.lang.debugH = "Debug"

pChat.lang.debug = "Debug"
pChat.lang.debugTT = "Debug"

-- Various strings not in panel settings

pChat.lang.undockTextEntry = "Détacher la zone de saisie"
pChat.lang.redockTextEntry = "Réattacher la zone de saisie"

pChat.lang.CopyMessageCT = "Copier le message"
pChat.lang.CopyLineCT = "Copier la ligne"
pChat.lang.CopyDiscussionCT = "Copier la discussion"
pChat.lang.AllCT = "Copier tout le chat"

pChat.lang.copyXMLTitle = "Copier le texte avec Ctrl+C"
pChat.lang.copyXMLLabel = "Copier le texte avec Ctrl+C"
pChat.lang.copyXMLTooLong = "Le texte est trop long et à été découpé"
pChat.lang.copyXMLNext = "Suivant"

pChat.lang.switchToNextTabBinding = "Passer à l'onglet suivant"
pChat.lang.toggleChatBinding = "Afficher/Masquer le chat"
pChat.lang.whispMyTargetBinding = "Chuchotter à la personne ciblée"

pChat.lang.savMsgErrAlreadyExists = "Impossible de sauvegarder votre message, celui-ci existe déjà"
pChat.lang.PCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Exemple : ts3"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Saisissez ici le texte qui sera envoyé lorsque vous utiliserez la fonction de message automatique"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Les retours à la ligne sont automatiquement supprimés"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "Ce message sera envoyé lorsque vous validerez le message \"!nomDuMessage\". (ex: |cFFFFFF!ts3|r)"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "Pour envoyer le message dans un canal précis, rajoutez le switch du canal au début du message (ex: |cFFFFFF/g1|r)"
pChat.lang.PCHAT_AUTOMSG_NAME_HEADER = "Abréviation de votre message"
pChat.lang.PCHAT_AUTOMSG_MESSAGE_HEADER = "Message de substitution"
pChat.lang.PCHAT_AUTOMSG_ADD_TITLE_HEADER = "Nouveau message automatique"
pChat.lang.PCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modifier message automatique"
pChat.lang.PCHAT_AUTOMSG_ADD_AUTO_MSG = "Ajouter"
pChat.lang.PCHAT_AUTOMSG_EDIT_AUTO_MSG = "Modifier"
pChat.lang.SI_BINDING_NAME_PCHAT_SHOW_AUTO_MSG = "Messages automatiques"
pChat.lang.PCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Supprimer"

pChat.lang.clearBuffer = "Effacer le chat"