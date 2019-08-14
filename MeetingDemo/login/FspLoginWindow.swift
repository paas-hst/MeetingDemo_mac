//
//  FspLoginWindow.swift
//  MacFspNewDemo
//
//  Created by admin on 2019/4/1.
//  Copyright © 2019年 hst. All rights reserved.
//

import Cocoa
import AVFoundation

class FspLoginWindow: FspWindowVC {

    @IBOutlet weak var settingsBtn: FspStateButton!
    @IBOutlet weak var loginBtn: FspStateButton!
    @IBOutlet weak var inputUserIdField: NSTextField!
    

    //登录状态
    @IBOutlet weak var load_view: NSView!
    //normal load
    @IBOutlet weak var login_view: NSView!
    var canSwitch: Bool?
    @IBOutlet weak var load_load: FMLoading!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.isCameraCanUse = false
        self.isMicCanUse = false
        
        //设置背景色
        self.window?.contentView?.wantsLayer = true
        let color = NSColor.init(red: 87.0/255, green: 94.0/255, blue: 134.0/255, alpha: 1.0)
        self.window?.contentView?.layer?.backgroundColor = color.cgColor
        
        login_view.wantsLayer = true
        login_view.layer?.backgroundColor = NSColor.init(red: 87.0/255, green: 94.0/255, blue: 134.0/255, alpha: 1.0).cgColor
        
        let frame = login_view.frame
        
        
        load_view.wantsLayer = true
        load_view.layer?.backgroundColor = NSColor.init(red: 87.0/255, green: 94.0/255, blue: 134.0/255, alpha: 1.0).cgColor
        load_view.frame = frame
        self.window?.contentView?.addSubview(load_view)
        
        self.loginBtn.setImages(NSImage.init(named: "login_btn"), hot: NSImage.init(named: "login_btn_hot"), press: NSImage.init(named: "login_btn_pressed"), disable: NSImage.init(named: "login_btn_pressed"))
        
        self.settingsBtn.setImages(NSImage.init(named: "login_set"), hot: NSImage.init(named: "login_set"), press: NSImage.init(named: "login_set"), disable: NSImage.init(named: "login_set"))
        
        /*
        self.checkAudioStatus()
        self.checkVideoStatus()
        */
        
        self.window?.makeKey()
        
        self.showLoad_view(show: false)
        
        //默认回车按钮
        self.window!.defaultButtonCell = loginBtn.cell as! NSButtonCell
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func showLoad_view(show: Bool) -> Void {
        if show == true {
            load_view.isHidden = false
            login_view.isHidden = true
            load_load.start()
        }else{
            load_view.isHidden = true
            login_view.isHidden = false
            load_load.stop()
        }
    }
    
    func checkVideoStatus() -> Void {
        if #available(OSX 10.14, *) {
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch (authStatus) {
            case .notDetermined:
                //没有询问是否开启麦克风
                self.videoAuthAction();
                break;
            case .restricted:
                //未授权，家长限制
                
                break;
            case .denied:
                //玩家未授权
                
                break;
            case .authorized:
                //玩家授权
                self.isCameraCanUse = true
                break;
            default:
                break;
            }
            
            
        }else{
            // Fallback on earlier versions
        }
    }
    
    func videoAuthAction() -> Void {
        
        if #available(OSX 10.14, *) {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted == true{
                    print("相机准许")
                    self.isCameraCanUse = true
                }else{
                    print("相机不准许")
                    self.isCameraCanUse = false
                }
                
            }
        } else {
            // Fallback on earlier versions
            self.isCameraCanUse = true
        }
    }
    
    func checkAudioStatus() -> Void {
        if #available(OSX 10.14, *) {
            let authStatus = AVCaptureDevice.authorizationStatus(for: .audio)
            switch (authStatus) {
            case .notDetermined:
                //没有询问是否开启麦克风
                self.requestMic();
                break;
            case .restricted:
                //未授权，家长限制
                
                break;
            case .denied:
                //玩家未授权
                
                break;
            case .authorized:
                //玩家授权
                self.isMicCanUse = true
                
                break;
            default:
                break;
            }
            

        }else{
             // Fallback on earlier versions
        }
    
    }
    
    func requestMic() -> Void {
        
        if #available(OSX 10.14, *) {
            AVCaptureDevice.requestAccess(for: .audio) { (granted) in
                if granted == true{
                    print("麦克风准许")
                    self.isMicCanUse = true
                }else{
                    print("麦克风不准许")
                    self.isMicCanUse = false
                }
                
            }
        } else {
            // Fallback on earlier versions
            self.isMicCanUse = true
        }
        
    }
    
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
    }
    
    
    var isMicCanUse: Bool?
    var isCameraCanUse: Bool?
    
    
    @IBAction func loginBtnDidClick(_ sender: Any) {
        
        var message = ""
        var information = ""
        /*
        if isCameraCanUse == false {
            information = "摄像头未授权！请允许应用使用您的摄像头！"
        }
        
        if isMicCanUse == false {
            information = "麦克风未授权！请允许应用使用您的麦克风！"
        }
        */
        
        if inputUserIdField.stringValue.count == 0 {
            information = "用户id不能为空！"
        }
        
        if information.count != 0 {
            _ = FspToolAlert.beginAlert(message: message, informativeText: information, window: self.window!)
            return
        }

        self.showLoad_view(show: true)
        
        //登录
        let token = FspTokenFile.token(SecretKey, appid: AppId, groupID: "", userid: self.inputUserIdField.stringValue)
        _ = fsp_manager.login(nToken: token, nUserid: self.inputUserIdField.stringValue)
        fsp_manager.userID = self.inputUserIdField.stringValue
    }
    
    @IBAction func SettingsBtnDidClick(_ sender: Any) {
        let settingWindow = FspSettingsWindow(windowNibName: "FspSettingsWindow")
        NSApplication.shared.runModal(for: settingWindow.window!)
    }
}
