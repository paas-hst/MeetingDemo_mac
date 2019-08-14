//
//  FspInputTextField.swift
//  MeetingDemo
//
//  Created by 张涛 on 2019/5/27.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

protocol FspInputTextFieldDelegate: class {
    func FspInputTextFieldValueDidChange(text: String) -> Void;
}


class FspInputTextField: NSTextField {

    weak var inputTextFieldDelegate: FspInputTextFieldDelegate?
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)


        // Drawing code here.
    }
    
    override func awakeFromNib() {
        
    }


    override func keyUp(with theEvent: NSEvent) {


        super.keyUp(with: theEvent)

        self.complete(self)
    }
    
    
    override func complete(_ sender: Any?) {
        if self.inputTextFieldDelegate != nil {
            self.inputTextFieldDelegate!.FspInputTextFieldValueDidChange(text: self.stringValue)
        }
    }
    
    override func textDidChange(_ notification: Notification) {
        
        
    }
    
}
