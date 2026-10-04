local ADDON_NAME = ...

ComfyQoL = ComfyQoL or {}
local A = ComfyQoL

A.name = ADDON_NAME or "ComfyQoL"
A.version = "0.6"
A.buildDate = "04.10.2026"
A.status = "Beta"
A.gameVersion = "WoW Forever 1.60.1"
A.targetBuild = "70009"
A.interface = 16001
A.author = "TheRealDoubleG"
A.discord = "the.real.double.g"
A.github = "https://github.com/TheRealDoubleG/ComfyQoL"

local defaults = {
    enabled = true,
    qol = {
        category = "automation",

        autoRepair = true,
        useGuildRepair = false,
        autoAcceptResurrect = false,

        chatArrowKeys = true,
        chatTimestamps = false,

        hideErrorText = false,
        hideZoneText = false,
        fadeObjectivesInCombat = false,
        objectiveCombatAlpha = 35,
        hideTalkingHead = false,

        blockDuels = false,
        blockGuildInvites = false,
        blockPartyInvites = false,

        cameraMaxZoom = false,
        cameraZoomFactor = 2.6,
        cameraCustomZoomSpeed = false,
        cameraZoomSpeed = 20,
    },
    optionsWindow = {point="CENTER",relativePoint="CENTER",x=0,y=20},
    ui = {windowLocked=false,windowOpacity=100,showWindowBorder=true,backgroundAlpha=92},
}

function A:Print(msg)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffffd200ComfyQoL:|r "..tostring(msg)) end
end

function A:GetClientBuildInfo()
    if type(GetBuildInfo)~="function" then return "?","?","?",nil end
    local v,b,d,i=GetBuildInfo()
    return tostring(v or "?"),tostring(b or "?"),tostring(d or "?"),tonumber(i)
end

function A:GetCompatibilityStatus()
    local _,_,_,i=self:GetClientBuildInfo()
    if i and tonumber(i)==tonumber(self.interface) then return true,self:T("COMPAT_MATCH") end
    return false,self:T("COMPAT_UPDATE_REQUIRED")
end

function A:InitializeDB()
    self:InitializeProfileStorage(defaults,"ComfyQoLDB")
end

function A:SetEnabled(v)
    if not self.db then return false end
    self.db.enabled=v and true or false
    if self.ApplyAll then self:ApplyAll() end
    if self.RefreshOptions then self:RefreshOptions() end
    return true
end

function A:GetComfyProfileProvider() return self end
function A:OpenOptions() if self.ShowOptions then self:ShowOptions() end end

SLASH_COMFYQOL1="/comfyqol"
SLASH_COMFYQOL2="/cqol"
SlashCmdList.COMFYQOL=function() A:OpenOptions() end

local e=CreateFrame("Frame")
e:RegisterEvent("ADDON_LOADED")
e:RegisterEvent("PLAYER_LOGIN")
e:SetScript("OnEvent",function(_,ev,arg1)
    if ev=="ADDON_LOADED" and arg1==A.name then
        A:InitializeDB()
        if A.InitializeFeature then A:InitializeFeature() end
        if A.InitializeOptions then A:InitializeOptions() end
    elseif ev=="PLAYER_LOGIN" and A.ApplyAll then
        A:ApplyAll()
    end
end)
