autoImport("BaseTip")
PetAdventureEffTip = class("PetAdventureEffTip", BaseTip)
local funDesc = "(宠物等级+好感度)*地图适应"

function PetAdventureEffTip:Init()
	self:FindObj()
	self:InitData()
end

function PetAdventureEffTip:InitData()
	self.contextDatas = {};
	self.funcDesc.text = GameConfig.PetAdventureMinLimit.funDesc or funDesc
end

function PetAdventureEffTip:FindObj()
	self.closecomp = self.gameObject:GetComponent(CloseWhenClickOtherPlace);
	local table = self:FindComponent("Table", UITable);
	self.funcDesc = self:FindComponent("funcDesc",UILabel)
	self.attriCtl = UIGridListCtrl.new(table, TipLabelCell, "TipLabelCell");
	self.closecomp.callBack = function (go)
		self:CloseSelf();
	end
	PetAdventureEffTip.super.Init(self);
	
	--todo xde fix ui
	self.funcDesc.pivot = UIWidget.Pivot.Top
	self.funcDesc.overflowMethod = 3;
	
	self.MainWidget = self:FindGO("Main"):GetComponent(UIWidget)
	self.MainWidget.topAnchor.target =  self.funcDesc.gameObject.transform
	self.MainWidget.topAnchor.relative = 0
	self.MainWidget.topAnchor.absolute = -10
	end

--args[1]  refine
--args[2]  enchant
--args[3]  adventureTitle
--args[4]  Astrolabe
--args[5]  headwear
--args[6]  card
local args = {}
local maxFlag = "(Max)"
function PetAdventureEffTip:SetData(data)
	local data = data.itemdata
	local maxEffConfig = data.maxEffConfig
	self.data=data
	if(not self.data)then return end
	local strFormat = string.format
	local mathFloor = math.floor
	TableUtility.TableClear(self.contextDatas);

	-- local FuncDescTip = {};
	-- FuncDescTip.label = {};
	-- FuncDescTip.hideline = true;
	-- local cell = "{uiicon=com_icon_mark} "..ZhString.PetAdventure_PetEffFunDesc;
	-- table.insert(FuncDescTip.label, strFormat(ZhString.PetAdventure_TipColor,cell));
	-- self.contextDatas[#self.contextDatas+1] = FuncDescTip;

	for i=1,#self.data do
		local petTip = {};
		local cellData = self.data[i]
		args[7] = mathFloor(cellData.lv*1000)*0.1
		args[7] = maxEffConfig[7] and args[7].."%"..maxFlag or args[7].."%"
		args[8] = mathFloor(cellData.flv*1000)*0.1
		args[8] = maxEffConfig[8] and args[8].."%"..maxFlag or args[8].."%"
		args[9] = mathFloor(cellData.area*1000)*0.1
		args[9] = maxEffConfig[9] and args[9].."%"..maxFlag or args[9].."%"
		local lab = strFormat(ZhString.PetAdventure_PetEffTips,cellData.name,args[7],args[8],args[9])
		petTip.label = strFormat(ZhString.PetAdventure_TipColor,lab)
		petTip.hideline = true;
		self.contextDatas[#self.contextDatas+1] = petTip;
	end

	if(self.data.role)then
		local roletip = {}
		local data = self.data.role
		args[1] = mathFloor(data.refineEff*1000)*0.1
		args[1] = maxEffConfig[1] and args[1].."%"..maxFlag or args[1].."%"
		args[2] = mathFloor(data.enchantEff*1000)*0.1
		args[2] = maxEffConfig[2] and args[2].."%"..maxFlag or args[2].."%"
		args[3] = mathFloor(data.AstrolabeEff*1000)*0.1 
		args[3] = maxEffConfig[3] and args[3].."%"..maxFlag or args[3].."%"
		args[4] = mathFloor(data.adventureTitleEff*1000)*0.1
		args[4] = maxEffConfig[4] and args[4].."%"..maxFlag or args[4].."%"
		args[5] = mathFloor(data.cardEff*1000)*0.1
		args[5] = maxEffConfig[5] and args[5].."%"..maxFlag or args[5].."%"
		args[6] = mathFloor(data.headwearEff*1000)*0.1
		args[6] = maxEffConfig[6] and args[6].."%"..maxFlag or args[6].."%"
		local lab = strFormat(ZhString.PetAdventure_RoleTip,args[1],args[2],args[3],args[4],args[5],args[6])
		roletip.label = strFormat(ZhString.PetAdventure_TipColor,lab)
		roletip.hideline = true;
		self.contextDatas[#self.contextDatas+1] = roletip;
	end
	self.attriCtl:ResetDatas(self.contextDatas);
end

function PetAdventureEffTip:AddIgnoreBounds(obj)
	if(self.gameObject and self.closecomp)then
		self.closecomp:AddTarget(obj.transform);
	end
end

function PetAdventureEffTip:CloseSelf()
	if(self.callback)then
		self.callback(self.callbackParam);
	end
	TipsView.Me():HideCurrent();
end

function PetAdventureEffTip:DestroySelf()
	if(not Slua.IsNull(self.gameObject))then
		GameObject.Destroy(self.gameObject);
	end	
end
