//
//  AppDelegate.swift
//  MacFspNewDemo
//
//  Created by admin on 2019/4/1.
//  Copyright © 2019年 hst. All rights reserved.
//

import Cocoa
import ReactiveObjC

//FSP Manager
let fsp_manager = FspManager.manager
let theApp = NSApplication.shared.delegate as! AppDelegate

//用户自己的登录账号
let CONFIG_USE_ID_KEY = "config use id key"
//是否使用默认配置
let CONFIG_USE_DEFAULT_OPEN_KEY = "config use default open key"
//自定义的appid
let CONFIG_APP_ID_KEY = "config_app_id_key"
//自定义的app_secret
let CONFIG_APP_SECRET_KEY = "config_app_secret_key"
//自定义的服务器地址
let CONFIG_SERVER_ADDRESS_KEY = "config_server_address_key"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate ,FspManagerRemoteSignallingDelegate{
    
    var resetManager: RACSubject<AnyObject> = RACSubject()
    
    
    func onInviteIncome(_ InviterUserId: String, inviteId nInviteId: Int32, groupId nGroupId: String, msg message: String?) {
        if self.online != nil && self.online?.window!.isVisible == true {
            self.online!.show_invite_meeting_wnd(InviterUserId: InviterUserId, nInviterId: nInviteId, ngroupId: nGroupId, message: message)
        }
    }
    
    func onInviteAccepted(_ RemoteUserId: String, inviteId nInviteId: Int32) {
        if self.meetingVc != nil && self.online?.window?.isVisible == true {
            print("用户" + RemoteUserId + "已经接受邀请！ 邀请id为" + ((NSString(format: "%d", nInviteId)) as String))
        }
        
        if meetingVc != nil {
            let msg = "用户" + RemoteUserId + "已经接受邀请！邀请id为" + ((NSString(format: "%d", nInviteId)) as String)
            print(msg)
            /*
            meetingVc!.msgDataSource.add(msg)
            DispatchQueue.main.async {
                self.meetingVc!.msgTableView.reloadData()
            }
 */
        }
        
    }
    
    func onInviteRejected(_ RemoteUserId: String, inviteId nInviteId: Int32) {
        if self.meetingVc != nil && self.meetingVc?.window!.isVisible == true {
            print("用户" + RemoteUserId + "已经拒绝邀请！邀请id为" + ((NSString(format: "%d", nInviteId)) as String))
        }
        
        if meetingVc != nil {
            let msg = "用户" + RemoteUserId + "已经拒绝邀请！邀请id为" + ((NSString(format: "%d", nInviteId)) as String)
            print(msg)
            /*
            meetingVc!.msgDataSource.add(msg)
            DispatchQueue.main.async {
                self.meetingVc!.msgTableView.reloadData()
            }
 */
        }
        
        
    }

    var loginWindow: FspLoginWindow?
    var online: FspOnlineWindow?
    var meetingVc: FspMeetingVC?
    public var callView: FspCallingWindow?
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    
        fsp_manager.singallingDelegate = self
        
        loginWindow = FspLoginWindow(windowNibName: "FspLoginWindow")
        loginWindow?.window?.makeKeyAndOrderFront(nil)
        loginWindow?.window?.center()
        loginWindow?.window?.makeKey()
        fsp_manager.cur_window = loginWindow
        
        _ = fsp_manager.initFsp()
        
        self.resetManager.subscribeNext { (id) in
            fsp_manager.destoryFsp()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                if fsp_manager.initFsp() != FspErrCode.FSP_ERR_FAIL {
                    print("重设成功")
                }else{
                    print("重设失败")
                }
            })
            
        }
    }
    
    
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        }else{
            online = nil
            meetingVc = nil
            callView = nil
            fsp_manager.cur_window!.window!.makeKeyAndOrderFront(self)
            return true
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        _ = fsp_manager.leaveGroup()
        _ = fsp_manager.loginOut()
        _ = fsp_manager.destoryFsp()
    }


    public func switchToOnline(canSwitch: Bool) -> Void {
        self.loginWindow!.canSwitch = canSwitch
        appCanSwitch = canSwitch
        self.performSelector(onMainThread: #selector(gotoOnlineWindow), with: nil, waitUntilDone: false)
    }
    
    var appCanSwitch = false
    
    @objc
    func gotoOnlineWindow() -> Void {
        if appCanSwitch == true {
            self.loginWindow?.close()
            self.loginWindow?.window?.orderOut(nil)
            self.online = FspOnlineWindow(windowNibName: "FspOnlineWindow")
            self.online!.window!.makeKeyAndOrderFront(nil)
            online?.window?.center()
        }
        self.loginWindow?.showLoad_view(show: false)
    }
    
    @objc
    func gotoMainWindow() -> Void {
        self.online?.close()
        self.online?.window?.orderOut(nil)
        meetingVc = FspMeetingVC(windowNibName: "FspMeetingVC")
        meetingVc!.window!.makeKeyAndOrderFront(nil)
        meetingVc!.window?.center()
    }
    
    public func alertMessage(message: String)  -> Void {
     
        self.performSelector(onMainThread: #selector(alert(message:)), with: message, waitUntilDone: false)
        
    }
    
    @objc
    func alert(message: String) -> Void {
        
        let window = NSApp.keyWindow
        FspToolAlert.beginAlert(message: "错误", informativeText: message, window: window)
        
        
    }
    
    public func switchToMainView() -> Void {
        
        self.performSelector(onMainThread: #selector(gotoMainWindow), with: nil, waitUntilDone: false)
    }
    
    public func switchToCallingView() -> Void{
        self.performSelector(onMainThread: #selector(gotoCallingView), with: nil, waitUntilDone: false)
    }
    
    @objc
    func gotoCallingView() -> Void {
        if callView != nil {
            callView = nil
        }
        callView = FspCallingWindow(windowNibName: "FspCallingWindow")
        callView!.window!.makeKeyAndOrderFront(nil)
        callView!.window?.center()
        callView!.meetingWindow = self.meetingVc
    }
    

}

