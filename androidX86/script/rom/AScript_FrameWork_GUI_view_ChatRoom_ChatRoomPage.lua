autoImport("ChatChannelView")
autoImport("PrivateChatView")
autoImport("ChatZoneView")
autoImport("ChatTextEmojiPage")
autoImport("PresetTextPage")
autoImport("ChatItemPage")
autoImport("ChatKeywordView")

ChatRoomPage = class("ChatRoomPage",ContainerView)

ChatRoomPage.ViewType = UIViewType.ChitchatLayer;

ChatRoomEnum = {
	CHANNEL = "CHANNEL",
	PRIVATECHAT = "PRIVATECHAT",
	CHATZONE = "CHATZONE",
}
ChatRoomPage.TabName = {
	ChannelBtn = ZhString.Chat_channel,
	PrivateChatBtn = ZhString.Chat_privateChat,
	ChatZoneBtn = ZhString.Chat_chatZone,
} -- Prefab里含UILongPress的组件名与其显示文字的Map
ChatRoomPage.LongPressEvent = "ChatRoomPage_LongPress"

ChatRoomPage.rid = ResourcePathHelper.UICell("ChatRoomCombineCell")

function ChatRoomPage:GetShowHideMode()
	return PanelShowHideMode.MoveOutAndMoveIn
end

function ChatRoomPage:Init()
	self:InitShow()
end

function ChatRoomPage:FindObjs()
	self.ChatRoom=self:FindGO("ChatRoom")
	self.ChatChannel = self:FindGO("ChatChannelView")
	self.PrivateChat = self:FindGO("PrivateChatView")
	self.ChatZone = self:FindGO("ChatZoneView")

	self.fadeInOutRoot=self:FindGO("fadeInOutRoot",self.ChatRoom)
	self.fadeInOutSymbol=self:FindGO("fadeInOutSymbol",self.ChatRoom):GetComponent(UISprite)
	self.fadeCloseSymbol=self:FindGO("fadeCloseSymbol",self.ChatRoom)
	self.fadeInOutRootTp=self.fadeInOutRoot:GetComponent(TweenPosition)

	self.channelToggle = self:FindGO("ChannelBtn",self.ChatRoom):GetComponent(UIToggle)
	self.privateChatToggle = self:FindGO("PrivateChatBtn",self.ChatRoom):GetComponent(UIToggle)
	self.chatZoneToggle = self:FindGO("ChatZoneBtn",self.ChatRoom):GetComponent(UIToggle)
	self.channelLongPress = self.channelToggle:GetComponent(UILongPress)
	self.privateChatLongPress = self.privateChatToggle:GetComponent(UILongPress)
	self.chatZoneLongPress = self.chatZoneToggle:GetComponent(UILongPress)

	self.channelLabel = self:FindGO("NameLabel" , self.channelToggle.gameObject):GetComponent(UILabel)
	self.privateChatLabel = self:FindGO("NameLabel" , self.privateChatToggle.gameObject):GetComponent(UILabel)
	self.chatZoneLabel = self:FindGO("NameLabel" , self.chatZoneToggle.gameObject):GetComponent(UILabel)
	self.channelIcon = self:FindGO("Icon" , self.channelToggle.gameObject):GetComponent(UISprite)
	self.privateChatIcon = self:FindGO("Icon" , self.privateChatToggle.gameObject):GetComponent(UISprite)
	self.chatZoneIcon = self:FindGO("Icon" , self.chatZoneToggle.gameObject):GetComponent(UISprite)

	self.canTalk = self:FindGO("CanTalk" , self.ChatRoom)
	self.sendButton=self:FindGO("sendButton",self.canTalk)

	self.inputRoot = self:FindGO("InputRoot" , self.canTalk)
	self.smiliesSprite=self:FindGO("smiliesSprite",self.canTalk)
	self.contentInput=self:FindGO("contentInput",self.canTalk):GetComponent(UIInput)
	UIUtil.LimitInputCharacter(self.contentInput, 39)

	----[[ todo xde 不翻译聊天内容，触发翻译时前置空格
	self.inputLabel = self:FindGO("Label", self:FindGO("contentInput",self.canTalk)):GetComponent(UILabel)
	self.addSpaceToInput = false
	self.specialChara = " "
	EventDelegate.Set(self.contentInput.onChange,function ()
		----[[
		if self.addSpaceToInput == true then
			if self.contentInput.value:sub(1,1) == self.specialChara then
				Debug.Log("删除空格")
				self.contentInput.value = self.contentInput.value:sub(2)
			else
				Debug.Log('竟然不是空格')
				Debug.Log(self.contentInput.value)
			end
			self.addSpaceToInput = false
		end
		local userInput = self.contentInput.value
		local key = userInput
		if OverSea.LangManager.Instance():GetLangByKey(key) ~= key then
			self.inputLabel.text = self.specialChara .. userInput
			redlog('onChange', 'self.inputLabel.text', self.inputLabel.text)
		end
		--]]
	end)
	self.hiddenValue = nil
	local func = function (go, state)
			if state == true and self.contentInput.value ~= nil and self.contentInput.value ~= '' then
				-- self.contentInput.value = self.hiddenValue
				self.addSpaceToInput = true
			elseif OverSea.LangManager.Instance():GetLangByKey(self.contentInput.value) ~= self.contentInput.value then
				self.hiddenValue = self.contentInput.value
				self.contentInput.value = self.specialChara .. self.contentInput.value
			end
			redlog('后执行', 'self.contentInput.value', self.contentInput.value, 'state', state)


		-- local key = self.contentInput.value
		-- redlog('后执行', 'key', key, 'state', state)
		-- if OverSea.LangManager.Instance():GetLangByKey(key) ~= key then
		-- 	self.inputLabel.text = self.specialChara .. key
		-- 	redlog('onChange', 'self.inputLabel.text', self.inputLabel.text)
		-- end
		-- if state == true then
		-- 	if key:sub(1,1) == self.specialChara then
		-- 		self.contentInput.value = key:sub(2)
		-- 	end
		-- else
		-- 	self.contentInput.value = self.specialChara .. key
		-- end
		-- redlog('self.contentInput.value', self.contentInput.value)
	end
	UIEventListener.Get(self.contentInput.gameObject).onSelect = {"+=", func}
	--]]

	self.CantTalk=self:FindGO("CantTalk",self.ChatRoom)
	self.CantTalkLabel=self:FindGO("CantTalkLabel"):GetComponent(UILabel)
	self.CantTalkSprite = self:FindGO("CantTalkSprite"):GetComponent(UISprite)

	self.inputInsertContent=self.contentInput:GetComponent(UIInputInsertContent)
	self.ContentScrollBg = self:FindGO("ContentScrollBg",self.ChatRoom):GetComponent(UIDragScrollView)
	self.tweenParent = self:FindGO("TweenParent"):GetComponent(TweenPosition)

	-- self.ContentScrollView = self:FindGO("CommonScrollView" , self.ChatRoom):GetComponent(UIScrollView)
	-- self.ContentPanel = self.ContentScrollView.gameObject:GetComponent(UIPanel)
	-- self.ContentTable = self:FindGO("CommonTable" , self.ChatRoom)

	self:FindPopUpWindow()

	if not MicrophoneManipulate.CanSpeech() then
		self.inputRoot:SetActive(false)
	end
end

function ChatRoomPage:FindPopUpWindow()
	self.PopUpWindow=self:FindGO("PopUpWindow")
	self.EmojiBtn=self:FindGO("EmojiBtn",self.PopUpWindow)
	self.TBtn=self:FindGO("TBtn",self.PopUpWindow)
	self.ItemBtn=self:FindGO("ItemBtn",self.PopUpWindow)
	self.ScrollBg=self:FindGO("ScrollBg",self.PopUpWindow):GetComponent(UIDragScrollView)
	self.PresetTextArrowBg = self:FindGO("PresetTextArrowBg" , self.PopUpWindow)
	self.TextEmojiArrowBg = self:FindGO("TextEmojiArrowBg" , self.PopUpWindow)
	self.CloseButton = self:FindGO("CloseButton" , self.PopUpWindow)
end

function ChatRoomPage:AddEvts()
	self:AddClickEvent(self.fadeInOutRoot,function (g)
		self:ClickfadeInOutRoot(g)
	end)
	self:AddClickEvent(self.channelToggle.gameObject,function (g)
		self:ClickChannelBtn(g)
	end)
	self:AddClickEvent(self.privateChatToggle.gameObject,function (g)
		self:ClickPrivateChatBtn(g)
	end)
	self:AddClickEvent(self.chatZoneToggle.gameObject,function (g)
		self:ClickChatZoneBtn(g)
	end)
	self:AddClickEvent(self.smiliesSprite,function (g)
		self:ClicksmiliesSprite(g)
	end)
	self:AddClickEvent(self.sendButton,function (g)
		FunctionSecurity.Me():TryDoRealNameCentify( self.ClicksendButton,self )
	end)
	self:AddClickEvent(self.EmojiBtn,function (g)
		self:ClickEmojiBtn(g)
	end)
	self:AddClickEvent(self.TBtn,function (g)
		self:ClickTBtn(g)
	end)
	self:AddClickEvent(self.ItemBtn,function (g)
		self:ClickItemBtn(g)
	end)
	self:AddClickEvent(self.CloseButton,function ()
		self.PopUpWindow:SetActive(false)
	end)
	self.tweenParent:SetOnFinished(function ()
		if self.tweenParent.value == self.tweenParent.to then
			--解决多次动画导致UIPanel(Soft Clip)内容丢失
			self.gameObject:SetActive(false)
			self.gameObject:SetActive(true)
		elseif self.tweenParent.value == self.tweenParent.from then
			self:CloseSelf()
		end
	end)
	local longPress = self.inputRoot:GetComponent(UILongPress)
	if(longPress)then
		longPress.pressEvent = function (obj, state)
			if state then
				ChatRoomProxy.Instance:TryRecognizer()
			else
				self:sendNotification(ChatRoomEvent.StopRecognizer)
			end
		end
	end

	-- LongPressEvent for TabNameTip
	local longPressEvent = function (obj, state)
		self:PassEvent(ChatRoomPage.LongPressEvent, {state, obj.gameObject});
	end
	self.channelLongPress.pressEvent = longPressEvent
	self.privateChatLongPress.pressEvent = longPressEvent
	self.chatZoneLongPress.pressEvent = longPressEvent
	self:AddEventListener(ChatRoomPage.LongPressEvent, self.HandleLongPress, self)

	-- self.ContentScrollView.onMomentumMove=function()
	-- 	local view = self:GetViewByState()
	-- 	if view == nil then return end

	-- 	if self.itemTableContent:GetIsMoveToFirst() then
	-- 		view:ResetNewMessage()				
	-- 	else
	-- 		view.isLock = true
	-- 	end
	-- end
end

 function ChatRoomPage:AddViewEvts()
 	self:AddListenEvt(ChatRoomEvent.CancelCreateChatRoom , self.CancelCreateChatRoom)
 	self:AddListenEvt(ChatRoomEvent.SendSpeech , self.SendSpeech)
 	self:AddListenEvt(ServiceEvent.ChatCmdQueryItemData , self.RecvQueryItemData)
 	self:AddListenEvt(ChatRoomEvent.StartVoice , self.StartVoice)
 	self:AddListenEvt(ChatRoomEvent.StopVoice , self.StopVoice)
 	self:AddListenEvt(ServiceEvent.ChatCmdChatRetCmd , self.RecvChatRetCmd)
 	self:AddListenEvt(ChatRoomEvent.SystemMessage , self.RecvSystemMessage)
 	self:AddListenEvt(ChatRoomEvent.KeywordEffect , self.RecvKeywordEffect)
 	self:AddListenEvt(ServiceEvent.NUserBoothReqUserCmd, self.RecvBoothInfo)
 end

function ChatRoomPage:InitShow()
	self.OutlineColor = { Default = "263E8C" , Toggle = "000000" }

	self:FindObjs()
	self:AddEvts()
	self:AddViewEvts()

	self.channelLabel.text = ZhString.Chat_channel
	self.privateChatLabel.text = ZhString.Chat_privateChat
	self.chatZoneLabel.text = ZhString.Chat_chatZone

	-- TabNameTip
	local iconActive, nameLabelActive
	if not GameConfig.SystemForbid.TabNameTip then -- 显示图标和气泡
		iconActive=true;nameLabelActive=false;
	else -- 不显示图标和气泡
		iconActive=false;nameLabelActive=true;
	end
	self.channelIcon.gameObject:SetActive(iconActive);
	self.privateChatIcon.gameObject:SetActive(iconActive);
	self.chatZoneIcon.gameObject:SetActive(iconActive);
	self.channelLabel.gameObject:SetActive(nameLabelActive);
	self.privateChatLabel.gameObject:SetActive(nameLabelActive);
	self.chatZoneLabel.gameObject:SetActive(nameLabelActive);

	self.chatChannelView=self:AddSubView("ChatChannelView",ChatChannelView)
	self.privateChatView = self:AddSubView("PrivateChatView",PrivateChatView)
	self.chatZoneView = self:AddSubView("ChatZoneView",ChatZoneView)
	self.chatTextEmojiPage=self:AddSubView("ChatTextEmojiPage",ChatTextEmojiPage)
	self.presetTextPage=self:AddSubView("PresetTextPage",PresetTextPage)
	self.chatItemPage=self:AddSubView("ChatItemPage",ChatItemPage)
	self.chatKeywordView = self:AddSubView("ChatKeywordView" , ChatKeywordView)

	-- self.itemTableContent = UITableListCtrl.new(self.ContentTable , "Chat" , 1)
	-- local config = {
	-- 	cellType = ChatTypeEnum.MySelfMessage,
	-- 	cellName = "ChatRoomMySelfCell",
	-- 	control = ChatRoomCell
	-- }
	-- self.itemTableContent:SetType(config)

	-- config.cellType = ChatTypeEnum.SomeoneMessage
	-- config.cellName = "ChatRoomSomeoneCell"
	-- config.control = ChatRoomCell
	-- self.itemTableContent:SetType(config)

	-- config.cellType = ChatTypeEnum.SystemMessage
	-- config.cellName = "ChatRoomSystemCell"
	-- config.control = ChatRoomSystemCell
	-- self.itemTableContent:SetType(config)

	-- self.itemTableContent:AddEventListener(ChatRoomEvent.SelectHead, self.HandleClickHead , self)
end

function ChatRoomPage:InitUI()
	self.PresetTextArrowBg:SetActive(false)
	self.TextEmojiArrowBg:SetActive(true)
	self:ShowFade(true)

	if self.viewdata.viewdata then
		if self.viewdata.viewdata.key == "ChatZone" then
			self:SwitchValue(ChatRoomEnum.CHATZONE)
			self:ShowFade(false)
		end
	else
		if ChatRoomProxy.Instance:GetChatRoomChannel() == ChatChannelEnum.Private then
			self:SwitchValue(ChatRoomEnum.PRIVATECHAT)
		elseif ChatZoomProxy.Instance:IsInChatZone() then
			self:SwitchValue(ChatRoomEnum.CHATZONE)
		else
			self:SwitchValue(ChatRoomEnum.CHANNEL)
		end
	end
	self.lastTime=0;
	-- self.contentInput.value=""

	self.PopUpWindow:SetActive(false)

	self.tweenParent:PlayForward()
	
	local privateChatSp = self.privateChatToggle.gameObject:GetComponent(UISprite)
	self:RegisterRedTipCheck(SceneTip_pb.EREDSYS_PRIVATE_CHAT, privateChatSp, nil, {-10,-10})
	
	self:UpdateChatZone()

	-- NetProtocol.AddListener(99, 1, function (id1,id2,dataBytes)
	-- 	print(type(dataBytes))
	-- 	local byteStream = ByteStream(dataBytes)
	-- 	local int = byteStream:ReadNetwork_string()
	-- end)

	-- self.testNum = 1
	-- self.timeTick = TimeTickManager.Me():CreateTick(0,500,self.ClicksendButton,self)
end

function ChatRoomPage:SetVisible(canTalk)
	self.canTalk:SetActive(canTalk)
	self.CantTalk:SetActive(not canTalk)
	self.CantTalkLabel.text=ZhString.Chat_cantTalk
	self.CantTalkSprite.width = self.CantTalkLabel.printedSize.x + 60
end

function ChatRoomPage:OnEnter()
	self.super.OnEnter(self)
	ServiceSessionSocialityProxy.Instance:CallFrameStatusSocialCmd(true)
	self:CameraRotateToMe(false, CameraConfig.UI_Msg_ViewPort, CameraController.singletonInstance.targetRotationEuler)
	self:InitUI()
end

function ChatRoomPage:OnExit()
	self.presetTextPage:SavePresetText()
	ChatRoomProxy.Instance.isEditorPresetText=false

	if ChatZoomProxy.Instance:IsInChatZone() then
		local data = ChatZoomProxy.Instance:CachedZoomInfo()
		ServiceChatRoomProxy.Instance:CallExitChatRoom(data.roomid, Game.Myself.data.id)
	end

	self:CameraReset()

 	self.ChatChannel:SetActive(true)
	self.PrivateChat:SetActive(true)

	ServiceSessionSocialityProxy.Instance:CallFrameStatusSocialCmd(false)

	self.super.OnExit(self)

	-- NetProtocol.RemoveListener(99, 1, nil)
end

function ChatRoomPage:ClickfadeInOutRoot(g)

	if ChatZoomProxy.Instance:IsInChatZone() then
		MsgManager.ConfirmMsgByID(810,function ()
			self:FadeInOut()
		end , nil , nil)
	else
		self:FadeInOut()
	end
end

function ChatRoomPage:FadeInOut()
	-- self:CloseSelf()
	GameFacade.Instance:sendNotification(ChatRoomEvent.ChangeChannel)
	self:CameraReset()
	self:ResetKeyword()
	self.tweenParent:PlayReverse()
end

function ChatRoomPage:ClickChannelBtn(g)	
	self:SwitchView(ChatRoomEnum.CHANNEL)
end

function ChatRoomPage:ClickPrivateChatBtn(g)
	self:SwitchView(ChatRoomEnum.PRIVATECHAT)
end

function ChatRoomPage:ClickChatZoneBtn()
	FunctionSecurity.Me():TryDoRealNameCentify( function ()
		self:SwitchView(ChatRoomEnum.CHATZONE)
	end,callbackParam )
end

function ChatRoomPage:ClicksmiliesSprite(g)
	self.PopUpWindow:SetActive(not self.PopUpWindow.activeSelf)
end

function ChatRoomPage:ClicksendButton(content,voice,voicetime)
	
	-- local fileBytes = FileDirectoryHandler.LoadFile("TestChatPb.bytes")

	-- local id1 = 99
	-- local id2 = 1
	-- local byteStream = ByteStream()
	-- byteStream:WriteNetwork_string("a")
	-- local bytes = byteStream.data
	-- local bytesLen = byteStream.dataLen
	-- print("byteStream.data : "..bytesLen)
	-- NetManager.GameSend(id1, id2, bytes, 0, bytesLen)

	-- if true then
	-- 	return
	-- end
	
	-- voice = FileDirectoryHandler.LoadFile("RO_1452928643.jpg")
	-- voicetime = 1

	if content == nil then
		content=self.contentInput.value
	end
	----[[ todo xde 已经被去掉特殊字符了，暂时不需要
	local key = content
	if OverSea.LangManager.Instance():GetLangByKey(key) ~= key then
		content = content .. self.specialChara
		redlog('ClicksendButton', '有空格', content)
	end
	--]]
	if(Game.ChatSystemManager:CheckChatContent(content)) then
		self:_EndSend()
		return
	end
	-- content = tostring(self.testNum)
	-- self.testNum = self.testNum + 1
	if(content and #content>0)then
		-- if(Time.realtimeSinceStartup-self.lastTime>2)then
			if self.CurrentState == ChatRoomEnum.CHANNEL then
				self.chatChannelView:SendMessage(content,voice,voicetime)
			elseif self.CurrentState == ChatRoomEnum.PRIVATECHAT then
				self.privateChatView:SendMessage(content,voice,voicetime)
			elseif self.CurrentState == ChatRoomEnum.CHATZONE then
				self.chatZoneView:SendMessage(content,voice,voicetime)
			end
			
			self:_EndSend()
		-- else
		-- 	MsgManager.FloatMsgTableParam(nil,ZhString.Chat_inputTooFrequently)
		-- end
	else
		MsgManager.FloatMsgTableParam(nil,ZhString.Chat_send)
	end
end

function ChatRoomPage:_EndSend()
	self.lastTime=Time.realtimeSinceStartup;
	self.contentInput.value=""
	ChatRoomProxy.Instance:ResetItemDataList()
end

function ChatRoomPage:IsInTeam()
	local isIn = true
	if(TeamProxy.Instance:IHaveTeam())then
		self:SetVisible(true)
	else
		self:SetVisible(false)
		self.CantTalkLabel.text=ZhString.Chat_notInParty
		self.CantTalkSprite.width = self.CantTalkLabel.printedSize.x + 60
		isIn = false
	end
	return isIn
end

function ChatRoomPage:IsInGuild()
	local isIn = true
	if GuildProxy.Instance:IHaveGuild() then
		self:SetVisible(true)
	else
		self:SetVisible(false)
		self.CantTalkLabel.text=ZhString.Chat_notInGuild
		self.CantTalkSprite.width = self.CantTalkLabel.printedSize.x + 60
		isIn = false
	end
	return isIn
end

function ChatRoomPage:ClickEmojiBtn(g)
	self.chatTextEmojiPage.ContentScrollView:ResetPosition()
	self.ScrollBg.scrollView = self.chatTextEmojiPage.ContentScrollView
end

function ChatRoomPage:ClickTBtn(g)
	self.presetTextPage.ContentScrollView:ResetPosition()
	self.ScrollBg.scrollView = self.presetTextPage.ContentScrollView
end

function ChatRoomPage:ClickItemBtn(g)
	self.chatItemPage.ContentScrollView:ResetPosition()
	self.ScrollBg.scrollView = self.chatItemPage.ContentScrollView
end

function ChatRoomPage:SetContentInputValue(content)
	if(content and #content>0)then
		self.inputInsertContent:InsertContent(content)
	end
end

function ChatRoomPage:SetDefaultColor()
 	if self.defaultResultC == nil then
 		local hasC = nil
		hasC , self.defaultResultC = ColorUtil.TryParseHexString(self.OutlineColor.Default)
	end
	if self.defaultResultC then
		self:SetColor(self.CurrentState,self.defaultResultC)
	end
end

 function ChatRoomPage:SetToggleColor()
 	if self.toggleResultC == nil then
 		local hasC = nil
		hasC , self.toggleResultC = ColorUtil.TryParseHexString(self.OutlineColor.Toggle)
	end
	if self.toggleResultC then
		self:SetColor(self.CurrentState,self.toggleResultC)
	end
 end

 function ChatRoomPage:SetColor(currentState,color)
 	if currentState == ChatRoomEnum.CHANNEL then
 		self.channelLabel.effectColor = color
 	elseif currentState == ChatRoomEnum.PRIVATECHAT then
 		self.privateChatLabel.effectColor = color
 	elseif currentState == ChatRoomEnum.CHATZONE then
 		self.chatZoneLabel.effectColor = color
 	end
 end

 function ChatRoomPage:SetCurrentState(state)
 	self:SetDefaultColor()
 	self.LastState = self.CurrentState
	self.CurrentState = state
	self:SetToggleColor()
 end

 function ChatRoomPage:SwitchView(state)
 	local tabNameTipData; local tabNameTipStick;

 	if state == ChatRoomEnum.CHANNEL then
 		self.ChatChannel:SetActive(true)
		self.PrivateChat:SetActive(false)
		self.ChatZone:SetActive(false)
		self.ContentScrollBg.scrollView = self.chatChannelView.contentScrollView
		self.chatKeywordView:SetPanel(self.chatChannelView.ContentPanel)
		self.chatChannelView:ResetPositionInfo(true)
		self.chatChannelView:ResetTalk()
		tabNameTipData=ZhString.Chat_channel
		tabNameTipStick=self.channelToggle
		-- self.ContentScrollView.gameObject:SetActive(false)

 	elseif state == ChatRoomEnum.PRIVATECHAT then
 		self.ChatChannel:SetActive(false)
		self.PrivateChat:SetActive(true)
		self.ChatZone:SetActive(false)		
		self.ContentScrollBg.scrollView = self.privateChatView.ContentScrollView
		self.chatKeywordView:SetPanel(self.privateChatView.ContentPanel)
		-- self.ContentScrollView.gameObject:SetActive(true)
		self.privateChatView:UpdateChat()
		self.privateChatView:ResetTalk()
		self.privateChatView:ClearRedTip()
		tabNameTipData=ZhString.Chat_privateChat
		tabNameTipStick=self.privateChatToggle

 	elseif state == ChatRoomEnum.CHATZONE then
 		self.ChatChannel:SetActive(false)
		self.PrivateChat:SetActive(false)	
		if not ChatZoomProxy.Instance:IsInChatZone() then
			self:sendNotification(UIEvent.ShowUI, { viewname = "CreateChatRoom" })
			self.ChatZone:SetActive(false)
			TipManager.Instance:CloseTabNameTip()
			-- self.chatZoneView:ShowView(false)
		else
			self.ChatZone:SetActive(true)
			-- self.chatZoneView:ShowView(true)	
			self.chatZoneView:UpdateChat()
		end
		self.ContentScrollBg.scrollView = self.chatZoneView.ContentScrollView
		self.chatKeywordView:SetPanel(self.chatZoneView.ContentPanel)
		self.chatZoneView:ResetTalk()
		tabNameTipData=ZhString.Chat_chatZone
		tabNameTipStick=self.chatZoneToggle
 	end

 	self:SetCurrentState(state)
 	self:ResetKeyword()
 end

 function ChatRoomPage:SwitchValue(state)
 	if state == ChatRoomEnum.CHANNEL then
 		self.channelToggle.value = true
 	elseif state == ChatRoomEnum.PRIVATECHAT then
 		self.privateChatToggle.value = true
	elseif state == ChatRoomEnum.CHATZONE then
		FunctionSecurity.Me():TryDoRealNameCentify( function ()
			self.chatZoneToggle.value = true		
			self:SwitchView(state)
 		end,callbackParam )
		return;
	end
	self:SwitchView(state)
 end

local tipData = {}
local funkey = {
		"InviteMember",
		"SendMessage",
		"AddFriend",
		"ShowDetail",
		"AddBlacklist",
		"InviteEnterGuild",
		"Tutor_InviteBeTutor",
		"Tutor_InviteBeStudent",
	}
 function ChatRoomPage:HandleClickHead(cellctl)
	local data = cellctl.data
	local id = data:GetId()

	if id == Game.Myself.data.id then
		return
	elseif data.roleType == ChatRoleEnum.Pet or data.roleType == ChatRoleEnum.Npc then
		return
	end

	local playerData = PlayerTipData.new()
	playerData:SetByChatMessageData(data)

	FunctionPlayerTip.Me():CloseTip();

	local playerTip = FunctionPlayerTip.Me():GetPlayerTip( cellctl.headIcon.clickObj , NGUIUtil.AnchorSide.Right, {10,60})

	tipData.playerData = playerData
	tipData.funckeys = funkey

	playerTip:SetData(tipData)
	playerTip:AcitiveIdObj(false)
end

function ChatRoomPage:StartVoice(note)
	local voiceId = FunctionChatSpeech.Me():GetCurrentVoiceId()
	if voiceId then
		cell = self:HandleVoice(voiceId)

		if cell then
			cell:StartVoiceTween()
		end
	end
end

function ChatRoomPage:StopVoice(note)
	local voiceId = FunctionChatSpeech.Me():GetCurrentVoiceId()
	if voiceId then
		cell = self:HandleVoice(voiceId)

		if cell then
			cell:StopVoiceTween()
		end	
	end
end

function ChatRoomPage:HandleVoice(voiceId)
	local cell
	if self.CurrentState == ChatRoomEnum.CHANNEL then
		cell = self:GetCellByVoiceId(self.chatChannelView.itemContent , voiceId)
	elseif self.CurrentState == ChatRoomEnum.PRIVATECHAT then
		cell = self:GetCellByVoiceId(self.privateChatView.itemContent , voiceId)
	elseif self.CurrentState == ChatRoomEnum.CHATZONE then
		cell = self:GetCellByVoiceId(self.chatZoneView.itemContent , voiceId)
	end
	return cell
end

function ChatRoomPage:GetCellByVoiceId(wrapScrollViewHelper,id)
	local cells = wrapScrollViewHelper:GetCells()
	if cells then
		for k,v in pairs(cells) do
			local cell = v:GetCurrentCell()
			if cell then
				local data = cell.data
				if data and data.GetVoiceid ~= nil then
					local voiceid = data:GetVoiceid()
					if voiceid and voiceid == id then
						return cell
					end
				end
			end
		end
	end

	return nil
end

function ChatRoomPage:CancelCreateChatRoom()
	if not ChatZoomProxy.Instance:IsInChatZone() then
		self:SwitchLastState()
	end
end

function ChatRoomPage:SwitchLastState()
	local state = ChatRoomEnum.CHANNEL
	if self.LastState and self.LastState ~= ChatRoomEnum.CHATZONE then
		state = self.LastState
	end
	-- print("SwitchLastState : "..state)
	self:SwitchValue(state)
end

function ChatRoomPage:AddKeywordEffect(data)
	self.chatKeywordView:AddKeywordEffect(data)
end

function ChatRoomPage:ResetKeyword()
	self.chatKeywordView:Reset()
end

function ChatRoomPage:SendSpeech(note)
	local data = note.body
	self:ClicksendButton(data.content,data.voice,data.voicetime)
end

function ChatRoomPage:RecvQueryItemData(note)
	local itemData = note.body.data
	if itemData then
		local item = ItemData.new(itemData.base.guid,itemData.base.id)
		item:ParseFromServerData(itemData)

		TipManager.Instance:ShowItemTip(item , {} , self.fadeInOutSymbol , NGUIUtil.AnchorSide.Right, {165,0})
	end
end

function ChatRoomPage:RecvChatRetCmd(note)
	self.chatChannelView:RecvChatRetUserCmd(note)
	self.privateChatView:HandleChatRetUserCmd(note)
	self.chatZoneView:OnReceiveChatMessage(note)
end

function ChatRoomPage:RecvSystemMessage(note)
	self.chatChannelView:RecvChatRetUserCmd(note)
	self.privateChatView:HandleChatRetUserCmd(note)	
end

function ChatRoomPage:RecvKeywordEffect(note)
	self.chatChannelView:HandleKeywordEffect(note)
	self.privateChatView:HandleKeywordEffect(note)
	self.chatZoneView:HandleKeywordEffect(note)	
end

function ChatRoomPage:RecvBoothInfo(note)
	local data = note.body
	if data then
		self:UpdateChatZone()
	end
end

function ChatRoomPage:ShowFade(isShowInOut)
	self.fadeInOutSymbol.gameObject:SetActive(isShowInOut)
	self.fadeCloseSymbol:SetActive(not isShowInOut)
end

function ChatRoomPage:GetViewByState(state)
	state = state or self.CurrentState
	if state == nil then
		return nil
	end
	if state == ChatRoomEnum.CHANNEL then
		return self.chatChannelView
	elseif state == ChatRoomEnum.PRIVATECHAT then
		return self.privateChatView
	elseif state == ChatRoomEnum.CHATZONE then
		return self.chatZoneView
	end
end

function ChatRoomPage:UpdateChatZone()
	self.chatZoneToggle.gameObject:SetActive(not Game.Myself:IsInBooth())
end

function ChatRoomPage:HandleLongPress(param)
	local isPressing, go = param[1], param[2];

	-- Show TabNameTip （ChatZoneBtn的TabNameTip写在ClickChatZoneBtn的回调里）
	if not GameConfig.SystemForbid.TabNameTip then
		if isPressing then
			local backgroundSp = go:GetComponent(UISprite);
			TipManager.Instance:TryShowHorizontalTabNameTip(ChatRoomPage.TabName[go.name], backgroundSp, NGUIUtil.AnchorSide.Left)
		else
			TipManager.Instance:CloseTabNameTipWithFadeOut()
		end
	end
end
