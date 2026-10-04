ComfyQoL = ComfyQoL or {}
local A = ComfyQoL

A.version = "0.6"
A.buildDate = "04.10.2026"

local function IsDE()
    return type(GetLocale)=="function" and GetLocale()=="deDE"
end

local function Text(de,en)
    return IsDE() and de or en
end

local function EnsureDefaults()
    if not A.db then return end
    A.db.qol = A.db.qol or {}
    local q=A.db.qol
    local defaults={
        chatTimestamps=false,
        fadeObjectivesInCombat=false,
        objectiveCombatAlpha=35,
        hideTalkingHead=false,
        blockGuildInvites=false,
        blockPartyInvites=false,
        cameraCustomZoomSpeed=false,
        cameraZoomSpeed=20,
    }
    for k,v in pairs(defaults) do if q[k]==nil then q[k]=v end end
end

local function SafeGetCVar(name)
    if type(GetCVar)~="function" then return nil end
    local ok,v=pcall(GetCVar,name)
    return ok and v or nil
end

local function SafeSetCVar(name,value)
    if type(SetCVar)~="function" then return false end
    return pcall(SetCVar,name,tostring(value))
end

function A:ApplyChatTimestamps()
    EnsureDefaults()
    local q=self.db and self.db.qol
    if not q then return end
    if self.__originalTimestampCVar==nil then self.__originalTimestampCVar=SafeGetCVar("showTimestamps") end
    if q.chatTimestamps then
        SafeSetCVar("showTimestamps","[%H:%M] ")
    elseif self.__originalTimestampCVar~=nil then
        SafeSetCVar("showTimestamps",self.__originalTimestampCVar)
    end
end

local function ObjectiveFrames()
    local out={}
    for _,f in ipairs({_G.ObjectiveTrackerFrame,_G.QuestWatchFrame,_G.WatchFrame}) do
        if f then out[#out+1]=f end
    end
    return out
end

function A:ApplyObjectiveTrackerComfort()
    EnsureDefaults()
    local q=self.db and self.db.qol
    if not q then return end
    local alpha=1
    if q.fadeObjectivesInCombat and type(InCombatLockdown)=="function" and InCombatLockdown() then
        alpha=math.max(0,math.min(100,tonumber(q.objectiveCombatAlpha) or 35))/100
    end
    for _,f in ipairs(ObjectiveFrames()) do
        if f.__ComfyQoLOriginalAlpha==nil and type(f.GetAlpha)=="function" then
            local ok,v=pcall(f.GetAlpha,f); if ok then f.__ComfyQoLOriginalAlpha=tonumber(v) or 1 end
        end
        if type(f.SetAlpha)=="function" then pcall(f.SetAlpha,f,alpha) end
    end
end

function A:ApplyTalkingHeadComfort()
    EnsureDefaults()
    local q=self.db and self.db.qol
    local f=_G.TalkingHeadFrame
    if not q or not f then return end
    if not f.__ComfyQoLHooked and type(f.HookScript)=="function" then
        f.__ComfyQoLHooked=true
        f:HookScript("OnShow",function(self)
            if A.db and A.db.enabled and A.db.qol and A.db.qol.hideTalkingHead then
                if type(self.SetAlpha)=="function" then self:SetAlpha(0) end
                if type(self.EnableMouse)=="function" then self:EnableMouse(false) end
            end
        end)
    end
    if q.hideTalkingHead then
        if type(f.SetAlpha)=="function" then pcall(f.SetAlpha,f,0) end
        if type(f.EnableMouse)=="function" then pcall(f.EnableMouse,f,false) end
    else
        if type(f.SetAlpha)=="function" then pcall(f.SetAlpha,f,1) end
        if type(f.EnableMouse)=="function" then pcall(f.EnableMouse,f,true) end
    end
end

function A:ApplyCameraZoomSpeed()
    EnsureDefaults()
    local q=self.db and self.db.qol
    if not q then return end
    if self.__originalCameraZoomSpeed==nil then self.__originalCameraZoomSpeed=SafeGetCVar("cameraZoomSpeed") end
    if q.cameraCustomZoomSpeed then
        local value=math.max(1,math.min(50,tonumber(q.cameraZoomSpeed) or 20))
        SafeSetCVar("cameraZoomSpeed",value)
    elseif self.__originalCameraZoomSpeed~=nil then
        SafeSetCVar("cameraZoomSpeed",self.__originalCameraZoomSpeed)
    end
end

local originalApplyAll=A.ApplyAll
function A:ApplyAll(...)
    if originalApplyAll then originalApplyAll(self,...) end
    if not self.db then return end
    EnsureDefaults()
    if not self.db.enabled then return end
    self:ApplyChatTimestamps()
    self:ApplyObjectiveTrackerComfort()
    self:ApplyTalkingHeadComfort()
    self:ApplyCameraZoomSpeed()
end

local function DeclineGuildInvite()
    if type(DeclineGuild)=="function" then pcall(DeclineGuild) end
    if type(StaticPopup_Hide)=="function" then pcall(StaticPopup_Hide,"GUILD_INVITE") end
end

local function DeclinePartyInvite()
    if type(DeclineGroup)=="function" then pcall(DeclineGroup) end
    if type(StaticPopup_Hide)=="function" then
        pcall(StaticPopup_Hide,"PARTY_INVITE")
        pcall(StaticPopup_Hide,"PARTY_INVITE_XREALM")
    end
end

local events=CreateFrame("Frame")
for _,ev in ipairs({"PLAYER_ENTERING_WORLD","PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED","GUILD_INVITE_REQUEST","PARTY_INVITE_REQUEST"}) do
    pcall(events.RegisterEvent,events,ev)
end
events:SetScript("OnEvent",function(_,event)
    if not A.db or not A.db.enabled then return end
    EnsureDefaults()
    if event=="PLAYER_REGEN_DISABLED" or event=="PLAYER_REGEN_ENABLED" or event=="PLAYER_ENTERING_WORLD" then
        A:ApplyObjectiveTrackerComfort()
        if event=="PLAYER_ENTERING_WORLD" then
            A:ApplyChatTimestamps(); A:ApplyTalkingHeadComfort(); A:ApplyCameraZoomSpeed()
        end
    elseif event=="GUILD_INVITE_REQUEST" and A.db.qol.blockGuildInvites then
        DeclineGuildInvite()
    elseif event=="PARTY_INVITE_REQUEST" and A.db.qol.blockPartyInvites then
        DeclinePartyInvite()
    end
end)
A.comfortPlusEvents=events

local originalBuildGeneralOptions=A.BuildGeneralOptions
function A:BuildGeneralOptions(page,ui)
    if originalBuildGeneralOptions then originalBuildGeneralOptions(self,page,ui) end
    EnsureDefaults()
    if not ui or not self.qolCategoryPages then return end
    local q=self.db.qol

    local p=self.qolCategoryPages.chat
    if p then
        ui.CreateCheck(p,Text("Zeitstempel im Chat anzeigen","Show timestamps in chat"),10,-50,
            function() return q.chatTimestamps end,
            function(v) q.chatTimestamps=v; A:ApplyChatTimestamps() end)
    end

    p=self.qolCategoryPages.interface
    if p then
        ui.CreateCheck(p,Text("Questtracker im Kampf abdunkeln","Fade objective tracker in combat"),10,-85,
            function() return q.fadeObjectivesInCombat end,
            function(v) q.fadeObjectivesInCombat=v; A:ApplyObjectiveTrackerComfort() end)
        ui.CreateSlider(p,Text("Questtracker-Deckkraft im Kampf","Objective tracker combat opacity"),0,100,5,20,-155,
            function() return q.objectiveCombatAlpha end,
            function(v) q.objectiveCombatAlpha=math.floor(v+0.5); A:ApplyObjectiveTrackerComfort() end,
            function(v) return string.format("%d%%",math.floor(v+0.5)) end)
        ui.CreateCheck(p,Text("Sprechkopf-Fenster ausblenden","Hide Talking Head frame"),10,-205,
            function() return q.hideTalkingHead end,
            function(v) q.hideTalkingHead=v; A:ApplyTalkingHeadComfort() end)
    end

    p=self.qolCategoryPages.camera
    if p then
        ui.CreateCheck(p,Text("Eigene Mausrad-Zoomgeschwindigkeit","Use custom mouse-wheel zoom speed"),10,-160,
            function() return q.cameraCustomZoomSpeed end,
            function(v) q.cameraCustomZoomSpeed=v; A:ApplyCameraZoomSpeed() end)
        ui.CreateSlider(p,Text("Zoomgeschwindigkeit","Zoom speed"),1,50,1,20,-235,
            function() return q.cameraZoomSpeed end,
            function(v) q.cameraZoomSpeed=math.floor(v+0.5); A:ApplyCameraZoomSpeed() end,
            function(v) return tostring(math.floor(v+0.5)) end)
    end

    p=self.qolCategoryPages.social
    if p then
        ui.CreateCheck(p,Text("Gildeneinladungen automatisch ablehnen","Automatically decline guild invites"),10,-50,
            function() return q.blockGuildInvites end,
            function(v) q.blockGuildInvites=v end)
        ui.CreateCheck(p,Text("Gruppeneinladungen automatisch ablehnen","Automatically decline party invites"),10,-85,
            function() return q.blockPartyInvites end,
            function(v) q.blockPartyInvites=v end)
    end
end
