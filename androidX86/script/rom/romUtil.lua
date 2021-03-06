-- romUtil.lua ----
function splitByChunk(text, chunkSize)
    local s = {}
    for i=1, #text, chunkSize do
        s[#s+1] = text:sub(i,i+chunkSize - 1)
    end
    return s
end

function tableForEach(t, f) 
        for i, v in pairs(t) do f(i,v) end 
end 

function tableIsEmpty(t)
    for _,_ in pairs(t) do
        return false
    end
    return true
end

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function singleLine(data)
	local line = string.gsub(tostring(data), "\n", " ");
	line = string.gsub(line, "\r", " ");
	line = string.gsub(line, "%s+", " ");
	return line;
end;

function ROM_Alert(mesg)
    UIUtil.FloatMsgByText(mesg);	
end;

function ROM_LogChat(mesg)
	local chat = ChatMessageData:new();
	chat:SetStr(mesg);
	chat[4] = ChatChannelEnum.System;
	ChatRoomProxy.Instance:UpdateScrollScreenContents(chat,ChatChannelEnum.System);
	ChatRoomProxy.Instance:UpdateChatContents(chat,ChatChannelEnum.System)
	GameFacade.Instance:sendNotification(ChatRoomEvent.SystemMessage , chat)
end;



function GameObjectToString(go,tab,visible)
	tab = tab or "";
	if go == nil then return "NULL"; end;
	local ret = tab .. UserDataToString(go);
	local trans = go.transform;
	for i=0, trans.childCount-1 do
		local goChild = trans:GetChild(i).gameObject;
        if visible == nil or goChild.activeSelf == visible then
            ret = ret .. "\n" .. GameObjectToString(goChild,tab .. " ",visible);
        end;
	end
	return ret;
end;


function UserDataToString(value)
	local ret = "[" .. type(value) .. "] " .. tostring(value);
	if string.match(ret, "(UnityEngine.GameObject)") then	
		--ret = "[GameObject] name=" .. tostring(value.name) .. " scene=" .. MyTostring(value.scene) .. " " .. tostring(value.activeSelf);
        if value.name == "Label" then
            local label = value:GetComponent(UILabel);
            if label ~= nil then
                ret = "[GameObject] name=" .. tostring(value.name) ..  " text=" .. label.text .. " " .. tostring(value.activeSelf);        
                return ret;
            end;
        end;
        ret = "[GameObject] name=" .. tostring(value.name) ..  " " .. tostring(value.activeSelf);        
	end;
	if string.match(ret, "(UnityEngine.SceneManagement.Scene)") then	
		--ret = "[Scene] name=" .. value.name .. " path=" .. value.path .. " rootCount=" .. value.rootCount;
		ret = "[Scene] name=" .. value.name .. " #root=" .. value.rootCount;
	end;
	if string.match(ret, "(UISprite)") then	
		ret = "[UISprite] name=" .. value.name .. " spriteName=" .. value.spriteName;
	end;
	if string.match(ret, "(UILabel)") then	
		ret = "[UILabel] name=" .. value.name .. " text=" .. value.text .. " fontSize=" .. value.fontSize;
	end;
	
	return ret;
end;

function PropToString(obj,prefix,order,ignore)
	ignore = ignore or {};
	if obj == nil then	
		return "";
	end;
	prefix = prefix or "";
	order = order or {"id","ID"};
	local ret = "";
	tableForEach(order, function(i, v)	
		if obj[v] ~= nil then
			if ((type(obj[v]) == 'string') or (type(obj[v]) == 'number') or (type(obj[v]) == 'boolean' ))  then
				ret = ret .. prefix .. tostring(v) .. "=" .. tostring(obj[v]) .. ",";
			end;
		end;
	end);

	tableForEach(obj, function(i, v)	
		if ((type(i) == 'string') or (type(i) == 'number')) and ((type(v) == 'string') or (type(v) == 'number') or (type(v) == 'boolean' )) then
			if TableUtil.HasValue(order,tostring(i)) == false and TableUtil.HasValue(ignore,tostring(i)) == false then	
				ret = ret .. prefix .. tostring(i) .. "=" .. tostring(v) .. ",";
			end;
		end;
	end);
	return ret;
end;

function ListField(obj,tab,tableHash,targetTab,ignore)
    ignore = ignore or {};
    targetTab = targetTab or "       ";
    tab = tab or "";
	tableHash = tableHash or {};
    if (type(obj) == 'table') then
		-- check if we visit this able before
		if tableHash[tostring(obj)]  ~= nil then
			return tab .. tostring(obj) .. "*";
		end;
		tableHash[tostring(obj)] = true;
		-- check if it a custom lua object
		--if obj["__cname"] ~= nil and obj["super"] ~= nil then
		--	LogDebug(tab .. "[" .. obj.__cname .. "] " .. tostring(obj));
		--end;
        tableForEach(obj, function(i, v)
            
			if (type(i) == 'userdata') then
				LogDebug(tab .. "[" .. tostring(i) ..  "] " .. tostring(v));			
				return;
			end;
--			if (type(i) == 'number') then
--				LogDebug(tab .. "[" .. i ..  "] " .. tostring(v));			
--				return;
--			end;
			if (type(i) == 'string') or (type(i) == 'number') then
                local key = tostring(i);
				if (key == "__cname") or  (key == "__ctype") then
					return;
				end;
                if TableUtil.HasValue(ignore,key) then
                    return;
                end;
				-- skip function
				if(type(v) == 'function') then
					LogDebug(tab .. "func " .. key .. "=" .. tostring(v));
					return;
				end;
				if(type(v) == 'table') then
					if tab == targetTab then
						LogDebug(tab .. key .. " " .. tostring(v) .. " >");			
					else
                        if tableIsEmpty(v) == false then
                            LogDebug(tab .. key .. " (" .. tostring(v) .. ")");							
                            ListField(v,tab .. " ",tableHash,targetTab,ignore);
                        else
                            LogDebug(tab .. key .. " " .. tostring(v) .. " {}");							
                        end;
					end;
				else
					LogDebug(tab .. key .. "=" .. tostring(v));
				end;
				return;
			end;
			LogDebug(tab .. tostring(i) .. "=" .. tostring(v));
        end)
    else
        LogDebug(tostring(obj));
    end;
end;


function MyTostring(value,level)
  local str = ''
  if level == nil then level = 0; end;
  if level > 2 then
	return tostring(value);
  end
  if (type(value) ~= 'table') then
	if type(value) == 'userdata' then
		return UserDataToString(value);
	end;
	if type(value) == 'function' then
		return "[func]";
	end;
	if type(value) == 'boolean' then
		return tostring(value);
	end;
	if (type(value) == 'number') then
	  str = "" .. value;
    else 
		if (type(value) == 'string') then
		  --str = string.format("%q", value)
		  str = string.format("%s", value)
		else
			if(value == nil) then
				str = "(nil)";
			else
				str = "[" .. type(value) .. "] " .. tostring(value);
			end;
		end
	end;
  else
    local auxTable = {}
    --table.foreach(value, function(i, v)
	tableForEach(value, function(i, v)
      if (tonumber(i) ~= i) then
        table.insert(auxTable, i)
      else
        table.insert(auxTable, tostring(i))
      end
    end)
    table.sort(auxTable)

    str = str..'{'
    local separator = ""
    local entry = ""
    --table.foreachi (auxTable, function (i, fieldName)
	tableForEach(auxTable, function (i, fieldName)
      if ((tonumber(fieldName)) and (tonumber(fieldName) > 0)) then
        entry = MyTostring(value[tonumber(fieldName)],level + 1)
      else
        if (type(fieldName) == 'string') then
            entry = fieldName .." = ".. MyTostring(value[fieldName], level + 1)
        else
            entry = tostring(fieldName); --.." = ".. MyTostring(value[fieldName], level + 1)
        end;
      end
      str = str..separator..entry
      separator = ", "
    end)
    str = str..'}'
  end
  return str
end




function DumpMyself()
    LogDebug("SKILL_POINT=" .. (Game.Myself.data.userdata:Get(UDEnum.SKILL_POINT) or 0));
    LogDebug("BATTLEPOINT=" .. (Game.Myself.data.userdata:Get(UDEnum.BATTLEPOINT) or 0));
    LogDebug("ROLEEXP=" .. (Game.Myself.data.userdata:Get(UDEnum.ROLEEXP) or 0));
    LogDebug("JOBEXP=" .. (Game.Myself.data.userdata:Get(UDEnum.JOBEXP) or 0));
    LogDebug("KILLERNAME=" .. (Game.Myself.data.userdata:Get(UDEnum.KILLERNAME) or 0));
    LogDebug("DROPBASEEXP=" .. (Game.Myself.data.userdata:Get(UDEnum.DROPBASEEXP) or 0));
    LogDebug("NORMAL_SKILL=" .. (Game.Myself.data.userdata:Get(UDEnum.NORMAL_SKILL) or 0));
    LogDebug("PET_PARTNER=" .. (Game.Myself.data.userdata:Get(UDEnum.PET_PARTNER) or 0));
    LogDebug("NAME=" .. (Game.Myself.data.userdata:Get(UDEnum.NAME) or 0));
    LogDebug("proxyName=" .. MyselfProxy.Instance.proxyName);
    LogDebug("Level=" .. MyselfProxy.Instance:RoleLevel());
    LogDebug("Zeny=" .. MyselfProxy.Instance:GetROB());
    LogDebug("Gold=" .. MyselfProxy.Instance:GetGold());
    LogDebug("Diamond=" .. MyselfProxy.Instance:GetDiamond());
    LogDebug("Garden=" .. MyselfProxy.Instance:GetGarden());
    LogDebug("Laboratory=" .. MyselfProxy.Instance:GetLaboratory());
    LogDebug("JobLevel=" .. MyselfProxy.Instance:JobLevel());
    LogDebug("ZoneId=" .. MyselfProxy.Instance:GetZoneId());
    LogDebug("ZoneString=" .. MyselfProxy.Instance:GetZoneString());
    LogDebug("GetMyProfession=" .. MyselfProxy.Instance:GetMyProfession());
    LogDebug("GetMyProfessionType=" .. MyselfProxy.Instance:GetMyProfessionType());
    LogDebug("GetMyMapID=" .. MyselfProxy.Instance:GetMyMapID());
    LogDebug("GetMySex=" .. MyselfProxy.Instance:GetMySex());
    LogDebug("GetQuota=" .. MyselfProxy.Instance:GetQuota());
    LogDebug("GetQuotaLock=" .. MyselfProxy.Instance:GetQuotaLock());
    LogDebug("GetHasCharge=" .. MyselfProxy.Instance:GetHasCharge());
    LogDebug("GetFashionHide=" .. MyselfProxy.Instance:GetFashionHide());
    LogDebug("GetPvpCoin=" .. MyselfProxy.Instance:GetPvpCoin());
    LogDebug("GetLottery=" .. MyselfProxy.Instance:GetLottery());
    LogDebug("GetGuildHonor=" .. MyselfProxy.Instance:GetGuildHonor());
    LogDebug("GetServantFavorability=" .. MyselfProxy.Instance:GetServantFavorability());
    LogDebug("GetBoothScore=" .. MyselfProxy.Instance:GetBoothScore());
end;

function DumpQuest()
    local currentMapID = Game.MapManager:GetMapID(); 
    local questlst = QuestProxy.Instance:getQuestListByMapAndSymbol(currentMapID);
    for k, q in pairs(questlst) do
        LogDebug(tostring(k));
        local params = q.staticData and q.staticData.Params;
        local symbolType = QuestSymbolCheck.GetQuestSymbolByQuest(q);
        LogDebug(tostring(params) .. ' ' .. MyTostring(params.ShowSymbol) .. ' ' .. tostring(symbolType));
        local uniqueid, npcid = params.uniqueid, params.npc;
        npcid = type(npcid) == "table" and npcid[1] or npcid;
        local npcPoint,combineId;
        if( uniqueid )then
            npcPoint = Game.MapManager:FindNPCPoint( uniqueid );
        elseif(npcid)then
            --npcPoint = self:GetMapNpcPointByNpcId( npcid );
            uniqueid = npcPoint and npcPoint.uniqueID or 0;
        else
            combineId = q.questDataStepType..q.id;
        end
        LogDebug("uniqueid=" .. tostring(uniqueid) .. ' npcid=' .. MyTostring(npcid) .. ' npcPoint=' .. MyTostring(npcPoint));
    end
end;

function DumpSelf(self)
    LogDebug("g_MainView " .. MyTostring(g_MainView));
    local go = self.gameObject;
    local childCount = go.transform.childCount;
    LogDebug("childCount " .. childCount);
    local trans = go.transform;
    for i=0, trans.childCount-1 do
        local transChild = trans:GetChild(i);
        --LogDebug("#"..i.. " " .. MyTostring(transChild));
        --LogDebug("#"..i.. " " ..  MyTostring(transChild.gameObject));
        LogDebug(GameObjectToString(transChild.gameObject));
        --transChild.gameObject.layer = layer;
        --UIUtil.ChangeLayer(transChild.gameObject, layer);
    end
    LogDebug("mapLabel " .. MyTostring(self.mapLabel));
    local activeScene = SceneManagement.SceneManager.GetActiveScene();
    LogDebug("activeScene " .. MyTostring(activeScene));
end;

function MapInfoToString(mapInfo)
	--[[
	02/09/19 08:36:42 {AdventureValue = -1, CallZh = Payon, Camera = 1, Desc = A hill city where the previous king was said to have lived in seclusion, EnterCond = {}, IndexRange = {}, LvRange = {}, MapAr
ea = 18, MapScale = 80, MapTips = 1, MapUi = 7, Mode = 1, Money = 400, MoneyType = 1, MonsterRatio = {}, NameEn = payon, NameZh = Payon, Position = {6, 11}, Range = 4004, SceneAnimation = 1, ShowInLis
t = 1, Type = 6, id = 18}
	]]
	local ret = "MAP" .. PropToString(mapInfo," ",{"id","NameZh","Type","Range"},{"SceneAnimation","Desc","CallZh","NameEn","AdventureValue","ShowInList","LvRange","Camera"});
	return ret;
end;

function QuestToString(wq)
    local listType = "";
    local wd = wq.wantedData;
    if wd and wd.questListType then
        if wq.questListType == SceneQuest_pb.EQUESTLIST_ACCEPT then listType = "EQUESTLIST_ACCEPT" end;
        if wq.questListType == SceneQuest_pb.EQUESTLIST_CANACCEPT then listType = "EQUESTLIST_CANACCEPT" end;
        if wq.questListType == SceneQuest_pb.EQUESTLIST_COMPLETE then listType = "EQUESTLIST_COMPLETE" end;
        if wq.questListType == SceneQuest_pb.EQUESTLIST_SUBMIT then listType = "EQUESTLIST_SUBMIT" end;
        local info = QuestDataUtil.parseWantedQuestTranceInfo(wq,wd);
        local ret = "id=" .. wd.id .. " " .. wq.questDataStepType .. " Target=[" .. tostring(wd.Target) .. "] MapId=" .. wd.MapId .. " NpcId=" .. tostring(wd.NpcId) .. " questListType=" .. listType .. " Content=" .. tostring(wd.Content) .. " info=[" .. tostring(info) .. "]";
        local steps = wq.steps or {};	
        ret = ret .. " step=" .. (wq.step or 0) .. "/" .. #steps;
        return ret;
    else
        --local info = QuestDataUtil.getTranceInfoTable(wq,wq.params);
        --local ret = "id=" .. wq.id .. " questDataStepType=[" .. wq.questDataStepType .. "] acceptlv=" .. wq.acceptlv .. " scope=" .. wq.scope;
		local ret = PropToString(wq,"",{"id","type","map","step"}) .. PropToString(wq.params,"params.");
        return ret;    
    end;    
end;

function CreatureToString(creature)
    if creature == nil then return "CreatureToString NULL" end;

    local creatureType = creature:GetCreatureType();
    if creatureType == Creature_Type.Player then
        return PlayerToString(creature);
    end;
    if creatureType == Creature_Type.Pet then
        return "PET ID=" .. creature.data.id;
    end;
    if creatureType == Creature_Type.Npc then
        if creature.data:IsNpc() then
            return NPCToString(creature);
        else
            return MonsterToString(creature);
        end;
    end;
    if creatureType == Creature_Type.Me then
        return MeToString(creature);
    end;
end;

function MeToString(m)
    local props = m.data.props;
    local stat = ROM_GetMonStatus(m);
    local mp = MyselfProxy.Instance;
    local pos = m:GetPosition();
    return "ME ID=" .. m.data.id .. ' HP=' .. stat.hp .. "/" .. stat.maxhp .. " SP=" .. stat.sp .. "/" .. stat.maxSp .. " lvl=" ..  mp:RoleLevel() .. " Zeny=" .. mp.GetROB() .. " pos=" .. tostring(pos);   
end;

function NPCToString(m)
    local stat = ROM_GetMonStatus(m);
    local props = m.data.props;
    local ret =  "ID=" .. m.data.id .. " TypeID=" .. m.data.staticData.id .. " name=" ..  m.data.staticData.NameZh .. " Type=" .. m.data.staticData.Type .. ' HP=' .. stat.hp .. " Race=" .. m.data.staticData.Race .. " Nature=" .. m.data.staticData.Nature .. " Shape=" .. m.data.staticData.Shape;	
    --ret = ret .. " lvl=" .. m.data.staticData.Level .. " BExp=" .. m.data.staticData.BaseExp .. " JExp=" .. m.data.staticData.JobExp .. " IsStar=" .. (m.data.staticData.IsStar or 0) .. " IsHatred=" .. tostring(m:IsHatred());
    return ret;			
end;

function PlayerToString(m)
    local stat = ROM_GetMonStatus(m);
    local props = m.data.props;
	return ROM_GetCreatureName(m) .. ' HP=' .. stat.hp;	
	--[[if TeamProxy.Instance:IsInMyTeam(m.data.id) then
		return "MY TEAM ID=" .. m.data.id .. ' PLAYER HP=' .. stat.hp;	
	else
		return "ID=" .. m.data.id .. ' PLAYER HP=' .. stat.hp;	
	end]]
    
end;

function MonsterToString(m)
    if m == nil then return "MonsterToString(null)" end;
	local stat = ROM_GetMonStatus(m);
	--if  m.data.props ~= nil then
	    local props = m.data.props;
		if m.data.staticData ~= nil then
			if  m.data.staticData.Type ~= "Monster" then
				return NPCToString(m);
				--return "ID=" .. m.data.id .. " TypeID=" .. m.data.staticData.id .. " name=" ..  m.data.staticData.NameZh .. " Type=" .. m.data.staticData.Type .. ' HP=' .. stat.hp .. " Race=" .. m.data.staticData.Race .. " Nature=" .. m.data.staticData.Nature .. " Shape=" .. m.data.staticData.Shape .. " " .. m:GetCreatureType() ;	
			else
                --return NPCToString(m);
				local ret =  "ID=" .. m.data.id .. " TypeID=" .. m.data.staticData.id .. " name=" ..  m.data.staticData.NameZh .. " Type=" .. m.data.staticData.Type .. ' HP=' .. stat.hp .. " Race=" .. m.data.staticData.Race .. " Nature=" .. m.data.staticData.Nature .. " Shape=" .. m.data.staticData.Shape;	
				ret = ret .. " lvl=" .. m.data.staticData.Level .. " BExp=" .. m.data.staticData.BaseExp .. " JExp=" .. m.data.staticData.JobExp .. " IsStar=" .. (m.data.staticData.IsStar or 0) .. " IsHatred=" .. tostring(m:IsHatred()) .. " click=" .. tostring(m:GetClickable());
				return ret;
			end;			
		else
            return PlayerToString(m);
		end;
end;

function SkillToString(s)
    local skillInfo = Game.LogicManager_Skill:GetSkillInfo(s.id);
    --return "ID=" .. skillInfo.staticData.id .. " name=[" .. skillInfo.staticData.NameZh .. "] type=" .. skillInfo.staticData.SkillType;
    return SkillInfoToString(skillInfo);
end;

function SkillToStringByID(id)
    local skillInfo = Game.LogicManager_Skill:GetSkillInfo(id);
    return SkillInfoToString(skillInfo);
end;

function SkillInfoToString(skillInfo)
    if skillInfo then
        return "ID=" .. skillInfo.staticData.id .. " name=[" .. skillInfo.staticData.NameZh .. "] type=" .. skillInfo.staticData.SkillType .. " CD=" .. (skillInfo.staticData.CD or 0);
    else
        return "SkillInfoToString(nil)";
    end;
end;




function DumpLearnSkill()
    local lstSkill = SkillProxy.Instance.learnedSkills;
    tableForEach(lstSkill, function(i, v)
        local skills = v;
        --local skillInfo = Game.LogicManager_Skill:GetSkillInfo(skill:GetID());
        --ListField(skill.id);
        tableForEach(skills, function(i, v)
            local skill = v;
            LogDebug(SkillToString(skill));
            --LogDebug(MyTostring(skill.id));
        end);
    end);    
end;

function DumpMonsters()
    local lst = NSceneNpcProxy.Instance.npcMap;
    tableForEach(lst, function(i, v)
        local mons = v;
        tableForEach(mons, function(i, v)
            local mon = v;
            LogDebug(MonsterToString(mon));
        end);
    end);    
end;

myButton = myButton or {};
function CreateMyButton(text,pos,onclick)
    if g_mainView == nil then 
        LogDebug("CreateMyButton: g_mainView not found");
        return nil 
    end;
    local templateButton = g_mainView:FindGO("RewardButton");
    if templateButton == nil then 
        LogDebug("CreateMyButton: RewardButton not found");
        return nil 
    end;
    local uiCamera = NGUIUtil:GetCameraByLayername("UI");	
    if uiCamera == nil then 
        LogDebug("CreateMyButton: uiCamera not found");
        return nil 
    end;
    local ret = myButton[text];
    if ret == nil then
        ret = GameObject.Instantiate(templateButton);
        myButton[text] = ret;
        ret:SetActive(false);
        UIUtil.FindGO("Sprite",ret):SetActive(false);
        local label = UIUtil.FindGO("Label",ret);
        --LogDebug(MyTostring(label.transform.localPosition));
        label.transform.localPosition = Vector3(0,0,0);
        label:GetComponent(UILabel).text = text;
        label:GetComponent(UILabel).effectColor = ColorUtil.NGUILabelBlueBlack;
        label:GetComponent(UILabel).effectStyle = UILabel.Effect.None;
        --ret.transform:SetParent(templateButton.transform.parent);
        if pos~= nil then
            ret.transform.position = uiCamera:ViewportToWorldPoint(pos);
        end;
    end;
    return ret;
end;


if class ~= nil then
    if MyBot == nil then
        MyBot = class("MyBot");
    end;
    MyBot.version = "1.0";
    function MyBot:ctor()
		LogDebug("MyBot:ctor()");
	end
    function MyBot:OnHPChange(evt)
        LogDebug("MyBot.OnHPChange " .. MyTostring(evt));
    end;
    function MyBot:OnSPChange(evt)
        LogDebug("MyBot.OnSPChange " .. MyTostring(evt));
    end;
    function MyBot:OnMyselfPlaceTo(evt)
        LogDebug("MyBot.OnMyselfPlaceTo data=" .. MyTostring(evt.data));
    end;
    function MyBot:OnMyselfLeaveScene(evt)
        LogDebug("MyBot.OnMyselfLeaveScene " .. MyTostring(evt));
    end;
    function MyBot:UsedSkillCheck(evt)
        LogDebug("MyBot.UsedSkillCheck " .. MyTostring(evt));
    end;
    function MyBot:PartnerUpdateCheck(evt)
        LogDebug("MyBot.PartnerUpdateCheck " .. MyTostring(evt));
    end;
    function MyBot:BuffUpdateCheck(evt)
        LogDebug("MyBot.BuffUpdateCheck " .. MyTostring(evt));
    end;
    function MyBot:PropChangeCheck(evt)
        LogDebug("MyBot.PropChangeCheck " .. MyTostring(evt));
    end;
    function MyBot:MeSceneUIClear(evt)
        LogDebug("MyBot.MeSceneUIClear " .. MyTostring(evt));
    end;
    function MyBot:handleMissionCommand(evt)
        LogDebug("MyBot.handleMissionCommand " .. MyTostring(evt));
    end;
    function MyBot:HandlePetHpChange(evt)
        LogDebug("MyBot.HandlePetHpChange " .. MyTostring(evt));
    end;
    function MyBot:OnSelectTargetChange(evt)
        LogDebug("MyBot.OnSelectTargetChange " .. MyTostring(evt));
    end;
    function MyBot:MyDataChange(evt)
        LogDebug("MyBot.MyDataChange " .. MyTostring(evt));
    end;
    function MyBot:LevelUp(evt)
        LogDebug("MyBot.LevelUp " .. MyTostring(evt));
    end;
    function MyBot:JobExpChange(evt)
        LogDebug("MyBot.JobExpChange " .. MyTostring(evt));
    end;
    function MyBot:BaseExpChange(evt)
        LogDebug("MyBot.BaseExpChange " .. MyTostring(evt));
    end;
    function MyBot:ZenyChange(evt)
        LogDebug("MyBot.ZenyChange " .. MyTostring(evt));
    end;
    function MyBot:HitTargets(evt)
        LogDebug("MyBot.HitTargets " .. MyTostring(evt));
    end;
    function MyBot:BeHited(evt)
        LogDebug("MyBot.BeHited " .. MyTostring(evt));
    end;
    function MyBot:BeHited(evt)
        LogDebug("MyBot.BeHited " .. MyTostring(evt));
    end;
    function MyBot:PlaceTo2(evt)
        LogDebug("MyBot.PlaceTo2 " .. MyTostring(evt));
    end;
    
    function MyBot:GetEvents()
        local ret = {
            {event=MyselfEvent.HpChange,"HpChange"},
            {event=MyselfEvent.SpChange,"SpChange"},
            {event=MyselfEvent.PlaceTo,"PlaceTo"},
        };
        return ret;
    end;
    function MyBot:UnHookEvents()
        tableForEach(EventManager.Me().handlers,function(index,tab)
            tableForEach(tab,function(_,o)
                while (TableUtil.Remove(o.owners,self) ~= 0)  do
                end;
            end);
        end);
        LogDebug("MyBot.UnHookEvents");
    end;
    function MyBot:HookEvents()
        if EventManager ~= nil then
            self:UnHookEvents();
            EventManager.Me():AddEventListener(MyselfEvent.HpChange,self.OnHPChange,self);
            EventManager.Me():AddEventListener(MyselfEvent.SpChange,self.OnSPChange,self);
            EventManager.Me():AddEventListener(MyselfEvent.PlaceTo, self.OnMyselfPlaceTo, self);
            EventManager.Me():AddEventListener(MyselfEvent.LeaveScene, self.OnMyselfLeaveScene, self);
            EventManager.Me():AddEventListener(MyselfEvent.SelectTargetChange, self.OnSelectTargetChange, self);
            EventManager.Me():AddEventListener(MyselfEvent.UsedSkill,self.UsedSkillCheck,self);
            EventManager.Me():AddEventListener(MyselfEvent.PartnerChange,self.PartnerUpdateCheck,self);
            EventManager.Me():AddEventListener(MyselfEvent.BuffChange,self.BuffUpdateCheck,self);
            EventManager.Me():AddEventListener(MyselfEvent.MyPropChange,self.PropChangeCheck,self);
            EventManager.Me():AddEventListener(MyselfEvent.MyDataChange,self.MyDataChange,self);
            EventManager.Me():AddEventListener(MyselfEvent.MyAttrChange,self.MyAttrChange,self);
            
            EventManager.Me():AddEventListener(MyselfEvent.LevelUp,self.LevelUp,self);
            EventManager.Me():AddEventListener(MyselfEvent.JobExpChange,self.JobExpChange,self);
            EventManager.Me():AddEventListener(MyselfEvent.BaseExpChange,self.BaseExpChange,self);
            EventManager.Me():AddEventListener(MyselfEvent.ZenyChange,self.ZenyChange,self);
            EventManager.Me():AddEventListener(MyselfEvent.HitTargets,self.HitTargets,self);
            EventManager.Me():AddEventListener(MyselfEvent.BeHited,self.BeHited,self);
            
            EventManager.Me():AddEventListener(MyselfEvent.MyselfSceneUIClear,self.MeSceneUIClear,self);
            EventManager.Me():AddEventListener(MyselfEvent.MissionCommandChanged,self.handleMissionCommand,self);
            EventManager.Me():AddEventListener(MyselfEvent.Pet_HpChange, self.HandlePetHpChange, self);
            LogDebug("MyBot.HookEvent");
        end;
    end;
    if myBot == nil or myBot.version ~= MyBot.version then
        if myBot ~= nil then
            myBot:UnHookEvents();
        end;
        myBot = MyBot.new();
        LogDebug("MyBot.new()");
    end;
    --myBot:HookEvents();
end;

--[[
MyselfEvent= {
	Inited = "MyselfEvent_Inited",
	PlaceTo = "MyselfEvent_PlaceTo",
	LeaveScene = "MyselfEvent_LeaveScene",
	SelectTargetChange = "MyselfEvent_SelectTargetChange",
	SelectTargetClassChange = "MyselfEvent_SelectTargetClassChange",
	--属性值发生变化，攻击力啦，生命值啦
	MyPropChange = "MyselfEvent_MyPropChange",
	--数据发生变化，等级，经验
	MyDataChange = "MyselfEvent_MyDataChange",
	--属性值、数据变化的通知
	MyAttrChange = "MyselfEvent_MyAttrChange",
	MyProfessionChange = "MyselfEvent_MyProfessionChange",
	ScaleChange = "MyselfEvent_ScaleChange",
	AskUseSkill = "MyselfEvent_AskUseSkill",
	CancelAskUseSkill = "MyselfEvent_CancelAskUseSkill",
	LevelUp = "MyselfEvent_LevelUp",
	JobExpChange = "MyselfEvent_JobExpChange",
	BaseExpChange = "MyselfEvent_BaseExpChange",
	ZenyChange = "MyselfEvent_ZenyChange",
	ContributeChange = "MyselfEvent_ContributeChange",
	BattlePointChange = "MyselfEvent_BattlePointChange",
	MusicInfoChange = "MyselfEvent_MusicInfoChange",
	ResetHpShortCut = "MyselfEvent_ResetHpShortCut",
	MyRoleChange = "MyselfEvent_MyRoleChange",
	ChangeDress = "MyselfEvent_ChangeDress",
	--击npc怪物通知
	HitTargets = "MyselfEvent_HitTargets",
	BeHited = "MyselfEvent_BeHited",
	-- 访问目标通知
	AccessTarget = "MyselfEvent_AccessTarget",
	AccessSealNpc = "MyselfEvent_AccessSealNpc",
	-- 玩家手动控制通知
	ManualControlled = "MyselfEvent_ManualControlled",
	SyncBuffs = "MyselfEvent_SyncBuffs",
	AddBuffs = "MyselfEvent_AddBuffs",
	RemoveBuffs = "MyselfEvent_RemoveBuffs",
	DeathBegin = "MyselfEvent_DeathBegin",
	DeathEnd = "MyselfEvent_DeathEnd",
	ReliveStatus = "MyselfEvent_ReliveStatus",
	DeathStatus = "MyselfEvent_DeathStatus",
	LeaveCarrier = "MyselfEvent_LeaveCarrier",
	SkillPointChange = "MyselfEvent_SkillPointChange",
	SpChange = "MyselfEvent_SpChange",
	HpChange = "MyselfEvent_HpChange",
	EnableUseSkillStateChange = "MyselfEvent_EnableUseSkillStateChange",
	UsedSkill = "MyselfEvent_UsedSkill",
	ChangeJobReady = "MyselfEvent_ChangeJobReady",
	ChangeJobBegin = "MyselfEvent_ChangeJobBegin",
	ChangeJobEnd = "MyselfEvent_ChangeJobEnd",
	PartnerChange = "MyselfEvent_PartnerChange",
	MyselfSceneUIClear = "MyselfSceneUIClear",
	TransformChange = "MyselfEvent_TransformChange",
	UpdateAttrEffect = "MyselfEvent_UpdateAttrEffect",
	AddWeakDialog = "MyselfEvent_AddWeakDialog",

	--skill
	SkillGuideBegin = "MyselfEvent_SkillGuideBegin",
	SkillGuideEnd = "MyselfEvent_SkillGuideEnd",

	--new
	TargetPositionChange = "MyselfEvent_TargetPositionChange",

	ZoneIdChange = "MyselfEvent_ZoneIdChange",

	MissionCommandChanged = "MyselfEvent_MissionCommandChanged",
	SceneGoToUserCmdHanded = "MyselfEvent_SceneGoToUserCmd",
	BuffChange = "MyselfEvent_BuffChange",

	CookerLvChange = "MyselfEvent_CookerLvChange",
	TasterLvChange = "MyselfEvent_TasterLvChange",
	Pet_HpChange = "MyselfEvent_Pet_HpChange",
	ServantFavorChange = "MyselfEvent_ServantFavorChange",

	TwinActionStart = "MyselfEvent_TwinActionStart",
}
]]


if class ~= nil then
	AutoAI_Rom = class("AutoAI_Rom")

	function AutoAI_Rom:ctor()
        self.enable = false;
		self.UpdateInterval = 0.0;
		self.nextUpdateTime = 0
		LogDebug("AutoAI_Rom:ctor()");
	end
    
    function AutoAI_Rom:Enable(value)
        self.enable = value;
    end;
    
    function AutoAI_Rom:IsEnable()
        return self.enable;
    end;
    

	function AutoAI_Rom:Clear(idleElapsed, time, deltaTime, creature)
		LogDebug("AutoAI_Rom:Clear()");
		self.nextUpdateTime = 0
	end

	function AutoAI_Rom:Prepare(idleElapsed, time, deltaTime, creature)
		--LogDebug("AutoAI_Rom:Prepare()");
		self.waitForTime = false;
        if self.enable then
			if time < self.nextUpdateTime then
				self.waitForTime = true;
				return true
			end
			--LogDebug("AutoAI_Rom:Prepare() " .. (time - self.nextUpdateTime) .. " " .. self.UpdateInterval);
			self.nextUpdateTime = time + self.UpdateInterval		
            for i= 1, #myAIRules do
                local rule = myAIRules[i];
                --LogDebug("" .. i .. " " .. MyTostring(rule));
				
                if rule.func ~= nil then
					local success, delay = rule.func(rule);
					if success then
						--self.nextUpdateTime = time + 1.0;
						if delay then
							self.nextUpdateTime = self.nextUpdateTime + delay;
						end;
						return true;
					end;
                end;
            end;
			local in2 = CDProxy.Instance:IsInCD(SceneUser2_pb.CD_TYPE_SKILL,CDProxy.CommunalSkillCDSortID);                
            --if Game.Myself.autoPos ~= nil and ROM_FindCurrentMonster() == nil then
			if Game.Myself.autoPos ~= nil and in2 == false and walkBack then
				if ROM_IsMeNear(Game.Myself.autoMapID,Game.Myself.autoPos,2) then
				else
					ROM_CommandGOTO(Game.Myself.autoMapID,Game.Myself.autoPos);
					return true;
				end;
			else	
				--LogDebug("Game.Myself.autoPos not set");
            end;

			if in2 then
				LogDebug("AutoAI_Rom:Prepare() InCD");
			else
				LogDebug("AutoAI_Rom:Prepare() nothing to do!! " .. tostring(walkBack));
				self.nextUpdateTime = self.nextUpdateTime + 1.0;
			end;
            -- nothing to do
            --self.nextUpdateTime = time + 1.0;
        end;
        return false
	end

	function AutoAI_Rom:Start(idleElapsed, time, deltaTime, creature)
	    --LogDebug("AutoAI_Rom:Start()");
	end

	function AutoAI_Rom:End(idleElapsed, time, deltaTime, creature)
        self.target = nil;
	    --LogDebug("AutoAI_Rom:End()");
	end

	function AutoAI_Rom:Update(idleElapsed, time, deltaTime, creature)
		if time < self.nextUpdateTime then
			return true
		end
		--LogDebug("AutoAI_Rom:Update() " .. (time - self.nextUpdateTime));
		self.nextUpdateTime = time + self.UpdateInterval		
		return false
	end
    
end;


function ROM_GetMonStatus(mon)
    local props = mon.data.props;
    local hp = props.Hp:GetValue();
    local maxhp = props.MaxHp:GetValue();
    local frachp = hp/maxhp;
    local sp = props.Sp:GetValue();
    local maxSp = props.MaxSp:GetValue();
    local fracsp = sp/maxSp;
    return {
        hp=hp,
        maxhp=maxhp,
        frachp=frachp,
        sp=sp,
        maxSp=maxSp,
        fracsp=fracsp,
    };
end;

function ROM_UseSkill(skillID,mon,numHit)
    numHit = numHit or 1;
    --local phaseData0 = SkillPhaseData.Create(skillID)
    --phaseData0:SetSkillPhase(0);
	local phaseData = SkillPhaseData.Create(skillID)
    phaseData:SetSkillPhase(1)
    --local mons = ROM_GetAllMonster();   
    --local mon = ROM_GetNearestMonFromList(mons);
    local rand = Game.Myself.data.randomFunc.index;
    if mon then    
        local damageType, damage, shareDamageInfos = SkillLogic_Base.CalcDamage(
            skillID, 
            Game.Myself, 
            mon, 
            1, 
        1)
    
        for h = 1,numHit do
        
            phaseData:AddTarget(
                mon.data.id, 
                damageType, 
                damage,
                shareDamageInfos)
        end;
        --[[phaseData0:AddTarget(
                mon.data.id, 
                0, 
                0,
                shareDamageInfos)]]
        ServicePlayerProxy.Instance:CallMapObjectData(mon.data.id);
        --LogDebug(MonsterToString(mon));
        Game.Myself:Client_UseSkillHandler(rand,phaseData)
    end;
    phaseData:Destroy()
    phaseData = nil
end;

function ROM_GetRandom(array, index)

    -- 随机数最大个数为20, 每个数包含5个随机数, 共可表示100个随机数
    local MAX_RANDOM_INDEX = 100
    --return 20,50
    local group = math.ceil(index / 5)              -- ex: 8 -> 2
    local key = index - math.floor(index / 5) * 5        -- ex: 8 -> 3, 取第二个数据的第3随机数,(1234567890->56)
    key = key ~= 0 and key or 5

    LogDebug("group="..group);
    if array[group]==nil or index > MAX_RANDOM_INDEX then
      return 0, index
    end

    local groupValue = array[group]
    local value = math.floor(groupValue/math.pow(100, 5-key)) % 100

    local newIndex = index == MAX_RANDOM_INDEX and 1 or index + 1

    return value, newIndex
end

function ROM_GetMyStatus()
	return ROM_GetMonStatus(Game.Myself);
end;

function ROM_GetSkillNeeded(skillID)
    local skillInfo = Game.LogicManager_Skill:GetSkillInfo(skillID);
    local spCost = skillInfo:GetSP(Game.Myself);
    local hpCost = skillInfo:GetHP(Game.Myself);
    local delayCD = skillInfo:GetDelayCD(Game.Myself);
    --local CD = skillInfo:GetCD(Game.Myself);
    local CD = skillInfo:GetLogicRealCD(Game.Myself);
    return {
        hp=hpCost or 0,sp=spCost or 0,delayCD=delayCD or 0,CD=CD or 0
    };
end;

function ROM_FindNearestMonsterEx(monlist)
    monlist = monlist or {};
    local filterFunc = function(mon)
        return #monlist == 0 or TableUtil.HasValue(monlist,mon.data.staticData.id)
    end;
    local mons = ROM_GetAllMonster(filterFunc);
    return ROM_GetNearestMonFromList(mons);
end;

function ROM_FindNearestMonsterEx2(tab)
    local monlist = tab.monlist or myMonsterList;
    local ignoreList = tab.ignore or {};
    local filterFunc = function(mon)
        if #monlist == 0 or TableUtil.HasValue(monlist,mon.data.staticData.id) then
            if TableUtil.HasValue(ignoreList,mon.data.staticData.id) then
                return false;
            end;
			-- check avoid monster
			local avoidDist = ROM_NearestAvoidMonDist(mon:GetPosition())
			if avoidDist < 16 then
				return false;
			end;
			
            if tab.filter ~= nil then
                return tab.filter(mon);
                --LogDebug(MonsterToString(mon));
            end;
            
            local monStatus = ROM_GetMonStatus(mon);
            if monStatus.hp <= 0 then
                return false;
            end;
            return true;
        end;
        return false;
    end;
    local mons = ROM_GetAllMonster(filterFunc);
	if tab.selectFunc ~= nil then
		return tab.selectFunc(mons);
	else
		return ROM_GetNearestMonFromList(mons);
	end;
end;

function ROM_GetBestScoreMonFromListWalknFight(mons)
    local minScore = 100000;
    local retNpc = nil;
    local myPos = Game.Myself:GetPosition();
    local maxDist = 0;
    local targetPos = MissionCommandWalknFight.pos;
    LogDebug("ROM_GetBestScoreMonFromListWalknFight " .. tostring(targetPos));
    LogDebug("ROM_GetBestScoreMonFromListWalknFight " .. tostring(myPos));
    local canArrive3,path3 = NavMeshUtils.CanArrived(targetPos, myPos, WorldTeleport.DESTINATION_VALID_RANGE, true, nil);            
    local myCost = NavMeshUtils.GetPathDistance(path3);
    LogDebug("myCost= " .. myCost);
    tableForEach(mons,function(i,v)
        local npc = v;
		local pos = npc:GetPosition();
        --local distance = LuaVector3.Distance(myPos,pos);
        local canArrive,path = NavMeshUtils.CanArrived(myPos, pos, WorldTeleport.DESTINATION_VALID_RANGE, true, nil);        
        local canArrive2,path2 = NavMeshUtils.CanArrived(targetPos, pos, WorldTeleport.DESTINATION_VALID_RANGE, true, nil);        

        if canArrive then
            local cost = NavMeshUtils.GetPathDistance(path);
            local cost2 = NavMeshUtils.GetPathDistance(path2);
            if cost < 30 and cost2 < myCost then
                --local players = NSceneUserProxy.Instance:FindNearUsers(pos,15,nil);
				local players = ROM_GetNearPlayers(range,true,pos);
                local score = cost + (#players * 10);
                if score < minScore then
                    retNpc = npc;
                    minScore = score;
                    maxDist = cost;
                    LogDebug("cost2= " .. cost2);
                end;
            end;
        end;
    end);
	if retNpc ~= nil then
		LogDebug("ROM_GetBestScoreMonFromListToMissionPos: maxDist=" .. maxDist);
	end;
    return retNpc;
end;


function ROM_GetBestScoreMonFromList(mons)
    local minScore = 100000;
    local retNpc = nil;
    local myPos = Game.Myself:GetPosition();
    local maxDist = 0;
    tableForEach(mons,function(i,v)
        local npc = v;
		local pos = npc:GetPosition();
        --local distance = LuaVector3.Distance(myPos,pos);
        
        local canArrive,path = NavMeshUtils.CanArrived(myPos, pos, WorldTeleport.DESTINATION_VALID_RANGE, true, nil);        
        if canArrive then
            local cost = NavMeshUtils.GetPathDistance(path);
            if cost < 30 then
                --local players = NSceneUserProxy.Instance:FindNearUsers(pos,15,nil);
				local players = ROM_GetNearPlayers(range,true,pos);
                local score = cost + (#players * 10);
                if score < minScore then
                    retNpc = npc;
                    minScore = score;
                    maxDist = cost;
                end;
            end;
        end;
    end);
	if retNpc ~= nil then
		LogDebug("ROM_GetBestScoreMonFromList: maxDist=" .. maxDist);
	end;
    return retNpc;
end;

function ROM_NoPlayerAround(mon,tab)
    local players =  ROM_GetNearPlayers(15,true);
	return #players == 0
end;

function ROM_TargetInRange(mon,tab)
	local range = tab.range or 4
	local dist = ROM_DistanceToCreature(mon);
	return dist <= range
end;

function ROM_GetNearestMonFromList(mons,exclude)
	exclude = exclude or {};
    local minDist = 100000;
    local retNpc = nil;
    local myPos = Game.Myself:GetPosition();
    --m.data.staticData.id 
    tableForEach(mons,function(i,v)
        local npc = v;
        local distance = LuaVector3.Distance(myPos, npc:GetPosition());
        --LogDebug("ID=" .. v .. " dist=" .. tostring(distance));
		if TableUtil.HasValue(exclude,npc.data.id) then
		else
			if distance < minDist then
				retNpc = npc;
				minDist = distance;
			end;
		end;
    end);
    if retNpc ~= nil then
        --LogDebug("ROM_GetNearestMonFromList: found " .. MonsterToString(retNpc) .. " " .. minDist);
    end;
    return retNpc;
end;

function ROM_GetAllNPC(filterFunc)
    filterFunc = filterFunc or function(mon) return true; end
    local ret = {};
    local lst = NSceneNpcProxy.Instance.npcMap;
    tableForEach(lst, function(i, v)
        local mons = v;
        tableForEach(mons, function(i, v)
            local mon = v;
			if ROM_IsMonster(mon) == false then
            --if mon.data.staticData.Type ~= "Monster" then
                if filterFunc(mon) then
                    table.insert(ret, mon);
                end;
            end;
        end);
    end);    
    return ret;
end;

function ROM_GetAllMonster(filterFunc)
    filterFunc = filterFunc or function(mon) return true; end
    local ret = {};
    local lst = NSceneNpcProxy.Instance.npcMap;
    tableForEach(lst, function(i, v)
        local mons = v;
        tableForEach(mons, function(i, v)
            local mon = v;
			local stat = ROM_GetMonStatus(mon);
            if ROM_IsMonster(mon) and stat.hp > 0 then
                if filterFunc(mon) then
                    table.insert(ret, mon);
                end;
            end;
        end);
    end);    
    return ret;
end;
--[[
function ROM_GetAllMonsterFromNSceneNpcProxy()
    filterFunc = filterFunc or function(mon) return true; end
    local ret = {};
    local lst = NSceneNpcProxy.Instance.npcMap;
    tableForEach(lst, function(i, v)
        local mons = v;
        tableForEach(mons, function(i, v)
            local mon = v;
            if filterFunc(mon) then
                table.insert(ret, mon);
            end;
        end);
    end);    
    return ret;
end;]]

function ROM_GetLearnSkill(filter)
    filter = filter or {};
    local ret = {};
    local lstSkill = SkillProxy.Instance.learnedSkills;
    tableForEach(lstSkill, function(i, v)
        local skills = v;
        tableForEach(skills, function(i, v)
            local skill = v;
            local skillInfo = Game.LogicManager_Skill:GetSkillInfo(skill.id);
            if #filter == 0 or TableUtil.HasValue(filter,skillInfo.staticData.SkillType) then
            --if skillInfo.staticData.SkillType == "Attack" then  -- "Heal"
                table.insert(ret, skill);
            end;
            --LogDebug(SkillToString(skill));
        end);
    end);    
    return ret;
end;

function ROM_GetActiveSkill()
    return ROM_GetLearnSkill({"Attack","Heal","Buff","FakeDead","Summon"});
end;

function ROM_GetMySkillInfoByName(name)
    local skills = ROM_GetActiveSkill();
    for i=1,#skills do
        local skill = skills[i];
        local skillInfo = Game.LogicManager_Skill:GetSkillInfo(skill.id);
        local skillName = skillInfo.staticData.NameZh;
        --LogDebug(skillName .. " vs " .. name);
        if string.match(skillName, name) then	
            return skillInfo;
        end;
    end;
    return nil;
end;

function ROM_IsStaticMonster(mon)
    return (mon.data.staticData.id >= 40000 and mon.data.staticData.id < 50000) 
end;

function ROM_IsEliteMonster(mon)
    --LogDebug("ROM_IsEliteMonster " .. tostring(mon.data.staticData.IsStar));
    return (mon.data.staticData.IsStar == 1) 
end;


function ROM_FindStaticMonster(tab)
    local filterFunc = function(mon)
		if mon.data.staticData.id == 40015 then 
			return false;
		end;
        return ROM_IsStaticMonster(mon) or ROM_IsEliteMonster(mon); 
    end;
    return ROM_FindMonByFilter(filterFunc,"ROM_FindStaticMonster");
end;

function ROM_FindMiniBoss(tab)
    local filterFunc = function(mon)
		local stat = ROM_GetMonStatus(mon);
		--LogDebug("ROM_FindMiniBoss " ..  MonsterToString(mon));
        return mon.data.staticData.Type == "MINI" and stat.hp > 0;
    end;
    return ROM_FindMonByFilter(filterFunc,"ROM_FindMiniBoss");
end;

function ROM_FindMonByFilter(filterFunc,str)
    str = str or "ROM_FindMonByFilter";
    local mons = ROM_GetAllMonster(filterFunc);   
    local mon = ROM_GetNearestMonFromList(mons);
    if mon ~= nil then
        LogDebug(str .. ": found " .. MonsterToString(mon));
	else
		--LogDebug(str .. ": not found ");
    end;
    return mon;
end;

function ROM_FindBestMonster()
    for i= 1, #myMonsterRules do
        local rule = myMonsterRules[i];
        --LogDebug(MyTostring(rule));
        if rule.func ~= nil then
            --local param = rule.param or rule;
            local npc = rule.func(rule);
            if npc ~= nil then
                return npc;
            end;
        end;
    end;     
    return nil;
end;

function ROM_FindCurrentMonster()
	local npc = ROM_GetMonsterLockTarget() or ROM_FindBestMonster();
    return npc;
end;

function ROM_GetMonsterLockTarget()
    local mon = Game.Myself:GetLockTarget();
    if mon~= nil then
		-- possible player here which does not has staticData
		if ROM_IsMonster(mon) then
			return mon;
		end;
		--[[
		if mon.data.staticData ~= nil then
			if mon.data.staticData.Type == "Monster" then
				return mon;
			end;
		end;
		]]
    end;
    return nil;
end;

function ROM_IsMonster(mon)
	if mon.data.staticData ~= nil then
		if mon.data.staticData.Type == "Monster" or mon.data.staticData.Type == "MINI" or mon.data.staticData.Type == "MVP" then
			return true;
		end;
	end;
	return false;
end;


function ROM_GetNearestExitPoint()
	local minDist = 100000;
    local ret = nil;
    local myPos = Game.Myself:GetPosition();
	local exitPoints =  Game.MapManager:GetExitPointArray();	
	tableForEach(exitPoints, function(i, v)
		local distance = LuaVector3.Distance(myPos, v.position);
        if distance < minDist then
            ret = v;
            minDist = distance;
        end;
	end);
    return ret;	
end;

function ROM_GetNPCPointByID(npcID)
    local npcList = Game.MapManager:GetNPCPointArray();
    --LogDebug("" .. #npcList);
    for i=1,#npcList do
        local v = npcList[i];
        if v and v.ID and v.position and v.uniqueID ~= 0 and v.ID == npcID then
            local npcData = Table_Npc[v.ID];
            if npcData  then
                --LogDebug("" .. v.ID .. " " .. npcID);
                --ListField(v,"",{}," ");
                --ListField(npcData,"",{},"");
                return v
            end;
            --return v;
        end;
    end;
    return nil;
end;    

function ROM_GetNearestNPC(npcid)
	local minDist = 100000;
    local ret = nil;
    local mons = ROM_GetAllNPC();
    local myPos = Game.Myself:GetPosition();
	--local exitPoints =  Game.MapManager:GetExitPointArray();	
	tableForEach(mons, function(i, v)
		if npcid == nil or v.data.staticData.id == npcid then
			local distance = LuaVector3.Distance(myPos, v:GetPosition());
			if distance < minDist then
				ret = v;
				minDist = distance;
			end;
		end;
	end);
    return ret,minDist;	
end;

if objDelayCal == nil then
    objDelayCal = {};
end;
function ROM_DelayCall(delayTime,func,param,index)
    index = index or 1;
    TimeTickManager.Me():ClearTick(objDelayCal, index);
    TimeTickManager.Me():CreateTick(delayTime, 33, function (self, deltatime)
        LogDebug("ROM_DelayCall: " .. deltatime);
        TimeTickManager.Me():ClearTick(self, index);
        if func ~= nil then
            func(param);
        end;
    end, objDelayCal, index);
end;

function ROM_HookFunc(obj,method,newFunc)
    if obj~= nil then
        obj["_" .. method] = obj[method];
        obj[method] = newFunc;
    end;
    --NetProtocol.SendProto(data)
end;
function ROM_UnHookFunc(obj,method)
    if obj~= nil then
        obj[method] = obj["_" .. method];
    end;
end;

function ROM_CreateSendPackets()
    local fileName = "/data/local/tmp/loadbufferx/AScript.Net.Protos.Proto_Include.lua";
    local lines = lines_from(fileName);
	LogDebug(" " .. fileName .. " lines=" .. #lines);
	local ret = "";
	for i=1,#lines do
		local line = lines[i];
        local id1,id2 = string.match(line,"%[(%d+)%].*{(.*)}");
        if id1 and id2 then
            --LogDebug(id1 .. " ");
            for item in string.gmatch(id2, "[^,]*") do
                local k,v = string.match(item,"%[(%d+)%] = ([A-Za-z0-9._]*)");
                if k and v then
                    --LogDebug("" .. k .. " " .. v);
                    ret = ret .. "{" .. tostring(id1) .. "," .. tostring(k) .. ",\"" .. tostring(v) .. "\"},\n"; 
                end;
            end
            
            --LogDebug(line);
        end;
		--[[local id1,id2 = string.match(line, 'self:Listen%((%d+)%s*,%s*(%d+)');
		if id1 ~= nil then
			line2 = lines[i+1];
			local funcName = string.match(line2, 'self:(%a+)%(');
			ret = ret .. "{" .. tostring(id1) .. "," .. tostring(id2) .. ",\"" .. tostring(funcName) .. "\"},\n"; 
		end;]]
        
	end;
    return ret;
end;


function ROM_CreatePacketCommand()
	local filenames = {
		"AScript_FrameWork_Proxy_Service_auto_ServiceAchieveCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceActivityCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceActivityEventAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceAstrolabeCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceAuctionCCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceAuthorizeAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceBossCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceCarrierCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceChatCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceChatRoomAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceDojoAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceErrorUserCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceFuBenCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceGuildCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceInfiniteTowerAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceItemAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceLoginUserCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceMapAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceMatchCCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceNUserAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceOverseasTaiwanCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServicePhotoCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServicePveCardAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceQuestAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceRecordTradeAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSceneAuguryAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSceneBeingAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSceneFoodAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSceneInterlocutionAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSceneManualAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceScenePetAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSceneSealAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSceneTipAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSessionMailAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSessionShopAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSessionSocialityAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSessionTeamAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceSkillAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceTeamRaidCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceTutorAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceUserEventAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceWeatherAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_auto_ServiceWeddingCCmdAutoProxy.lua",
		"AScript_FrameWork_Proxy_Service_ServicePlayerProxy.lua",
		"AScript_FrameWork_Proxy_Service_ServiceNpcProxy.lua",
		"AScript_FrameWork_Proxy_Service_ServiceSceneProxy.lua",
	};
	local out = "";
	for i=1,#filenames do
		local fileName = filenames[i];
		local tmp = ROM_CreatePacketCommandFromFile("/data/local/tmp/loadbufferx/" .. fileName);
		if tmp ~= "" then
			out = out .. "\n" .. tmp;
		end;
	end;
	LogDebug("\n" .. out);
end;

function ROM_CreatePacketCommandFromFile(fileName)
	local lines = lines_from(fileName);
	LogDebug("ROM_CreatePacketCommandFromFile " .. fileName .. " lines=" .. #lines);
	local ret = "";
	for i=1,#lines do
		local line = lines[i];
		local id1,id2 = string.match(line, 'self:Listen%((%d+)%s*,%s*(%d+)');
		if id1 ~= nil then
			line2 = lines[i+1];
			local funcName = string.match(line2, 'self:(%a+)%(');
			ret = ret .. "{" .. tostring(id1) .. "," .. tostring(id2) .. ",\"" .. tostring(funcName) .. "\"},\n"; 
		end;
	end;
	--logDebug("\n" .. ret);
	return ret;
end;

function ROM_MapDist(map1,map2)
    local pos1 = Table_Map[map1].Position;
    local pos2 = Table_Map[map2].Position;
    if pos1 ~= _EmptyTable and pos2 ~= _EmptyTable then
        local dist = (pos1[1]-pos2[1])*(pos1[1]-pos2[1])  + (pos1[2]-pos2[2])*(pos1[2]-pos2[2]);
        return dist;
    end;
    return 100000;
end;

function ROM_GetNearestTown(mapID)
    mapID = mapID or Game.MapManager:GetMapID();
    local currentMapID = mapID; --15;
    local minDist = 10000;
    local nearestMapID = -1;
    --LogDebug("currentMapID=" .. currentMapID);
    if Table_Map[currentMapID].MapArea ~= nil then
        local currentPos = Table_Map[Table_Map[currentMapID].MapArea].Position;
        if currentPos ~= _EmptyTable then
            tableForEach(Table_Map,function(i,v)
                local map = v;
                if map.Type == 6 then
                    --LogDebug(MyTostring(map));
                    local pos = Table_Map[map.MapArea].Position;
                    if pos ~= _EmptyTable then
                        local dist = (currentPos[1]-pos[1])*(currentPos[1]-pos[1])  + (currentPos[2]-pos[2])*(currentPos[2]-pos[2]);
                        --LogDebug("Dist=" .. dist);
                        if dist < minDist then
                            minDist = dist;
                            nearestMapID = map.id;
                        end;
                    end;
                end;
            end);
        end;
        if nearestMapID > 0 then
            LogDebug("ROM_GetNearestTown: " .. Table_Map[mapID].NameEn .. " -> " .. Table_Map[nearestMapID].NameEn);
            return nearestMapID, minDist;
        else
            LogDebug("ROM_GetNearestTown: " .. Table_Map[mapID].NameEn .. " -> NOT FOUND");
            return nil;
        end;
    end;    
    return nil;
end;

function ROM_GetNearPlayers(range,checkTeam,pos)
	pos = pos or Game.Myself:GetPosition();
    range = range or 10;
	checkTeam = checkTeam or false;
    local players = NSceneUserProxy.Instance:FindNearUsers(pos,range,nil);
	if checkTeam then
		if TeamProxy.Instance ~= nil then
			local ret = {};
			for i=1,#players do
                local dist = ROM_DistanceToCreature(players[i]);            
				if TeamProxy.Instance:IsInMyTeam(players[i].data.id) == false and players[i].data:GetProperty("Hp") > 0 then
					LogDebug("ROM_GetNearPlayers " .. CreatureToString(players[i]) .. ' dist=' .. dist);									
					ret[#ret+1] = players[i];
				else	

					--LogDebug("ROM_GetNearPlayers MY TEAM " .. CreatureToString(players[i]) .. ' dist=' .. dist);											
				end;
			end;
			return ret;
		end;
	end;
	return players;    
end;

function ROM_DataGetName(id)
    local GetKey = function (attribute)
        local key = UserData.CacheEUSERkey[attribute]
        if(key==nil) then
            key = ProtoCommon_pb["EUSERDATATYPE_"..attribute]
            UserData.CacheEUSERkey[attribute] = key
        end
        return key
    end
    for i, v in pairs(UDEnum) do 
        local key = GetKey(v);
        if key == id then
            return v;
        end;
    end;
    return "DATA_" .. id;
end;

function ROM_GetCreatureName(creature)
    if creature == nil then return "Creature(NULL)" end;

    local creatureType = creature:GetCreatureType();
    if creatureType == Creature_Type.Player then
		if TeamProxy.Instance:IsInMyTeam(creature.data.id) then
			return "MY TEAM[" .. creature.data.id .. "]";
		else
			return "PLAYER[" .. creature.data.id .. "]";
		end
        
    end;
    if creatureType == Creature_Type.Pet then
        return "PET[" .. creature.data.id .. "]";
    end;
    if creatureType == Creature_Type.Npc then
        if creature.data:IsNpc() then
            return "NPC[" .. creature.data.id .. "] " .. creature.data.staticData.NameZh;
        else
            return "MON[" .. creature.data.id .. "] " .. creature.data.staticData.NameZh;
        end;
    end;
    if creatureType == Creature_Type.Me then
        return "ME"
    end;    
end;

function ROM_GetCreatureNameFromID(id)
    local creature = SceneCreatureProxy.FindCreature(id);
	if creature == nil then 
		return "CREATURE[" .. id .. "]";
	else
		return ROM_GetCreatureName(creature);
	end;
end;

function ROM_PropGetName(props,id)
    if props then
        for i, v in pairs(props.configs) do 
            if i == id then
                return v.name or "PROP_" .. id;
            end;
        end;        
    end;
    return "PROP_" .. id;
end;

function ROM_IsCleanSkill(skillInfo)
	local skillName = skillInfo.staticData.NameZh;
	for i=1,#cleanSkill do
		if string.match(skillName, cleanSkill[i]) then
			return true;
		end;
	end;
	return false;
end;

function ItemToString(item)
    local ret = ""
    ret = ret .. "index=" .. item.index .. " guid=" .. item.id .. " typeID=" .. item.staticData.id .. " name=" .. item.staticData.NameZh .. " num" .. item.num;
    return ret;
end;

function ROM_DumpBag()
    for i,v in pairs(BagProxy.Instance.bagData:GetItems()) do
        LogDebug(ItemToString(v));
    end;
end;

function ROM_GetBagItemByName(itemName)
    for i,item in pairs(BagProxy.Instance.bagData:GetItems()) do
        local name = item.staticData.NameZh;
        if string.match(item.staticData.NameZh,itemName) then
            return item;
        end;
    end;
    return nil;
end;

function ROM_UseItem(itemName,target,num)
    --ROM_DumpBag();
    local item = ROM_GetBagItemByName(itemName);
    if item then
        LogDebug(ItemToString(item));
        ServiceItemProxy.Instance:CallItemUse(item, nil, nil);
    end;

end;

function ROM_CloseAllModal()
    tableForEach(UIManagerProxy.Instance.modalLayer, function(_, layerType)
        --logDebug(tostring(layerType));
        GameFacade.Instance:sendNotification(UIEvent.CloseUI,layerType);    
    end);
end;

function ROM_GetMapName(id)
    if Table_Map[id] then
        return Table_Map[id].CallZh .. "(" .. id .. ")";
    else
        return "MAP" .. id;
    end;
end;

function ROM_GetTeamLeaderID()
    local leaderTeamMemberData = TeamProxy.Instance.myTeam:GetNowLeader()
	if leaderTeamMemberData then
		return leaderTeamMemberData.id;
	end
	return nil;
end;

function ROM_AmITeamLeader()
	return ROM_GetTeamLeaderID() == Game.Myself.data.id
end;

function ROM_GetMyTeamMapIDAndPosition(id)
    local myTeam = TeamProxy.Instance.myTeam;
    if myTeam then
        local teamMember = myTeam:GetMemberByGuid(id);
        if teamMember then
            local memberPos = teamMember.pos	-- default data not accurate
            local memberCreature = SceneCreatureProxy.FindCreature(id)
            if memberCreature then
                memberPos = memberCreature:GetPosition();
            end
            return teamMember.mapid, memberPos;
        end;
    end;
    return nil,nil;
end;

function ROM_IsTeamReady()
    local currentMapID = Game.MapManager:GetMapID();
    local followers = Game.Myself:Client_GetAllFollowers();
    for followID,_ in pairs(followers) do
        local mapID, pos = ROM_GetMyTeamMapIDAndPosition(followID);
        if mapID then
            if currentMapID ~= mapID then
                LogDebug("ROM_IsTeamReady: different map " .. followID .. " " .. currentMapID .. " ~= " .. mapID);
                return false;
            end;
            local dist = ROM_DistanceToPos(pos);
            if dist > 2 then
                LogDebug("ROM_IsTeamReady: too far " .. followID .. " " .. dist);
                return false;            
            end;
        end;
    end;
    LogDebug("ROM_IsTeamReady: true");
    return true;
--[[	local myTeam = TeamProxy.Instance.myTeam;
    if(myTeam)then
        local myMembers = myTeam:GetMembersList();
        for i=1,#myMembers do
            local memberData = myMembers[i];
            local id = memberData.id;
            local creature = SceneCreatureProxy.FindCreature(id);
            if creature then
                local dist = ROM_DistanceToCreature(creature);     
                local stat = ROM_GetMonStatus(creature);						
                --LogDebug("ROM_Heal id=" .. id .. ' dist=' .. dist .. );
                if stat.frachp < frac and dist < 5 and stat.hp > 0 then
                    Game.Myself:Client_UseSkill(skillID, creature ,nil,nil,true);
                    return true;
                end;
            end;
        end
    end]]
end;

function ROM_PetAdventure(questID,monID)
	monID = monID or 0;
	local petEggs = BagProxy.Instance:GetMyPetEggs();
	if #petEggs == 3 then
		local petids = {};
		for i=1,#petEggs do
			--LogDebug(PropToString(petEggs[i]," ") .. " " .. PropToString(petEggs[i].staticData,"staticData."));		
			petids[#petids+1] = petEggs[i].id;
		end;
		--LogDebug(MyTostring(petids));		
		ServiceScenePetProxy.Instance:CallStartAdventurePetCmd(questID, petids, monID);
	end;
end;

function ROM_PetAdventureQuestByID(questID)
	for i=1,#PetAdventureProxy.Instance.questData do
		if PetAdventureProxy.Instance.questData[i].id==questID then
			return PetAdventureProxy.Instance.questData[i];
		end
	end	
	return nil;
end;

function ROM_HasFollowers()
	local followers = Game.Myself:Client_GetAllFollowers();
    local count = 0;
    for i,v in pairs(followers) do
        count = count + 1;
    end;
    return count > 0
end;

function ROM_GetExitPoints(mapID)
    if Table_MapInfo[mapID] and Table_MapInfo[mapID].exitPoints then
        return Table_MapInfo[mapID].exitPoints;
    else 
        return nil;
    end;
end;

function ROM_GetMapIDPath(fromMapID, toMapID)
    local startMapID = fromMapID;
    for i=1,20 do
        if startMapID == toMapID then
            break;
        end;
        if MapOutterTeleport[startMapID] and MapOutterTeleport[startMapID][toMapID] then
            local v = MapOutterTeleport[startMapID][toMapID];
            local ep,v1 = next(v, nil);
            local retep,val = next(v1,nil);
            LogDebug("#" .. i .. " " .. ROM_GetMapName(startMapID) .. " exit=" .. ep .. " returnExit=" .. retep .. " " .. MyTostring(val));   
            local exits = ROM_GetExitPoints(startMapID)    
            if exits and exits[ep] then
                startMapID = exits[ep];
            end
        end;
    end;
end;

function ROM_IsActiveMap(mapID)	-- player activate taht map
	local activeMaps = WorldMapProxy.Instance.activeMaps
	if activeMaps and activeMaps[mapID] then
		return activeMaps[mapID] == 1
	else
		return false;
	end
end

function ROM_IsTeleportableMap(mapID) -- possible to teleport to if activate
	for _, v in pairs(Table_Map) do
		if v.Money and v.MoneyType == 1 then -- we can transport if v.MoneyType == 1 
			if v.id == mapID then
				return true;
			end;
		end
	end
	return false;
end;

function ROM_GetPathToMap(fromMapID,toMapID)
	local ret = {};
	-- check if we can teleport to that the target
	if ROM_IsTeleportableMap(toMapID) and ROM_IsActiveMap(toMapID) then
		--ret[1] = {func="FindNearestNPC"}
		ret[1] = {func="Teleport", mapID=toMapID}
	else	
		-- need to walk to that map by find nearest town and walk
		local nearestTown = ROM_GetNearestTown(toMapID);
		if nearestTown == fromMapID then
			ret[1] = {func="Walk"}
		else
            if ROM_IsTeleportableMap(nearestTown) and ROM_IsActiveMap(nearestTown) then
                ret[1] = {func="Teleport", mapID=nearestTown}
                ret[2] = {func="Walk"}
            else
                ret[1] = {func="Walk"}
            end;
            --ret[1] = {func="Walk"}
		end;
	end;
    --LogDebug("ROM_GetPathToMap return " .. MyTostring(ret));
	return ret;
end;

function ROM_TeleportTo(mapID)
	local currentMapID = Game.MapManager:GetMapID();
	if mapID == currentMapID then
		return true;	-- already there
	end;
	local path = ROM_GetPathToMap(currentMapID,mapID);
    LogDebug(MyTostring(path));
    --LogDebug(MyTostring(path[1]));
	local cmd = path[1];
	if cmd.func == "Walk" then
		ROM_CommandGOTO(mapID);
		return false;
	end;
	if cmd.func == "Teleport" then
		local npcID,targetPos,mindist = ROM_FindNearestNPC();
		if npcID then
			if ROM_WalkToNPC(currentMapID,npcID) then
				LogDebug("ROM_TeleportTo: npc reach");
				ROM_ClickNearestNPC(true);
				local followers = Game.Myself:Client_GetAllFollowers();
				--for followID,_ in pairs(followers) do
				local followingTeammatesID = UIModelKaplaTransmit.Ins():GetFollowingTeammates()
				if #followingTeammatesID == 0 then
					ServiceNUserProxy.Instance:CallGoToGearUserCmd(cmd.mapID, SceneUser2_pb.EGoToGearType_Single, nil);
				else
					ServiceNUserProxy.Instance:CallGoToGearUserCmd(cmd.mapID, SceneUser2_pb.EGoToGearType_Team, followingTeammatesID)
				end;
				--
				--
				--logDebug(MyTostring(followers));
				--logDebug(MyTostring(followingTeammatesID));
				return false;
			end;
				--function()
					--ROM_VisitNearestNPC();
					--ServiceQuestProxy.Instance:CallRunQuestStep(q.id, nil, nil, q.step); 
					--GameFacade.Instance:sendNotification(UIEvent.CloseUI,UIViewType.DialogLayer);
					--LogDebug(QuestToString(q));
					--ROM_ClickNearestNPC(true);
				--end
        else        
            return false,"NPCNotFound";
		end;
		return false;
	end;
	
end;

function ROM_FindNearestNPC()
	LogDebug("ROM_FindNearestNPC: start1");
	local npcs = ROM_GetMapNPCsEx();
    if npcs == nil or #npcs == 0 then
        return nil;
    end;
	local mindist = 1000;
	local minNPC = nil;
	local myPos = Game.Myself:GetPosition();
	for i, v in pairs(npcs) do 		
		--local pos = --[[Vector3]] LuaVector3(v.position[1],v.position[2],v.position[3]);
		--local distance = LuaVector3.Distance(myPos,pos);
		--if distance < mindist then
		--	mindist = distance;
		--	minNPC = v;
		--	targetPos = pos;
		--end;
		--LogDebug(PropToString(v));
		local npcData = Table_Npc[v.ID];
		if npcData and npcData.Position and npcData.Icon and npcData.MapIcon  and npcData.Desc and npcData.Desc ~="" then
			if npcData.Icon ~= "" or (npcData.MapIcon ~= "" and npcData.MapIcon ~= "map_collection") then
				local poses = ROM_GetOriginalPoses(v.ID,mapID)
				if poses then
					--LogDebug("ROM_FindNearestNPC:found" .. " " .. PropToString(npcData));
					--LogDebug("ROM_FindNearestNPC:at" .. " " ..MyTostring(poses))
					--return v.ID, poses[1].pos;
					local pos = --[[Vector3]] LuaVector3(poses[1].pos[1],poses[1].pos[2],poses[1].pos[3]);
					local distance = LuaVector3.Distance(myPos,pos);
					if  distance < mindist then
						mindist = distance;
						minNPC = v.ID;
						targetPos = pos;
					end;
				end;
			end;
		end;
	end;
	LogDebug("ROM_FindNearestNPC:found ".. tostring(minNPC) .. " " .. tostring(targetPos) .. " " .. mindist);
	LogDebug("ROM_FindNearestNPC: end");
	return minNPC,targetPos,mindist
end;



if FunctionMonster ~= nil then
    function FunctionMonster:FilterMonster(ignoreSkill)
        --LogDebug("FunctionMonster:FilterMonster()");
        TableUtility.ArrayClear(self.monsterList)

        local userMap = NSceneNpcProxy.Instance.userMap

        local hasLearnMvp,hasLearnMini = true, true;
        --if(ignoreSkill ~= true)then
        --    hasLearnMvp = SkillProxy.Instance:HasLearnedSkill(GameConfig.Expression_SearchSkill.searchmvpskill)
        --    hasLearnMini = SkillProxy.Instance:HasLearnedSkill(GameConfig.Expression_SearchSkill.searchminiskill)
        --end

        for _,monster in pairs(userMap)do
            if monster.data and monster.data:IsMonster() then
                if(monster.data.staticData.Type == "MVP")then
                    LogDebug("MVP found" .. MonsterToString(monster));
                    if(hasLearnMvp)then
                        table.insert(self.monsterList, monster.data.id)
                    end
                elseif(monster.data.staticData.Type == "MINI")then
                    LogDebug("MINI found" .. MonsterToString(monster));
                    if(hasLearnMini)then
                        table.insert(self.monsterList, monster.data.id)
                    end
                else
                    table.insert(self.monsterList, monster.data.id)
                end
            end
        end

        return self.monsterList
    end
end;

if MissionCommand then
    if MissionCommandHunt == nil then
        MissionCommandHunt = class("MissionCommandHunt", MissionCommand)
    end;
    function MissionCommandHunt:ctor()
        LogDebug("MissionCommandHunt:ctor()");
        MissionCommandHunt.super.ctor(self)
        self.ai = AutoAI_Rom.new();
        self.count = 0;
    end
    function MissionCommandHunt:DoLaunch()
        LogDebug("MissionCommandHunt:DoLaunch()");
        self.ai:Enable(true);
        if self.args.quest and self.args.quest.params.monster ~= nil then
            ListField(self.args.quest.params,"",{},"    ");          
            self.args.config.myMonsterList = {self.args.quest.params.monster};
            self.args.config.myMonsterRules ={
                {func= ROM_FindNearestMonsterEx2, monlist=self.args.config.myMonsterList, ignore=ignoreMonList, selectFunc=ROM_GetBestScoreMonFromList}, 
                {func= ROM_FindNearestMonsterEx2, monlist=self.args.config.myMonsterList, ignore=ignoreMonList}, 
            };
            LogDebug("MissionCommandHunt Hunt " .. self.args.quest.params.monster);
        else
            self.args.config.myMonsterRules ={
                {func= ROM_FindNearestMonsterEx2, monlist={}, ignore=ignoreMonList, selectFunc=ROM_GetBestScoreMonFromList}, 
                {func= ROM_FindNearestMonsterEx2, monlist={}, ignore=ignoreMonList}, 
            };
            LogDebug("MissionCommandHunt Hunt ALL");
        end
        self.oldConfig = ROM_SetConfig(self.args.config);    
    end
    function MissionCommandHunt:DoShutdown()
        LogDebug("MissionCommandHunt:DoShutdown()");
        self.ai:Enable(false);
        ROM_SetConfig(self.oldConfig);
    end
    function MissionCommandHunt:DoUpdate(time, deltaTime)
        LogDebug("MissionCommandHunt:DoUpdate() " .. time .. " " .. self.count);
        local q = self.args.quest;
        if q then
            if q.params.num == nil then
                if q.params.team_can_finish and q.params.team_can_finish ~= 1 then 
                    LogDebug("MissionCommandHunt: wait for team");                                                        
                else
                    LogDebug("MissionCommandHunt: Quest done");                            
                    --ROM_WalkToBoard();
                    return false;
                end;     
            end;
        end;
        --function AutoAI_Rom:Prepare(idleElapsed, time, deltaTime, creature)
        local ret = self.ai:Prepare(0, time, deltaTime, nil);
        if ret == false then
            self.count = self.count + 1;
            LogDebug("MissionCommandHunt: " .. self.count);
        else
			if self.ai.waitForTime == false then
				self.count = 0;
				LogDebug("MissionCommandHunt: " .. self.count);
			end;
        end;
        return true;
    end;
    
    if MissionCommandWalknFight == nil then
        MissionCommandWalknFight = class("MissionCommandWalknFight", MissionCommand)
    end;
    function MissionCommandWalknFight:ctor()
        LogDebug("MissionCommandWalknFight:ctor()");
        MissionCommandWalknFight.super.ctor(self)
        self.ai = AutoAI_Rom.new();
        self.count = 0;
    end
    function MissionCommandWalknFight:DoLaunch()
        LogDebug("MissionCommandWalknFight:DoLaunch()");
        self.ai:Enable(true);
        MissionCommandWalknFight.pos = self.args.pos;
        if self.args.quest and self.args.quest.params.monster ~= nil then
            ListField(self.args.quest.params,"",{},"    ");          
            self.args.config.myMonsterList = {self.args.quest.params.monster};
            self.args.config.myMonsterRules ={
                {func= ROM_FindNearestMonsterEx2, monlist=self.args.config.myMonsterList, ignore=ignoreMonList, selectFunc=ROM_GetBestScoreMonFromListWalknFight}, 
                {func= ROM_FindNearestMonsterEx2, monlist=self.args.config.myMonsterList, ignore=ignoreMonList}, 
            };
            LogDebug("MissionCommandWalknFight Hunt " .. self.args.quest.params.monster);
        else
            self.args.config.myMonsterRules ={
                {func= ROM_FindNearestMonsterEx2, monlist={}, ignore=ignoreMonList, selectFunc=ROM_GetBestScoreMonFromListWalknFight}, 
                {func= ROM_FindNearestMonsterEx2, monlist={}, ignore=ignoreMonList}, 
            };
            LogDebug("MissionCommandWalknFight Hunt ALL");
        end
        self.oldConfig = ROM_SetConfig(self.args.config);    
    end
    function MissionCommandWalknFight:DoShutdown()
        LogDebug("MissionCommandWalknFight:DoShutdown()");
        self.ai:Enable(false);
        ROM_SetConfig(self.oldConfig);
    end
    function MissionCommandWalknFight:DoUpdate(time, deltaTime)
        LogDebug("MissionCommandWalknFight:DoUpdate() " .. time .. " " .. self.count);
        local q = self.args.quest;
        if q then
            if q.params.num == nil then
                if q.params.team_can_finish and q.params.team_can_finish ~= 1 then 
                    LogDebug("MissionCommandWalknFight: wait for team");                                                        
                else
                    LogDebug("MissionCommandWalknFight: Quest done");                            
                    --ROM_WalkToBoard();
                    return false;
                end;     
            end;
        end;
        --function AutoAI_Rom:Prepare(idleElapsed, time, deltaTime, creature)
        local ret = self.ai:Prepare(0, time, deltaTime, nil);
        if ret == false then
            self.count = self.count + 1;
            LogDebug("MissionCommandWalknFight: " .. self.count);
        else
			if self.ai.waitForTime == false then
				self.count = 0;
				LogDebug("MissionCommandWalknFight: " .. self.count);
			end;
        end;
        return true;
    end;
    
    
end;

ROM_tabTeleport = {
    [22]=20,
}

ROM_tabMonsterOrigin = {
    [10057]={
		[1]={
			pos={
				[1]=41.136248,
				[2]=-1.329748,
				[3]=-61.917320
			},
			mapID=32
		}
	},
    [10054]={
        [1]={
			pos={
				[1]=-32.269790649414,
				[2]=5.9512996673584,
				[3]=36.969463348389
			},
			mapID=54
		},
    },    
    [10052]={
        [1]={
			pos={
				[1]=131.35940551758,
				[2]=12.591299057007,
				[3]=-36.680313110352
			},
			mapID=17
		},
    },
    [10051]={
    	[1]={
			pos={--210.169942, 12.480402, -48.204506
				[1]=211.169942,
				[2]=12.480402,
				[3]=-46.204506
			},
			mapID=17
		},
    },
    [10053]={
		[1]={
			pos={--110.713799, 12.822729, 8.222836
				[1]=110.713799,
				[2]=12.822729,
				[3]=8.222836
			},
			mapID=17
		},
    },
    [10056]={
		[1]={
			pos={
				[1]=46.774910,
				[2]=0.057374,
				[3]=-37.507874
			},
			mapID=19
		},
    },
    [10057]={
		[1]={
			pos={---1.691658, -1.313200, -79.897491
				[1]=-1.691658,
				[2]=-1.322711,
				[3]=-79.897491
			},
			mapID=19
		},
    },
    [10057]={
		[1]={
			pos={
				[1]=-49.490476,
				[2]=-4.939921,
				[3]=-10.082882
			},
			mapID=22
		},
    },
    [10081]={
		[1]={
            pos={
				[1]=31.940000534058,
				[2]=10.880000114441,
				[3]=69.349998474121
			},
			mapID=37
		},
    },
    [10130]={
		[1]={
            pos={
				[1]=6.73,
				[2]=4.36,
				[3]=66.62
			},
			mapID=45
		},
    },
    [10141]={
		[1]={
            pos={
				[1]=96.579296,
				[2]=18.529636,
				[3]=-57.093349
			},
			mapID=49
		},
    },    
    [10090]={
		[1]={
            pos={
				[1]=-56.703093,
				[2]=7.654091,
				[3]=18.114621
			},
			mapID=29
		},
    },    
    [10095]={   --10095 name=Joker
		[1]={
            pos={   ---55.529498, 1.677692, 44.057675
				[1]=-55.529498,
				[2]=1.677692,
				[3]=44.057675
			},
			mapID=30
		},
    },    
    
    
    
    --ME ID=4300736919 HP=10834/10834 SP=496/617 lvl=94 Zeny=52505494 pos=LuaVector3(-56.703093, 7.654091, 18.114621) mapID=29 leader=true
    --ME ID=4300736919 HP=10834/10834 SP=327/617 lvl=94 Zeny=52467547 pos=LuaVector3(96.579296, 18.529636, -57.093349) mapID=49 leader=true
};
