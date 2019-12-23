//
//  FspCallBtnCell.swift
//  MeetingDemo
//
//  Created by 张涛 on 2019/4/15.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class FspCallBtnCell: NSButtonCell {
    var isSeleted = false
    public var selected: Bool {
        get{
            return isSeleted
        }set{
            isSeleted = newValue
            if isSeleted == true {
                self.image = NSImage(named: NSImage.Name("group_3"))
            }else{
                self.image = NSImage(named: NSImage.Name("group_2"))
            }
        }
    }
    
    override init(imageCell image: NSImage?) {
        super.init(imageCell: image)
        self.selected = false
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.selected = false
    }
    
}
