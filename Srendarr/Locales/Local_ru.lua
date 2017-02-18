-- Russian (ru) - Translations provided by @KiriX (http://www.esoui.com/forums/member.php?u=105)
local Srendarr		= _G['Srendarr'] -- grab addon table from global
local L				= {}

L.Srendarr  = '|c67b1e9S|c4779ce\'rendarr|r'

L.Usage     = '|c67b1e9S|c4779ce\'rendarr|r - Ècïoìöçoáaîèe: /srendarr áêìôùèòö/oòêìôùèòö áoçíoæîocòö ïepeäáèâaòö ëìeíeîòÿ èîòep³eéca aääoîa ïo ëêpaîó.'



-- time format

L.Time_Seconds          = '%dc'
L.Time_Minutes          = '%dí'
L.Time_Hours            = '%dù'


-- aura grouping














-- whitelist & blacklist control







-- settings: base

























-- settings: generic








-- settings: dropdown entries


































-- ------------------------
-- SETTINGS: GENERAL
-- ------------------------



















-- settings: general (aura control: display groups)













-- settings: general (prominent auras)










-- ------------------------
-- SETTINGS: FILTERS
-- ------------------------







































-- ------------------------
-- SETTINGS: CAST BAR
-- ------------------------






-- settings: cast bar (name)


-- settings: cast bar (timer)


-- settings: cast bar (bar)











-- ------------------------
-- SETTINGS: DISPLAY FRAMES
-- ------------------------




-- settings: display frames (aura)














-- settings: display frames (name)

-- settings: display frames (timer)



-- settings: display frames (bar)















-- ------------------------
-- SETTINGS: PROFILES
-- ------------------------














if (GetCVar('language.2') == 'ru') then -- overwrite GetLocale for new language
    for k, v in pairs(Srendarr:GetLocale()) do
        if (not L[k]) then -- no translation for this string, use default
            L[k] = v
        end
    end

    function Srendarr:GetLocale() -- set new locale return
        return L
    end
end
