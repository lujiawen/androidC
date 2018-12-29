local tmpVector3 = LuaVector3.zero
local tempCreatureArray = {}
local log = LogUtility.Info
local tempArray = {}

function NMyselfPlayer:Client_PlaceXYZTo(x,y,z,div,ignoreNavMesh)
	tmpVector3:Set(x,y,z)
	if(div~=nil) then
		tmpVector3:Div(div)
	end
	self:Client_PlaceTo(tmpVector3,ignoreNavMesh)
end

function NMyselfPlayer:Client_PlaceTo(pos,ignoreNavMesh)
	self.ai:PushCommand(FactoryAICMD.Me_GetPlaceToCmd(pos,ignoreNavMesh), self)
end

function NMyselfPlayer:Client_MoveXYZTo(x,y,z,div,ignoreNavMesh,callback,callbackOwner,callbackCustom)
	tmpVector3:Set(x,y,z)
	if(div~=nil) then
		tmpVector3:Div(div)
	end
	self:Client_MoveTo(tmpVector3,ignoreNavMesh,callback,callbackOwner,callbackCustom)
end

function NMyselfPlayer:Client_SetDirCmd(mode,dir,noSmooth)
	self.ai:PushCommand(FactoryAICMD.Me_GetSetAngleYCmd(mode,dir,noSmooth), self)
end

function NMyselfPlayer:Client_MoveTo(pos,ignoreNavMesh,callback,callbackOwner,callbackCustom,range)
	self.ai:PushCommand(FactoryAICMD.Me_GetMoveToCmd(pos,ignoreNavMesh,callback,callbackOwner,callbackCustom,range), self)
end

function NMyselfPlayer:Client_DirMove(dir,ignoreNavMesh)
	self.ai:PushCommand(FactoryAICMD.Me_GetDirMoveCmd(dir,ignoreNavMesh), self)
end

function NMyselfPlayer:Client_DirMoveEnd()
	self.ai:PushCommand(FactoryAICMD.Me_GetDirMoveEndCmd(), self)
end

function NMyselfPlayer:Client_PlayAction(name,normalizedTime,loop,fakeDead,forceDuration)
	self.ai:PushCommand(FactoryAICMD.Me_GetPlayActionCmd(name,normalizedTime,loop,fakeDead,forceDuration), self)
end

function NMyselfPlayer:Client_PlayMotionAction(actionID)
	local actionInfo = Table_ActionAnime[actionID]
	if nil == actionInfo then
		return
	end
	self:Client_PlayAction(actionInfo.Name, nil, true)
	ServiceNUserProxy.Instance:CallUserActionNtf(
		self.data.id, 
		actionID, 
		SceneUser2_pb.EUSERACTIONTYPE_MOTION)
end

--锁定目标
function NMyselfPlayer:Client_LockTarget(creature)
	if self == creature then
		return
	end
	if(creature) then
		if(creature:GetClickable()) then
			-- log(string.format("选中目标->id:%s , name:%s",creature.data.id,creature.data:GetName()))
			ServicePlayerProxy.Instance:CallMapObjectData(creature.data.id)
			Game.LockTargetEffectManager:SwitchLockedTarget(creature)
		else
			Game.LockTargetEffectManager:ClearLockedTarget()
			creature = nil
		end
	else
		-- log(string.format("取消选中目标"))
		Game.LockTargetEffectManager:ClearLockedTarget()
	end
	self:SetWeakData(NMyselfPlayer.WeakKey_LockTarget,creature)
	GameFacade.Instance:sendNotification(MyselfEvent.SelectTargetChange, creature)
end

--访问目标
function NMyselfPlayer:Client_AccessTarget(creature,custom,customDeleter,customType,accessRange)
	-- 暂时不需要
	-- self:SetWeakData(NMyselfPlayer.WeakKey_AccessTarget,creature)
	self.ai:PushCommand(FactoryAICMD.Me_GetAccessCmd(creature,ignoreNavMesh,accessRange,custom,customDeleter,customType), self)
	-- log(string.format("push访问目标命令->id:%s , name:%s",creature.data.id,creature.data:GetName()))
end

function NMyselfPlayer:Client_ArrivedAccessTarget(creature,custom,customType)
	-- 暂时不需要
	-- self:SetWeakData(NMyselfPlayer.WeakKey_AccessTarget,creature)
	if(creature) then
		-- log(string.format("到达访问目标->id:%s , name:%s",creature.data.id,creature.data:GetName()))
		FunctionVisitNpc.Me():AccessTarget(creature, custom,customType);
	else
		errorLog("访问到达目标不存在")
	end
end

function NMyselfPlayer:Client_MoveHandler(destination)
	Game.LogicManager_HandInHand:TryBreakMyDoubleAction();
	-- LogUtility.InfoFormat("<color=yellow>Client_MoveHandler 1: </color>{0}", destination)
	if(FunctionCheck.Me():CanSyncMove()) then
		-- LogUtility.InfoFormat("<color=yellow>Client_MoveHandler 2: </color>{0}", destination)
		ServicePlayerProxy.Instance:CallMoveTo(destination[1],destination[2],destination[3])
	end
end

function NMyselfPlayer:Client_UseSkillHandler(random,phaseData,targetCreatureGUID)
	if self.disableSkillBroadcast then
		return
	end
	ServicePlayerProxy.Instance:CallSkillBroadcast(
		random, 
		phaseData,
		self,
		targetCreatureGUID)
	-- log("使用技能:"..phaseData:GetSkillID()..", "..phaseData:GetSkillPhase()) 
end

--攻击（普通攻击)目标
function NMyselfPlayer:Client_AttackTarget(targetCreature)
	local id = self.data:GetAttackSkillIDAndLevel()
	if(id==0) then
		return
	end
	self:Client_UseSkill(
		id, 
		targetCreature,
		nil,
		false,
		true)
end

--技能
function NMyselfPlayer:Client_UseSkill(skillID, targetCreature, targetPosition, forceTargetCreature, noSearch, searchFilter, allowResearch, noLimit)
	if self == targetCreature then
		targetCreature = nil
		forceTargetCreature = false
	end
	local skillInfo = Game.LogicManager_Skill:GetSkillInfo(skillID)
	--fake dead begin
	if(skillInfo:GetSkillType() == SkillType.FakeDead) then
		if(self:IsFakeDead()) then
			--off fake dead, straight to send request
			local phaseData = SkillPhaseData.Create(skillID)
			phaseData:SetSkillPhase(SkillPhase.Attack)
			self:Client_UseSkillHandler(0,phaseData)
			phaseData:Destroy()
			phaseData = nil
			return true
		end
	end
	--fake dead end

	local lockedCreature = self:GetLockTarget()

	local oldTargetCreature = targetCreature
	local teamFirst = skillInfo:TeamFirst(self)
	local hatredFirst = self:IsAutoBattleProtectingTeam() and skillInfo:TargetEnemy(self)
	if not noSearch and nil ~= targetCreature then
		if teamFirst and not targetCreature:IsInMyTeam() then
			targetCreature = nil
		else
			local res,resValue,reason = skillInfo:CheckTarget(self, targetCreature)
			if not res then
				--check life
				if(resValue and resValue == 4) then
					if(reason == 1) then
						MsgManager.ShowMsgByIDTable(2216)
					end
				end
				targetCreature = nil
			elseif hatredFirst and skillInfo:TargetOnlyEnemy(creature) and not targetCreature:IsHatred() then
				targetCreature = nil
			end
		end
	end
	if nil == targetCreature then
		if SkillTargetType.Creature == skillInfo:GetTargetType(self) then
			if noSearch then
				-- LogUtility.InfoFormat("<color=yellow>UseSkill failed 1: </color>{0}, TargetCreature no target and no search", 
				-- 	skillID)
				return false
			end

			if nil ~= lockedCreature 
				and (not teamFirst or lockedCreature:IsInMyTeam())
				and (not hatredFirst or lockedCreature:IsHatred())
				and skillInfo:CheckTarget(self, lockedCreature) then
				targetCreature = lockedCreature
			else
				-- search
				local searchRange = 40
				if self:IsAutoBattleStanding() then
					searchRange = skillInfo:GetLaunchRange(self)
				end
				if hatredFirst then
					-- hatred first
					SkillLogic_Base.SearchTargetInRange(
						tempCreatureArray, 
						self:GetPosition(), 
						searchRange, 
						skillInfo, 
						self, 
						searchFilter, 
						SkillLogic_Base.SortComparator_HatredFirstDistance)
					targetCreature = tempCreatureArray[1]
					TableUtility.ArrayClear(tempCreatureArray)
					if nil == targetCreature or not targetCreature:IsHatred() then
						local autoBattleLockTarget, lockID = self.ai:GetAutoBattleLockTarget(
							self, 
							skillInfo)
						if nil ~= autoBattleLockTarget then
							targetCreature = autoBattleLockTarget
						elseif nil ~= oldTargetCreature then
							targetCreature = oldTargetCreature
						end
					end
				else
					local autoBattleLockTarget, lockID = self.ai:GetAutoBattleLockTarget(
						self, 
						skillInfo)
					if nil ~= autoBattleLockTarget then
						targetCreature = autoBattleLockTarget
					else--if 0 == lockID then
						local sortComparator = teamFirst 
							and SkillLogic_Base.SortComparator_TeamFirstDistance
							or SkillLogic_Base.SortComparator_Distance
						SkillLogic_Base.SearchTargetInRange(
							tempCreatureArray, 
							self:GetPosition(), 
							searchRange, 
							skillInfo, 
							self, 
							searchFilter, 
							sortComparator)
						targetCreature = tempCreatureArray[1]
						TableUtility.ArrayClear(tempCreatureArray)
						if nil ~= oldTargetCreature then
							if nil == targetCreature or (teamFirst and not targetCreature:IsInMyTeam()) then
								targetCreature = oldTargetCreature
							end
						end
					end
				end
				if nil ~= targetCreature then
					-- lock
					self:Client_LockTarget(targetCreature)
				else
					-- LogUtility.InfoFormat("<color=yellow>UseSkill failed 2: </color>{0}, {1}, TargetCreature no target and search failed", 
					-- 	skillID, searchRange)
					return false
				end
			end
		elseif SkillTargetType.Point == skillInfo:GetTargetType(self) then
			if nil ~= targetPosition then
				forceTargetCreature = false
			end
		end
	elseif targetCreature ~= lockedCreature then
		if SkillTargetType.Creature == skillInfo:GetTargetType(self) or forceTargetCreature then
			if self:IsAutoBattleStanding() then
				local dist = VectorUtility.DistanceXZ(
					self:GetPosition(), 
					targetCreature:GetPosition())
				if dist > skillInfo:GetLaunchRange(self) then
					self:Client_ClearAutoBattleCurrentTarget()
					-- LogUtility.InfoFormat("<color=yellow>UseSkill failed 3: </color>{0}, {1}, {2}, TargetCreature not in launch range", 
					-- 	skillID, skillInfo:GetLaunchRange(self), dist)
					return false
				end
			end
		end
		-- lock
		self:Client_LockTarget(targetCreature)
	end
	self.ai:PushCommand(FactoryAICMD.Me_GetSkillCmd(
		skillID, 
		targetCreature, 
		targetPosition, 
		nil, 
		forceTargetCreature,
		allowResearch,
		noLimit), self)
	return true
end

function NMyselfPlayer:Client_SyncRotationY(y)
	ServiceNUserProxy.Instance:CallSetDirection(y)
end

function NMyselfPlayer:Client_EnterExitRangeHandler(exitPoint)
	if self:Client_IsCurrentCommand_Skill() then
		LogUtility.InfoFormat("<color=yellow>Call Enter Exit Point: </color>{0}, but skill is running", 
			exitPoint.ID)
		return
	end
	LogUtility.InfoFormat("<color=blue>Call Enter Exit Point: </color>{0}", 
		exitPoint.ID)
	local pos = self.logicTransform.currentPosition
	tmpVector3:Set(pos[1]*1000,pos[2]*1000,pos[3]*1000)
	local mapid = SceneProxy.Instance.currentScene.mapID
	-- local isHanding,handOther = self:IsHandInHand()

	-- if isHanding == handOther then
		ServiceNUserProxy.Instance:CallExitPosUserCmd(tmpVector3, exitPoint.ID,mapid) 
	-- end
end

function NMyselfPlayer:Client_PauseIdleAI()
	self.ai:PauseIdleAI(self)
end

function NMyselfPlayer:Client_ResumeIdleAI()
	self.ai:ResumeIdleAI(self)
end

function NMyselfPlayer:Client_SetMissionCommand(newCmd)
	self.ai:SetAuto_MissionCommand(newCmd, self)
end

function NMyselfPlayer:Client_GetCurrentMissionCommand()
	self.ai:GetCurrentMissionCommand(self)
end

function NMyselfPlayer:Client_SetFollowLeader(leaderID, followType, ignoreNotifyServer) -- 0 is cancel
	self.ai:SetAuto_FollowLeader(leaderID, followType, self, ignoreNotifyServer)
end

function NMyselfPlayer:Client_SetFollowLeaderMoveToMap(mapID, pos)
	self.ai:SetAuto_FollowLeaderMoveToMap(mapID, pos)
end

function NMyselfPlayer:Client_SetFollowLeaderTarget(guid, time)
	self.ai:SetAuto_FollowLeaderTarget(guid, time)
end

function NMyselfPlayer:Client_SetFollowLeaderDelay()
	self.ai:SetAuto_FollowLeaderDelay()
end

function NMyselfPlayer:Client_GetFollowLeaderID()
	return self.ai:GetFollowLeaderID(self)
end

function NMyselfPlayer:Client_IsFollowHandInHand()
	if(self.handInActionID ~= nil)then
		return false;
	end
	return self.ai:IsFollowHandInHand(self)
end

function NMyselfPlayer:Client_SetFollower(followerID, followType)
	self.ai:SetFollower(followerID, followType, self)
end

function NMyselfPlayer:Client_ClearFollower()
	self.ai:ClearFollower(self)
end

-- return k,v table, key:guid, value:type
function NMyselfPlayer:Client_GetAllFollowers()
	return self.ai:GetAllFollowers(self)
end

function NMyselfPlayer:Client_GetHandInHandFollower()
	return self.ai:GetHandInHandFollower(self)
end

function NMyselfPlayer:Client_ClearAutoBattleCurrentTarget()
	self.ai:ClearAuto_BattleCurrentTarget(self)
end

function NMyselfPlayer:Client_SetAutoBattleLockID(lockID) -- 0 is no lock
	self.ai:SetAuto_BattleLockID(lockID, self)
end

function NMyselfPlayer:Client_SetAutoBattleProtectTeam(on)
	self.ai:SetAuto_BattleProtectTeam(on, self)
end

function NMyselfPlayer:Client_SetAutoBattleStanding(on)
	self.ai:SetAuto_BattleStanding(on, self)
end

function NMyselfPlayer:Client_SetAutoBattle(on) -- 0 is no lock
	self.ai:SetAuto_Battle(on, self)
end

function NMyselfPlayer:Client_GetAutoBattleLockID() -- 0 is no lock
	return self.ai:GetAutoBattleLockID(self)
end

function NMyselfPlayer:Client_ManualControlled()
	self:Client_SetMissionCommand(nil)
	self:Client_SetFollowLeaderDelay()
end

function NMyselfPlayer:Client_IsCurrentCommand_Skill()
	local cmd = self.ai:GetCurrentCommand(self)
	return nil ~= cmd and AI_CMD_Myself_Skill == cmd.AIClass
end

function NMyselfPlayer:Client_SetAutoFakeDead(skillID)
	self.fakeDeadLogic:SetSkill(skillID)
	self.ai:SetAutoFakeDead(skillID, self)
end

function NMyselfPlayer:Client_SetAutoEndlessTowerSweep(on)
	self.ai:SetAuto_EndlessTowerSweep(on, self)
end

function NMyselfPlayer:Client_GetAutoEndlessTowerSweep()
	return self.ai:GetAuto_EndlessTowerSweep(self)
end