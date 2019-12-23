//
//  FspToolAlert.swift
//  MeetingDemo
//
//  Created by 张涛 on 2019/4/12.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

typealias callBlock = (NSApplication.ModalResponse) -> ()
let alert = FspToolAlert()
class FspToolAlert: NSAlert {

    static func beginAlert(message: String, informativeText: String,window: NSWindow!) -> Void{
        
        if window == nil {
            return
        }
        alert.messageText = message
        alert.informativeText = informativeText
        alert.alertStyle = .warning
        alert.beginSheetModal(for: window) { (response) in
            window.makeKey()
        }
    }
    
    override init() {
        super.init()
        self.addButton(withTitle: "OK")
    }
    
    var iconImage: NSImage = NSImage(named: NSImage.Name("Group"))!
    
    override var icon: NSImage!{
        get{
            return iconImage
        }set{
            iconImage = newValue
        }
    }
    
}
