ComfyQoL = ComfyQoL or {}
local A=ComfyQoL
local de=GetLocale and GetLocale()=="deDE"

local EN={
    TAB_GENERAL="Quality of Life",TAB_INFO="Info",ADDON_ENABLED="Enable ComfyQoL",
    INFO_VERSION="Version",INFO_BUILD_DATE="Build date",INFO_STATUS="Status",INFO_CLIENT="Current client",
    INFO_TESTED_TARGET="Tested target",INFO_COMPAT_STATUS="Compatibility",INFO_AUTHOR="Author",
    INFO_DISCORD="Discord",INFO_GITHUB="GitHub",INFO_COMMANDS="Slash commands",
    COMPAT_MATCH="Compatible",COMPAT_UPDATE_REQUIRED="Interface differs from the tested target",
    INFO_NOTICE="ComfyQoL contains small independent convenience modules. Every feature can be disabled individually.",
    INFO_THANKS="Thanks for using ComfyQoL! Feedback and bug reports are welcome via Discord.",

    CAT_AUTOMATION="Automation",CAT_CHAT="Chat",CAT_INTERFACE="Interface",CAT_CAMERA="Camera",CAT_SOCIAL="Social",
    AUTO_REPAIR="Automatically repair at merchants",
    GUILD_REPAIR="Use guild funds for repair when available",
    AUTO_RESURRECT="Automatically accept resurrection requests",
    CHAT_ARROWS="Use arrow keys to edit chat text",
    HIDE_ERRORS="Hide red UI error messages",
    HIDE_ZONE_TEXT="Hide large zone/subzone text",
    BLOCK_DUELS="Automatically decline duel requests",
    CAMERA_MAX_ZOOM="Use custom maximum camera distance",
    CAMERA_ZOOM_FACTOR="Maximum camera zoom factor",
    REPAIRED_FOR="Repaired for",
    FOREVER_NOTE="Only guarded Forever-compatible or legacy APIs are used. ComfyQoL does not automate combat, movement or protected actions.",
}
local DE={
    TAB_GENERAL="Komfort",TAB_INFO="Info",ADDON_ENABLED="ComfyQoL aktivieren",
    INFO_VERSION="Version",INFO_BUILD_DATE="Build-Datum",INFO_STATUS="Status",INFO_CLIENT="Aktueller Client",
    INFO_TESTED_TARGET="Getestetes Ziel",INFO_COMPAT_STATUS="Kompatibilität",INFO_AUTHOR="Autor",
    INFO_DISCORD="Discord",INFO_GITHUB="GitHub",INFO_COMMANDS="Slash-Befehle",
    COMPAT_MATCH="Kompatibel",COMPAT_UPDATE_REQUIRED="Interface weicht vom getesteten Ziel ab",
    INFO_NOTICE="ComfyQoL enthält kleine unabhängige Komfortmodule. Jede Funktion kann einzeln ausgeschaltet werden.",
    INFO_THANKS="Danke, dass du ComfyQoL nutzt! Feedback und Fehlermeldungen sind über Discord willkommen.",

    CAT_AUTOMATION="Automatisierung",CAT_CHAT="Chat",CAT_INTERFACE="Interface",CAT_CAMERA="Kamera",CAT_SOCIAL="Sozial",
    AUTO_REPAIR="Beim Händler automatisch reparieren",
    GUILD_REPAIR="Wenn verfügbar Gildengold für Reparaturen nutzen",
    AUTO_RESURRECT="Wiederbelebungsanfragen automatisch annehmen",
    CHAT_ARROWS="Pfeiltasten zum Bearbeiten von Chattext verwenden",
    HIDE_ERRORS="Rote UI-Fehlermeldungen ausblenden",
    HIDE_ZONE_TEXT="Große Zonen-/Unterzonen-Texte ausblenden",
    BLOCK_DUELS="Duellanfragen automatisch ablehnen",
    CAMERA_MAX_ZOOM="Eigene maximale Kameradistanz verwenden",
    CAMERA_ZOOM_FACTOR="Maximaler Kamera-Zoomfaktor",
    REPAIRED_FOR="Repariert für",
    FOREVER_NOTE="Es werden nur abgesicherte Forever-kompatible oder Legacy-APIs genutzt. ComfyQoL automatisiert weder Kampf noch Bewegung oder geschützte Aktionen.",
}
local S=de and DE or EN
function A:T(k) return S[k] or EN[k] or k end
