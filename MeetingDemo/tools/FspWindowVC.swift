//
//  FspWindowVC.swift
//  MacFspNewDemo
//
//  Created by 张涛 on 2019/4/4.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class FspWindowVC: NSWindowController {

    
    var lock: NSLock = NSLock()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // self.addwindowEvent()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @objc
    func windowWillClose() -> Void {
       // self.removeWindowEvent()
       // NSApp.stopModal()
    }
    
    //observer
    func addwindowEvent() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose), name: NSWindow.willCloseNotification, object: nil)
    }
    
    func removeWindowEvent() -> Void {
        NotificationCenter.default.removeObserver(self, name:  NSWindow.willCloseNotification, object: nil)
    }
    
    func updateListTableView(dataSourceArr: NSMutableArray) -> Void{
        
    }
    
    func onReceiveUserMsg(_ nSrcUserId: String, msg nMsg: String, msgId nMsgId: Int32) -> Void {
        
        
    }
    
    func onReceiveGroupMsg(_ nSrcUserId: String, msg nMsg: String, msgId nMsgId: Int32) -> Void {
        
        
    }
    
}
