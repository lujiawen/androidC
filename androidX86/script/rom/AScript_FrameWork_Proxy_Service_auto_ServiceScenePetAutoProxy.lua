ServiceScenePetAutoProxy = class('ServiceScenePetAutoProxy', ServiceProxy)

ServiceScenePetAutoProxy.Instance = nil

ServiceScenePetAutoProxy.NAME = 'ServiceScenePetAutoProxy'

function ServiceScenePetAutoProxy:ctor(proxyName)
	if ServiceScenePetAutoProxy.Instance == nil then
		self.proxyName = proxyName or ServiceScenePetAutoProxy.NAME
		ServiceProxy.ctor(self, self.proxyName)
		self:Init()

		ServiceScenePetAutoProxy.Instance = self
	end
end

function ServiceScenePetAutoProxy:Init()
end

function ServiceScenePetAutoProxy:onRegister()
	self:Listen(10, 1, function (data)
		self:RecvPetList(data) 
	end)
	self:Listen(10, 2, function (data)
		self:RecvFireCatPetCmd(data) 
	end)
	self:Listen(10, 3, function (data)
		self:RecvHireCatPetCmd(data) 
	end)
	self:Listen(10, 4, function (data)
		self:RecvEggHatchPetCmd(data) 
	end)
	self:Listen(10, 5, function (data)
		self:RecvEggRestorePetCmd(data) 
	end)
	self:Listen(10, 6, function (data)
		self:RecvCatchValuePetCmd(data) 
	end)
	self:Listen(10, 7, function (data)
		self:RecvCatchResultPetCmd(data) 
	end)
	self:Listen(10, 8, function (data)
		self:RecvCatchPetPetCmd(data) 
	end)
	self:Listen(10, 12, function (data)
		self:RecvCatchPetGiftPetCmd(data) 
	end)
	self:Listen(10, 9, function (data)
		self:RecvPetInfoPetCmd(data) 
	end)
	self:Listen(10, 10, function (data)
		self:RecvPetInfoUpdatePetCmd(data) 
	end)
	self:Listen(10, 11, function (data)
		self:RecvPetOffPetCmd(data) 
	end)
	self:Listen(10, 13, function (data)
		self:RecvGetGiftPetCmd(data) 
	end)
	self:Listen(10, 14, function (data)
		self:RecvEquipOperPetCmd(data) 
	end)
	self:Listen(10, 15, function (data)
		self:RecvEquipUpdatePetCmd(data) 
	end)
	self:Listen(10, 16, function (data)
		self:RecvQueryPetAdventureListPetCmd(data) 
	end)
	self:Listen(10, 17, function (data)
		self:RecvPetAdventureResultNtfPetCmd(data) 
	end)
	self:Listen(10, 18, function (data)
		self:RecvStartAdventurePetCmd(data) 
	end)
	self:Listen(10, 19, function (data)
		self:RecvGetAdventureRewardPetCmd(data) 
	end)
	self:Listen(10, 20, function (data)
		self:RecvQueryBattlePetCmd(data) 
	end)
	self:Listen(10, 21, function (data)
		self:RecvHandPetPetCmd(data) 
	end)
	self:Listen(10, 22, function (data)
		self:RecvGiveGiftPetCmd(data) 
	end)
	self:Listen(10, 23, function (data)
		self:RecvUnlockNtfPetCmd(data) 
	end)
	self:Listen(10, 24, function (data)
		self:RecvResetSkillPetCmd(data) 
	end)
	self:Listen(10, 26, function (data)
		self:RecvChangeNamePetCmd(data) 
	end)
	self:Listen(10, 27, function (data)
		self:RecvSwitchSkillPetCmd(data) 
	end)
	self:Listen(10, 28, function (data)
		self:RecvUnlockPetWorkManualPetCmd(data) 
	end)
	self:Listen(10, 29, function (data)
		self:RecvStartWorkPetCmd(data) 
	end)
	self:Listen(10, 30, function (data)
		self:RecvStopWorkPetCmd(data) 
	end)
	self:Listen(10, 31, function (data)
		self:RecvQueryPetWorkManualPetCmd(data) 
	end)
	self:Listen(10, 32, function (data)
		self:RecvQueryPetWorkDataPetCmd(data) 
	end)
	self:Listen(10, 33, function (data)
		self:RecvGetPetWorkRewardPetCmd(data) 
	end)
	self:Listen(10, 34, function (data)
		self:RecvWorkSpaceUpdate(data) 
	end)
	self:Listen(10, 35, function (data)
		self:RecvPetExtraUpdatePetCmd(data) 
	end)
end

-- *********************************************** Call ***********************************************
function ServiceScenePetAutoProxy:CallPetList(datas) 
	local msg = ScenePet_pb.PetList()
	if( datas ~= nil )then
		for i=1,#datas do 
			table.insert(msg.datas, datas[i])
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallFireCatPetCmd(catid) 
	local msg = ScenePet_pb.FireCatPetCmd()
	if(catid ~= nil )then
		msg.catid = catid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallHireCatPetCmd(catid, etype) 
	local msg = ScenePet_pb.HireCatPetCmd()
	if(catid ~= nil )then
		msg.catid = catid
	end
	if(etype ~= nil )then
		msg.etype = etype
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallEggHatchPetCmd(name, guid) 
	local msg = ScenePet_pb.EggHatchPetCmd()
	if(name ~= nil )then
		msg.name = name
	end
	if(guid ~= nil )then
		msg.guid = guid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallEggRestorePetCmd(petid) 
	local msg = ScenePet_pb.EggRestorePetCmd()
	if(petid ~= nil )then
		msg.petid = petid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallCatchValuePetCmd(npcguid, value, from_npcid) 
	local msg = ScenePet_pb.CatchValuePetCmd()
	msg.npcguid = npcguid
	if(value ~= nil )then
		msg.value = value
	end
	if(from_npcid ~= nil )then
		msg.from_npcid = from_npcid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallCatchResultPetCmd(success, npcguid) 
	local msg = ScenePet_pb.CatchResultPetCmd()
	if(success ~= nil )then
		msg.success = success
	end
	if(npcguid ~= nil )then
		msg.npcguid = npcguid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallCatchPetPetCmd(npcguid, isstop) 
	local msg = ScenePet_pb.CatchPetPetCmd()
	if(npcguid ~= nil )then
		msg.npcguid = npcguid
	end
	if(isstop ~= nil )then
		msg.isstop = isstop
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallCatchPetGiftPetCmd(npcguid) 
	local msg = ScenePet_pb.CatchPetGiftPetCmd()
	if(npcguid ~= nil )then
		msg.npcguid = npcguid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallPetInfoPetCmd(petinfo) 
	local msg = ScenePet_pb.PetInfoPetCmd()
	if( petinfo ~= nil )then
		for i=1,#petinfo do 
			table.insert(msg.petinfo, petinfo[i])
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallPetInfoUpdatePetCmd(petid, datas) 
	local msg = ScenePet_pb.PetInfoUpdatePetCmd()
	msg.petid = petid
	if( datas ~= nil )then
		for i=1,#datas do 
			table.insert(msg.datas, datas[i])
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallPetOffPetCmd(petid) 
	local msg = ScenePet_pb.PetOffPetCmd()
	msg.petid = petid
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallGetGiftPetCmd(petid) 
	local msg = ScenePet_pb.GetGiftPetCmd()
	if(petid ~= nil )then
		msg.petid = petid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallEquipOperPetCmd(oper, petid, guid) 
	local msg = ScenePet_pb.EquipOperPetCmd()
	if(oper ~= nil )then
		msg.oper = oper
	end
	if(petid ~= nil )then
		msg.petid = petid
	end
	if(guid ~= nil )then
		msg.guid = guid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallEquipUpdatePetCmd(petid, update, del) 
	local msg = ScenePet_pb.EquipUpdatePetCmd()
	if(petid ~= nil )then
		msg.petid = petid
	end
	if(update.base ~= nil )then
		if(update.base.guid ~= nil )then
			msg.update.base.guid = update.base.guid
		end
	end
	if(update.base ~= nil )then
		if(update.base.id ~= nil )then
			msg.update.base.id = update.base.id
		end
	end
	if(update.base ~= nil )then
		if(update.base.count ~= nil )then
			msg.update.base.count = update.base.count
		end
	end
	if(update.base ~= nil )then
		if(update.base.index ~= nil )then
			msg.update.base.index = update.base.index
		end
	end
	if(update.base ~= nil )then
		if(update.base.createtime ~= nil )then
			msg.update.base.createtime = update.base.createtime
		end
	end
	if(update.base ~= nil )then
		if(update.base.cd ~= nil )then
			msg.update.base.cd = update.base.cd
		end
	end
	if(update.base ~= nil )then
		if(update.base.type ~= nil )then
			msg.update.base.type = update.base.type
		end
	end
	if(update.base ~= nil )then
		if(update.base.bind ~= nil )then
			msg.update.base.bind = update.base.bind
		end
	end
	if(update.base ~= nil )then
		if(update.base.expire ~= nil )then
			msg.update.base.expire = update.base.expire
		end
	end
	if(update.base ~= nil )then
		if(update.base.quality ~= nil )then
			msg.update.base.quality = update.base.quality
		end
	end
	if(update.base ~= nil )then
		if(update.base.equipType ~= nil )then
			msg.update.base.equipType = update.base.equipType
		end
	end
	if(update.base ~= nil )then
		if(update.base.source ~= nil )then
			msg.update.base.source = update.base.source
		end
	end
	if(update.base ~= nil )then
		if(update.base.isnew ~= nil )then
			msg.update.base.isnew = update.base.isnew
		end
	end
	if(update.base ~= nil )then
		if(update.base.maxcardslot ~= nil )then
			msg.update.base.maxcardslot = update.base.maxcardslot
		end
	end
	if(update.base ~= nil )then
		if(update.base.ishint ~= nil )then
			msg.update.base.ishint = update.base.ishint
		end
	end
	if(update.base ~= nil )then
		if(update.base.isactive ~= nil )then
			msg.update.base.isactive = update.base.isactive
		end
	end
	if(update.base ~= nil )then
		if(update.base.source_npc ~= nil )then
			msg.update.base.source_npc = update.base.source_npc
		end
	end
	if(update.base ~= nil )then
		if(update.base.refinelv ~= nil )then
			msg.update.base.refinelv = update.base.refinelv
		end
	end
	if(update.base ~= nil )then
		if(update.base.chargemoney ~= nil )then
			msg.update.base.chargemoney = update.base.chargemoney
		end
	end
	if(update.base ~= nil )then
		if(update.base.overtime ~= nil )then
			msg.update.base.overtime = update.base.overtime
		end
	end
	if(update.base ~= nil )then
		if(update.base.quota ~= nil )then
			msg.update.base.quota = update.base.quota
		end
	end
	if(update ~= nil )then
		if(update.equiped ~= nil )then
			msg.update.equiped = update.equiped
		end
	end
	if(update ~= nil )then
		if(update.battlepoint ~= nil )then
			msg.update.battlepoint = update.battlepoint
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.strengthlv ~= nil )then
			msg.update.equip.strengthlv = update.equip.strengthlv
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.refinelv ~= nil )then
			msg.update.equip.refinelv = update.equip.refinelv
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.strengthCost ~= nil )then
			msg.update.equip.strengthCost = update.equip.strengthCost
		end
	end
	if(update ~= nil )then
		if(update.equip.refineCompose ~= nil )then
			for i=1,#update.equip.refineCompose do 
				table.insert(msg.update.equip.refineCompose, update.equip.refineCompose[i])
			end
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.cardslot ~= nil )then
			msg.update.equip.cardslot = update.equip.cardslot
		end
	end
	if(update ~= nil )then
		if(update.equip.buffid ~= nil )then
			for i=1,#update.equip.buffid do 
				table.insert(msg.update.equip.buffid, update.equip.buffid[i])
			end
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.damage ~= nil )then
			msg.update.equip.damage = update.equip.damage
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.lv ~= nil )then
			msg.update.equip.lv = update.equip.lv
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.color ~= nil )then
			msg.update.equip.color = update.equip.color
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.breakstarttime ~= nil )then
			msg.update.equip.breakstarttime = update.equip.breakstarttime
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.breakendtime ~= nil )then
			msg.update.equip.breakendtime = update.equip.breakendtime
		end
	end
	if(update.equip ~= nil )then
		if(update.equip.strengthlv2 ~= nil )then
			msg.update.equip.strengthlv2 = update.equip.strengthlv2
		end
	end
	if(update ~= nil )then
		if(update.equip.strengthlv2cost ~= nil )then
			for i=1,#update.equip.strengthlv2cost do 
				table.insert(msg.update.equip.strengthlv2cost, update.equip.strengthlv2cost[i])
			end
		end
	end
	if(update ~= nil )then
		if(update.card ~= nil )then
			for i=1,#update.card do 
				table.insert(msg.update.card, update.card[i])
			end
		end
	end
	if(update.enchant ~= nil )then
		if(update.enchant.type ~= nil )then
			msg.update.enchant.type = update.enchant.type
		end
	end
	if(update ~= nil )then
		if(update.enchant.attrs ~= nil )then
			for i=1,#update.enchant.attrs do 
				table.insert(msg.update.enchant.attrs, update.enchant.attrs[i])
			end
		end
	end
	if(update ~= nil )then
		if(update.enchant.extras ~= nil )then
			for i=1,#update.enchant.extras do 
				table.insert(msg.update.enchant.extras, update.enchant.extras[i])
			end
		end
	end
	if(update ~= nil )then
		if(update.enchant.patch ~= nil )then
			for i=1,#update.enchant.patch do 
				table.insert(msg.update.enchant.patch, update.enchant.patch[i])
			end
		end
	end
	if(update.previewenchant ~= nil )then
		if(update.previewenchant.type ~= nil )then
			msg.update.previewenchant.type = update.previewenchant.type
		end
	end
	if(update ~= nil )then
		if(update.previewenchant.attrs ~= nil )then
			for i=1,#update.previewenchant.attrs do 
				table.insert(msg.update.previewenchant.attrs, update.previewenchant.attrs[i])
			end
		end
	end
	if(update ~= nil )then
		if(update.previewenchant.extras ~= nil )then
			for i=1,#update.previewenchant.extras do 
				table.insert(msg.update.previewenchant.extras, update.previewenchant.extras[i])
			end
		end
	end
	if(update ~= nil )then
		if(update.previewenchant.patch ~= nil )then
			for i=1,#update.previewenchant.patch do 
				table.insert(msg.update.previewenchant.patch, update.previewenchant.patch[i])
			end
		end
	end
	if(update.refine ~= nil )then
		if(update.refine.lastfail ~= nil )then
			msg.update.refine.lastfail = update.refine.lastfail
		end
	end
	if(update.refine ~= nil )then
		if(update.refine.repaircount ~= nil )then
			msg.update.refine.repaircount = update.refine.repaircount
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.exp ~= nil )then
			msg.update.egg.exp = update.egg.exp
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.friendexp ~= nil )then
			msg.update.egg.friendexp = update.egg.friendexp
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.rewardexp ~= nil )then
			msg.update.egg.rewardexp = update.egg.rewardexp
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.id ~= nil )then
			msg.update.egg.id = update.egg.id
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.lv ~= nil )then
			msg.update.egg.lv = update.egg.lv
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.friendlv ~= nil )then
			msg.update.egg.friendlv = update.egg.friendlv
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.body ~= nil )then
			msg.update.egg.body = update.egg.body
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.relivetime ~= nil )then
			msg.update.egg.relivetime = update.egg.relivetime
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.hp ~= nil )then
			msg.update.egg.hp = update.egg.hp
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.restoretime ~= nil )then
			msg.update.egg.restoretime = update.egg.restoretime
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.time_happly ~= nil )then
			msg.update.egg.time_happly = update.egg.time_happly
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.time_excite ~= nil )then
			msg.update.egg.time_excite = update.egg.time_excite
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.time_happiness ~= nil )then
			msg.update.egg.time_happiness = update.egg.time_happiness
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.time_happly_gift ~= nil )then
			msg.update.egg.time_happly_gift = update.egg.time_happly_gift
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.time_excite_gift ~= nil )then
			msg.update.egg.time_excite_gift = update.egg.time_excite_gift
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.time_happiness_gift ~= nil )then
			msg.update.egg.time_happiness_gift = update.egg.time_happiness_gift
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.touch_tick ~= nil )then
			msg.update.egg.touch_tick = update.egg.touch_tick
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.feed_tick ~= nil )then
			msg.update.egg.feed_tick = update.egg.feed_tick
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.name ~= nil )then
			msg.update.egg.name = update.egg.name
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.var ~= nil )then
			msg.update.egg.var = update.egg.var
		end
	end
	if(update ~= nil )then
		if(update.egg.skillids ~= nil )then
			for i=1,#update.egg.skillids do 
				table.insert(msg.update.egg.skillids, update.egg.skillids[i])
			end
		end
	end
	if(update ~= nil )then
		if(update.egg.equips ~= nil )then
			for i=1,#update.egg.equips do 
				table.insert(msg.update.egg.equips, update.egg.equips[i])
			end
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.buff ~= nil )then
			msg.update.egg.buff = update.egg.buff
		end
	end
	if(update ~= nil )then
		if(update.egg.unlock_equip ~= nil )then
			for i=1,#update.egg.unlock_equip do 
				table.insert(msg.update.egg.unlock_equip, update.egg.unlock_equip[i])
			end
		end
	end
	if(update ~= nil )then
		if(update.egg.unlock_body ~= nil )then
			for i=1,#update.egg.unlock_body do 
				table.insert(msg.update.egg.unlock_body, update.egg.unlock_body[i])
			end
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.version ~= nil )then
			msg.update.egg.version = update.egg.version
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.skilloff ~= nil )then
			msg.update.egg.skilloff = update.egg.skilloff
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.exchange_count ~= nil )then
			msg.update.egg.exchange_count = update.egg.exchange_count
		end
	end
	if(update.egg ~= nil )then
		if(update.egg.guid ~= nil )then
			msg.update.egg.guid = update.egg.guid
		end
	end
	if(update.letter ~= nil )then
		if(update.letter.sendUserName ~= nil )then
			msg.update.letter.sendUserName = update.letter.sendUserName
		end
	end
	if(update.letter ~= nil )then
		if(update.letter.bg ~= nil )then
			msg.update.letter.bg = update.letter.bg
		end
	end
	if(update.letter ~= nil )then
		if(update.letter.configID ~= nil )then
			msg.update.letter.configID = update.letter.configID
		end
	end
	if(update.letter ~= nil )then
		if(update.letter.content ~= nil )then
			msg.update.letter.content = update.letter.content
		end
	end
	if(update.letter ~= nil )then
		if(update.letter.content2 ~= nil )then
			msg.update.letter.content2 = update.letter.content2
		end
	end
	if(update.code ~= nil )then
		if(update.code.code ~= nil )then
			msg.update.code.code = update.code.code
		end
	end
	if(update.code ~= nil )then
		if(update.code.used ~= nil )then
			msg.update.code.used = update.code.used
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.id ~= nil )then
			msg.update.wedding.id = update.wedding.id
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.zoneid ~= nil )then
			msg.update.wedding.zoneid = update.wedding.zoneid
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.charid1 ~= nil )then
			msg.update.wedding.charid1 = update.wedding.charid1
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.charid2 ~= nil )then
			msg.update.wedding.charid2 = update.wedding.charid2
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.weddingtime ~= nil )then
			msg.update.wedding.weddingtime = update.wedding.weddingtime
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.photoidx ~= nil )then
			msg.update.wedding.photoidx = update.wedding.photoidx
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.phototime ~= nil )then
			msg.update.wedding.phototime = update.wedding.phototime
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.myname ~= nil )then
			msg.update.wedding.myname = update.wedding.myname
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.partnername ~= nil )then
			msg.update.wedding.partnername = update.wedding.partnername
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.starttime ~= nil )then
			msg.update.wedding.starttime = update.wedding.starttime
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.endtime ~= nil )then
			msg.update.wedding.endtime = update.wedding.endtime
		end
	end
	if(update.wedding ~= nil )then
		if(update.wedding.notified ~= nil )then
			msg.update.wedding.notified = update.wedding.notified
		end
	end
	if(update.sender ~= nil )then
		if(update.sender.charid ~= nil )then
			msg.update.sender.charid = update.sender.charid
		end
	end
	if(update.sender ~= nil )then
		if(update.sender.name ~= nil )then
			msg.update.sender.name = update.sender.name
		end
	end
	if(del ~= nil )then
		msg.del = del
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallQueryPetAdventureListPetCmd(items) 
	local msg = ScenePet_pb.QueryPetAdventureListPetCmd()
	if( items ~= nil )then
		for i=1,#items do 
			table.insert(msg.items, items[i])
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallPetAdventureResultNtfPetCmd(item) 
	local msg = ScenePet_pb.PetAdventureResultNtfPetCmd()
	if(item ~= nil )then
		if(item.id ~= nil )then
			msg.item.id = item.id
		end
	end
	if(item ~= nil )then
		if(item.starttime ~= nil )then
			msg.item.starttime = item.starttime
		end
	end
	if(item ~= nil )then
		if(item.status ~= nil )then
			msg.item.status = item.status
		end
	end
	if(item ~= nil )then
		if(item.eggs ~= nil )then
			for i=1,#item.eggs do 
				table.insert(msg.item.eggs, item.eggs[i])
			end
		end
	end
	if(item ~= nil )then
		if(item.steps ~= nil )then
			for i=1,#item.steps do 
				table.insert(msg.item.steps, item.steps[i])
			end
		end
	end
	if(item ~= nil )then
		if(item.raresreward ~= nil )then
			for i=1,#item.raresreward do 
				table.insert(msg.item.raresreward, item.raresreward[i])
			end
		end
	end
	if(item ~= nil )then
		if(item.specid ~= nil )then
			msg.item.specid = item.specid
		end
	end
	if(item ~= nil )then
		if(item.eff ~= nil )then
			for i=1,#item.eff do 
				table.insert(msg.item.eff, item.eff[i])
			end
		end
	end
	if(item ~= nil )then
		if(item.rewardinfo ~= nil )then
			for i=1,#item.rewardinfo do 
				table.insert(msg.item.rewardinfo, item.rewardinfo[i])
			end
		end
	end
	if(item ~= nil )then
		if(item.extrarewardinfo ~= nil )then
			for i=1,#item.extrarewardinfo do 
				table.insert(msg.item.extrarewardinfo, item.extrarewardinfo[i])
			end
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallStartAdventurePetCmd(id, petids, specid) 
	local msg = ScenePet_pb.StartAdventurePetCmd()
	if(id ~= nil )then
		msg.id = id
	end
	if( petids ~= nil )then
		for i=1,#petids do 
			table.insert(msg.petids, petids[i])
		end
	end
	if(specid ~= nil )then
		msg.specid = specid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallGetAdventureRewardPetCmd(id) 
	local msg = ScenePet_pb.GetAdventureRewardPetCmd()
	if(id ~= nil )then
		msg.id = id
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallQueryBattlePetCmd(pets) 
	local msg = ScenePet_pb.QueryBattlePetCmd()
	if( pets ~= nil )then
		for i=1,#pets do 
			table.insert(msg.pets, pets[i])
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallHandPetPetCmd(petguid, breakup) 
	local msg = ScenePet_pb.HandPetPetCmd()
	msg.petguid = petguid
	if(breakup ~= nil )then
		msg.breakup = breakup
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallGiveGiftPetCmd(petid, itemguid) 
	local msg = ScenePet_pb.GiveGiftPetCmd()
	msg.petid = petid
	if(itemguid ~= nil )then
		msg.itemguid = itemguid
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallUnlockNtfPetCmd(petid, equipids, bodys) 
	local msg = ScenePet_pb.UnlockNtfPetCmd()
	if(petid ~= nil )then
		msg.petid = petid
	end
	if( equipids ~= nil )then
		for i=1,#equipids do 
			table.insert(msg.equipids, equipids[i])
		end
	end
	if( bodys ~= nil )then
		for i=1,#bodys do 
			table.insert(msg.bodys, bodys[i])
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallResetSkillPetCmd(id) 
	local msg = ScenePet_pb.ResetSkillPetCmd()
	if(id ~= nil )then
		msg.id = id
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallChangeNamePetCmd(petid, name) 
	local msg = ScenePet_pb.ChangeNamePetCmd()
	if(petid ~= nil )then
		msg.petid = petid
	end
	if(name ~= nil )then
		msg.name = name
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallSwitchSkillPetCmd(petid, open) 
	local msg = ScenePet_pb.SwitchSkillPetCmd()
	if(petid ~= nil )then
		msg.petid = petid
	end
	if(open ~= nil )then
		msg.open = open
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallUnlockPetWorkManualPetCmd() 
	local msg = ScenePet_pb.UnlockPetWorkManualPetCmd()
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallStartWorkPetCmd(id, pets) 
	local msg = ScenePet_pb.StartWorkPetCmd()
	if(id ~= nil )then
		msg.id = id
	end
	if( pets ~= nil )then
		for i=1,#pets do 
			table.insert(msg.pets, pets[i])
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallStopWorkPetCmd(id) 
	local msg = ScenePet_pb.StopWorkPetCmd()
	if(id ~= nil )then
		msg.id = id
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallQueryPetWorkManualPetCmd(manual) 
	local msg = ScenePet_pb.QueryPetWorkManualPetCmd()
	if(manual ~= nil )then
		if(manual.unlock ~= nil )then
			msg.manual.unlock = manual.unlock
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallQueryPetWorkDataPetCmd(datas, extras, max_space, card_expiretime) 
	local msg = ScenePet_pb.QueryPetWorkDataPetCmd()
	if( datas ~= nil )then
		for i=1,#datas do 
			table.insert(msg.datas, datas[i])
		end
	end
	if( extras ~= nil )then
		for i=1,#extras do 
			table.insert(msg.extras, extras[i])
		end
	end
	if(max_space ~= nil )then
		msg.max_space = max_space
	end
	if(card_expiretime ~= nil )then
		msg.card_expiretime = card_expiretime
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallGetPetWorkRewardPetCmd(id) 
	local msg = ScenePet_pb.GetPetWorkRewardPetCmd()
	if(id ~= nil )then
		msg.id = id
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallWorkSpaceUpdate(updates) 
	local msg = ScenePet_pb.WorkSpaceUpdate()
	if( updates ~= nil )then
		for i=1,#updates do 
			table.insert(msg.updates, updates[i])
		end
	end
	self:SendProto(msg)
end

function ServiceScenePetAutoProxy:CallPetExtraUpdatePetCmd(updates) 
	local msg = ScenePet_pb.PetExtraUpdatePetCmd()
	if( updates ~= nil )then
		for i=1,#updates do 
			table.insert(msg.updates, updates[i])
		end
	end
	self:SendProto(msg)
end

-- *********************************************** Recv ***********************************************
function ServiceScenePetAutoProxy:RecvPetList(data) 
	self:Notify(ServiceEvent.ScenePetPetList, data)
end

function ServiceScenePetAutoProxy:RecvFireCatPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetFireCatPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvHireCatPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetHireCatPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvEggHatchPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetEggHatchPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvEggRestorePetCmd(data) 
	self:Notify(ServiceEvent.ScenePetEggRestorePetCmd, data)
end

function ServiceScenePetAutoProxy:RecvCatchValuePetCmd(data) 
	self:Notify(ServiceEvent.ScenePetCatchValuePetCmd, data)
end

function ServiceScenePetAutoProxy:RecvCatchResultPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetCatchResultPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvCatchPetPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetCatchPetPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvCatchPetGiftPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetCatchPetGiftPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvPetInfoPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetPetInfoPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvPetInfoUpdatePetCmd(data) 
	self:Notify(ServiceEvent.ScenePetPetInfoUpdatePetCmd, data)
end

function ServiceScenePetAutoProxy:RecvPetOffPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetPetOffPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvGetGiftPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetGetGiftPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvEquipOperPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetEquipOperPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvEquipUpdatePetCmd(data) 
	self:Notify(ServiceEvent.ScenePetEquipUpdatePetCmd, data)
end

function ServiceScenePetAutoProxy:RecvQueryPetAdventureListPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetQueryPetAdventureListPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvPetAdventureResultNtfPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetPetAdventureResultNtfPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvStartAdventurePetCmd(data) 
	self:Notify(ServiceEvent.ScenePetStartAdventurePetCmd, data)
end

function ServiceScenePetAutoProxy:RecvGetAdventureRewardPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetGetAdventureRewardPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvQueryBattlePetCmd(data) 
	self:Notify(ServiceEvent.ScenePetQueryBattlePetCmd, data)
end

function ServiceScenePetAutoProxy:RecvHandPetPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetHandPetPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvGiveGiftPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetGiveGiftPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvUnlockNtfPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetUnlockNtfPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvResetSkillPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetResetSkillPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvChangeNamePetCmd(data) 
	self:Notify(ServiceEvent.ScenePetChangeNamePetCmd, data)
end

function ServiceScenePetAutoProxy:RecvSwitchSkillPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetSwitchSkillPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvUnlockPetWorkManualPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetUnlockPetWorkManualPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvStartWorkPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetStartWorkPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvStopWorkPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetStopWorkPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvQueryPetWorkManualPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetQueryPetWorkManualPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvQueryPetWorkDataPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetQueryPetWorkDataPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvGetPetWorkRewardPetCmd(data) 
	self:Notify(ServiceEvent.ScenePetGetPetWorkRewardPetCmd, data)
end

function ServiceScenePetAutoProxy:RecvWorkSpaceUpdate(data) 
	self:Notify(ServiceEvent.ScenePetWorkSpaceUpdate, data)
end

function ServiceScenePetAutoProxy:RecvPetExtraUpdatePetCmd(data) 
	self:Notify(ServiceEvent.ScenePetPetExtraUpdatePetCmd, data)
end

ServiceEvent = _G["ServiceEvent"] or {}
ServiceEvent.ScenePetPetList = "ServiceEvent_ScenePetPetList"
ServiceEvent.ScenePetFireCatPetCmd = "ServiceEvent_ScenePetFireCatPetCmd"
ServiceEvent.ScenePetHireCatPetCmd = "ServiceEvent_ScenePetHireCatPetCmd"
ServiceEvent.ScenePetEggHatchPetCmd = "ServiceEvent_ScenePetEggHatchPetCmd"
ServiceEvent.ScenePetEggRestorePetCmd = "ServiceEvent_ScenePetEggRestorePetCmd"
ServiceEvent.ScenePetCatchValuePetCmd = "ServiceEvent_ScenePetCatchValuePetCmd"
ServiceEvent.ScenePetCatchResultPetCmd = "ServiceEvent_ScenePetCatchResultPetCmd"
ServiceEvent.ScenePetCatchPetPetCmd = "ServiceEvent_ScenePetCatchPetPetCmd"
ServiceEvent.ScenePetCatchPetGiftPetCmd = "ServiceEvent_ScenePetCatchPetGiftPetCmd"
ServiceEvent.ScenePetPetInfoPetCmd = "ServiceEvent_ScenePetPetInfoPetCmd"
ServiceEvent.ScenePetPetInfoUpdatePetCmd = "ServiceEvent_ScenePetPetInfoUpdatePetCmd"
ServiceEvent.ScenePetPetOffPetCmd = "ServiceEvent_ScenePetPetOffPetCmd"
ServiceEvent.ScenePetGetGiftPetCmd = "ServiceEvent_ScenePetGetGiftPetCmd"
ServiceEvent.ScenePetEquipOperPetCmd = "ServiceEvent_ScenePetEquipOperPetCmd"
ServiceEvent.ScenePetEquipUpdatePetCmd = "ServiceEvent_ScenePetEquipUpdatePetCmd"
ServiceEvent.ScenePetQueryPetAdventureListPetCmd = "ServiceEvent_ScenePetQueryPetAdventureListPetCmd"
ServiceEvent.ScenePetPetAdventureResultNtfPetCmd = "ServiceEvent_ScenePetPetAdventureResultNtfPetCmd"
ServiceEvent.ScenePetStartAdventurePetCmd = "ServiceEvent_ScenePetStartAdventurePetCmd"
ServiceEvent.ScenePetGetAdventureRewardPetCmd = "ServiceEvent_ScenePetGetAdventureRewardPetCmd"
ServiceEvent.ScenePetQueryBattlePetCmd = "ServiceEvent_ScenePetQueryBattlePetCmd"
ServiceEvent.ScenePetHandPetPetCmd = "ServiceEvent_ScenePetHandPetPetCmd"
ServiceEvent.ScenePetGiveGiftPetCmd = "ServiceEvent_ScenePetGiveGiftPetCmd"
ServiceEvent.ScenePetUnlockNtfPetCmd = "ServiceEvent_ScenePetUnlockNtfPetCmd"
ServiceEvent.ScenePetResetSkillPetCmd = "ServiceEvent_ScenePetResetSkillPetCmd"
ServiceEvent.ScenePetChangeNamePetCmd = "ServiceEvent_ScenePetChangeNamePetCmd"
ServiceEvent.ScenePetSwitchSkillPetCmd = "ServiceEvent_ScenePetSwitchSkillPetCmd"
ServiceEvent.ScenePetUnlockPetWorkManualPetCmd = "ServiceEvent_ScenePetUnlockPetWorkManualPetCmd"
ServiceEvent.ScenePetStartWorkPetCmd = "ServiceEvent_ScenePetStartWorkPetCmd"
ServiceEvent.ScenePetStopWorkPetCmd = "ServiceEvent_ScenePetStopWorkPetCmd"
ServiceEvent.ScenePetQueryPetWorkManualPetCmd = "ServiceEvent_ScenePetQueryPetWorkManualPetCmd"
ServiceEvent.ScenePetQueryPetWorkDataPetCmd = "ServiceEvent_ScenePetQueryPetWorkDataPetCmd"
ServiceEvent.ScenePetGetPetWorkRewardPetCmd = "ServiceEvent_ScenePetGetPetWorkRewardPetCmd"
ServiceEvent.ScenePetWorkSpaceUpdate = "ServiceEvent_ScenePetWorkSpaceUpdate"
ServiceEvent.ScenePetPetExtraUpdatePetCmd = "ServiceEvent_ScenePetPetExtraUpdatePetCmd"
