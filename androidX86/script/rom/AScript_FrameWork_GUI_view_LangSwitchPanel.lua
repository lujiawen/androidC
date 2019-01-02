LangSwitchPanel = class("LangSwitchPanel",BaseView)
LangSwitchPanel.ViewType = UIViewType.PopUpLayer

LangSwitchPanel.NeedLanguage = {
    [1] = {key = "ChineseSimplified",title = "简体中文"},
    [2] = {key = "Thai",title = "泰语"},
    [3] = {key = "Indonesian",title = "印尼语"},
    [4] = {key = "English",title = "英语"},
    [5] = {key = "Vietnamese",title = "越南语"}
}

function LangSwitchPanel:Init()

    -- 多语言设置
    for _,v in pairs(LangSwitchPanel.NeedLanguage) do
        local lbtn = self:FindGO(v.key)
        if lbtn then
            lbtn:SetActive(true)
            local title = self:FindGO('Title',lbtn)
            title:GetComponent(UILabel).text = v.title
            self:AddClickEvent(lbtn, function (go)
                self:ReloadLanguage(v.key)
            end)
        end
    end
    
end

function LangSwitchPanel:GetCurLanguageKey(title)
    for _,v in pairs(LangSwitchPanel.NeedLanguage) do
        if v.title == title then
            return v.key
        end
    end
    return LangSwitchPanel.NeedLanguage[4].key
end

function LangSwitchPanel:GetCurLanguageConf()
    local curLang =  OverSea.LangManager.Instance().CurSysLang
    for _,v in pairs(LangSwitchPanel.NeedLanguage) do
        if v.key == curLang then
            return v
        end
    end
    return LangSwitchPanel.NeedLanguage[4]
end

function LangSwitchPanel:ReloadLanguage(lang)
    OverSea.LangManager.Instance():SetCurLang(lang)
    OverSeas_TW.OverSeasManager.GetInstance():SetSDKLang(AppBundleConfig.GetSDKLang())
    Game.Me():BackToLogo()
end

function LangSwitchPanel:OnEnter()
    LangSwitchPanel.super.OnEnter(self);
end

function LangSwitchPanel:OnExit()
    LangSwitchPanel.super.OnExit(self);
end