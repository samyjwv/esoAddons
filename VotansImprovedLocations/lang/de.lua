if GetAPIVersion() <= 100016 then
	SafeAddString(SI_VOTANSIMPROVEDLOCATIONS_SHOW_LEVELS, "Stufen anzeigen", 0)
	SafeAddString(SI_VOTANSIMPROVEDLOCATIONS_SORT_ASC, "Stufe aufsteigend", 0)
	SafeAddString(SI_VOTANSIMPROVEDLOCATIONS_SORT_DSC, "Stufe absteigend", 0)
else
	SafeAddString(SI_VOTANSIMPROVEDLOCATIONS_SHOW_LEVELS, "Reihenfolge der Hauptgeschichte anzeigen", 0)
	SafeAddString(SI_VOTANSIMPROVEDLOCATIONS_SORT_ASC, "Geschichte aufsteigend", 0)
	SafeAddString(SI_VOTANSIMPROVEDLOCATIONS_SORT_DSC, "Geschichte absteigend", 0)
end
SafeAddString(SI_VOTANSIMPROVEDLOCATIONS_SORT, "Sortierung nach", 0)
SafeAddString(SI_VOTANSIMPROVEDLOCATIONS_SORT_NAME, "Name", 0)
SafeAddString(SI_VOTANSIMPROVEDLOCATIONS_SHOW_ALL_ALLIANCE_ON_TOP, "\"Alle Allianzen\" zuerst anzeigen")
