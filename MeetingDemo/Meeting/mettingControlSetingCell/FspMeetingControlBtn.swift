//
//  FspMeetingControlBtn.swift
//  MeetingDemo
//
//  Created by 张涛 on 2019/4/19.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class FspMeetingControlBtn: NSButton {
    
    var _selected = false
    var isSelected : Bool{
        get{
            return _selected
        }set{
            _selected = newValue
            if _selected == true {
                self.image = selectedImage
            }else{
                self.image = normalImage
            }
        }
    }
    
    var normalImage: NSImage?
    var selectedImage: NSImage?
    
    
    func setImageForNormal(image: NSImage) -> Void {
        normalImage = image
    }
    
    func setImageForSelected(image: NSImage) -> Void {
        selectedImage = image
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
       
        // Drawing code here.
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setButtonType(NSButton.ButtonType.momentaryChange)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setButtonType(NSButton.ButtonType.momentaryChange)
    }
    
    
    
}
