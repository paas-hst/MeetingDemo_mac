//
//  FspRowView.swift
//  MacFspNewDemo
//
//  Created by 张涛 on 2019/4/4.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class FspRowView: NSTableRowView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func drawSelection(in dirtyRect: NSRect) {
        super.drawSelection(in: dirtyRect)
        
        if self.selectionHighlightStyle != .none {
            let rect = NSInsetRect(self.bounds, 0, 0)
            NSColor.white.setFill()
            let selectionPath = NSBezierPath.init(roundedRect: rect, xRadius: 0, yRadius: 0)
            selectionPath.fill()
        }
        
    }
    
}
