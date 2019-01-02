autoImport("TipFormulaCell")
autoImport("ItemTipBaseCell");
ItemFormulaTip = class("ItemFormulaTip", ItemTipBaseCell);

FormulaGainPos = {
	Left = Vector3(-702,0,0),
	Right = Vector3(-45,330,0),
}

-- function ItemFormulaTip:ctor(obj, index)
-- 	ItemFormulaTip.super.ctor(self, obj);
-- 	self.index = index;
-- end


function ItemFormulaTip:Init()
	self.formulaScrollView=self:FindComponent("formulaScrollView",UIScrollView);
	self.mainScrollView=self:FindComponent("ScrollView",UIScrollView);
	self.formulaMainMenu=self:FindGO("mainMenu");
	self.mainMenuDes=self:FindComponent("MainMenuDes",UILabel);
	self.formulaBgImg=self:FindGO("formulaBg");
	self.formulaTable = self:FindComponent("ctl",UITable);
	self.closecomp = self.gameObject:GetComponent(CloseWhenClickOtherPlace);
	self.root = GameObjectUtil.Instance:FindCompInParents(self.gameObject, UIRoot);
	self.menu=self:FindGO("menu");
	self.menuDes=self:FindComponent("menuDes",UILabel);
	self.gpContainer = self:FindGO("GetPathContainer");
	self:AddEventListener(ItemTipEvent.ShowGetPath, self.ShowGetPath, self);
	self.closecomp.callBack = function (go)
		self:CloseSelf();
	end
	ItemFormulaTip.super.Init(self);
	
	--todo xde 
	OverseaHostHelper:FixLabelOverV1(self.mainMenuDes,3,350)
end


function ItemFormulaTip:ShowGetPath(cell)
	if(cell and cell.gameObject)then
		if(not self.bdt)then
			local rootPos = self.root.transform:InverseTransformPoint(cell.gameObject.transform.position); 
			self.gpContainer.transform.localPosition = rootPos.x>0 and FormulaGainPos.Left or FormulaGainPos.Right;
			local data = cell.data;
			if(data and data.staticData)then
				self.bdt = GainWayTip.new(self.gpContainer)
				self.bdt:SetData(data.staticData.id);
				self.bdt:AddEventListener(ItemEvent.GoTraceItem, function ()
					self:CloseSelf();
				end, self);
				self.bdt:AddIgnoreBounds(self.gameObject);
				self:AddIgnoreBounds(self.bdt.gameObject);

				self.bdt:AddEventListener(GainWayTip.CloseGainWay, function ()
					self.closecomp:ReCalculateBound();
					self.bdt = nil;
				end, self);
			end
		else
			self.bdt:OnExit();
		end
	end
end

function ItemFormulaTip:SetPos(pos)
	if(self.gameObject~=nil) then
		local p = self.gameObject.transform.position
		pos.z = p.z
		self.gameObject.transform.position = pos
		-- TipsView.Me().panel:ConstrainTargetToBounds(self.gameObject.transform,true)
	else
		self.pos = pos
	end 
end

function ItemFormulaTip:SetData(Itemdata)
	ItemFormulaTip.super.SetData(self,Itemdata);
	self:GetFormula(Itemdata.staticData)
	self:SetFormulaMenu(Itemdata.staticData.id)
	self:ShowMainMenu(self:GetMainMenuDes(Itemdata.staticData.id));
end

function ItemFormulaTip:GetMainMenuDes(id)
	local des =nil;
	local bUnlock = AdventureDataProxy.Instance:checkShopItemIsUnlock(id)
	if(not bUnlock)then
		des = AdventureDataProxy.Instance:GetMenuDesById(id);
	end
	return des;
end

-- toy&hair unlock 
function ItemFormulaTip:ShowMainMenu(menuDes)
	if(menuDes)then
		self:Show(self.formulaMainMenu)
		self.mainMenuDes.text=menuDes;
		self.mainScrollView.enabled=false;
	else
		self.mainScrollView.enabled=true;
		self:Hide(self.formulaMainMenu)
	end
end


function ItemFormulaTip:SetFormulaMenu(staticID)
	local menuDes;
	local menuID = 0;
	for k,v in pairs(Table_Compose) do
		if(v.Product.id==staticID and v.MenuID)then
			menuID=v.MenuID;
			local result = FunctionUnLockFunc.Me():CheckCanOpen(menuID);
			if(not result)then
				menuDes=v.MenuDes;
				self:ShowFormulaMenu(menuDes);
				return;
			end
		end
	end
	self.formulaScrollView.enabled=true;
	self:Hide(self.menu);
end


function ItemFormulaTip:ShowFormulaMenu(menuDes)
	if(menuDes and menuDes~="")then
		self:Show(self.menu);
		self.menuDes.text=menuDes;
		self.formulaScrollView.enabled=false;
	else
		self.formulaScrollView.enabled=true;
		self:Hide(self.menu);
	end
end


function ItemFormulaTip:OpenFormula(bShow)
	if(Show)then
		self:Show(self.formulaScrollView.gameObject);
		self:Show(self.formulaBgImg);
	else
		self:Hide(self.formulaScrollView.gameObject);
		self:Hide(self.formulaBgImg);
	end
end


function ItemFormulaTip:InitAttriContext()
	ItemFormulaTip.super.InitAttriContext(self);
	self.formulaCtl = UIGridListCtrl.new(self.formulaTable,TipFormulaCell,"TipFormulaCell");
	self.formulaData={};
end


--显示升级装备的所需材料
function ItemFormulaTip:LevelUpFormula(data)
	self.formulaData={};
	for k,value in pairs(Table_EquipUpgrade) do
		local mtTemp={}
		if(value.Product and value.Product==data.id)then
			local originalEquip = Table_Item[value.id] and Table_Item[value.id].NameZh
			if(nil==originalEquip)then
				helplog("查找原始装备失败未在Item表中找到，id： "..tostring(value.id))
				return
			end
			mtTemp.originalId=value.id;
			mtTemp.title=string.format(ZhString.Formula_LvUpFrom,originalEquip)
			local tipTab = {}
			local temp = "Material_"
			for k,va in pairs(value) do
				local tips=nil;
				if(string.match(k,temp))then
					tem=string.sub(k,-1);
					if(nil~=tem and #va>0)then
						local a = StringUtil.IntToRoman(tonumber(tem));
						local str = string.format(ZhString.Fromula_format,StringUtil.IntToRoman(tonumber(tem)))
						if(nil==tips)then
							tips=str
						else
							tips=tips.."\n"..str
						end
						for _,v in pairs(va) do
							tips=tips.."\n"..self:_formatMaterial(v.id,v.num)
						end
						tipTab[tonumber(tem)]=tips;
					end
				end
			end
			local t
			local max = StringUtil.IntToRoman(#tipTab);
			for i,v in ipairs(tipTab) do
				if(nil==t)then
					t=v
				elseif(i==#tipTab)then
					local endStr = string.gsub(v,max,ZhString.Formula_End);
					t=t.."\n\n"..endStr;
				else
					t=t.."\n\n"..v;
				end
			end
			mtTemp.mtText=t
			table.insert(self.formulaData,mtTemp);
		end
	end
	table.sort(self.formulaData, function (l,r)
				return self:SortFunc(l,r)
			end )
end

function ItemFormulaTip:SortFunc(left,right)
	if(left == nil) then 
		return false
	elseif(right ==nil) then 
		return true
	end
	return left.originalId<right.originalId
end


--制作装备
function ItemFormulaTip:GetFormula(data)
	if (not data) then return end
	self.formulaData= {}
	
	for k,v in pairs(Table_Compose) do
		if(v.Category and v.Category==1 and v.Product and v.Product.id==data.id and v.BeCostItem)then
			local mtTemp={}
			local tips;
			for key,value in pairs(v.BeCostItem) do
				if(nil==tips)then
					tips=self:_formatMaterial(value.id,value.num);
				else
					tips=tips.."\n"..self:_formatMaterial(value.id,value.num);
				end
			end
			mtTemp.title=ZhString.Formula_Make;
			mtTemp.mtText=tips
			table.insert(self.formulaData,mtTemp);
		end
	end
	if(self.formulaData and #self.formulaData>0) then self:ShowFormula() return end --是制作装备的话肯定不是升级来的
	self:LevelUpFormula(data)
	self:ShowFormula()
end

function ItemFormulaTip:_formatMaterial(id,count)
	local itemName = Table_Item[id] and Table_Item[id].NameZh;
	local itemOwned = BagProxy.Instance:GetItemByStaticID(id);
	itemOwned=itemOwned and itemOwned.num or 0;
	return string.format(ZhString.Formula_Tips , itemName , itemOwned , count)
end


-- 制作／升级配方
function ItemFormulaTip:ShowFormula()
	if(self.formulaData and #self.formulaData>0)then
		self.formulaCtl:ResetDatas(self.formulaData);
	else
		self:Hide(self.formulaBgImg)
		self:Hide(self.formulaScrollView)
	end
end

function ItemFormulaTip:AddIgnoreBounds(obj)
	if(self.gameObject and self.closecomp)then
		self.closecomp:AddTarget(obj.transform);
	end
end


function ItemFormulaTip:CloseSelf()
	self:Exit()
	if(not self:ObjIsNil(self.gameObject))then
		GameObject.Destroy(self.gameObject)
		TipManager.Instance.formularTip=nil;
	end
end




