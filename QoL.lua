ComfyQoL = ComfyQoL or {}
local A = ComfyQoL

local function MoneyText(copper)
    copper=tonumber(copper) or 0
    if type(GetMoneyString)=="function" then
        local ok,text=pcall(GetMoneyString,copper,true)
        if ok and text then return text end
    end
    local g=math.floor(copper/10000)
    local s=math.floor((copper%10000)/100)
    local c=copper%100
    return string.format("%dg %ds %dc",g,s,c)
end

local function SetShownSafe(frame,shown)
    if not frame then return end
    if frame.SetShown then frame:SetShown(shown) elseif shown and frame.Show then frame:Show() elseif not shown and frame.Hide then frame:Hide() end
end

function A:Repair()
    if not self.db or not self.db.enabled or not self.db.qol.autoRepair then return end
    if type(CanMerchantRepair)~="function" or not CanMerchantRepair() then return end
    if type(GetRepairAllCost)~="function" or type(RepairAllItems)~="function" then return end

    local ok,cost,canRepair=pcall(GetRepairAllCost)
    cost=ok and tonumber(cost) or 0
    if not canRepair or not cost or cost<=0 then return end

    local usedGuild=false
    if self.db.qol.useGuildRepair and type(CanGuildBankRepair)=="function" then
        local good,allowed=pcall(CanGuildBankRepair)
        if good and allowed then
            local success=pcall(RepairAllItems,1)
            usedGuild=success
        end
    end

    if not usedGuild then
        local money=type(GetMoney)=="function" and tonumber(GetMoney()) or 0
        if money>=cost then pcall(RepairAllItems) else return end
    end
    self:Print(self:T("REPAIRED_FOR")..": "..MoneyText(cost))
end

function A:ApplyChatArrows()
    local enabled=self.db and self.db.enabled and self.db.qol.chatArrowKeys
    local count=tonumber(NUM_CHAT_WINDOWS) or 10
    for i=1,count do
        local edit=_G["ChatFrame"..i.."EditBox"]
        if edit and type(edit.SetAltArrowKeyMode)=="function" then
            pcall(edit.SetAltArrowKeyMode,edit,not enabled)
        end
    end
end

function A:ApplyErrorText()
    if not UIErrorsFrame then return end
    local hide=self.db and self.db.enabled and self.db.qol.hideErrorText
    if hide then
        if type(UIErrorsFrame.UnregisterEvent)=="function" then pcall(UIErrorsFrame.UnregisterEvent,UIErrorsFrame,"UI_ERROR_MESSAGE") end
    else
        if type(UIErrorsFrame.RegisterEvent)=="function" then pcall(UIErrorsFrame.RegisterEvent,UIErrorsFrame,"UI_ERROR_MESSAGE") end
    end
end

function A:ApplyZoneText()
    local hide=self.db and self.db.enabled and self.db.qol.hideZoneText
    for _,frame in ipairs({ZoneTextFrame,SubZoneTextFrame}) do
        if frame then
            if frame.__ComfyQoLOriginalAlpha==nil and type(frame.GetAlpha)=="function" then
                local ok,a=pcall(frame.GetAlpha,frame)
                frame.__ComfyQoLOriginalAlpha=ok and a or 1
            end
            if type(frame.SetAlpha)=="function" then
                pcall(frame.SetAlpha,frame,hide and 0 or (frame.__ComfyQoLOriginalAlpha or 1))
            end
        end
    end
end

function A:ApplyCamera()
    if type(SetCVar)~="function" then return end
    local enabled=self.db and self.db.enabled and self.db.qol.cameraMaxZoom
    if self.defaultCameraZoom==nil and type(GetCVar)=="function" then
        local ok,v=pcall(GetCVar,"cameraDistanceMaxZoomFactor")
        if ok then self.defaultCameraZoom=tonumber(v) end
    end
    if enabled then
        local value=math.max(1,math.min(2.6,tonumber(self.db.qol.cameraZoomFactor) or 2.6))
        pcall(SetCVar,"cameraDistanceMaxZoomFactor",value)
    elseif self.defaultCameraZoom then
        pcall(SetCVar,"cameraDistanceMaxZoomFactor",self.defaultCameraZoom)
    end
end

function A:ApplyAll()
    if not self.db then return end
    self:ApplyChatArrows()
    self:ApplyErrorText()
    self:ApplyZoneText()
    self:ApplyCamera()
end

function A:HandleEvent(event,...)
    if not self.db or not self.db.enabled then return end
    if event=="MERCHANT_SHOW" then
        self:Repair()
    elseif event=="RESURRECT_REQUEST" and self.db.qol.autoAcceptResurrect then
        if type(AcceptResurrect)=="function" then pcall(AcceptResurrect) end
    elseif event=="DUEL_REQUESTED" and self.db.qol.blockDuels then
        if type(CancelDuel)=="function" then pcall(CancelDuel) end
        if StaticPopup_Hide then pcall(StaticPopup_Hide,"DUEL_REQUESTED") end
    elseif event=="UPDATE_CHAT_WINDOWS" then
        self:ApplyChatArrows()
    elseif event=="PLAYER_ENTERING_WORLD" then
        self:ApplyAll()
    end
end

function A:InitializeFeature()
    local f=CreateFrame("Frame")
    self.eventFrame=f
    for _,ev in ipairs({"MERCHANT_SHOW","RESURRECT_REQUEST","DUEL_REQUESTED","UPDATE_CHAT_WINDOWS","PLAYER_ENTERING_WORLD"}) do
        pcall(f.RegisterEvent,f,ev)
    end
    f:SetScript("OnEvent",function(_,event,...) A:HandleEvent(event,...) end)

    for _,frame in ipairs({ZoneTextFrame,SubZoneTextFrame}) do
        if frame and type(frame.HookScript)=="function" then
            pcall(frame.HookScript,frame,"OnShow",function(self)
                if A.db and A.db.enabled and A.db.qol.hideZoneText and self.SetAlpha then self:SetAlpha(0) end
            end)
        end
    end
    self:ApplyAll()
end

local function CreateCategoryButton(page,text,x,y,width,onClick)
    local b=CreateFrame("Button",nil,page,"UIPanelButtonTemplate")
    b:SetSize(width or 150,24)
    b:SetPoint("TOPLEFT",x,y)
    b:SetText(text)
    b:SetScript("OnClick",onClick)
    return b
end

function A:ShowQoLCategory(category)
    if not self.qolCategoryPages then return end
    self.db.qol.category=category
    for key,frame in pairs(self.qolCategoryPages) do frame:SetShown(key==category) end
    for key,button in pairs(self.qolCategoryButtons or {}) do
        if button.LockHighlight then
            if key==category then button:LockHighlight() else button:UnlockHighlight() end
        end
    end
end

function A:BuildGeneralOptions(page,ui)
    local title=page:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    title:SetPoint("TOPLEFT",20,-18)
    title:SetText(self:T("TAB_GENERAL"))

    self.qolCategoryPages={}
    self.qolCategoryButtons={}

    local categories={
        {"automation",self:T("CAT_AUTOMATION")},
        {"chat",self:T("CAT_CHAT")},
        {"interface",self:T("CAT_INTERFACE")},
        {"camera",self:T("CAT_CAMERA")},
        {"social",self:T("CAT_SOCIAL")},
    }

    for i,entry in ipairs(categories) do
        local key,label=entry[1],entry[2]
        local button=CreateCategoryButton(page,label,20,-60-(i-1)*32,160,function() A:ShowQoLCategory(key) end)
        self.qolCategoryButtons[key]=button

        local sub=CreateFrame("Frame",nil,page)
        sub:SetPoint("TOPLEFT",200,-55)
        sub:SetPoint("BOTTOMRIGHT",-20,20)
        sub:Hide()
        self.qolCategoryPages[key]=sub
    end

    local p=self.qolCategoryPages.automation
    ui.CreateCheck(p,self:T("AUTO_REPAIR"),10,-15,function() return A.db.qol.autoRepair end,function(v) A.db.qol.autoRepair=v end)
    ui.CreateCheck(p,self:T("GUILD_REPAIR"),35,-50,function() return A.db.qol.useGuildRepair end,function(v) A.db.qol.useGuildRepair=v end)
    ui.CreateCheck(p,self:T("AUTO_RESURRECT"),10,-85,function() return A.db.qol.autoAcceptResurrect end,function(v) A.db.qol.autoAcceptResurrect=v end)

    p=self.qolCategoryPages.chat
    ui.CreateCheck(p,self:T("CHAT_ARROWS"),10,-15,function() return A.db.qol.chatArrowKeys end,function(v) A.db.qol.chatArrowKeys=v; A:ApplyChatArrows() end)

    p=self.qolCategoryPages.interface
    ui.CreateCheck(p,self:T("HIDE_ERRORS"),10,-15,function() return A.db.qol.hideErrorText end,function(v) A.db.qol.hideErrorText=v; A:ApplyErrorText() end)
    ui.CreateCheck(p,self:T("HIDE_ZONE_TEXT"),10,-50,function() return A.db.qol.hideZoneText end,function(v) A.db.qol.hideZoneText=v; A:ApplyZoneText() end)

    p=self.qolCategoryPages.camera
    ui.CreateCheck(p,self:T("CAMERA_MAX_ZOOM"),10,-15,function() return A.db.qol.cameraMaxZoom end,function(v) A.db.qol.cameraMaxZoom=v; A:ApplyCamera() end)
    ui.CreateSlider(p,self:T("CAMERA_ZOOM_FACTOR"),1,2.6,0.1,20,-100,
        function() return A.db.qol.cameraZoomFactor end,
        function(v) A.db.qol.cameraZoomFactor=math.floor(v*10+0.5)/10; A:ApplyCamera() end,
        function(v) return string.format("%.1f",v) end)

    p=self.qolCategoryPages.social
    ui.CreateCheck(p,self:T("BLOCK_DUELS"),10,-15,function() return A.db.qol.blockDuels end,function(v) A.db.qol.blockDuels=v end)

    local note=page:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
    note:SetPoint("BOTTOMLEFT",200,25)
    note:SetWidth(620)
    note:SetJustifyH("LEFT")
    note:SetText(self:T("FOREVER_NOTE"))

    self:ShowQoLCategory(self.db.qol.category or "automation")
end
