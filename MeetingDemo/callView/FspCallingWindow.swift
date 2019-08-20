//
//  FspCallingWindow.swift
//  MeetingDemo
//
//  Created by 张涛 on 2019/4/12.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class FspCallingWindow: FspWindowVC, NSTableViewDelegate,NSTableViewDataSource,NSWindowDelegate,FspInputTextFieldDelegate{
    

    
    //MARK:模糊搜索
    var searchedModels = Array<listStatusModel>()
    var use_searched_result: Bool?
    func FspInputTextFieldValueDidChange(text: String) {
        searchedModels.removeAll()
        self.listDataSourceArr.enumerateObjects { (model, index, isStop) in
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
            self.tableView.reloadData()
        }
        
    }
    
    @IBOutlet weak var inputTextField: FspInputTextField!
    func tableViewSelectionDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            
            var model: listStatusModel!
            let text = self.tableView.selectedRow
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
            
            self.tableView.reloadData()
        }
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
        let detailsModel = self.listDataSourceArr[row] as! listStatusModel
        cellView.cellTextLabel.stringValue = detailsModel.user_id
        if detailsModel.user_id == fsp_manager.groupID {
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
    

    
    @IBOutlet weak var topBgView: NSView!
    @IBOutlet weak var bgView: NSView!
    @IBOutlet weak var tableView: NSTableView!

    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.bgView.wantsLayer = true
        self.bgView.layer?.backgroundColor = NSColor.white.cgColor
        
        self.topBgView.wantsLayer = true
        self.topBgView.layer?.backgroundColor = NSColor.white.cgColor
        
        self.inputTextField.inputTextFieldDelegate = self
        
    }

    override func updateListTableView(dataSourceArr: NSMutableArray) -> Void {
        lock.lock()
        weak var weakself = self
        DispatchQueue.main.async {
            let minArr = NSMutableArray()
            var isFind = false
            for model in dataSourceArr {
                let newModel = model as! FspUserInfo
                for fs in weakself!.listDataSourceArr {
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
            
            weakself!.listDataSourceArr.removeAllObjects()
            weakself!.listDataSourceArr.addObjects(from: minArr as! [Any])
            weakself!.tableView.reloadData()
        }
        lock.unlock()
    }
    
    
    lazy var listDataSourceArr: NSMutableArray = {
        let listDataSourceArr = NSMutableArray()
        return listDataSourceArr
    }()
    
    
    var meetingWindow: FspMeetingVC?
    @IBOutlet weak var bottomView: NSView!
    @IBOutlet weak var fspSeletedButton: NSButton!
    @IBOutlet weak var callBtn: FspStateButton!
    var inviteID = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
    @IBAction func callBtnDidClick(_ sender: Any) {
        print("呼叫")
        lock.lock()
        for model in self.listDataSourceArr {
            let NewModel = model as! listStatusModel
            if NewModel.is_selected == true{
                fsp_manager.call_userIds.append(NewModel.user_id)
            }
            
        }
        lock.unlock()
        if fsp_manager.call_userIds.count == 0 {
            return
        }
        
        _ = fsp_manager.inviteUser(nUsersId: fsp_manager.call_userIds, nGroupId: fsp_manager.groupID!, nExtraMsg: "测试", nInviteId: inviteID)
        fsp_manager.call_userIds.removeAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.register(NSNib.init(nibNamed: "onlineListTableCell", bundle: Bundle.main), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCell"))
       
        self.callBtn.setImages(NSImage.init(named: "login_btn"), hot: NSImage.init(named: "login_btn_hot"), press: NSImage.init(named: "login_btn_pressed"), disable: NSImage.init(named: "login_btn_pressed"))

        self.bottomView.wantsLayer = true
        self.bottomView.layer?.backgroundColor = NSColor.white.cgColor
    }
    @IBAction func fspSelectedButtonDidClick(_ sender: Any) {
       let cell = self.fspSeletedButton.cell as! FspCallBtnCell
        cell.selected = !cell.selected
        lock.lock()
 
        if cell.selected == true {
            //全选
            print("全选")
            if self.listDataSourceArr.count > 0{
                for model in self.listDataSourceArr {
                    let newModel = model as! listStatusModel
                    newModel.is_selected = true
                }
            }
        }else{
            //全不选
            print("全不选")
            if self.listDataSourceArr.count > 0{
                for model in self.listDataSourceArr {
                    let newModel = model as! listStatusModel
                    newModel.is_selected = false
                }
            }
        }
        
        self.tableView.reloadData()
        lock.unlock()
    }
    
    

    func windowWillClose(_ notification: Notification) {
        
        self.window?.orderOut(nil)
        let views = self.window?.contentView?.subviews
        for view in views! {
            (view as NSView).removeFromSuperview()
        }
        self.window = nil
        
        let app: AppDelegate = NSApp.delegate as! AppDelegate
        app.meetingVc?.window?.makeKey()
        listDataSourceArr.removeAllObjects()
    }
    
    
    deinit {
        print("FspCallingWindow dealloc")
    }
    
}
