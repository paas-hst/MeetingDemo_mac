//
//  FspOnlineWindow.swift
//  MacFspNewDemo
//
//  Created by admin on 2019/4/2.
//  Copyright © 2019年 hst. All rights reserved.
//

import Cocoa

class listStatusModel: NSObject {
    var user_id = ""
    //1 代表在线 0代表下线
    var is_online = 1
    //是否选中
    var is_selected = false
}

class FspOnlineWindow: FspWindowVC,NSTableViewDelegate,NSTableViewDataSource,NSWindowDelegate,NSTextFieldDelegate, FspInputTextFieldDelegate{
    
    
    
    
    //MARK:模糊搜索
    var searchedModels = Array<listStatusModel>()
    var use_searched_result: Bool?
    
    func FspInputTextFieldValueDidChange(text: String) {
        

        searchedModels.removeAll()
        self.listDataSourceArr.enumerateObjects { (model, index, isStop) in
            print(model)
            let getModel = model as! listStatusModel
            let inputTextCount = text.count
            if inputTextCount > getModel.user_id.count{
                
            }else{
                let nsRange = NSRange(location: 0, length: inputTextCount)
                let getModelStr = (getModel.user_id as NSString).substring(with: nsRange)
                if getModelStr == text{
                    searchedModels.append(getModel)
                }
            }
        }
        
        
        if text.count > 0 {
            use_searched_result = true
        }else{
            use_searched_result = false
        }
        DispatchQueue.main.async {
          self.listTableView.reloadData()
        }
        
    }
    
    override func windowWillClose() {

    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        //updateStatus()
        lock.lock()
        DispatchQueue.main.async {
            
            var model: listStatusModel!
            let text = self.listTableView.selectedRow
            if  self.use_searched_result == true{
                model  = self.searchedModels[text]
            }else{
                model  = (self.listDataSourceArr[text] as! listStatusModel)
            }
            if model.user_id == fsp_manager.userID{
                self.lock.unlock()
                return
            }
            model.is_selected = !model.is_selected
            self.listDataSourceArr.replaceObject(at: text, with: model)
            
            self.listTableView.reloadData()
        }
        lock.unlock()

    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if  use_searched_result == true{
            if self.searchedModels.count == 0 {
                return 0
            }else{
                return self.searchedModels.count
            }
        }else{
            if self.listDataSourceArr.count == 0 {
                return 0
            }else{
                return self.listDataSourceArr.count
            }
        }
    
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCell"), owner: nil) as! onlineListTableCell
        cellView.cellChooseImage.image = NSImage(named: "group_2")
        cellView.cellImageIcon.image = NSImage(named: "Group")
        
        var detailsModel: listStatusModel!
        
        if  use_searched_result == true{
            detailsModel  = self.searchedModels[row]
        }else{
            detailsModel  = (self.listDataSourceArr[row] as! listStatusModel)
        }
        
        cellView.cellTextLabel.stringValue = detailsModel.user_id
        if detailsModel.user_id == fsp_manager.userID {
            cellView.cellTextLabel.stringValue = detailsModel.user_id + "(我)"
            cellView.cellChooseImage.isHidden = true
        }else{
            cellView.cellChooseImage.isHidden = false
        }
        if detailsModel.is_selected {
            cellView.cellChooseImage.image = NSImage(named: "group_3")
        }else{
            cellView.cellChooseImage.image = NSImage(named: "group_2")
        }
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return FspRowView()
    }


    override func updateListTableView(dataSourceArr: NSMutableArray) -> Void {
        lock.lock()
        DispatchQueue.main.async {
            let minArr = NSMutableArray()
            var isFind = false
            for model in dataSourceArr {
                let newModel = model as! FspUsrInfo
                for fs in self.listDataSourceArr {
                    let oldModel = fs as! listStatusModel
                    if oldModel.user_id == newModel.userId{
                        //老模型里面有新的模型，则保存
                        let model = listStatusModel()
                        if newModel.userStatus == FspUsrStatus.FSP_USR_STATUS_ONLINE{
                            model.is_online = 1
                        }else if newModel.userStatus == FspUsrStatus.FSP_USR_STATUS_OFFLINE{
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
                    if newModel.userStatus == FspUsrStatus.FSP_USR_STATUS_ONLINE{
                        model.is_online = 1
                    }else if newModel.userStatus == FspUsrStatus.FSP_USR_STATUS_OFFLINE{
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
            self.listTableView.reloadData()
        }
        lock.unlock()
    }
    

    lazy var listDataSourceArr: NSMutableArray = {
        let listDataSourceArr = NSMutableArray()
        return listDataSourceArr
    }()
    @IBOutlet weak var topSelectView: NSView!
    @IBOutlet weak var listTableView: NSTableView!
    @IBOutlet weak var joinBtnDid: FspStateButton!
    lazy var dataArray: Array = { () -> [Any] in
        let dataArr = Array<Any>()
        return dataArr
    }()
    

    override func windowWillLoad() {
        super.windowWillLoad()
   
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.listTableView.register(NSNib.init(nibNamed: "onlineListTableCell", bundle: Bundle.main), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCell"))
        
        self.topSelectView.wantsLayer = true
        self.topSelectView.layer?.backgroundColor = .white
    }
    
    //MARK: 收到邀请
    @IBOutlet var _recevie_invite_meeting_wnd: NSWindow!
    @IBOutlet weak var _btn_meeting_Accept: FspStateButton!
    @IBOutlet weak var _btn_meeting_reject: FspStateButton!
    @IBOutlet weak var _text_meeting_description: NSTextField!
    var inviterUserId: String?
    var inviteId: Int32?
    var inviteGroupId: String?
    
    
    @IBAction func _btn_accpet_click(_ sender: Any) {
        if inviterUserId != nil && inviteId != nil {
            _ = fsp_manager.acceptInvite(nInviteUserId: inviterUserId!, nInviteId: inviteId!)
        }
        self.window?.endSheet(self._recevie_invite_meeting_wnd)
        
        _ = fsp_manager.joinGroup(nGroup: inviteGroupId!)
        fsp_manager.groupID = inviteGroupId!
    }
    
    
    @IBAction func _btn_reject_click(_ sender: Any) {
        if inviterUserId != nil && inviteId != nil {
           _ = fsp_manager.rejectInvite(nInviteUserId: inviterUserId!, nInviteId: inviteId!)
        }
        self.window?.endSheet(self._recevie_invite_meeting_wnd)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.joinBtnDid.setImages(NSImage.init(named: "login_btn"), hot: NSImage.init(named: "login_btn_hot"), press: NSImage.init(named: "login_btn_pressed"), disable: NSImage.init(named: "login_btn_pressed"))
        
        self._btn_meeting_Accept.setImages(NSImage.init(named: "login_btn"), hot: NSImage.init(named: "login_btn_hot"), press: NSImage.init(named: "login_btn_pressed"), disable: NSImage.init(named: "login_btn_pressed"))
        
        self._btn_meeting_reject.setImages(NSImage.init(named: "login_btn"), hot: NSImage.init(named: "login_btn_hot"), press: NSImage.init(named: "login_btn_pressed"), disable: NSImage.init(named: "login_btn_pressed"))

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window!.makeKey()
        fsp_manager.startRefresh()
        
        self.searchInputTextFiled.inputTextFieldDelegate = self

        self.window?.defaultButtonCell = self.joinBtnDid.cell as! NSButtonCell
    }

    @IBOutlet weak var searchInputTextFiled: FspInputTextField!
    
    
    func show_invite_meeting_wnd(InviterUserId: String,nInviterId: Int32, ngroupId: String, message: String?) -> Void {
        DispatchQueue.main.async {
            let inviteIdStr = NSString(format: "%d", nInviterId) as String
            let descriptionStr = "收到用户: " + InviterUserId + "的与会邀请！" + "邀请id: " + inviteIdStr + " 群组id: " + ngroupId
            self.inviterUserId = InviterUserId
            self.inviteId = nInviterId
            self.inviteGroupId = ngroupId
            self._text_meeting_description.stringValue = descriptionStr
            self.window?.beginSheet(self._recevie_invite_meeting_wnd, completionHandler: nil)
        }
        
    }

    @IBOutlet weak var inputGroupTextField: NSTextField!
    @IBAction func onlineCallingBtnDidClick(_ sender: Any) {
        

        for model in listDataSourceArr {
            let curModel = model as! listStatusModel
            if curModel.is_selected == true{
                fsp_manager.call_userIds.append(curModel.user_id)
            }
        }
        
        print("呼叫总人数",fsp_manager.call_userIds.count)
        
        if self.inputGroupTextField.stringValue.count == 0 {
            FspToolAlert.beginAlert(message: "错误", informativeText: "组名不能为空！", window: self.window!)
        }else{
            _ = fsp_manager.joinGroup(nGroup: self.inputGroupTextField.stringValue)
            fsp_manager.groupID = self.inputGroupTextField.stringValue

        }
    }
    
    deinit {
        print("FspOnlineWindow dealloc")
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if sender == self.window! {
            _ = fsp_manager.loginOut()
        }
        return true
    }
    
    
}
