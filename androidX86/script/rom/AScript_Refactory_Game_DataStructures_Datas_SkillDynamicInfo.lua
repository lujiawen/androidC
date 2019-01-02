SkillDynamicInfo = class("SkillDynamicInfo")

function SkillDynamicInfo:ctor()
	--cost
	self.costs = nil
	--like role props
	self.props = nil
	--影响范围
	self.targetRange = 0
	--改变技能目标数量
	self.targetNumChange = 0
	--readytime
	self.changeready = 0

	self._hasItemCostChange = false
end

function SkillDynamicInfo:Server_SetProps(serverAttrs)
	if(self.props==nil) then
		self.props = RolePropsContainer.new()
	end
	local props = self.props
	local sdata
	for i = 1, #serverAttrs do
		sdata = serverAttrs[i]
		if sdata ~= nil then
			props:SetValueById(sdata.type,sdata.value)
		end
	end
end

function SkillDynamicInfo:Server_SetCosts(costs)
	if(self.costs==nil) then
		self.costs = {}
	end
	local cost,serverCost
	for i=1,#costs do
		serverCost = costs[i]
		cost = self.costs[serverCost.itemid]
		if(cost == nil) then
			cost = {}
			self.costs[serverCost.itemid] = cost
		end
		self._hasItemCostChange = true
		cost[1] = serverCost.itemid
		cost[2] = serverCost.changenum
		cost[3] = serverCost.changeper/1000
	end
end

function SkillDynamicInfo:Server_SetTargetRange( range )
	self.targetRange = range
end

function SkillDynamicInfo:GetTargetRange()
	return self.targetRange
end

function SkillDynamicInfo:Server_SetChangeReady( changeready )
	self.changeready = changeready/1000
end

function SkillDynamicInfo:GetChangeReady()
	return self.changeready
end

function SkillDynamicInfo:Server_SetTargetNumChange(change)
	self.targetNumChange = change
end

function SkillDynamicInfo:GetTargetNumChange()
	return self.targetNumChange
end

function SkillDynamicInfo:HasItemCostChange()
	return self._hasItemCostChange
end

function SkillDynamicInfo:GetItemNewCost(itemid,originCost)
	if(self.costs~=nil) then
		local cost = self.costs[itemid]
		if(cost) then
			return math.floor(math.max(0,(originCost+cost[2])*(1+cost[3])))
		end
	end
	return originCost
end