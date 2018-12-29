baseCell = autoImport("BaseCell");
NpcMenuBtnCell = class("NpcMenuBtnCell",baseCell);

-- 添加新手引导
NpcMenuBtnCell.GuideType = {
	VarietyShop = 10,
	HeadShop = 18,
	PicMake = 21,
	AdventureSkill = 37,
}

NpcMenuBtnCell.Style = {
	Primary = 1, 
	Second = 2,
	Normal = 3,
	Grey = 4,
}

function NpcMenuBtnCell:Init()
	self.bg = self:FindComponent("Bg", UIMultiSprite);
	self.icon = self:FindComponent("Icon", UIMultiSprite);
	self.label = self:FindComponent("Label", UILabel);
	self.contentTip = self:FindGO("ContentTip");
	self.contentLabel = self:FindComponent("ContentLabel", UILabel);
	self.button = self:FindGO("Button");

	self.multiplySymbol = self:FindGO("MultiplySymbol");
	--todo xde 
--	self.multiplySymbol_label = self:FindComponent("Label", UILabel, self.multiplySymbol.gameObject);
	self.multiplySymbol_label = self:FindGO("muLabel"):GetComponent(UILabel);
	helplog(self.multiplySymbol_label)
--	 self:AddCellClickEvent();

	self:SetEvent(self.button, function ()
		if(self.style ~= NpcMenuBtnCell.Style.Grey)then
			self:PassEvent(MouseEvent.MouseClick, self);
		end
	end);

	local longPress = self.button:GetComponent(UILongPress)
	longPress.pressEvent = function ( obj,state )
		if not self.isContentToLong then
			self:TriggerContentTip(state)
		end
	end
end

-- type name staticData
function NpcMenuBtnCell:SetData(data)
	--todo xde
	self:AddOrRemoveGuideId(self.button)

	self.data = data;
	local menuType, name = data.menuType, data.name;
	self.content = tostring( name )
	self.label.text = self.content
	self.isContentToLong = UIUtil.WrapLabel(self.label)

	local style = NpcMenuBtnCell.Style.Normal;
	if(menuType == Dialog_MenuData_Type.NpcFunc)then
		style = NpcMenuBtnCell.Style.Normal;

		if(data.key)then
			local guideId = NpcMenuBtnCell.GuideType[data.key];
			if( guideId )then
				self:AddOrRemoveGuideId(self.button, guideId); --todo xde
			end

			self:UpdateStorehouseBagNum(data.key);
		end
	elseif(menuType == Dialog_MenuData_Type.Task)then
		local task = data.task;
		if(task.type == QuestDataType.QuestDataType_MAIN or task.type == QuestDataType.QuestDataType_WANTED)then
			style = NpcMenuBtnCell.Style.Primary;
		elseif(task.type == QuestDataType.QuestDataType_BRANCH)then
			style = NpcMenuBtnCell.Style.Second;
		else
			style = NpcMenuBtnCell.Style.Normal;
		end
	elseif(menuType == Dialog_MenuData_Type.Option)then
		style = NpcMenuBtnCell.Style.Normal;
	elseif(menuType == Dialog_MenuData_Type.CustomFunc)then
		style = NpcMenuBtnCell.Style.Normal;
	end

	if(data.state == NpcFuncState.InActive)then
		self.gameObject:SetActive(false);
	else
		self.gameObject:SetActive(true);
		if(data.state == NpcFuncState.Grey)then
			style = NpcMenuBtnCell.Style.Grey;
		end
	end

	self:SetStyle( style );

	self:UpdateMultiplyInfo();
end


local tempColor = LuaColor.New(1,1,1,1);
local tempV3 = LuaVector3();
function NpcMenuBtnCell:SetStyle( style )
	if(style ~= self.style)then
		self.style = style;

		if(style == NpcMenuBtnCell.Style.Primary)then
			self.bg.CurrentState = 1;
			tempColor:Set(1,1,1,1);
			self.bg.color = tempColor;

			tempColor:Set(170/255, 94/255, 2/255, 1);
			self.label.effectColor = tempColor;

			self:ActiveIcon(true, 0);
		elseif(style == NpcMenuBtnCell.Style.Second)then
			self.bg.CurrentState = 0;
			tempColor:Set(1,1,1,1);
			self.bg.color = tempColor;

			tempColor:Set(48/255, 65/255, 147/255, 1);
			self.label.effectColor = tempColor;

			self:ActiveIcon(true, 1);
		elseif(style == NpcMenuBtnCell.Style.Normal)then
			self.bg.CurrentState = 0;
			tempColor:Set(1,1,1,1);
			self.bg.color = tempColor;

			tempColor:Set(48/255, 65/255, 147/255, 1);
			self.label.effectColor = tempColor;

			self:ActiveIcon(false);
		elseif(style == NpcMenuBtnCell.Style.Grey)then
			self.bg.CurrentState = 0;
			tempColor:Set(1/255,2/255,3/255,1);
			self.bg.color = tempColor;

			tempColor:Set(177/255, 177/255, 177/255, 1);
			self.label.effectColor = tempColor;

			self:ActiveIcon(false);
		end
	end
end

function NpcMenuBtnCell:ActiveIcon(b, state)
	if(b)then
		self.icon.gameObject:SetActive(true);
		if(state)then
			self.icon.CurrentState = state;
		end
		self.icon:UpdateAnchors();

		tempV3:Set(10, 6, 0);
		self.label.transform.localPosition = tempV3;
	else
		self.icon.gameObject:SetActive(false);

		tempV3:Set(0, 6, 0);
		self.label.transform.localPosition = tempV3;
	end
end

function NpcMenuBtnCell:UpdateStorehouseBagNum(type)
	if(not self.storehouseNum)then
		self.storehouseNum = self:FindComponent("BagNum", UILabel);
	end

	if(type == storehouse)then
		local repBag = BagProxy.Instance.repositoryBag;
		local uplimit = repBag:GetUplimit();

		local items = repBag:GetItems();
		self.storehouseNum.gameObject:SetActive(true);
		self.storehouseNum.text = #items.."/"..uplimit;

		-- if(uplimit > 0)then
		-- 	local items = repBag:GetItems();
		-- 	if(#items > uplimit)then
		-- 		self.storehouseNum.gameObject:SetActive(true);
		-- 		self.storehouseNum.text = #items.."/"..uplimit;
		-- 	else
		-- 		self.storehouseNum.gameObject:SetActive(false);
		-- 	end
		-- else
		-- 	self.storehouseNum.gameObject:SetActive(false);
		-- end
	else
		self.storehouseNum.gameObject:SetActive(false);
	end
end

local NpcFunction_Multiply_RewardMap = 
{
	[1000] = AERewardType.Tower, 
	[1100] = AERewardType.Laboratory,

	[4015] = AERewardType.GuildRaid,	--公会副本
	[1450] = AERewardType.GuildDojo, --公会道场
	[10002] = AERewardType.PveCard, -- 卡牌副本
}
function NpcMenuBtnCell:UpdateMultiplyInfo()
	local data = self.data;
	if(data == nil or data.npcFuncData == nil)then
		self.multiplySymbol:SetActive(false);
		return;
	end

	local typeid = data.npcFuncData.id;
	local rewardType = NpcFunction_Multiply_RewardMap[typeid];
	if(rewardType == nil)then
		self.multiplySymbol:SetActive(false);
		return;
	end

	local rewardInfo = ActivityEventProxy.Instance:GetRewardByType(rewardType);
	if(rewardInfo == nil)then
		self.multiplySymbol:SetActive(false);
		return;
	end

	local multiply = rewardInfo:GetMultiple() or 1;
	if(multiply > 1)then
		self.multiplySymbol_label.text = "*" .. multiply;
		self.multiplySymbol:SetActive(true);
	else
		self.multiplySymbol:SetActive(false);
	end
end

function NpcMenuBtnCell:TriggerContentTip( isShow )
	if isShow then
		self.contentTip:SetActive(true)
		self.contentLabel.text = self.content
	else
		self.contentTip:SetActive(false)
	end
end
