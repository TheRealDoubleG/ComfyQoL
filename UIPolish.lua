ComfyQoL = ComfyQoL or {}
local A = ComfyQoL

A.version = "0.5"
A.buildDate = "04.10.2026"

local function FontText(region)
    if not region or type(region.GetObjectType)~="function" or region:GetObjectType()~="FontString" or type(region.GetText)~="function" then return nil end
    local ok,text=pcall(region.GetText,region); return ok and text or nil
end

local function PolishCheckButtons(frame,depth)
    if not frame or (depth or 0)>5 or type(frame.GetChildren)~="function" then return end
    local children={frame:GetChildren()}
    for _,child in ipairs(children) do
        if child and type(child.GetObjectType)=="function" and child:GetObjectType()=="CheckButton" then
            local label=child.Text or child.text
            if label then
                label:ClearAllPoints(); label:SetPoint("LEFT",child,"RIGHT",5,1); label:SetJustifyH("LEFT")
            end
        end
        PolishCheckButtons(child,(depth or 0)+1)
    end
end

function A:PolishOptionsUI()
    local f=self.optionsFrame
    if not f or not f.pages then return end
    local general=f.pages[1]
    if not general then return end

    -- Options.lua already creates the main page heading. BuildGeneralOptions
    -- used to create the same heading a second time, which produced the
    -- duplicated "Komfort" text seen during the play test.
    local heading=self:T("TAB_GENERAL")
    local foundHeading=false
    if type(general.GetRegions)=="function" then
        local regions={general:GetRegions()}
        for _,region in ipairs(regions) do
            local text=FontText(region)
            if text==heading then
                if foundHeading then region:Hide() else
                    foundHeading=true
                    region:ClearAllPoints(); region:SetPoint("TOPLEFT",20,-12)
                end
            elseif text==self:T("FOREVER_NOTE") then
                region:ClearAllPoints(); region:SetPoint("BOTTOMLEFT",210,42); region:SetWidth(500); region:SetJustifyH("LEFT")
            end
        end
    end

    local order={"automation","chat","interface","camera","social"}
    for i,key in ipairs(order) do
        local b=self.qolCategoryButtons and self.qolCategoryButtons[key]
        if b then
            b:ClearAllPoints(); b:SetPoint("TOPLEFT",20,-72-(i-1)*38); b:SetSize(165,27)
        end
        local page=self.qolCategoryPages and self.qolCategoryPages[key]
        if page then
            page:ClearAllPoints(); page:SetPoint("TOPLEFT",210,-58); page:SetPoint("BOTTOMRIGHT",-28,58)
        end
    end

    PolishCheckButtons(general,0)
end

local function SelectTab(index)
    local f=A.optionsFrame; if not f or not f.tabs then return end
    for i,tab in ipairs(f.tabs) do
        tab:SetEnabled(true)
        tab:SetButtonState(i==index and "PUSHED" or "NORMAL",false)
        if f.pages and f.pages[i] then f.pages[i]:SetShown(i==index) end
    end
end

local originalInitializeOptions=A.InitializeOptions
function A:InitializeOptions(...)
    if originalInitializeOptions then originalInitializeOptions(self,...) end
    if not self.optionsFrame or self.__qolPolishInstalled then return end
    self.__qolPolishInstalled=true
    self:PolishOptionsUI()
    for i,tab in ipairs(self.optionsFrame.tabs or {}) do local index=i; tab:SetScript("OnClick",function() SelectTab(index) end) end
    SelectTab(1)
    self.optionsFrame:HookScript("OnShow",function() A:PolishOptionsUI() end)
end
