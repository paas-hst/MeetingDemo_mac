//
//  FspMeetingVC.swift
//  MacFspNewDemo
//
//  Created by 张涛 on 2019/4/4.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

let welcomeStr = "欢迎来到好视通演示Demo!"
extension NSView {
    
    static func loadFromNib(nibName: String, owner: Any?) -> NSView? {
        
        var arrayWithObjects: NSArray?
        
        let nibLoaded = Bundle.main.loadNibNamed(NSNib.Name(nibName), owner: owner, topLevelObjects: &arrayWithObjects)
        
        if nibLoaded {
            guard let unwrappedObjectArray = arrayWithObjects else { return nil }
            for object in unwrappedObjectArray {
                if object is NSView {
                    return object as? NSView
                }
            }
            return nil
        } else {
            return nil
        }
    }
}

class FspMeetingVC: FspWindowVC,NSTableViewDelegate,NSTableViewDataSource,NSWindowDelegate,FspCollectionViewCellDelegate,FspManagerRemoteEventDelegate,NSTextViewDelegate{

    func onInviteIncome(_ InviterUserId: String, inviteId nInviteId: Int32, groupId nGroupId: String, msg message: String?) {
        print("收到邀请")
    }
    
    func onInviteAccepted(_ RemoteUserId: String, inviteId nInviteId: Int32) {
        print("接受邀请")
        self.addMsgInviteData(user_id: RemoteUserId, invite_id: nInviteId, extrgMsg: "接受邀请！")
    }
    
    func onInviteRejected(_ RemoteUserId: String, inviteId nInviteId: Int32) {
        print("拒绝邀请")
        self.addMsgInviteData(user_id: RemoteUserId, invite_id: nInviteId, extrgMsg: "拒绝邀请！")
    }
    
    func addMsgInviteData(user_id: String, invite_id: Int32,extrgMsg: String) -> Void {
        print("发送邀请***************")
        /*
        DispatchQueue.main.async {
            var decriptionStr: String? = "用户"
            decriptionStr = decriptionStr! + user_id + extrgMsg
            let msgModel = FspMsgModel()
            msgModel.descriptionString = decriptionStr
            self.msgDataSource.add(msgModel)
            self.msgTableView.reloadData()
        }
        */
    }
    
    
    func remoteVideoEvent(_ userId: String, videoId: String, eventType: FspRemoteVideoEvent) {
        print("收到远端视频")
        
        let attendeeModel = self.getAttendeeModelWithUrsId(userId: userId)
         if attendeeModel != nil {
            if videoId == FSP_RESERVED_VIDEOID_SCREENSHARE {
                //桌面共享
                if eventType == .FSP_REMOTE_VIDEO_PUBLISH_STARTED {
                    attendeeModel!.isScreenShareOpen = true
                }else if eventType == .FSP_REMOTE_VIDEO_PUBLISH_STOPED{
                    attendeeModel!.isScreenShareOpen = false
                }
            }else{
                //视频
                if eventType == .FSP_REMOTE_VIDEO_PUBLISH_STARTED {
                    attendeeModel!.isCameraOpen = true
                }else if eventType == .FSP_REMOTE_VIDEO_PUBLISH_STOPED{
                    attendeeModel!.isCameraOpen = false
                }
            }
             self.updateAttendeeModelStatusWithModel(attendeeModel: attendeeModel!)
         }
        
        DispatchQueue.main.async {

            let cell = self.getFreeCell(user_id: userId,video_id: videoId)
            print("cell == ",cell as Any)
            if cell == nil {
                print("没有空闲的cell")
                //model.messageText = NSString(format: "当前没有空闲的窗口来展示用户id:%@", userId) as String
                //self.msgDataArr.add(model)
                //self.MessageListView.reloadData()
                return
            }
            
            if eventType == .FSP_REMOTE_VIDEO_PUBLISH_STARTED {
                //远端广播
                //远端增加
                _ = fsp_manager.setRemoteVideoRender(nUserId: userId, nVideoId: videoId, nRenderView: cell!.renderView!, nMode: .FSP_RENDERMODE_FIT_CENTER)
                cell?.user_Id = userId
                cell?.video_Id = videoId
                cell!.userid_text.stringValue = userId
                cell!.isVideoUsed = true
                cell!.noVideoStatusView.isHidden = true
                
            }else if eventType == .FSP_REMOTE_VIDEO_PUBLISH_STOPED {
                //远端停止
                _ = fsp_manager.setRemoteVideoRender(nUserId: userId, nVideoId: videoId, nRenderView: nil, nMode: .FSP_RENDERMODE_FIT_CENTER)
                cell!.userid_text.stringValue = ""
                cell!.isVideoUsed = false
                cell!.noVideoStatusView.isHidden = false
                
               // model.messageText = FspTools.createCustomModelStr(user_id: userId, eventStr: fsp_tool_remote_video_close)
                
                
            }else{
                //远端视频加载完成第一帧
                print("渲染视频第一帧")
               // DebugLogTool.debugLog(item: "渲染视频第一帧")
               // model.messageText =  NSString(format: "渲染视频第一帧 用户id:%@", userId) as String
            }
            
           // self.msgDataArr.add(model)
           // self.MessageListView.reloadData()
            
        }
    }
    
    //查找相应的在线列表模型
    func getAttendeeModelWithUrsId(userId: String!) -> listStatusModel? {
        var attendeeModel: listStatusModel?
        for model in listDataSourceArr {
            if (model as! listStatusModel).user_id == userId{
                attendeeModel = (model as! listStatusModel)
                break
            }
        }
        return attendeeModel
    }
    
    func updateAttendeeModelStatusWithModel(attendeeModel: listStatusModel) -> Void {

          listDataSourceArr.enumerateObjects { (obj, idx, objcBool) in
              let attendeeObj = obj as! listStatusModel
              if attendeeModel.user_id == attendeeObj.user_id{
                  attendeeObj.isAudioOpen = attendeeModel.isAudioOpen
                  attendeeObj.isCameraOpen = attendeeModel.isCameraOpen
                  attendeeObj.isScreenShareOpen = attendeeModel.isScreenShareOpen
                  objcBool.pointee = true
              }
          }
          
          self.updateAttendeeTableViewOnMainThread()
    }
    
    //更新列表
    func updateAttendeeTableViewOnMainThread() -> Void {
        if Thread.current == Thread.main {
            self.tableViewlist.reloadData()
        }else{
            DispatchQueue.main.async {
                self.tableViewlist.reloadData()
            }
        }
    }

    func remoteAudioEvent(_ userId: String, eventType: FspRemoteAudioEvent) {
        print("收到远端音频")
        
        let attendeeModel = self.getAttendeeModelWithUrsId(userId: userId)
        if attendeeModel != nil {
            if eventType == .FSP_REMOTE_AUDIO_EVENT_PUBLISHED {
                attendeeModel!.isAudioOpen = true
            }else if eventType == .FSP_REMOTE_AUDIO_EVENT_PUBLISH_STOPED{
                attendeeModel!.isAudioOpen = false
            }
            self.updateAttendeeModelStatusWithModel(attendeeModel: attendeeModel!)
        }
        
        DispatchQueue.main.async {
            
            let cell = self.getFreeCell(user_id: userId,video_id: "")
            print("cell == ",cell as Any)
            if cell == nil {
                print("没有空闲的cell")
                return
            }
            
            if eventType == .FSP_REMOTE_AUDIO_EVENT_PUBLISHED {
                //远端广播
                //远端增加
                cell?.user_Id = userId
                cell!.isAudioUsed = true
                print("设置音频状态")
                
            }else if eventType == .FSP_REMOTE_AUDIO_EVENT_PUBLISH_STOPED {
                //远端停止
                cell!.isAudioUsed = false
                print("关闭音频状态")
            }
        }
      
    }
    
    func doubleClickEventSendOut(clickGesture: NSClickGestureRecognizer) {
        
        let width = self.collectionView.bounds.width
        let height = self.collectionView.bounds.height
        
        let view = clickGesture.view as! FspCollectionViewCell
        if view.isFullScreen == false{
            view.isFullScreen = true
            print("全屏")
            view.frame = NSRect(x: 0, y: 0, width: width, height: height)
            for viewCell in self.cellsArr {
                let NewCell = viewCell as! FspCollectionViewCell
                if NewCell != view {
                    NewCell.frame = NSRect(x: 0, y: 0, width: 0, height: 0)
                }else{
                    //NewCell.frame = NewCell.normalFrame!
                }
            }
            
            self.fullGestureDidClicked = clickGesture
            
        }else{
            view.isFullScreen = false
            print("关闭全屏")
            view.frame = view.normalFrame!
            for viewCell in self.cellsArr {
                let NewCell = viewCell as! FspCollectionViewCell
                if NewCell != view {
                    NewCell.frame = NewCell.normalFrame!
                }else{
                    //NewCell.isHidden = false
                }
            }
            
            self.fullGestureDidClicked = nil
        }
     
      //  self.window!.toggleFullScreen(nil)
        
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        
    }
    
    func windowWillExitFullScreen(_ notification: Notification) {
        
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        
    }
    
  
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    //MARK://刷新会议
    var i = 0
    
    var listDataSourceArr = NSMutableArray()
    override func updateListTableView(dataSourceArr: NSMutableArray) -> Void {
        
        return
        super .updateListTableView(dataSourceArr: dataSourceArr)
        lock.lock()
        DispatchQueue.main.async {
            let minArr = NSMutableArray()
            var isFind = false
            if dataSourceArr.count > 0{
                for model in dataSourceArr {
                    let newModel = model as! FspUserInfo
                    for fs in self.listDataSourceArr {
                        let oldModel = fs as! listStatusModel
                        if oldModel.user_id == newModel.userId{
                            //老模型里面有新的模型，则保存
                            let model = listStatusModel()
                            if newModel.userStatus == FspUserStatus.FSP_USER_STATUS_ONLINE{
                                model.is_online = 1
                            }else if newModel.userStatus == FspUserStatus.FSP_USER_STATUS_OFFLINE{
                                model.is_online = 0
                            }
                            model.is_selected = oldModel.is_selected
                            model.user_id = newModel.userId
                            minArr.add(model)
                            isFind = true
                            break
                        }else{
                            isFind = false
                        }
                        
                        
                    }
                    
                    if isFind == false{
                        //老模型里面没有新的模型，则直接添加新的
                        let model = listStatusModel()
                        if newModel.userStatus == FspUserStatus.FSP_USER_STATUS_ONLINE{
                            model.is_online = 1
                        }else if newModel.userStatus == FspUserStatus.FSP_USER_STATUS_OFFLINE{
                            model.is_online = 0
                        }
                        model.is_selected = false
                        model.user_id = newModel.userId
                        minArr.add(model)
                        continue;
                    }
                    
                }
                
                self.listDataSourceArr.removeAllObjects()
                self.listDataSourceArr.addObjects(from: minArr as! [Any])
                self.tableViewlist.reloadData()
            }

        }
        lock.unlock()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if tableView == self.tableViewlist {
            if self.listDataSourceArr.count == 0 {
                return 0
            }else{
                return self.listDataSourceArr.count
            }
            
        }
        
        if tableView == self.msgTableView {
            if self.msgDataSource.count == 0 {
                return 0
            }else{
                return self.msgDataSource.count
            }
        }
       
        return 0

    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView == self.tableViewlist {
            return 60
        }
        
        if tableView == msgTableView {
            let msgModel = self.msgDataSource[row] as! FspMsgModel
            let msgDescription = msgModel.descriptionString!
            return self.messageFrame(messageText: msgDescription).size.height
        }
        
        return 200
    }
    
    override func onReceiveUserMsg(_ nSrcUserId: String, msg nMsg: String, msgId nMsgId: Int32) -> Void {
        
        print("收到用户信息")
        let model = self.createModel(msgType: .ByRemoteUser, msgStr: nMsg, userId: nSrcUserId)
        self.refreshTableViewByMsgModel(msgModel: model)

    }
    
    override func onReceiveGroupMsg(_ nSrcUserId: String, msg nMsg: String, msgId nMsgId: Int32) -> Void {
        
        print(nSrcUserId)
        print("收到群消息")
        let model = self.createModel(msgType: .ByRemoteUser, msgStr: nMsg, userId: nSrcUserId)
        self.refreshTableViewByMsgModel(msgModel: model)
        
    }
    
    func refreshTableViewByMsgModel(msgModel: FspMsgModel) -> Void {
        //MARK:刷新列表
        if Thread.current == Thread.main {
            self.msgDataSource.append(msgModel)
            self.msgTableView.reloadData()
            self.msgTableView.scrollRowToVisible(self.msgDataSource.count - 1)
        }else{
            DispatchQueue.main.sync {
                self.msgDataSource.append(msgModel)
                self.msgTableView.reloadData()
                self.msgTableView.scrollRowToVisible(self.msgDataSource.count - 1)
            }
        }
 
    }
    
    
    
    func createModel(msgType: FspMsgModelType!, msgStr: String!, userId: String!) -> FspMsgModel {
        let model = FspMsgModel()
       
        var description = ""
        let color = NSColor.init(red: 106.0/255, green: 125.0/255, blue: 254.0/255, alpha: 1.0)
        if msgType == FspMsgModelType.ByUser {
            
            model.time_user_info_Str = model.calendarString + " " + "我对 " + userId + " " + "说: "
            model.msgType = FspMsgModelType.ByUser
            
        }else if msgType == FspMsgModelType.ByRemoteUser{
            
            model.time_user_info_Str = model.calendarString + " " + userId + " " + "对我说: "
            model.msgType = FspMsgModelType.ByRemoteUser
            
        }else{
            
            //系统消息
            print("&&&&&&&& 系统消息")
            model.time_user_info_Str = model.calendarString + " "
            model.msgType = FspMsgModelType.BySystem
            
        }
        
        model.descriptionString = msgStr
        return model
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableView == self.msgTableView {
            let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CusMsgCell"), owner: nil) as! FspMeetingMsgViewCell
            let msgModel = self.msgDataSource[row]
            if msgModel.msgType == FspMsgModelType.BySystem{
    
            }else{
               cellView.topMessageField.stringValue = msgModel.time_user_info_Str!
            }
            
            cellView.messageField.stringValue = msgModel.descriptionString!
            return cellView
        }
        
        if tableView == self.tableViewlist {
            let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MeetingListControlCell"), owner: nil) as! FspMeetingListControlCell
            let detailsModel = self.listDataSourceArr[row] as! listStatusModel
            if detailsModel.user_id == fsp_manager.userID
            {
                cellView.cellUserIdText.stringValue = detailsModel.user_id + "(我)"
            }else{
                cellView.cellUserIdText.stringValue = detailsModel.user_id
            }
            
            cellView.cellScreenShareBtn.isSelected = detailsModel.isScreenShareOpen
            cellView.cellMuteBtn.isSelected = detailsModel.isAudioOpen
            cellView.cellVideoBtn.isSelected = detailsModel.isCameraOpen
            
            return cellView
        }
        
        return onlineListTableCell()
    }
    
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return FspRowView()
    }
 
    func windowWillClose(_ notification: Notification) {
        perSecondTimer?.invalidate()
        perSecondTimer = nil
        NSApp.terminate(nil)
    }
    
    
    @IBOutlet weak var bottomView: NSView!
    
    @IBOutlet weak var videoChooseBtn: FspMeetingBtn!
    @IBOutlet weak var screenShareBtn: FspMeetingBtn!
    @IBOutlet weak var electricityBtn: FspMeetingBtn!
    
    
    @IBAction func videoBtnDidClick(_ sender: Any) {
        if videoChooseBtn.choosedOn == false {
            videoChooseBtn.choosedOn = true
        }
        
        electricityBtn.choosedOn = false
        screenShareBtn.choosedOn = false
    }
    @IBAction func electricityBtnDidClick(_ sender: Any) {
        
        if electricityBtn.choosedOn == false {
            electricityBtn.choosedOn = true
        }

        screenShareBtn.choosedOn = false
        videoChooseBtn.choosedOn = false
        
    }

    @IBAction func screenShareBtnDidClick(_ sender: Any) {
        if screenShareBtn.choosedOn == false {
            screenShareBtn.choosedOn = true
        }
        
        videoChooseBtn.choosedOn = false
        electricityBtn.choosedOn = false
    }
    
    
    @IBOutlet weak var topView: NSView!
    @IBOutlet weak var tableViewlist: NSTableView!
    
    
    var perSecondTimer: Timer?
    
    var refreashListTableSignal: RACSubject = RACSubject<AnyObject>()
    
    @IBOutlet weak var group_text_label: NSTextField!
    override func windowDidLoad() {
        super.windowDidLoad()
        //默认
        NSSound.setSystemVolume(0.5)
        speakerView.isHidden = true
        fsp_manager.delegate = self
        
        
        speakerView.wantsLayer = true
        speakerView.layer!.backgroundColor = NSColor.white.cgColor
        
        videoChooseBtn.choosedOn = true
        screenShareBtn.choosedOn = false
        electricityBtn.choosedOn = false
        self.addCells()
        self.updateCellFrames(isRefreash: false)
    
        for usr in fsp_manager.curGroupUsers {
            let model = listStatusModel()
            model.user_id = usr.useId
            model.is_selected = false
            model.is_online = 1
            listDataSourceArr.add(model)
        }
        
        self.tableViewlist.reloadData()

        refreashListTableSignal.subscribeNext { (obj) in
             for usr in fsp_manager.curGroupUsers {
                    let model = listStatusModel()
                    model.user_id = usr.useId
                    model.is_selected = false
                    model.is_online = 1
                self.listDataSourceArr.add(model)
            }
                
            self.tableViewlist.reloadData()
        }
        
        self.initChatDefault()
        
        //发一个系统消息
        let model = self.createModel(msgType: .BySystem, msgStr: welcomeStr, userId: fsp_manager.userID)
        self.refreshTableViewByMsgModel(msgModel: model)
        
        fsp_manager.onJoinedSingnal.subscribeNext { (obj) in
            let des = obj as! String
            let msgstr = des + "进入会议室！"
            let model = self.createModel(msgType: .BySystem, msgStr: msgstr, userId: fsp_manager.userID)
            self.refreshTableViewByMsgModel(msgModel: model)
            
            
            //刷新在线列表 增加
            let modelList = listStatusModel()
            modelList.user_id = des
            modelList.is_selected = false
            modelList.is_online = 1
            modelList.isCameraOpen = false
            modelList.isAudioOpen = false
            modelList.isScreenShareOpen = false
            self.listDataSourceArr.add(modelList)
            self.tableViewlist.reloadData()
            
            for id in self.listDataSourceArr {
                print(id)
            }
            //刷新消息按钮 增加
            let newItem = NSMenuItem(title: des, action: nil, keyEquivalent: "")
            newItem.tag = self.listDataSourceArr.count
            newItem.target = self
            self.popBtn_ChatUser.menu!.addItem(newItem)
        }
        
        fsp_manager.onLeftSingnal.subscribeNext { (obj) in
            let des = obj as! String
            let msgstr = des + "离开会议室！"
            let model = self.createModel(msgType: .BySystem, msgStr: msgstr, userId: fsp_manager.userID)
            self.refreshTableViewByMsgModel(msgModel: model)
            
            
            //刷新在线列表 移除
            self.listDataSourceArr.enumerateObjects({ (obj, idx, isStop) in
                let curModel = obj as! listStatusModel
                if des == curModel.user_id {
                    self.listDataSourceArr.remove(curModel)
                    isStop.pointee = true
                }
                
            })
            
            self.tableViewlist.reloadData()
            
            
            //刷新消息按钮 移除
            var item: NSMenuItem?
            var allGroupItem: NSMenuItem?
            for Item in self.popBtn_ChatUser.itemArray
            {
                if Item.title == des{
                    item = Item
                }
                
                if Item.title == "所有人"
                {
                    allGroupItem = Item
                }
            }
            
            if item != nil {
                self.popBtn_ChatUser.menu!.removeItem(item!)
            }
            
            if item?.title == self.CHATTOALLUSER_MENU_TAG
            {
                print("选中发送消息的退出了，切换发送所有人")
                self.popBtn_ChatUser.selectItem(withTitle: "所有人")
            }else{
                print("不是选择发送消息的人退出了")
            }
            
        }
        
        self.group_text_label.stringValue =  "用户ID: " + fsp_manager.userID! + " 分组ID: " + fsp_manager.groupID!
        
        perSecondTimer  = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
             self.onPerSecondTimer()
        }
        

        if fsp_manager.call_userIds.count > 0 {
            _ = fsp_manager.inviteUser(nUsersId: fsp_manager.call_userIds, nGroupId: fsp_manager.groupID!, nExtraMsg: "测试", nInviteId: inviteId)
            fsp_manager.call_userIds.removeAll()
        }
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func updateCellFrames(isRefreash: Bool) -> Void {
        
        let width = (self.collectionView.bounds.width + 1.0) / 3.0
        let height = (self.collectionView.bounds.height + 1.0 ) / 2.0
   
        for i in 0...5 {
            if i / 3 == 0{
                let cell = self.cellsArr[i] as! FspCollectionViewCell
                cell.delegate = self
                self.collectionView.addSubview(cell)
                cell.frame = NSRect(x: width * CGFloat(i % 3), y: height, width: width, height: height)
                cell.normalFrame = NSRect(x: width * CGFloat(i % 3), y: height, width: width, height: height)
                
            }
            
            if i / 3 == 1{
                let cell = self.cellsArr[i] as! FspCollectionViewCell
                cell.delegate = self
                self.collectionView.addSubview(cell)
                cell.frame = NSRect(x: width * CGFloat(i % 3), y: 0, width: width, height: height)
                cell.normalFrame = NSRect(x: width * CGFloat(i % 3), y: 0, width: width, height: height)
            }
        }
            

    }
    
    let inviteId = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
    
    
    func onPerSecondTimer() -> Void {
        for i in 0...5 {
            let cell = self.cellsArr[i] as! FspCollectionViewCell
            cell.upateStatus()
        }
    }
    
    func getFreeCell(user_id: String, video_id: String) -> FspCollectionViewCell? {
        for cell in self.cellsArr{
            let res_cell = cell as! FspCollectionViewCell
            if video_id.count == 0{
                //本地音频或者远端音频
                if res_cell.user_Id == user_id{
                    return res_cell
                }
                
            }else{
                //正常查找
                if res_cell.user_Id == user_id && res_cell.video_Id == video_id{
                    return res_cell
                }
            }
        }
        
        for i in 0...5 {
            let res_cell = self.cellsArr[i] as! FspCollectionViewCell
            if (res_cell.isVideoUsed == true || res_cell.isAudioUsed == true){
                continue
            }
            return res_cell
        }
        
        for i in 0...5 {
            let res_cell = self.cellsArr[i] as! FspCollectionViewCell
            if (res_cell.isVideoUsed == false && res_cell.isAudioUsed == false){
                return res_cell
            }
        }
        
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.tableViewlist.register(NSNib.init(nibNamed: NSNib.Name("FspMeetingListControlCell"), bundle: Bundle.main), forIdentifier: NSUserInterfaceItemIdentifier("MeetingListControlCell"))

        self.msgTableView.register(NSNib.init(nibNamed: NSNib.Name("FspMeetingMsgViewCell"), bundle: Bundle.main), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CusMsgCell"))
        
        self.topView.wantsLayer = true
        self.topView.layer?.backgroundColor = .white
        

        self.bottomView.wantsLayer = true
        self.bottomView.layer?.backgroundColor = .white
        
        self.collectionView.wantsLayer = true
        self.collectionView.layer?.backgroundColor = .white
        
        let color = NSColor.init(red: 98.0/255, green: 117.0/255, blue: 250.0/255, alpha: 1.0).cgColor
        
        self.bottomToolBar.wantsLayer = true
        self.bottomToolBar.layer?.backgroundColor = color
    }
    
    func windowWillStartLiveResize(_ notification: Notification) {
        print("######### resize ")
    }
    
    var fullGestureDidClicked: NSClickGestureRecognizer?
    func windowDidResize(_ notification: Notification)
    {
        self.updateCellFrames(isRefreash: true)
        
        
        let width = self.collectionView.bounds.width
        let height = self.collectionView.bounds.height
        if fullGestureDidClicked == nil {
            return
        }
        let view = fullGestureDidClicked!.view as! FspCollectionViewCell
        if view.isFullScreen == false{
            view.frame = NSRect(x: 0, y: 0, width: width, height: height)
            for viewCell in self.cellsArr {
                let NewCell = viewCell as! FspCollectionViewCell
                if NewCell != view {
                    NewCell.frame = NSRect(x: 0, y: 0, width: 0, height: 0)
                }else{
                    //NewCell.frame = NewCell.normalFrame!
                }
            }
            
        }else{

            for viewCell in self.cellsArr {
                let NewCell = viewCell as! FspCollectionViewCell
                if NewCell != view {
                    NewCell.frame = NSRect(x: 0, y: 0, width: 0, height: 0)
                }else{
                    //NewCell.isHidden = false
                    view.frame = NSRect(x: 0, y: 0, width: width, height: height)
                }
            }
        }
        
    }


    
    var arrayWithObjects: NSArray?
    
    
    
    lazy var cellsArr: NSMutableArray = {
        let cellsArr = NSMutableArray()
 
        return cellsArr
    }()
    
    
    func addCells() -> Void {

        for _ in 0...5{
            
            if let loadedNavButtons: FspCollectionViewCell = NSView.loadFromNib(nibName: "FspCollectionViewCell", owner: nil) as? FspCollectionViewCell {
                cellsArr.add(loadedNavButtons)
            }
            
        }
    }
    
    @IBOutlet weak var collectionView: NSView!
    @IBOutlet weak var bottomToolBar: NSView!
    @IBOutlet weak var popBtn_ChatUser: NSPopUpButton!
    @IBAction func settingBtnDidClick(_ sender: Any) {
        let settingWindow = FspSettingWindowController(windowNibName: NSNib.Name("FspSettingWindowController"))
        NSApplication.shared.runModal(for: settingWindow.window!)
        
    }
    
    //MARK:消息列表
    //MARK:发送消息
    var msgDataSource = Array<FspMsgModel>()
    @IBOutlet weak var msgView: NSView!
    @IBOutlet var inputSendMessage: FspTextView!
    @IBOutlet weak var msgTableView: NSTableView!
    
    var CHATTOALLUSER_MENU_TAG: String!
    @IBAction func popUpBtn_ChatUser(_ sender: Any) {
        
        print("选中")
        let pop = sender as! NSPopUpButton
        let item =  pop.selectedItem!
        print("选中indx == %d",item.tag)
        CHATTOALLUSER_MENU_TAG = item.title
    }
    
    private(set) var sendMsgId = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
    
    
    @IBOutlet weak var sendMsgBtn: NSButton!
    @IBAction func sendMsgBtnDidClick(_ sender: Any) {
        
        print("发送数据")
        var SendMessageFormation = "消息不能为空!"
        if inputSendMessage.string.count == 0 {
            _ = FspToolAlert.beginAlert(message: "警告", informativeText: SendMessageFormation, window: self.window!)
            return
        }
  
        let chatText = self.inputSendMessage.textStorage!.getPlainString()

        let items = self.popBtn_ChatUser.selectedItem
        var code = FspErrCode.FSP_ERR_OK
        if CHATTOALLUSER_MENU_TAG == "所有人" {
            //群消息
            code = fsp_manager.sendGroupMsg(nMsg: chatText, nMsgId: sendMsgId)
            print("群消息")
            
        }else{
            //用户消息
            let userId = items?.title
            code = fsp_manager.sendUsrMsg(nUserId: userId, nMsg: chatText, nMsgId: sendMsgId)
            print("用户消息")
        }
 
        if code == .FSP_ERR_OK {
            print("发送成功")
        }else{
            print("发送消息失败")
        }
        
        var model:FspMsgModel? = nil
        if self.popBtn_ChatUser.selectedItem!.title == "所有人" {
            model = self.createModel(msgType: .ByUser, msgStr: chatText, userId: "所有人")
        }else{
           model = self.createModel(msgType: .ByUser, msgStr: chatText, userId: fsp_manager.userID)
        }
        
        self.refreshTableViewByMsgModel(msgModel: model!)
        
        self.inputSendMessage.string = ""
        
        //显示placehold
    }
    
    func labelAutoCalculateRectWith(text: String, textFont: NSFont, maxSize: NSSize) -> NSSize {
        let attributes = [NSAttributedString.Key.font : textFont]
        let rect = (text as NSString).boundingRect(with: maxSize, options: NSString.DrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.size
    }
    
    //消息cell大小
    func messageFrame(messageText: String) -> NSRect {
        let timeRect = CGRect.zero
        var rect = CGRect.zero
        let maxWidth = 300.0 * 0.7 //- 60
        let size = self.labelAutoCalculateRectWith(text: messageText, textFont: NSFont.init(name: FONT_REGULAR, size: 12)!, maxSize: NSSize(width: CGFloat(maxWidth), height:  CGFloat(MAXFLOAT)))
        
        if messageText.count == 0 {
            return rect
        }
        rect = NSRect(x: CGFloat(300.0 * 0.1), y: timeRect.size.height + 10.0, width: CGFloat(maxWidth - 5.0), height: size.height > 44.0 ? size.height : 44.0)
        
        
        return rect
    }

    
    //MARK: Chat Init
    func initChatDefault() -> Void {
        self.defaultChatToAllUser()
    }

    
    func defaultChatToAllUser() -> Void {
        
     
        if self.listDataSourceArr.count >= 1 {
            self.listDataSourceArr.enumerateObjects { (obj, idx, isStop) in
                
                let model = obj as! listStatusModel
                var newItem: NSMenuItem?
                if model.user_id == fsp_manager.userID {
                    newItem = NSMenuItem(title: "所有人", action: nil, keyEquivalent: "")
                }else{
                    newItem = NSMenuItem(title: model.user_id, action: nil, keyEquivalent: "")
                }
                
                newItem!.tag = idx
                newItem!.target = self
                popBtn_ChatUser.menu!.addItem(newItem!)
                
            }
        }else{
            let newItem = NSMenuItem(title: "所有人", action: nil, keyEquivalent: "")
            newItem.tag = 0
            newItem.target = self
            popBtn_ChatUser.menu!.addItem(newItem)

        }
        
        popBtn_ChatUser.selectItem(withTitle: "所有人")
        CHATTOALLUSER_MENU_TAG = "所有人"
        
        self.inputSendMessage.onEnterSginal.subscribeNext { (obj) in
            self.sendMsgBtnDidClick(self.sendMsgBtn)
        }
 
    }
    
    func defaultChatInputText() -> Void {
        
    }
    
    //MARK: 呼叫
    @IBAction func callBtnDidClick(_ sender: Any) {
        let delegate:AppDelegate = NSApp!.delegate as! AppDelegate
        if delegate.callView != nil {
            delegate.callView?.window?.orderOut(nil)
            delegate.callView = nil
        }else{
           delegate.switchToCallingView()
        }
        
    }
    
    //MARK: 扬声器
    @IBOutlet weak var speakerView: NSView!
    @IBOutlet weak var speakerSlider: NSSlider!
    @IBOutlet weak var speakerVolumeLabel: NSTextField!
    @IBAction func speakerSliderDidChanged(_ sender: Any) {
        speakerVolumeLabel.stringValue = String(speakerSlider.integerValue)
        let slider = Float(speakerSlider.integerValue) / 100.0
        NSSound.setSystemVolume(slider)
    }
    
    @IBAction func showOrHideSpeakerVolumeSlider(_ sender: Any) {
        speakerView.isHidden = !speakerView.isHidden
  
    }
    
    
    //MARK: 广播音频
    var isAudioPublishing = false
    @IBOutlet weak var micPhoneBtnObjC: NSButton!
    @IBAction func micPhoneBtnDidClick(_ sender: Any) {

        let arrMicrophoneDevices =  fsp_manager.getMicrophoneDevices()
        if arrMicrophoneDevices.count <= 0 {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.addButton(withTitle: "确定")
            alert.messageText = "错误"
            alert.informativeText = "没有麦克风设备"
            alert.beginSheetModal(for: self.window!, completionHandler: nil)
            return
        }
        
        let index = fsp_manager.fsp_engine!.getCurrentMicrophoneDevice()
        
        let theMenu = NSMenu.init(title: "Microphone Contextual Menu")
        var nItemIndex = 0
        for microphoneDeviceInfo in arrMicrophoneDevices {
            let menuTitle = NSString(format: "  麦克风(%@)", microphoneDeviceInfo.deviceName! as NSString)
            let videoMenuItem = theMenu.insertItem(withTitle: menuTitle as String, action: #selector(onMenuItemMicphone(menuItem:)), keyEquivalent: "", at: nItemIndex)
            videoMenuItem.tag = microphoneDeviceInfo.deviceId
            
            if isAudioPublishing == true && microphoneDeviceInfo.deviceId == index {
                videoMenuItem.image = NSImage(named: NSImage.Name("checkbox_sel.png"))
            }else{
                videoMenuItem.image = NSImage(named: NSImage.Name("checkbox.png"))
            }

            nItemIndex = nItemIndex + 1
        }
        
        var locationInWindow : NSPoint = NSPoint(x: 0, y: 0)
        locationInWindow.x = micPhoneBtnObjC.frame.origin.x + 168.0/2.0
        locationInWindow.y = micPhoneBtnObjC.frame.origin.y + micPhoneBtnObjC.frame.size.height + theMenu.size.height;
        
        print(locationInWindow.x,locationInWindow.y)
        let eventType = NSEvent.EventType.leftMouseDown
        
        let fakeMouseEvent = NSEvent.mouseEvent(with: eventType, location: locationInWindow, modifierFlags: NSEvent.ModifierFlags.init(rawValue: 0), timestamp: 0, windowNumber: self.window!.windowNumber, context: self.window!.graphicsContext, eventNumber: 0, clickCount: 0, pressure: 0)
        NSMenu.popUpContextMenu(theMenu, with: fakeMouseEvent!, for: self.window!.contentView!)
    }
    
    @objc
    func onMenuItemMicphone(menuItem: NSMenuItem) -> Void {
        
        var msg = ""
        let menuIndex = menuItem.tag
        let cur_index = fsp_manager.fsp_engine!.getCurrentMicrophoneDevice()
        print(cur_index)
        let arrMicrophoneDevices =  fsp_manager.getMicrophoneDevices()
        if arrMicrophoneDevices.count == 1 {
            //只有一个设备
            if isAudioPublishing == true {
                let fspErr = fsp_manager.stopPublishAudio()
                msg = "用户id: " + fsp_manager.userID! + " 停止广播音频流！"
                if fspErr == FspErrCode.FSP_ERR_OK{
                   isAudioPublishing = false
                }else{
                   print("stop publish audio fail :%d",fspErr)
                }
            }else{
                let fspErr = fsp_manager.startPublishAudio()
                msg = "用户id: " + fsp_manager.userID! + " 开始广播音频流！"
                if fspErr == FspErrCode.FSP_ERR_OK{
                    isAudioPublishing = true
                }else{
                    isAudioPublishing = false
                    print("start publish audio fail :%d",fspErr)
                }
            }
            
        }else{
            //有广播 先停掉
            if isAudioPublishing == true {
                let fspErr = fsp_manager.stopPublishAudio()
                msg = "用户id: " + fsp_manager.userID! + " 停止广播音频流！"
                if fspErr == FspErrCode.FSP_ERR_OK{
                   isAudioPublishing = false
                }else{
                   print("stop publish audio fail :%d",fspErr)
                    return
                }
                
                if menuItem.tag != cur_index {
                    fsp_manager.fsp_engine!.setCurrentMicrophoneDevice(menuIndex)
                    let fspErr = fsp_manager.startPublishAudio()
                    msg = "用户id: " + fsp_manager.userID! + " 开始广播音频流！"
                    if fspErr == FspErrCode.FSP_ERR_OK{
                        isAudioPublishing = true
                    }else{
                        isAudioPublishing = false
                        print("start publish audio fail :%d",fspErr)
                    }
                }
                
            }else{
                //没广播
                fsp_manager.fsp_engine!.setCurrentMicrophoneDevice(menuIndex)
                let fspErr = fsp_manager.startPublishAudio()
                msg = "用户id: " + fsp_manager.userID! + " 开始广播音频流！"
                if fspErr == FspErrCode.FSP_ERR_OK{
                    isAudioPublishing = true
                }else{
                    isAudioPublishing = false
                    print("start publish audio fail :%d",fspErr)
                }
                
                
            }
            
            
            
        }

      
        
        let attendeeModel = self.getAttendeeModelWithUrsId(userId: fsp_manager.userID)
        if (attendeeModel != nil){
            attendeeModel!.isAudioOpen = isAudioPublishing
            self.updateAttendeeModelStatusWithModel(attendeeModel: attendeeModel!)
        }
        
        print("我开关音频广播")
    }
    
    
    //MARK: 广播视频
    @IBOutlet weak var cameraBtnObc: NSButton!
    @IBAction func cameraBtnDidClick(_ sender: Any) {
      
        let arrVideoDevices =  fsp_manager.getVideoDevices()
        if arrVideoDevices.count <= 0 {
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.addButton(withTitle: "确定")
            alert.messageText = "错误"
            alert.informativeText = "没有视频设备"
            alert.beginSheetModal(for: self.window!, completionHandler: nil)
            return
        }
        
        let theMenu = NSMenu.init(title: "Contextual Menu")
        var nItemIndex = 0
        for videoDeviceInfo in arrVideoDevices {
            let menuTitle = NSString(format: "  摄像头(%@)", videoDeviceInfo.deviceName! as NSString)
            let videoMenuItem = theMenu.insertItem(withTitle: menuTitle as String, action: #selector(onMenuItemVideo(menuItem:)), keyEquivalent: "", at: nItemIndex)
            videoMenuItem.tag = videoDeviceInfo.cameraId
            if fsp_manager.getCameraPublishedVideoId(cameraId: videoDeviceInfo.cameraId) == nil {
                videoMenuItem.image = NSImage(named: NSImage.Name("checkbox.png"))
            }else{
                videoMenuItem.image = NSImage(named: NSImage.Name("checkbox_sel.png"))
            }
            nItemIndex = nItemIndex + 1
        }
        
        var locationInWindow : NSPoint = NSPoint(x: 0, y: 0)
        locationInWindow.x = cameraBtnObc.frame.origin.x + 168.0/2.0
        locationInWindow.y = cameraBtnObc.frame.origin.y + cameraBtnObc.frame.size.height + theMenu.size.height;

        print(locationInWindow.x,locationInWindow.y)
        let eventType = NSEvent.EventType.leftMouseDown
        
        let fakeMouseEvent = NSEvent.mouseEvent(with: eventType, location: locationInWindow, modifierFlags: NSEvent.ModifierFlags.init(rawValue: 0), timestamp: 0, windowNumber: self.window!.windowNumber, context: self.window!.graphicsContext, eventNumber: 0, clickCount: 0, pressure: 0)
        NSMenu.popUpContextMenu(theMenu, with: fakeMouseEvent!, for: self.window!.contentView!)
    }
    
    @objc
    func onMenuItemVideo(menuItem: NSMenuItem) -> Void {
        
        print("我开关视频广播")
        let nCameraId = menuItem.tag
        //判断是否有多的videocell
        let videoId = self.generateVideoId(cameraId: nCameraId)
 
        print(fsp_manager.getCameraPublishedVideoId(cameraId: nCameraId) as Any)
        if fsp_manager.getCameraPublishedVideoId(cameraId: nCameraId) == nil {
            
           
            let fspErr = fsp_manager.publishVideo(videoId: videoId, cameraId: nCameraId)
            if fspErr != FspErrCode.FSP_ERR_OK {
                debugPrint("start publish video fail :%d",fspErr)
                fsp_manager.stopPublishVideo(videoId: videoId)
                let attendeeModel = self.getAttendeeModelWithUrsId(userId: fsp_manager.userID)
                if (attendeeModel != nil){
                    attendeeModel!.isCameraOpen = false
                    self.updateAttendeeModelStatusWithModel(attendeeModel: attendeeModel!)
                }
                return
            }else{
                let profile = FspVideoProfile(video_width, height: video_height, framerate: video_fsp)
                fsp_manager.fsp_engine!.setVideoProfile(videoId, profile: profile)
            }
        
            let cell = self.getFreeCell(user_id: videoId,video_id: videoId)
            if cell != nil{
                cell!.noVideoStatusView.isHidden = true
                cell?.isVideoUsed = true
                cell?.userid_text.stringValue = videoId
                
                cell?.video_Id = videoId
                cell?.user_Id = fsp_manager.userID
                
                _ = fsp_manager.addVideoPreview(nCameraId: nCameraId, nRenderView: cell!.renderView, nMode: .FSP_RENDERMODE_SCALE_FILL)
                let attendeeModel = self.getAttendeeModelWithUrsId(userId: fsp_manager.userID)
                if (attendeeModel != nil){
                    attendeeModel!.isCameraOpen = true
                    self.updateAttendeeModelStatusWithModel(attendeeModel: attendeeModel!)
                }
            }else{
                print("没有空闲的cell")
                return
            }
 
        }else{
            
            let videoId = self.generateVideoId(cameraId: nCameraId)
            _ = fsp_manager.stopPublishVideo(videoId: videoId)
            
            let attendeeModel = self.getAttendeeModelWithUrsId(userId: fsp_manager.userID)
            if (attendeeModel != nil){
                attendeeModel!.isCameraOpen = false
                self.updateAttendeeModelStatusWithModel(attendeeModel: attendeeModel!)
            }
            
            let cell = self.getFreeCell(user_id: fsp_manager.userID!,video_id: videoId)
            if cell != nil{
                _ = fsp_manager.removeVideoPreview(nCameraId: nCameraId, nRenderView: cell!.renderView)
                //得到当前的cell
                cell!.noVideoStatusView.isHidden = false
                cell!.isVideoUsed = false
             
            }else{
                print("没有空闲的cell")
                return
            }

        }
        
        
        self.msgTableView.reloadData()
    }

    func generateVideoId(cameraId: Int) -> String {
        return NSString(format: "macvideo%d", cameraId) as String
    }
    
    
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        return frameSize
    }
    
    deinit {
        print("FspMeetingVC dealloc")
    }
}
