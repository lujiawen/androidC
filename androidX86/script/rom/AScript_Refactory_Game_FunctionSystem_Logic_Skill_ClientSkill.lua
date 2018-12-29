ClientSkill = class("ClientSkill", SkillBase)

local FindCreature = SceneCreatureProxy.FindCreature

function ClientSkill:ctor()
	ClientSkill.super.ctor(self)
	self.targetCreatureGUID = 0
	self.targetPosition = LuaVector3.zero
	self.allowInterrupted = false
	self.castTime = 0
	self.castTimeElapsed = 0
	self.random = 0
end

function ClientSkill:GetCastTime(creature)
	return self.castTime
end

function ClientSkill:Launch(targetCreature, targetPosition, creature)
	if nil == creature.data.randomFunc then
		return false
	end

	if nil ~= targetCreature then
		self.targetCreatureGUID = targetCreature.data.id
	else
		self.targetCreatureGUID = 0
	end

	local p = nil
	if nil ~= targetPosition then
		p = targetPosition
		self.phaseData:SetPosition(targetPosition)
		local angleY = VectorHelper.GetAngleByAxisY(creature:GetPosition(), targetPosition)
		self.phaseData:SetAngleY(angleY)
	else
		if nil ~= targetCreature and self.info:PlaceTarget(creature) then
			p = targetCreature:GetPosition()
		else
			p = creature:GetPosition()
		end
		self.phaseData:SetAngleY(nil)
	end
	self.targetPosition:Set(p[1], p[2], p[3])

	self.castTime, self.allowInterrupted = self.info:GetCastInfo(creature)
	--和后端有可能有精度误差，他们认为10毫秒以内就可以认为是顺发了
	if 0.01 < self.castTime then
		self:_SwitchToCast(creature)
	else
		self:_SwitchToAttack(creature)
	end
	return self.running, self.allowInterrupted
end

function ClientSkill:InterruptCast(creature)
	if self.running and self.phaseData:GetSkillPhase() == SkillPhase.Cast then
		self:End(creature)
	end
end

function ClientSkill:CheckTargetCreature(creature)
	local targetCreature = FindCreature(self.targetCreatureGUID)
	if nil == targetCreature then
		return false
	end

	local launchRange = self.info:GetLaunchRange(creature)
	if 0 < launchRange then
		local testRange = launchRange * 1.5
		local currentPosition = creature:GetPosition()
		local targetPosition = targetCreature:GetPosition()
		if VectorUtility.DistanceXZ(currentPosition, targetPosition) > testRange then
			return false
		end
	end

	return self.info:CheckTarget(creature, targetCreature)
end

function ClientSkill:_SetPhase(phase, creature)
	-- 1. 
	self:_Clear(creature)
	-- 2.
	self.phaseData:SetSkillPhase(phase)
end

function ClientSkill:_NotifyServer(creature)
	local phaseData = self.phaseData

	-- LogUtility.InfoFormat("<color=green>{0} Notify Skill: </color>{1}\n{2}", 
	-- 	creature.data and creature.data:GetName() or "No Name",
	-- 	phaseData:GetSkillID(),
	-- 	phaseData:GetSkillPhase())
	-- local targetCount = phaseData:GetTargetCount()
	-- local logString = LogUtility.StringFormat("Targets: {0}\n", targetCount)
	-- for i=1, targetCount do
	-- 	local guid, damageType, damage = phaseData:GetTarget(i)
	-- 	local targetCreature = SceneCreatureProxy.FindCreature(guid)
	-- 	logString = LogUtility.StringFormat("{0}{1}, {2}\n", 
	-- 		logString, 
	-- 		LogUtility.StringFormat("({0}, {1})", 
	-- 			targetCreature and targetCreature.data and targetCreature.data:GetName() or "Null", 
	-- 			guid),
	-- 		LogUtility.StringFormat("{0}, {1}", 
	-- 			damageType, 
	-- 			damage))
	-- end
	-- LogUtility.Info(logString)

	if SkillPhase.Attack == phaseData:GetSkillPhase() then
		local targetCount = phaseData:GetTargetCount()
		for i=1, targetCount do
			local guid,_,_ = phaseData:GetTarget(i)
			local targetCreature = SceneCreatureProxy.FindCreature(guid)
			if nil ~= targetCreature and nil ~= targetCreature.data then
				local targetCamp = targetCreature.data:GetCamp()
				if RoleDefines_Camp.ENEMY == targetCamp then
					creature:Logic_SetSkillState(guid)
					break
				end
			end
		end
	end

	creature:Client_UseSkillHandler(
		self.random, 
		phaseData, 
		self.targetCreatureGUID)
end

-- override begin
function ClientSkill:_OnLaunch(creature)
	ClientSkill.super._OnLaunch(self, creature)
	creature:Logic_OnSkillLaunch(self.info:GetSkillID())
end

function ClientSkill:_OnAttack(creature)
	ClientSkill.super._OnAttack(self, creature)
	creature:Logic_OnSkillAttack(self.info:GetSkillID())
end

function ClientSkill:SetSkillID(skillID)
	self.phaseData:Reset(skillID)
	ClientSkill.super.SetSkillID(self, skillID)
end

function ClientSkill:_SwitchToCast(creature)
	self.castTimeElapsed = 0
	self:_SetPhase(SkillPhase.Cast, creature)
	ClientSkill.super._SwitchToCast(self, creature)
	local phase = self.phaseData:GetSkillPhase()
	if SkillPhase.Cast == phase then
		-- notify server
		self:_NotifyServer(creature)
	end
end

function ClientSkill:_SwitchToLeadComplete(creature)
	self.info.LogicClass.Client_DeterminTargets(self, creature)
	self.allowInterrupted = true
	self:_SetPhase(SkillPhase.LeadComplete, creature)
	self:_OnPhaseChanged(creature)
	-- notify server
	self:_NotifyServer(creature)
end

function ClientSkill:_SwitchToAttack(creature)
	self.random = creature.data.randomFunc.index
	self.info.LogicClass.Client_DeterminTargets(self, creature)
	self.allowInterrupted = false
	self:_SetPhase(SkillPhase.Attack, creature)
	ClientSkill.super._SwitchToAttack(self, creature)

	local phase = self.phaseData:GetSkillPhase()
	if SkillPhase.Attack == phase then
		-- notify server
		self:_NotifyServer(creature)
	end
end

function ClientSkill:_End(creature)
	local phase = self.phaseData:GetSkillPhase()
	self.phaseData:SetSkillPhase(SkillPhase.None)
	if SkillPhase.Cast == phase then
		-- notify server
		self:_NotifyServer(creature)
	end
	ClientSkill.super._End(self, creature)
end

function ClientSkill:Update_Cast(time, deltaTime, creature)
	if not self.info.LogicClass.Client_PreUpdate_Cast(self, time, deltaTime, creature) then
		self:_End(creature)
		return false
	end
	if ClientSkill.super.Update_Cast(self, time, deltaTime, creature) then
		self.castTimeElapsed = self.castTimeElapsed + deltaTime
		if self.castTime > self.castTimeElapsed then
			return true
		else
			if self.info:IsGuideCast(creature) or self.info:InfiniteCast(creature) then
				self:_SwitchToLeadComplete(creature)
				return true
			end
		end
	end
	return false
end

function ClientSkill:Update_LeadComplete(time, deltaTime, creature)
	if self.info:IsGuideCast(creature) then
		return false
	end
	if not self.info.LogicClass.Client_PreUpdate_Cast(self, time, deltaTime, creature) then
		return false
	end
	return true
end

function ClientSkill:Update_Attack(time, deltaTime, creature)
	if not self.info.LogicClass.Client_PreUpdate_Attack(self, time, deltaTime, creature) then
		return false
	end
	return ClientSkill.super.Update_Attack(self, time, deltaTime, creature)
end

function ClientSkill:Update(time, deltaTime, creature)
	if not self.running then
		return
	end
	local skillPhase = self.phaseData:GetSkillPhase()
	if SkillPhase.LeadComplete == skillPhase then
		if not self:Update_LeadComplete(time, deltaTime, creature) then
			self:_End(creature)
		end
	else
		ClientSkill.super.Update(self, time, deltaTime, creature)
	end
end
-- override end