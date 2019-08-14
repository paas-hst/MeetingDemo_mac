//
//  FspSettingsWindow.swift
//  MacFspNewDemo
//
//  Created by admin on 2019/4/1.
//  Copyright © 2019年 hst. All rights reserved.
//

import Cocoa

class FspSettingsWindow: FspWindowVC {

    @IBOutlet weak var seperatorLineView: NSView!
    @IBOutlet weak var cancleBtn: FspStateButton!
    @IBOutlet weak var ensureBtn: FspStateButton!
    
    
    @IBOutlet weak var isDefaultBtn: NSButton!
    @IBOutlet weak var anti_DefaultBtn: NSButton!
    @IBOutlet weak var appIDTextField: NSTextField!
    @IBOutlet weak var appSecretTextField: NSTextField!
    @IBOutlet weak var serverTextField: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        //设置背景色
        self.window?.contentView?.wantsLayer = true
        let color = NSColor.init(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        self.window?.contentView?.layer?.backgroundColor = color.cgColor

        
        self.window?.title = "配置"
        self.seperatorLineView.wantsLayer = true
        let Seperatorcolor = NSColor.init(red: 214.0/255, green: 214.0/255, blue: 214.0/255, alpha: 1.0)
        self.seperatorLineView.layer?.backgroundColor = Seperatorcolor.cgColor
        
        self.cancleBtn.setImages(NSImage.init(named: "login_btn"), hot: NSImage.init(named: "login_btn_hot"), press: NSImage.init(named: "login_btn_pressed"), disable: NSImage.init(named: "login_btn_pressed"))
        
        self.ensureBtn.setImages(NSImage.init(named: "login_btn"), hot: NSImage.init(named: "login_btn_hot"), press: NSImage.init(named: "login_btn_pressed"), disable: NSImage.init(named: "login_btn_pressed"))
        
        
        
        let use_custom_id = UserDefaults.standard.bool(forKey: CONFIG_USE_DEFAULT_OPEN_KEY)
        if use_custom_id == true {
            //使用自定义m配置
            self.anti_DefaultBtn.state = .on
            self.isDefaultBtn.state = .off
        }else{
            self.anti_DefaultBtn.state = .off
            self.isDefaultBtn.state = .on
        }
        
        let strAppId = UserDefaults.standard.object(forKey: CONFIG_KEY_APPID)
        let strSecretKey = UserDefaults.standard.object(forKey: CONFIG_KEY_SECRECTKEY)
        let strServerAddr = UserDefaults.standard.object(forKey: CONFIG_KEY_SERVETADDR)
        
        if strAppId != nil || strSecretKey != nil || strServerAddr != nil  {
            appIDTextField.stringValue =  strAppId as! String
            appSecretTextField.stringValue = strSecretKey as! String
            serverTextField.stringValue = strServerAddr as! String
        }
        
       
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    

    

    
    
    @IBAction func cancleBtnDidClick(_ sender: Any) {
        print("取消按钮")
        self.window?.close()
        NSApp.stopModal()
    }
    
    @IBAction func ensureBtnDidClick(_ sender: Any) {
        print("确认按钮")
        
        let strAppId = appIDTextField.stringValue
        let strSecretKey = appSecretTextField.stringValue
        let strServerAddr = serverTextField.stringValue
        
        if strAppId.count <= 0 || strSecretKey.count <= 0 || strServerAddr.count <= 0 {
            //用回默认
            //啥都不改
            UserDefaults.standard.set(true, forKey: CONFIG_USE_DEFAULT_OPEN_KEY)
            UserDefaults.standard.set(false, forKey: CONFIG_KEY_USECONFIG)
        }else{
            
            UserDefaults.standard.set(false, forKey: CONFIG_USE_DEFAULT_OPEN_KEY)
            UserDefaults.standard.set(true, forKey: CONFIG_KEY_USECONFIG)
            
            UserDefaults.standard.set(strAppId, forKey: CONFIG_KEY_APPID)
            UserDefaults.standard.set(strSecretKey, forKey: CONFIG_KEY_SECRECTKEY)
            UserDefaults.standard.set(strServerAddr, forKey: CONFIG_KEY_SERVETADDR)
            
            
        }
        
        let theApp = NSApplication.shared.delegate as! AppDelegate
        theApp.resetManager.sendNext(nil)
        
        self.window?.close()
        NSApp.stopModal()
    }
    
    @IBAction func isdefaultBtnClick(_ sender: Any) {
        
        let btn = sender as! NSButton
        
        if btn.state == .on {
            //使用自定义配置
            
            //关闭否Btn状态
            self.anti_DefaultBtn.state = .off
        }else{
            //不使用默认配置
            
            //开启否Btn状态
            self.anti_DefaultBtn.state = .on
        }
        
    }
    @IBAction func is_antiDefaultBtnClick(_ sender: Any) {
        let btn = sender as! NSButton
        
        if btn.state == NSButton.StateValue.on {
            //使用自定义配置
            
            //关闭默认Btn状态
            self.isDefaultBtn.state = .off
        }else{
            //使用默认配置
            
            //开启默认Btn状态
            self.anti_DefaultBtn.state = .on
        }
    }
    
    
    
    deinit {
        print("dealloc")
        
    }
}
