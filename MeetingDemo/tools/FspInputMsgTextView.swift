//
//  FspInputMsgTextView.swift
//  MeetingDemo
//
//  Created by 张涛 on 2019/5/24.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class FspInputMsgTextView: NSTextView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func becomeFirstResponder() -> Bool {
        self.needsDisplay = true
        return super.becomeFirstResponder()
    }
    
}
