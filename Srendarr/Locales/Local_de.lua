-- German (de) - Translations provided by Tonyleila, and silentgecko, and Scootworks
local Srendarr		= _G['Srendarr'] -- grab addon table from global
local L				= {}

L.Srendarr			= '|c67b1e9S|c4779ce\'rendarr|r'
L.Srendarr_Basic	= 'S\'rendarr'
L.Usage				= '|c67b1e9S|c4779ce\'rendarr|r - Verwendung: /srendarr lock|unlock um die Leisten zu Entsperren/Sperren.'
L.CastBar			= 'Zauberleiste'
L.Sound_DefaultProc = 'Srendarr (Standard Proc)'

-- time format
L.Time_Tenths		= '%.1fs'
L.Time_Seconds		= '%ds'
L.Time_Minutes		= '%dm'
L.Time_Hours		= '%dh'
L.Time_Days			= '%dd'

-- aura grouping
L.Group_Displayed_Here	= 'Angezeigte Leisten'
L.Group_Displayed_None	= 'keine'
L.Group_Player_Short	= 'Deine kurzen Buffs'
L.Group_Player_Long		= 'Deine langen Buffs'
L.Group_Player_Toggled	= 'Deine umschaltbaren Buffs'
L.Group_Player_Passive	= 'Deine Passiven Effekte'
L.Group_Player_Debuff	= 'Deine Debuffs'
L.Group_Player_Ground	= 'Deine Bodeneffekte'
L.Group_Player_Major	= 'Deine größeren Buffs'
L.Group_Player_Minor	= 'Deine kleineren Buffs'
L.Group_Player_Enchant	= 'Deine Verzauberungs Procs'
L.Group_Target_Buff		= 'Ziel Buffs'
L.Group_Target_Debuff	= 'Ziel Debuffs'
L.Group_Prominent		= 'Spezial Buffs Gruppe 1'
L.Group_Prominent2		= 'Spezial Buffs Gruppe 2'

-- whitelist & blacklist control
L.Prominent_AuraAddSuccess	= 'wurde zur Spezial Whitelist 1 hinzugefügt.'
L.Prominent_AuraAddSuccess2	= 'wurde zur Spezial Whitelist 2 hinzugefügt.'
L.Prominent_AuraAddFail 	= 'wurde nicht gefunden und konnte nicht hinzugefügt werden.'
L.Prominent_AuraAddFailByID	= 'Keine gültige Effekt-ID! Die ID dieser Aura konnte nicht hinzugefügt werden.'
L.Prominent_AuraRemoved		= 'wurde aus der Spezial Whitelist 1 entfernt.'
L.Prominent_AuraRemoved2	= 'wurde aus der Spezial Whitelist 2 entfernt.'
L.Blacklist_AuraAddSuccess	= 'wurde zur Blacklist hinzugefügt und wird nicht länger dargestellt.'
L.Blacklist_AuraAddFail 	= 'wurde nicht gefunden und konnte nicht hinzugefügt werden.'
L.Blacklist_AuraAddFailByID	= 'Keine gültige Effekt-ID! Die ID dieser Aura konnte nicht der Blacklist hinzugefügt werden.'
L.Blacklist_AuraRemoved		= 'wurde aus der Blacklist entfernt.'

-- settings: base
L.Show_Example_Auras		= 'Beispiel Buffs'
L.Show_Example_Castbar		= 'Beispiel Zauberleiste'

L.SampleAura_PlayerTimed	= 'Spieler Zeitlich'
L.SampleAura_PlayerToggled	= 'Spieler Umgeschaltbar'
L.SampleAura_PlayerPassive	= 'Spieler Passive'
L.SampleAura_PlayerDebuff	= 'Spieler Debuff'
L.SampleAura_PlayerGround	= 'Boden Effect'
L.SampleAura_PlayerMajor	= 'Größere Buffs'
L.SampleAura_PlayerMinor	= 'Kleinere Buffs'
L.SampleAura_TargetBuff		= 'Ziel Buff'
L.SampleAura_TargetDebuff	= 'Ziel Debuff'

L.TabButton1				= 'Allgemein'
L.TabButton2				= 'Filter'
L.TabButton3				= 'Zauberleiste'
L.TabButton4				= 'Leisten'
L.TabButton5				= 'Profile'

L.TabHeader1				= 'Allgemein Einstellungen'
L.TabHeader2				= 'Filter Einstellungen'
L.TabHeader3				= 'Zauberleisten Einstellungen'
L.TabHeader5				= 'Profil Einstellungen'
L.TabHeaderDisplay			= 'Leisten Einstellungen'

-- settings: generic
L.GenericSetting_ClickToViewAuras	= 'Klick = Auren anzeigen'
L.GenericSetting_NameFont			= 'Text Schrift'
L.GenericSetting_NameStyle			= 'Text Farbe & Aussehen'
L.GenericSetting_NameSize			= 'Text Größe'
L.GenericSetting_TimerFont			= 'Zeit Schriftart'
L.GenericSetting_TimerStyle			= 'Zeit Schrift Farbe & Aussehen'
L.GenericSetting_TimerSize			= 'Zeit Größe'

-- settings: dropdown entries
L.DropGroup_1				= 'In Leiste [|cffd1001|r]'
L.DropGroup_2				= 'In Leiste [|cffd1002|r]'
L.DropGroup_3				= 'In Leiste [|cffd1003|r]'
L.DropGroup_4				= 'In Leiste [|cffd1004|r]'
L.DropGroup_5				= 'In Leiste [|cffd1005|r]'
L.DropGroup_6				= 'In Leiste [|cffd1006|r]'
L.DropGroup_7				= 'In Leiste [|cffd1007|r]'
L.DropGroup_8				= 'In Leiste [|cffd1008|r]'
L.DropGroup_None			= 'Nicht anzeigen'

L.DropStyle_Full			= 'Komplett anzeigen'
L.DropStyle_Icon			= 'Nur Icon'
L.DropStyle_Mini			= 'Nur Text & Timer'

L.DropGrowth_Up				= 'Hoch'
L.DropGrowth_Down			= 'Runter'
L.DropGrowth_Left			= 'Links'
L.DropGrowth_Right			= 'Rechts'
L.DropGrowth_CenterLeft		= 'Zentriert (Links)'
L.DropGrowth_CenterRight	= 'Zentriert (Rechts)'

L.DropSort_NameAsc			= 'Fähigkeits Name (auf)'
L.DropSort_TimeAsc			= 'Verbleibende Zeit (auf)'
L.DropSort_CastAsc			= 'Zauberreihenfolge (auf)'
L.DropSort_NameDesc			= 'Fähigkeits Name (ab)'
L.DropSort_TimeDesc			= 'Verbleibende Zeit (ab)'
L.DropSort_CastDesc			= 'Zauberreihenfolge (ab)'

L.DropTimer_Above			= 'Über Icon'
L.DropTimer_Below			= 'Unter Icon'
L.DropTimer_Over			= 'Auf Icon'
L.DropTimer_Hidden			= 'Versteckt'


-- ------------------------
-- SETTINGS: GENERAL
-- ------------------------
L.General_UnlockDesc			= 'Entsperren, um das verschieben von den verschiedenen Leisten mit der Maus zu aktivieren. Der Zurücksetzen-Knopf wird alle Fenster wieder auf die Standartposition zurücksetzen.'
L.General_UnlockLock			= 'Sperren'
L.General_UnlockUnlock			= 'Entsperren'
L.General_UnlockReset			= 'Zurücksetzen'
L.General_UnlockResetAgain		= 'Nochmal klicken zum Zurücksetzen'
L.General_CombatOnly			= 'Nur im Kampf anzeigen'
L.General_CombatOnlyTip			= 'Auf "Ein" stellen wenn die Leisten nur im Kampf angezeigt werden sollen.'
L.General_AuraFakeEnabled		= 'Künstlich Buffs/Debuffs Aktivieren'
L.General_AuraFakeEnabledTip	= 'Gewisse Fähigkeiten können falsche Anzeigen generieren. Mit diesen künstlichen Buffs/Debuffs wird versucht, bessere Informationen wiederzugeben. Leider können diese Informationen auch Fehler enthalten.'
L.General_ConsolidateEnabled	= 'Konsolidiere Multi-Auras'
L.General_ConsolidateEnabledTip	= 'Bestimmte Fähigkeiten (z.B. Wiederherstellen Aura vom Templer) haben mehrere Buff-Effekte. Diese Effekte werden meistens alle mit dem selben Symbol angezeigt. Diese Option konsolidiert die Effekte zu einer einzigen Aura.'



L.General_AuraFadeout			= 'Buff/Debuff Ausblendezeit'
L.General_AuraFadeoutTip		= 'Die Ausblendzeit in Millisekunden. Beim Wert \'0\' blendet das Icon direkt beim verstreichen der Zeit aus.'
L.General_ShortThreshold		= 'Kurzer Buff Grenzwert'
L.General_ShortThresholdTip		= 'Alle Werte unter dieser Grenze werden zählen als \'kurze Buffs\', alle oberhalb dieser Grenze als \'lange Buffs\'.'
L.General_ShortThresholdWarn	= 'Die Anzeige-Änderungen werden nur aktiv, nachdem das Menü Einstellungen geschlossen ist oder die Beispiel Buffs gezeigt werden.'
L.General_ProcEnableAnims		= 'Proc Animationen Aktivieren'
L.General_ProcEnableAnimsTip	= 'Aktivieren um die Proc Animationen in der Aktionsleiste anzuzeigen. Proc Fähigkeiten sind:\n- Kristallfragemente (Zauberer)\n- Grimmiger Fokus und deren Morphs (Nachtklinge)\n- Flammenleine (Drachenritter)\n- tödlicher Umhang (Zwei Waffen)'
L.General_ProcenableAnimsWarn	= 'Wenn du die originale Aktionsleiste ausgeblendet hast, wird die Animation auch nicht angezeigt.'
L.General_ProcPlaySound			= 'Sound bei Proc abspielen'
L.General_ProcPlaySoundTip		= 'Solange aktiviert, wird ein Ton abgespielt wenn eine Fähigkeit proct. Ansonsten ist der Ton bei Procs unterdrückt.'
L.General_PassiveEffectsAsPassive		= 'Behandelt passive Buffs als passive Effekte'
L.General_PassiveEffectsAsPassiveTip	= 'Legt fest, ob passive kleinere & grössere Buffs gruppiert oder verborgen sind anhand deiner \'Deine Passiven Effekte\' Einstellungen.\n\nFalls diese deaktiviert sind, werden alle kleinen & grossen Buffs separat gruppiert angezeigt, unabhängig ob diese passiv oder zeitlich gesteuert sind.'


-- settings: general (aura control: display groups)
L.General_ControlHeader				= 'Buff/Debuff Anzeige Einstellungen'
L.General_ControlBaseTip			= 'Hier wird festgelegt in welchem Anzeigefenster die Aura Gruppen angezeigt werden.'
L.General_ControlShortTip			= 'Diese Aura Gruppe zeigt deine eigenen Effekte unterhalb des \'kurzer Buff Grenzwertes\'.'
L.General_ControlLongTip 			= 'Diese Aura Gruppe zeigt deine eigenen Effekte oberhalb des \'kurzer Buff Grenzwertes\'.'
L.General_ControlToggledTip			= 'Diese Aura Gruppe zeigt deine umschaltbaren Effekte.'
L.General_ControlPassiveTip			= 'Diese Aura Gruppe zeigt alle passiven Effekte die gerade auf dich selbst wirken.'
L.General_ControlDebuffTip			= 'Diese Aura Gruppe zeigt alle negativen Effekte die auf dich von Gegnern, Spieler oder der Umgebung gewirkt wurden.'
L.General_ControlGroundTip			= 'Diese Aura Gruppe zeigt alle Flächeneffekte die von dir benutzt wurden.'
L.General_ControlMajorTip			= 'Diese Aura Gruppe zeigt alle positive \'grossen Buffs\'. Negativ auswirkende Effekte werden in der negativen Effekte Gruppe angezeigt.'
L.General_ControlMinorTip			= 'Diese Aura Gruppe zeigt alle positive \'kleinen Buffs\'. Negativ auswirkende Effekte werden in der negativen Effekte Gruppe angezeigt.'
L.General_ControlEnchantTip			= 'Diese Aura Gruppe enthält alle Verzauberungs Effekte, die auf sich selbst aktiv sind (z. B. Härten, Berserker).'
L.General_ControlTargetBuffTip		= 'Diese Aura Gruppe zeigt alle positive Effekte von deinem Ziel, unabhängig von umschaltbaren, passiven oder aktiven Effekten.'
L.General_ControlTargetDebuffTip 	= 'Diese Aura Gruppe zeigt alle negativen Effekte von deinem Ziel die du gemacht hast. In seltenen Fällen werden weitere negative Effekte angezeigt, die nicht von dir direkt sind.'
L.General_ControlProminentTip		= 'Diese Aura Gruppe zeigt alle von dir gesetzten Effekte, die du in der \'Spezial Buff\' Leiste hinzugefügt hast.'
-- settings: general (prominent auras)
L.General_ProminentHeader			= 'Spezial Buffs'
L.General_ProminentDesc				= 'Auf dich selbst wirkende Effekte oder Bodeneffekte können zur \'Spezial Buffs\' Liste hinzugefügt werden, damit sie in einer extra Gruppe dargestellt werden.'
L.General_ProminentAdd				= 'Spezial Buff hinzufügen'
L.General_ProminentAddTip			= 'Auf dich selbst wirkende Effekte oder Bodeneffekte mit Hilfe der Effekt-ID der Spezial Buff Liste hinzufügen. ID im Feld eingeben und Enter drücken, bis im Chatfenster eine Bestätigung erscheint. Passive und umschaltbare Effekte werden ignoriert.'
L.General_ProminentAddWarn			= 'Um eine Aura hinzufügen zu können, wird das ganze Spiel nach der Fähigkeit durchsucht. Das kann zu einer kurzen Verzögerung, respektive Hängenbleiben des Spiels führen.'
L.General_ProminentList				= 'Aktuelle Spezial Buffs:'
L.General_ProminentListTip			= 'Eine Liste mit allen Auras die als spezial gekennzeichnet wurden. Um eine Aura zu löschen, die entsprechende Aura anklicken und auf \'entferne Spezial Buff\' klicken.'
L.General_ProminentRemove1			= 'Entfernen aus Gruppe 1'
L.General_ProminentRemove2			= 'Entfernen aus Gruppe 2'
-- settings: general (debug)
L.General_DebugOptions			= 'Debug Optionen'
L.General_DebugOptionsDesc		= 'Eine Hilfe um fehlende oder falsche Auren aufzuspüren!'
L.General_ShowCombatEvents		= 'Zeige Kampf Ereignisse'
L.General_ShowCombatEventsTip	= 'Wenn diese Einstellung aktiviert ist, werden alle Effekt-ID\'s & deren Namen im Chat angezeigt. Diese enthalten auch die Effekte, die der Gegner auf dich ausführt.\n\nUm eine Informations-Überflutung zu verhindern, wird eine Fähigkeit nur einmal angezeigt. Mit \'/reloadui\' oder \'/sdbclear\' kann man den Cache manuell leeren um die Effekt-ID\'s erneut anzeigen zu lassen.'
L.General_DisableSpamControl	= 'Deaktivieren Flood Control'
L.General_DisableSpamControlTip	= 'Wenn der Kampfereignisfilter aktiviert ist, wird das gleiche Ereignis es ohne tritt jedes Mal drucken /sdbclear eingeben oder laden Sie die Datenbank zu löschen.'
L.General_AllowManualDebug		= 'Lassen Sie Manuelle Debug bearbeiten'
L.General_AllowManualDebugTip		= 'Wenn diese Option aktiviert können Sie /sdbadd XXXXXX oder /sdbremove XXXXXX hinzufügen/entfernen, um eine einzelne ID aus der Flut Filter geben. Typing /sdbclear noch den Filter zurückzusetzen .'
L.General_ShowNoNames			= 'Anzeigen Nameless Veranstaltungen'
L.General_ShowNoNamesTip		= 'Wenn der Kampfereignisfilter  aktiviert zeigt auch Ereignis-IDs, wenn sie keinen Namen Text.'


-- ------------------------
-- SETTINGS: FILTERS
-- ------------------------
L.Filter_Desc             		= 'Das Aktivieren eines Filters verhindert die Anzeige dieser Kategorie.'
L.Filter_BlacklistHeader  		= 'Buff/Debuff Blacklist'
L.Filter_BlacklistAdd    		= 'Buff/Debuff zur Blacklist hinzufügen'
L.Filter_BlacklistAddTip  		= 'Eine Aura zu einer Blacklist hinzufügen, damit diese nicht mehr angezeigt werden. ID im Feld eingeben und Enter drücken, bis im Chatfenster eine Bestätigung erscheint.'
L.Filter_BlacklistAddWarn 		= 'Um eine Aura hinzufügen zu können, wird das ganze Spiel nach der Fähigkeit durchsucht. Das kann zu einer kurzen Verzögerung, respektive Hängenbleiben des Spiels führen.'
L.Filter_BlacklistList			= 'Aktuelle Blacklist Buffs/Debuffs:'
L.Filter_BlacklistListTip		= 'Eine Liste mit allen Auras in der Blacklist. Um eine Aura zu löschen, die entsprechende Aura anklicken und auf \'entferne von Blacklist\' klicken.'
L.Filter_BlacklistRemove		= 'Entferne von Blacklist'

L.Filter_PlayerHeader			= 'Buff/Debuff Filter für Spieler'
L.Filter_TargetHeader			= 'Buff/Debuff Filter für Ziel'
L.Filter_Block					= 'Filter: Blocken'
L.Filter_BlockPlayerTip			= 'Deaktiviert deine Aura \'Blocken\' wenn der Filter EIN ist.'
L.Filter_BlockTargetTip			= 'Deaktiviert die Ziel Aura \'Blocken\' wenn der Filter EIN ist.'
L.Filter_Cyrodiil				= 'Filter: Cyrodiil Boni'
L.Filter_CyrodiilPlayerTip		= 'Deaktiviert deine \'Cyrodiil Auren\' wenn der Filter EIN ist.'
L.Filter_CyrodiilTargetTip		= 'Deaktiviert die Ziel \'Cyrodiil Auren\' wenn der Filter EIN ist.'
L.Filter_Disguise				= 'Filter: Verkleidungen'
L.Filter_DisguisePlayerTip		= 'Deaktiviert deine \'Verkleidungs\' Aura wenn der Filter EIN ist.'
L.Filter_DisguiseTargeTtip		= 'Deaktiviert die Ziel \'Verkleidungs\' Aura wenn der FIlter EIN ist.'
L.Filter_MajorEffects			= 'Filter: Größere Buffs'
L.Filter_MajorEffectsTargetTip	= 'Deaktiviert die \'grossen Buffs\' des Ziels wenn der Filter EIN ist.'
L.Filter_MinorEffects			= 'Filter: Kleinere Buffs'
L.Filter_MinorEffectsTargetTip	= 'Deaktiviert die \'kleinen Buffs\' des Ziels wenn der Filter EIN ist.'
L.Filter_MundusBoon				= 'Filter: Mundussteine'
L.Filter_MundusBoonPlayerTip	= 'Deaktiviert deine \'Mundussteine\' Aura/Auren wenn der Filter EIN ist.'
L.Filter_MundusBoonTargetTip	= 'Deaktiviert die Ziel \'Mundussteine\' Aura/Auren wenn der Filter EIN ist.'
L.Filter_SoulSummons			= 'Filter: Abklingzeit Seelenbeschwörung'
L.Filter_SoulSummonsPlayerTip	= 'Deaktiviert deine \'Abklingzeit Seelenbeschwörung\' Aura wenn der Filter EIN ist.'
L.Filter_SoulSummonsTargetTip	= 'Deaktiviert die Ziel \'Abklingzeit Seelenbeschwörung\' Aura wenn der Filter EIN ist.'
L.Filter_VampLycan				= 'Filter: Vampir & Werwolf Verwandlung'
L.Filter_VampLycanPlayerTip		= 'Deaktiviert deine \'Vampir & Werwolf Verwandlung\' Aura wenn der Filter EIN ist.'
L.Filter_VampLycanTargetTip		= 'Deaktiviert die Ziel \'Vampir & Werwolf Verwandlung\' Aura wenn der Filter EIN ist.'
L.Filter_VampLycanBite			= 'Filter: Vampir & Werwolf Biss Abklingzeit'
L.Filter_VampLycanBitePlayerTip	= 'Deaktiviert deine \'Vampir & Werwolf Biss Abklingzeit\' Aura wenn der Filter EIN ist.'
L.Filter_VampLycanBiteTargetTip	= 'Deaktiviert die Ziel \'Vampir & Werwolf Biss Abklingzeit\' Aura wenn der Filter EIN ist.'


-- ------------------------
-- SETTINGS: CAST BAR
-- ------------------------
L.CastBar_Enable				= 'Aktiviere Zauber- & Kanalisierungs Leiste'
L.CastBar_EnableTip				= 'Wenn diese Leiste aktiviert ist, zeigt es den Fortschritt der Fähigkeit bevor diese ausgelöst wird.'
L.CastBar_Alpha					= 'Transparenz'
L.CastBar_AlphaTip				= 'Die Transparenz der Leiste solange sie aktiv ist.\nEin Wert von 100 = sichtbar, 0 = unsichtbar.'
L.CastBar_Scale					= 'Grösse'
L.CastBar_ScaleTip				= 'Ein Wert von 100 entspricht dem Standard in Prozent.'
-- settings: cast bar (name)
L.CastBar_NameHeader			= 'Gezauberte Text der Fähigkeit'
L.CastBar_NameShow				= 'Zeige Fähigkeitsnamen'
-- settings: cast bar (timer)
L.CastBar_TimerHeader			= 'Zauberzeit Text'
L.CastBar_TimerShow				= 'Zeige Zauberzeit Text'
-- settings: cast bar (bar)
L.CastBar_BarHeader				= 'Zauberzeit Leiste'
L.CastBar_BarReverse			= 'Countdown umkehren'
L.CastBar_BarReverseTip			= 'Die Richtung des Countdowns kann seitlich umgekehrt werden.'
L.CastBar_BarGloss				= 'Glänzende Leiste'
L.CastBar_BarGlossTip			= 'Legt fest, ob die Zeitleiste glänzend ist. Standard ist EIN'
L.CastBar_BarWidth				= 'Leisten Breite'
L.CastBar_BarWidthTip			= 'Legt die Breite der Zeitleiste fest.\nEs kann sein, dass du nacher die Aura Gruppe verschieben musst.'
L.CastBar_BarColour				= 'Leisten Farbe'
L.CastBar_BarColourTip			= 'Legt die Farbe der Zeitleiste fest. Die linke Farbe definiert den Anfang (Countdown beginnt) und die rechte Farbe das Ende (Countdown läuft ab).'


-- ------------------------
-- SETTINGS: DISPLAY FRAMES
-- ------------------------
L.DisplayFrame_Alpha			= 'Fenster Transparenz'
L.DisplayFrame_AlphaTip			= 'Definiert die Transparenz des Fensters./nEin Wert von 100 = sichtbar, 0 = unsichtbar.'
L.DisplayFrame_Scale			= 'Fenster Skalierung'
L.DisplayFrame_ScaleTip			= 'Ein Wert von 100 entspricht dem Standard in Prozent.'
-- settings: display frames (aura)
L.DisplayFrame_AuraHeader		= 'Buff/Debuff Anzeige'
L.DisplayFrame_Style			= 'Buff/Debuff Aussehen'
L.DisplayFrame_StyleTip			= 'Ändert den Stil wie die Auren angezeigt werden.\n\n|cffd100Komplett anzeigen|r - Zeigt den Fähigkeitsnamen, Symbol, Zeittext und Zeitleiste.\n\n|cffd100Nur Icon|r - Zeigt das Symbol und den Zeittext.\n\n|cffd100Nur Text & Timer|r - Zeit den Fähigkeitsname und eine kleinere Zeitleiste.'
L.DisplayFrame_Growth			= 'Buff/Debuff Erweiterungsrichtung'
L.DisplayFrame_GrowthTip		= 'Zeigt die Richtung wo sich die Aura ausbreiten kann. Bei zentrierter Ausrichtung wächst sie beidseitig mit der gewünschten Sortierreihenfolge.\n\nDie Auren können nur nach oben und unten wachsen beim |cffd100Komplett anzeigen|r oder |cffd100Nur Text & Timer|r Stil.'
L.DisplayFrame_Padding			= 'Buff/Debuff Abstand'
L.DisplayFrame_PaddingTip		= 'Setzt den Abstand zwischen den Auren.'
L.DisplayFrame_Sort				= 'Buff/Debuff Reihenfolge'
L.DisplayFrame_SortTip			= 'Setzt die Sortierreihenfolge der Auren. Falls nach der Dauer sortiert wird, werden die passiven oder die umschaltbaren Auren immer am Anfang angezeigt.'
L.DisplayFrame_Highlight		= 'Umschaltbare Buffs/Debuffs hervorheben'
L.DisplayFrame_HighlightTip		= 'Die umschaltbaren Auren werden beim Symbol hervorgehoben.\n\nDieses Hervorheben funktioniert nicht beim |cffd100Nur Text & Timer|r Stil.'
L.DisplayFrame_Tooltips			= 'Buff/Debuff Tooltips mit Zaubernamen'
L.DisplayFrame_TooltipsTip		= 'Wenn die Aura mit dem Mauszeiger überfahren wird, zeigt es weitere Informationen zur Fähigkeit an. Nur beim Stil |cffd100Nur Icon|r möglich.'
L.DisplayFrame_TooltipsWarn		= 'Die Tooltips müssen ausgeschalten werden, wenn man das Fenster verschieben will. Ansonsten wird das Fenster zum Verschieben geblockt.'
-- settings: display frames (name)
L.DisplayFrame_NameHeader		= 'Fähigkeitenanzeige'
-- settings: display frames (timer)
L.DisplayFrame_TimerHeader		= 'Zeittext'
L.DisplayFrame_TimerLocation	= 'Zeit Position'
L.DisplayFrame_TimerLocationTip	= 'Setze die Zeitanzeige Position aus der Sicht des Symbols. \'Versteckt\' deaktiviert den Zeittext für diese Gruppe.\n\nEs sind nur bestimmte Einstellungen möglich, abhängig vom ausgewählten Stil.'
L.DisplayFrame_TimerHMS			= 'Zeige Minuten für Timer > 1 Stunde'
L.DisplayFrame_TimerHMSTip		= 'Festlegen, ob auch nur wenige Minuten zu zeigen, die verbleibt, wenn ein Timer von mehr als 1 Stunde.'


-- settings: display frames (bar)
L.DisplayFrame_BarHeader		= 'Zeitleiste'
L.DisplayFrame_BarReverse		= 'Countdown Richtung umkehren'
L.DisplayFrame_BarReverseTip	= 'Die Richtung des Countdowns kann seitlich umgekehrt werden. Beim |cffd100Komplett anzeigen|r Stil wird das Aura Symbol auf der anderen Seite angezeigt.'
L.DisplayFrame_BarGloss			= 'Glänzende Leisten'
L.DisplayFrame_BarGlossTip		= 'Legt fest, ob die Zeitleiste glänzend ist. Standard ist EIN'
L.DisplayFrame_BarWidth			= 'Leisten Breite'
L.DisplayFrame_BarWidthTip		= 'Legt die Breite der Zeitleiste fest.\nEs kann sein, dass du nacher die Aura Gruppe verschieben musst.'
L.DisplayFrame_BarTimed			= 'Farbe: Zeitliche Buffs/Debuffs'
L.DisplayFrame_BarTimedTip		= 'Legt die Farbe der Zeitleiste fest. Die linke Farbe definiert den Anfang (Countdown beginnt) und die rechte Farbe das Ende (Countdown läuft ab).'
L.DisplayFrame_BarToggled		= 'Farbe: Umschaltbare Buffs/Debuffs'
L.DisplayFrame_BarToggledTip	= 'Legt die Farbe der umschaltbaren Buffs/Debuffs fest. Die linke Farbe definiert den Anfang (Countdown beginnt) und die rechte Farbe das Ende (Countdown läuft ab).'
L.DisplayFrame_BarPassive		= 'Farbe: Passive Buffs/Debuffs'
L.DisplayFrame_BarPassiveTip	= 'Legt die Farbe der passiven Buffs/Debuffs fest. Die linke Farbe definiert den Anfang (Countdown beginnt) und die rechte Farbe das Ende (Countdown läuft ab).'
L.General_DisplayAbilityID		= 'Effekt-ID der Auren anzeigen'
L.General_DisplayAbilityIDTip	= 'Zeigt die internen Effekt-ID\'s der Auren an. Das wird benötigt, um z.B. die Fähigkeiten der Blacklist oder den Spezial Buffs hinzuzufügen.\nEs kann natürlich auch verwendet werden, um gewisse Auren dem AddOn Author zu melden.'
L.General_HideOnDeadTargets		= 'Verstecke Auren an toten Zielen'
L.General_HideOnDeadTargetsTip	= 'Wenn du keine Auren an toten Zielen sehen willst, aktiviere diese Option.'
L.General_ShowHoursMinutes		= 'Zeige Minuten bei Zeitanzeige > 1 Stunde'
L.General_ShowHoursMinutesTip	= 'Aktiviere diese Option um zusätzlich eine Minutenanzeige zu sehen bei\nBuffs > 1 Stunde.'

-- ------------------------
-- SETTINGS: PROFILES
-- ------------------------
L.Profile_Desc					= 'Verschiedene Profil- oder accountweite Einstellung kann hier gesetzt werden. Accountweite Einstellung wird für alle Charakter übernommen. Um die Funktionen zu aktivieren, muss zuerst die \'Profilverwaltung\', welche sich am Schluss befindet, aktiviert werden.'
L.Profile_UseGlobal				= 'Auf alle Charakter verwenden (accountweit)'
L.Profile_UseGlobalWarn			= 'Beim Umstellen von lokalen zu globalen Einstellungen wird das Interface neu geladen.'
L.Profile_Copy					= 'Profil zum Kopieren auswählen'
L.Profile_CopyTip				= 'Wähle ein Profil das zum aktuellen Charakter kopiert werden soll. Das aktive Profil wird entsprechend ersetzt oder neu als accountweite Einstellung gespeichert. Das aktuelle Profil wird \'unwiederruflich\' überschrieben!'
L.Profile_CopyButton			= 'Profil kopieren'
L.Profile_CopyButtonWarn		= 'Beim Kopieren eines Profils wird das Interface neu geladen.'
L.Profile_CopyCannotCopy		= 'Es ist nicht möglich das ausgewählte Profil zu kopieren. Versuche es erneut oder wähle ein anderes Profil.'
L.Profile_Delete				= 'Profil zum Löschen auswählen'
L.Profile_DeleteTip				= 'Wähle das zu löschende Profil aus. Wenn du dich später mit dem Charakter anmeldest und nicht das accountweite Profil ausgewählt hast, werden die ganzen Einstellung neu gesetzt.\n\nDas Löschen eines Profils kann nicht rückgängig gemacht werden!'
L.Profile_DeleteButton			= 'Profil Löschen'
L.Profile_Guard					= 'Profilverwaltung aktivieren'


if (GetCVar('language.2') == 'de') then -- overwrite GetLocale for new language
	for k, v in pairs(Srendarr:GetLocale()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function Srendarr:GetLocale() -- set new locale return
		return L
	end
end
