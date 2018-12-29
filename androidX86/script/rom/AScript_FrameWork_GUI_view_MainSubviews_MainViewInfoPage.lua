MainViewInfoPage = class("MainViewInfoPage",SubView)

autoImport("BaseItemCell")
autoImport("PlayerFaceCell");
autoImport("BuffCell");
autoImport("WeakDialogCell");

local BUFFTYPE_DOUBLEEXPCARD = "MultiTime";

function MainViewInfoPage:Init()
	self:Init_RecallBuffMap();
	self:InitGvgDroiyanTriggerInfo();

	self:FindObjs();
	self:AddViewListen();
	self.buffs = {};
	self.guideList = {}
	self.weak_dialog_queue = {};
end

local RECALL_BUFF_REFLECT_MAP;
local RECALL_BUFF_REWARD_MAP = {};

local recall_buffmap = {};
function MainViewInfoPage:Init_RecallBuffMap()
	RECALL_BUFF_REFLECT_MAP = GameConfig.Recall.reward_buff_reflectshow or _EmptyTable;

	local ZhTip_Map =
	{
		['seal'] = ZhString.MainViewInfoPage_seal,
		['board'] = ZhString.MainViewInfoPage_board,
		['laboratory'] = ZhString.MainViewInfoPage_laboratory,
		['tower'] = ZhString.MainViewInfoPage_tower,
		['donate'] = ZhString.MainViewInfoPage_donate,
	};
	local reward_bufflayer = GameConfig.Recall.reward_bufflayer or _EmptyTable;
	for k,v in pairs(reward_bufflayer)do
		RECALL_BUFF_REWARD_MAP[ v.id ] = { v.layer, ZhTip_Map[k] };
	end
end

function MainViewInfoPage:OnEnter()
	self.super.OnEnter(self);
	self:UpdateAllInfo();
end

function MainViewInfoPage:OnExit()
	self.super.OnExit(self);
end

function MainViewInfoPage:FindObjs()
	self.buffgrid = self:FindComponent("BuffGrids", UIGrid);
	self.buffCtl = UIGridListCtrl.new(self.buffgrid, BuffCell,"BuffCell")
	self.buffCtl:AddEventListener(BuffCellEvent.BuffEnd, self.RemoveTimeEndBuff, self);
	self.buffCtl:AddEventListener(MouseEvent.MouseClick, self.ClickBuffEvent, self);
	self.buffDatas = {};
	self.buffListDatas = {};

	self.sceneMapName = self:FindComponent("SceneMapName", UILabel);

	self.foldbord = self:FindChild("foldBord");
	self.foldSymbol = self:FindChild("foldSymbol");

	self.sysTimeLab = self:FindComponent("SysTime", UILabel);
	self.batterySlider = self:FindComponent("BatteryPctSlider", UISlider);
	self.batterySlider_Foreground = self:FindComponent("Foreground", UISprite, self.batterySlider.gameObject);
	self.battery_IsCharge = self:FindGO("BatteryChargeSymbol");
	self.currentLine = self:FindComponent("CurrentLine", UILabel);
	self.objCurrentLine = self:FindGO("WorldLine")
	self.map_currentLine = self:FindComponent("Map_CurrentLine", UILabel);
	self.objMap_currentLine = self:FindGO("Map_WorldLine")

	self.wifiSymbols = {};
	for i=1,4 do
		table.insert(self.wifiSymbols, self:FindGO("Wifi"..i));
	end
	
	self.endlessTower = self:FindComponent("EndLessTowerLevel", UILabel);
	
	-- update Weak Dialog
	self.weakDialogBord = self:FindGO("WeakDialogBord");

	self.fullProgress = self:FindGO("FullProgress");
	self:AddClickEvent(self.fullProgress, function (go)
		self:ClickFullProgress();
	end);
	self.eatFoodCount = self:FindComponent("FoodCount", UILabel)

	self.fullProgress_Icon = self:FindComponent("Icon", UISprite, self.fullProgress);
	IconManager:SetSkillIcon("Food_buff", self.fullProgress_Icon)

	self.skillAssist = self:FindGO("SkillAssist");
	self.autoBattleButton =	self:FindGO("AutoBattleButton");

	self.boothBtn = self:FindGO("BoothBtn")
	self:AddClickEvent(self.boothBtn, function ()
		self:sendNotification(UIEvent.JumpPanel, {view = PanelConfig.BoothMainView})
	end)
	
	--todo xde fix cur line ui
	OverseaHostHelper:FixLabelOver(self.currentLine,60)
	self.currentLine.fontSize = 26
end

function MainViewInfoPage:ClickFullProgress()
	local buffProps, buffInvalidTimeList = FoodProxy.Instance:GetMyFoodBuffProps();

	local curentSeverTime = ServerTime.CurServerTime()
	local buffDesc = "";
	local buffDescTime = "";
	for i=1,#buffProps do
		local buffData = buffProps[i];
		TableUtil.Print(buffData)
		if(buffData.value > 0)then
			if(buffData.propVO.isPercent)then
				buffDesc = buffDesc .. OverSea.LangManager.Instance():GetLangByKey(buffData.propVO.displayName).."+"..tostring(buffData.value/10) .. "%"; --todo xde 修复buff描述翻译
			else
				buffDesc = buffDesc .. OverSea.LangManager.Instance():GetLangByKey(buffData.propVO.displayName).."+"..tostring(buffData.value);--todo xde 修复buff描述翻译
			end
		else
			if(buffData.propVO.isPercent)then
				buffDesc = buffDesc .. OverSea.LangManager.Instance():GetLangByKey(buffData.propVO.displayName)..tostring(buffData.value/10) .. "%";--todo xde 修复buff描述翻译
			else
				buffDesc = buffDesc .. OverSea.LangManager.Instance():GetLangByKey(buffData.propVO.displayName)..tostring(buffData.value);--todo xde 修复buff描述翻译
			end
		end

		local lastTime = (buffInvalidTimeList[buffData.propVO.name] - curentSeverTime/1000)/60
		if lastTime > 0 then
			buffDescTime = buffDescTime .. math.floor(lastTime) .. ZhString.MainViewInfoPage_Min .. "\n"
		end

		if(i < #buffProps)then
			buffDesc = buffDesc .. "\n";
		end
	end

	-- local myUserData = Game.Myself.data.userdata;
	-- local fullProgress = myUserData:Get(UDEnum.SATIETY);
	-- local myTasterlv = myUserData:Get(UDEnum.TASTER_LV);
	-- local maxFullProgress;
	-- if(myTasterlv == nil or Table_TasterLevel[myTasterlv] == nil)then
	-- 	maxFullProgress = GameConfig.Food.MaxSatiety_Default or 80;
	-- else
	-- 	maxFullProgress = Table_TasterLevel[myTasterlv].FullProgress;
	-- end
	-- local fullProgressStr = string.format(ZhString.MainViewInfoPage_FullProgress, fullProgress, maxFullProgress);
	-- if(buffDesc ~= "")then
	-- 	fullProgressStr = fullProgressStr .. "\n\n" .. buffDesc;
	-- end
	TipManager.Instance:ShowEatFoodInfoTip(buffDesc, buffDescTime, self.fullProgress_Icon, NGUIUtil.AnchorSide.DownRight, {30, 0});
end

function MainViewInfoPage:ClickBuffEvent(cellCtl)
	local data = cellCtl.data;
	if(data)then
		local staticData = data and data.staticData;
		local oriDec = staticData and staticData.BuffDesc or "";
		local normalTip = TipManager.Instance:ShowNormalTip(oriDec, cellCtl.icon, NGUIUtil.AnchorSide.DownRight, {30, 0});
		normalTip:SetUpdateSetText(1000, MainViewInfoPage.UpdateBuffTip, data);
	end
end

function MainViewInfoPage.UpdateBuffTip(data)
	if(data == nil)then
		return true, "NO DATA";
	end

	-- handle storage buff
	if(data.storage)then
		return true, MainViewInfoPage.GetStorgeDesc(data.storage);
	end


	local staticData = data.staticData;
	if(staticData == nil)then
		return true, "No Buff StaticData";
	end

	local desc, text = staticData.BuffDesc;
	if(data.fromname and data.fromname~="")then
		desc = string.format(desc, data.fromname);
	end

	-- handle recall buff
	if(data.isRecallBuff)then
		local tempArray = {};
		for  id, layer in pairs(recall_buffmap)do
			local info = RECALL_BUFF_REWARD_MAP[id];
			table.insert(tempArray, {id, string.format(info[2], info[1] - layer, info[1]) })
		end
		table.sort(tempArray, function (a,b)
			return a[1] < b[1];
		end)

		local recall_desc = "";
		for i=1,#tempArray do
			recall_desc = recall_desc .. tempArray[i][2];
			if( i<#tempArray )then
				recall_desc = recall_desc .. "\n";
			end
		end

		return true, desc .. recall_desc ;
	end

	if(data.isEquipBuff and desc ~= "")then
		desc = string.gsub(desc,"%[OffingEquipPoses%]", MainViewInfoPage.GetOffingEquipPoses());
		desc = string.gsub(desc,"%[ProtectEquipPoses%]", MainViewInfoPage.GetProtectEquipPoses());
		desc = string.gsub(desc,"%[BreakEquipPoses%]", MainViewInfoPage.GetBreakEquipPoses());
	end

	local betype = staticData.BuffEffect.type;
	if(betype == BUFFTYPE_DOUBLEEXPCARD)then
		if(data.active)then
			text = staticData.BuffName..ZhString.BuffCell_BuffActive.."\n\n";
		else
			text = staticData.BuffName..ZhString.BuffCell_BuffInActive.."\n\n";
		end
		local leftTime = math.ceil(data.layer/60);
		text = text..desc.."\n\n"..string.format(ZhString.BuffCell_DELeftTimeTip, leftTime)
	else
		if(data.isalways)then
			return true, desc;
		end

		local curServerTime = ServerTime.CurServerTime()/1000;
		local endtime = data.endtime and data.endtime/1000;
		if(endtime)then
			if(curServerTime > endtime)then
				return true, text;
			else
				local leftSec = math.floor(endtime - curServerTime);
				if(leftSec < 60)then
					text = desc.."\n\n"..string.format(ZhString.MainViewInfoPage_BuffLeftTimeTip, leftSec)..ZhString.MainViewInfoPage_Sec;
				else
					local leftMin = math.ceil(leftSec/60);
					text = desc.."\n\n"..string.format(ZhString.MainViewInfoPage_BuffLeftTimeTip, leftMin)..ZhString.MainViewInfoPage_Min;
				end
			end
		else
			return true, desc;
		end
	end
	return false, text;
end

function MainViewInfoPage.GetOffingEquipPoses()
	local offPoses = FunctionEquipPosState.Me():GetOffingEquipPoses()
	local resultStr = "";
	for i=1,#offPoses do
		resultStr = resultStr .. RoleEquipBagData.GetSiteNameZh(offPoses[i])
		if(i < #offPoses)then
			resultStr = resultStr .. ZhString.MainViewInfoPage_DunHao;
		end
	end
	return resultStr;
end

function MainViewInfoPage.GetProtectEquipPoses()
	local protectPoses = FunctionEquipPosState.Me():GetProtectEquipPoses()
	local resultStr = "";
	for i=1,#protectPoses do
		resultStr = resultStr .. RoleEquipBagData.GetSiteNameZh(protectPoses[i])
		if(i < #protectPoses)then
			resultStr = resultStr .. ZhString.MainViewInfoPage_DunHao;
		end
	end
	return resultStr;
end

function MainViewInfoPage.GetBreakEquipPoses()
	local breakInfos = BagProxy.Instance.roleEquip:GetBreakEquipSiteInfo();
	local resultStr = "";
	for i=1,#breakInfos do
		resultStr = resultStr .. RoleEquipBagData.GetSiteNameZh(breakInfos[i].index)
		if(i < #breakInfos)then
			resultStr = resultStr .. ZhString.MainViewInfoPage_DunHao;
		end
	end
	return resultStr;
end

function MainViewInfoPage.GetStorgeDesc(storage)
	local desc = "";
	if(storage[1])then
		local desc1 = Table_Buffer[ storage[1][1] ].BuffDesc;
		desc1 = string.gsub(desc1, "%[HPStorage%]", storage[1][2] or 0);

		if(desc ~= "")then
			desc = desc .. "\n";
		end
		desc = desc .. desc1;
	end
	if(storage[2])then
		local desc2 = Table_Buffer[ storage[2][1] ].BuffDesc;
		desc2 = string.gsub(desc2, "%[SPStorage%]", storage[2][2] or 0);

		if(desc ~= "")then
			desc = desc .. "\n";
		end
		desc = desc .. desc2;
	end
	return desc;
end

function MainViewInfoPage.GetHPStorage(data)
	return data.storage or 0;
end

function MainViewInfoPage.GetSPStorage(data)
	return data.storage or 0;
end

function MainViewInfoPage:UpdateAllInfo()
	self:UpdateJobSlider();
	self:UpdateExpSlider();
	self:UpdateSysInfo();
	self:UpdateCurrentLine(false);
	self:UpdateFoodCount()
	self.battlePoint = Game.Myself.data.userdata:Get(UDEnum.BATTLEPOINT);
end

function MainViewInfoPage:OnShow()
	self.baseBg = self:FindComponent("BaseBg", UISprite);
	self.jobBg = self:FindComponent("JobBg", UISprite);

	-- todo xde 修复返回登陆卡死
	-- TimeTickManager.Me():ClearTick(self, 11)
	-- TimeTickManager.Me():CreateTick(1000, 33, function ()
	-- 	local baseGrid = self:FindComponent("BaseExpGrid", UIGrid);
	-- 	baseGrid.cellWidth = (self.baseBg.width - 50) / 10;
	-- 	baseGrid:Reposition();

	-- 	local jobGrid = self:FindComponent("JobExpGrid", UIGrid);
	-- 	jobGrid.cellWidth = (self.jobBg.width - 50) / 10;
	-- 	jobGrid:Reposition();
	-- end, self, 11)
	self.baseBg:ResetAndUpdateAnchors();
	self.jobBg:ResetAndUpdateAnchors();

	local baseGrid = self:FindComponent("BaseExpGrid", UIGrid);
	baseGrid.cellWidth = (self.baseBg.width - 50) / 10;
	baseGrid:Reposition();

	local jobGrid = self:FindComponent("JobExpGrid", UIGrid);
	jobGrid.cellWidth = (self.jobBg.width - 50) / 10;
	jobGrid:Reposition();
end

function MainViewInfoPage:UpdateCurrentLine()
	if(Game.MapManager:IsPVPMode_MvpFight())then
		--ZhString.MainViewInfoPage_MvpFightLine;
		self.objCurrentLine:SetActive(false)
		self.objMap_currentLine:SetActive(false)
		return;		
	end
	self.objCurrentLine:SetActive(true)
	self.objMap_currentLine:SetActive(true)
	self.currentLine.text = ChangeZoneProxy.Instance:ZoneNumToString( MyselfProxy.Instance:GetZoneId() ); -- ZhString.MainViewInfoPage_line
	self.map_currentLine.text = ChangeZoneProxy.Instance:ZoneNumToString( MyselfProxy.Instance:GetZoneId() ); -- ZhString.MainViewInfoPage_MapCurrentline
end

function MainViewInfoPage:UpdateFoodCount()
	local foodList = FoodProxy.Instance:GetEatFoods()
	local effectiveFoodCount = 0

	if foodList and #foodList > 0 then
		for i=1,#foodList do
			local food = foodList[i]
			if food.itemid ~= 551019 then
				effectiveFoodCount = effectiveFoodCount + 1
			end
		end
	end

	if effectiveFoodCount > 0 then
		self.eatFoodCount.text = effectiveFoodCount
	else
		self.eatFoodCount.text = ""
	end

	self.fullProgress:SetActive(effectiveFoodCount >0)
end

function MainViewInfoPage:UpdateCurrentLine(isMvp)
	if(isMvp == true)then
		self.objCurrentLine:SetActive(false)
		self.objMap_currentLine:SetActive(false)
		return;		
	end
	self.objCurrentLine:SetActive(true)
	self.objMap_currentLine:SetActive(true)
	self.currentLine.text = ChangeZoneProxy.Instance:ZoneNumToString( MyselfProxy.Instance:GetZoneId() );
	self.map_currentLine.text = ChangeZoneProxy.Instance:ZoneNumToString( MyselfProxy.Instance:GetZoneId() );
end

function MainViewInfoPage:RemoveTimeEndBuff(buffdata)
	local id = buffdata.id;
	self:RemoveRoleBuff({body = {id}});
end

function MainViewInfoPage:AddViewListen()
	self:AddListenEvt(MyselfEvent.BaseExpChange, self.UpdateExpSlider);
	self:AddListenEvt(MyselfEvent.JobExpChange, self.UpdateJobSlider);
	self:AddListenEvt(MyselfEvent.ZoneIdChange,self.UpdateCurrentLine);
	self:AddListenEvt(PVPEvent.PVP_MVPFightLaunch,self.HandleEnterMvp);
	self:AddListenEvt(PVPEvent.PVP_MVPFightShutDown,self.HandleExitMvp);
	self:AddListenEvt(ServiceEvent.SceneFoodFoodInfoNtf,self.UpdateFoodCount);
	self:AddListenEvt(ServiceEvent.SceneFoodUpdateFoodInfo,self.UpdateFoodCount);
	self:AddListenEvt(LoadSceneEvent.FinishLoad,self.HandleSceneMapName);
	-- update buff
	self:AddListenEvt(MyselfEvent.AddBuffs, self.AddRoleBuff);
	self:AddListenEvt(MyselfEvent.RemoveBuffs, self.RemoveRoleBuff);
	-- 添加弱对话事件
	self:AddListenEvt(MyselfEvent.AddWeakDialog, self.HandleAddWeakDialog);

	-- 波利大乱斗
	self:AddListenEvt(PVPEvent.PVP_PoringFightLaunch, self.HandlePoringFightLaunch);
	self:AddListenEvt(PVPEvent.PVP_PoringFightShutdown, self.HandlePoringFightShutdown);

	self:AddListenEvt(ServiceEvent.LoginUserCmdLoginResultUserCmd, self.ClearBuffCache);

	self:AddListenEvt(BoothEvent.ShowMiniBooth, self.HandleBooth)
	self:AddListenEvt(ServiceEvent.NUserBoothReqUserCmd, self.HandleBooth)
	self:AddListenEvt(ServiceUserProxy.RecvLogin, self.HandleReconnect)
end

function MainViewInfoPage:HandleEnterMvp(note)
	self:UpdateCurrentLine(true);
end

function MainViewInfoPage:HandleExitMvp(note)
	self:UpdateCurrentLine(false);
end

function MainViewInfoPage:ClearBuffCache()
	TableUtility.ArrayClear(recall_buffmap);
	self:ResetBuffData();
end

-- SysInfo Begin
local tempColor = LuaColor.New(1,1,1,1);
function MainViewInfoPage:UpdateSysInfo()
	TimeTickManager.Me():ClearTick(self, 1)
	TimeTickManager.Me():CreateTick(0,1000,function ()
		self.sysTimeLab.text = ClientTimeUtil.GetNowHourMinStr()
		local btvalue = ExternalInterfaces.GetSysBatteryPct()/100;
		self.batterySlider.value = btvalue;
		if(btvalue<=0.1)then
			tempColor:Set(173/255,0/255,0/255,1);
			self.batterySlider_Foreground.color = tempColor;
		else
			tempColor:Set(1,1,1,1);
			self.batterySlider_Foreground.color = tempColor;
		end
		
		local isCharge = ExternalInterfaces.GetSysBatteryIsCharge();
		self.battery_IsCharge:SetActive(isCharge);
		
	end, self, 1)
end
-- SysInfo end


-- SceneMap Name begin
local MapManager = Game.MapManager;
function MainViewInfoPage:HandleSceneMapName(note)
	if(MapManager:IsRaidMode())then
		local mapid = MapManager:GetMapID();
		-- 无限塔显示层数
		local raidData = Table_MapRaid[mapid];
		if(raidData)then
			if(raidData.Type == FunctionDungen.EndlessTowerType)then
				self:Show(self.sceneMapName);
				self.sceneMapName.text = Game.MapManager:GetMapName();
				return;
			elseif(raidData.Type == FunctionDungen.DojoType)then
				self:Show(self.sceneMapName);
				self.sceneMapName.text = raidData.NameZh;
				return;
			end
		end
	end

	self:Hide(self.sceneMapName);
end
-- Scene Name End

-- ExpJob Slider begin
function MainViewInfoPage:UpdateExpSlider(note)
	if(not self.roleSlider)then
		self.roleSlider = self:FindComponent("BaseExpSlider", UISlider);
	end

	local userdata = Game.Myself.data.userdata;
	local roleExp = userdata:Get(UDEnum.ROLEEXP);
	local nowrolelv = userdata:Get(UDEnum.ROLELEVEL);
	
	if(nowrolelv)then
		local upExp = 1;
		if(Table_BaseLevel[nowrolelv+1]~=nil)then
			upExp = Table_BaseLevel[nowrolelv+1].NeedExp
		end
		self.roleSlider.value = roleExp/upExp;
	end
end

local tempColor = LuaColor(1,1,1,1);
function MainViewInfoPage:UpdateJobSlider(note)
	if(not self.jobSlider)then
		self.jobSlider = self:FindComponent("JobExpSlider", UISlider);
	end
	local userdata = Game.Myself.data.userdata;
	local jobExp = userdata:Get(UDEnum.JOBEXP);
	local nowJobLevel = userdata:Get(UDEnum.JOBLEVEL);

	if(nowJobLevel)then
		local referenceValue = Table_JobLevel[nowJobLevel+1];
		referenceValue = referenceValue==nil and 1 or referenceValue.JobExp
		self.jobSlider.value = jobExp/referenceValue;

		if(not self.jobSliderSps)then
			self.jobSliderSps = {};
			local jobBg = self:FindGO("JobBg");
			for i=1,9 do
				table.insert(self.jobSliderSps, self:FindComponent(tostring(i), UISprite, jobBg)) ;
			end
		end
		for i=1,#self.jobSliderSps do
			local sp = self.jobSliderSps[i];
			if(self.jobSlider.value >= i * 0.1)then
				sp.color = tempColor;
			else
				sp.color = tempColor;
			end
		end
	end
end
-- ExpJob Slider end


-- function MainViewInfoPage:HandleBattlePointChange(note)
-- 	if(self.battlePoint and note.body)then
-- 		local delta = note.body-self.battlePoint;
-- 		if(delta>0)then
-- 			MsgManager.ShowMsgByIDTable(45, {note.body});
-- 		end
-- 		self.battlePoint = note.body;
-- 	end
-- end


-- Buff Begin
function MainViewInfoPage:AddRoleBuff(note)
	local ids = note.body;
	if(ids == nil)then
		return;
	end

	for i=1,#ids do
		self:UpdateBuffData(ids[i]);
	end

	self:ResetBuffData();
end

function MainViewInfoPage:UpdateBuffData(recv_buffdata)
	local id = recv_buffdata.id;

	if(RECALL_BUFF_REFLECT_MAP[id])then
		self:UpdateBuffData_RecallBuffer(recv_buffdata);
		return;
	end

	local configData = Table_Buffer[id];
	if(configData == nil)then
		return;
	end

	local betype = configData.BuffEffect.type;
	if(betype == "HPStorage" or betype == "SPStorage")then
		self:UpdateStorageBuffer(recv_buffdata);
		return;
	end

	if(configData.BuffIcon == nil or configData.BuffIcon == "")then
		return;
	end

	local buffData = self.buffDatas[id];
	if(buffData == nil)then
		buffData = {
			id = id,
			staticData = configData,
		};
		self.buffDatas[id] = buffData;
	end

	buffData.layer = recv_buffdata.layer;
	buffData.fromname = recv_buffdata.fromname;
	buffData.active = recv_buffdata.active;

	buffData.isEquipBuff = recv_buffdata.isEquipBuff;

	buffData.isalways = recv_buffdata.isalways;

	if(not buffData.isalways)then
		if(configData.IconType and configData.IconType == 1)then
			if(recv_buffdata.time and recv_buffdata.time~=0)then
				if(not buffData.endtime or buffData.endtime~=recv_buffdata.time)then
					buffData.starttime = ServerTime.CurServerTime();
				end
				buffData.endtime = recv_buffdata.time;
			end
		end
	end

	self.buffDatas[id] = buffData;
end


local STORAGE_FAKE_ID = "storage_fake_id";
function MainViewInfoPage:UpdateStorageBuffer(recv_buffdata)
	local id, layer = recv_buffdata.id, recv_buffdata.layer or 0;

	local fakeBuff = self.buffDatas[ STORAGE_FAKE_ID ];
	if(layer > 0)then
		if(fakeBuff == nil)then
			fakeBuff = {
				id = STORAGE_FAKE_ID,
				storage = {},
			};
			self.buffDatas[ STORAGE_FAKE_ID ] = fakeBuff;
		end
		local etype = Table_Buffer[id].BuffEffect.type;
		local storage;
		if(etype == "HPStorage")then
			storage = fakeBuff.storage[1];
			if(storage == nil)then
				storage = {id};
				fakeBuff.storage[1] = storage;
			end
		elseif(etype == "SPStorage")then
			storage = fakeBuff.storage[2];
			if(storage == nil)then
				storage = {id};
				fakeBuff.storage[2] = storage;
			end
		end
		storage[2] = layer;
	else
		if(fakeBuff ~= nil)then
			local etype = Table_Buffer[id].BuffEffect.type;
			local storage;
			if(etype == "HPStorage")then
				fakeBuff.storage[1] = nil;
			elseif(etype == "SPStorage")then
				fakeBuff.storage[2] = nil;
			end
			if(not next(fakeBuff.storage))then
				fakeBuff = nil;
				self.buffDatas[ STORAGE_FAKE_ID ] = nil;
			end
		end
	end
end

-- 处理冒险者回归Buff
function MainViewInfoPage:UpdateBuffData_RecallBuffer(recv_buffdata)
	local id, layer = recv_buffdata.id, recv_buffdata.layer;

	local maxlayer = RECALL_BUFF_REWARD_MAP[id][1];
	if(layer == 0)then
		recall_buffmap[id] = nil;
	else
		recall_buffmap[id] = layer;
	end

	self:UpdateBuffData_RecallBuffer_Reflect(RECALL_BUFF_REFLECT_MAP[id]);
end

function MainViewInfoPage:UpdateBuffData_RecallBuffer_Reflect(reflectid)
	if(reflectid == nil)then
		return;
	end

	local has_recallBuff = false;
	local tk,_ = next(recall_buffmap);
	if(tk ~= nil)then
		has_recallBuff = true;
	end

	if(has_recallBuff == false)then
		if(self.buffDatas[reflectid] ~= nil)then
			self.buffDatas[reflectid] = nil;
		end
	else
		local configData = Table_Buffer[reflectid];
		if(configData == nil)then
			return;
		end

		if(self.buffDatas[reflectid] == nil)then
			local reflect_buffData = {};
			reflect_buffData.id = reflectid;
			reflect_buffData.staticData = configData;

			reflect_buffData.isRecallBuff = true;
			reflect_buffData.isalways = true;

			self.buffDatas[reflectid] = reflect_buffData;
		end
	end
end

function MainViewInfoPage:RemoveRoleBuff(note)
	local ids = note.body or {};

	local t_buffer = Table_Buffer;
	for i=1,#ids do
		local id = ids[i];

		if(RECALL_BUFF_REFLECT_MAP[id])then
			self:UpdateBuffData_RecallBuffer_Reflect(RECALL_BUFF_REFLECT_MAP[id]);
		else
			local config = t_buffer[id];
			local betype
			if(config ~= nil and config.BuffEffect ~= nil)then
				betype = config.BuffEffect.type;
			end
			if(betype == "HPStorage" or betype == "SPStorage")then
				self:UpdateStorageBuffer( {id = id, layer = 0} );
			else
				self.buffDatas[id] = nil;
			end
		end
	end

	self:ResetBuffData();
end

function MainViewInfoPage._SortBuffData( a, b )
	if(a.isalways~=nil or b.isalways~=nil)then
		return a.isalways == true;
	end
	if(a.id == STORAGE_FAKE_ID or b.id == STORAGE_FAKE_ID)then
		return a.id == STORAGE_FAKE_ID ;
	end
	local aBuffCfg = Table_Buffer[a.id];
	local bBuffCfg = Table_Buffer[b.id];
	if(aBuffCfg and bBuffCfg)then
		local aIsDeBuff = aBuffCfg.BuffType.isgain == 0;
		local bIsDeBuff = bBuffCfg.BuffType.isgain == 0;
		if(aIsDeBuff~=bIsDeBuff)then
			return aIsDeBuff;
		end
		if(aBuffCfg.IconType and bBuffCfg.IconType)then
			if(aBuffCfg.IconType~=bBuffCfg.IconType)then
				return aBuffCfg.IconType > bBuffCfg.IconType;
			end
			if(aBuffCfg.IconType == 1 and bBuffCfg.IconType == 1)then
				if(a.endtime and b.endtime)then
					if(a.endtime and b.endtime)then
						return a.endtime > b.endtime;
					end
				end
			end
		end
	end
	return a.id<b.id;
end

function MainViewInfoPage:ResetBuffData()
	TableUtility.ArrayClear(self.buffListDatas);
	for _,bData in pairs(self.buffDatas)do
		table.insert(self.buffListDatas, bData);
	end
	table.sort(self.buffListDatas, MainViewInfoPage._SortBuffData)
	
	local limit = 10
	if(#self.buffListDatas>limit)then
		for i=#self.buffListDatas,limit+1,-1 do
			table.remove(self.buffListDatas, i);
		end
	end
	self.buffCtl:ResetDatas(self.buffListDatas);
	self.buffgrid.enabled = true;
end
-- Buff end



function MainViewInfoPage:HandleAddWeakDialog(note)
	table.insert(self.weak_dialog_queue, note.body);

	if(#self.weak_dialog_queue == 1)then
		self:PlayWeakDialog();
	end
end

function MainViewInfoPage:HandleWeakDialogHide(data)
	table.remove(self.weak_dialog_queue, 1)
	
	self:PlayWeakDialog();
end

function MainViewInfoPage:PlayWeakDialog()
	if(self.weak_dialog_queue[1] == nil)then
		return;
	end

	if(not self.weakDialogCell)then
		local obj = self:LoadPreferb("cell/WeakDialogCell", self.weakDialogBord)
		self.weakDialogCell = WeakDialogCell.new(obj);
		self.weakDialogCell:AddEventListener(WeakDialogEvent.Hide, self.HandleWeakDialogHide, self);
	end
	
	self.weakDialogCell:Show();
	self.weakDialogCell:SetData(self.weak_dialog_queue[1]);
end


local PoringFight_ForbidView = { 1,4,181,320,400,101,480,520,720,920,83,11,351,352,354 };
function MainViewInfoPage:HandlePoringFightLaunch(note)
	for i=1,#PoringFight_ForbidView do
		UIManagerProxy.Instance:SetForbidView(PoringFight_ForbidView[i], 3606, true);
	end

	self.fullProgress:SetActive(false);
	self.skillAssist:SetActive(false);
	self.autoBattleButton:SetActive(false);
end

function MainViewInfoPage:HandlePoringFightShutdown(note)
	for i=1,#PoringFight_ForbidView do
		UIManagerProxy.Instance:UnSetForbidView(PoringFight_ForbidView[i]);
	end

	self.fullProgress:SetActive(true);
	self.skillAssist:SetActive(true);
	self.autoBattleButton:SetActive(true);
end





-- gvg决战 争夺区域 UI信息 begin
function MainViewInfoPage:InitGvgDroiyanTriggerInfo()
	-- map Event
	self:AddListenEvt(TriggerEvent.Enter_GDFightForArea, self.HandleEnterGDFightforArea);
	self:AddListenEvt(TriggerEvent.Leave_GDFightForArea, self.HandleLeaveOrRemoveGDFightforArea);
	self:AddListenEvt(TriggerEvent.Remove_GDFightForArea, self.HandleLeaveOrRemoveGDFightforArea);
end

function MainViewInfoPage:GetGvgDroiyanOccupyInfoCell()
	if(self.gvg_OccupyInfoCell ~= nil)then
		return self.gvg_OccupyInfoCell;
	end
	local obj = self:LoadPreferb("cell/GvgDroiyan_OccupyInfoCell", self.gameObject)

	if(GvgDroiyan_OccupyInfoCell == nil)then
		autoImport("GvgDroiyan_OccupyInfoCell");
	end

	self.gvg_OccupyInfoCell = GvgDroiyan_OccupyInfoCell.new(obj);
	return self.gvg_OccupyInfoCell;
end

function MainViewInfoPage:HandleEnterGDFightforArea(note)
	local id = note.body;
	if(id == nil)then
		return;
	end

	local occupyInfoCell = self:GetGvgDroiyanOccupyInfoCell();
	occupyInfoCell:SetData(id);
end

function MainViewInfoPage:HandleLeaveOrRemoveGDFightforArea(note)
	local occupyInfoCell = self:GetGvgDroiyanOccupyInfoCell();
	occupyInfoCell:HideSelf();
end
-- gvg决战 争夺区域 UI信息 begin


-- 摆摊
function MainViewInfoPage:HandleBooth(note)
	local data = note.body
	if type(data) == "table" then
		self.boothBtn:SetActive(data.oper == BoothProxy.OperEnum.Open)
	else
		self.boothBtn:SetActive(data)
	end
end

function MainViewInfoPage:HandleReconnect(note)
	if Game.Myself:IsInBooth() then
		BoothProxy.Instance:ClearMyselfBooth()
	end
end