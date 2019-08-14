//
//  FspMeetingBtn.swift
//  MacFspNewDemo
//
//  Created by 张涛 on 2019/4/8.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class FspMeetingBtn: NSButton {

    //选中
    private var isChooseOn = false
    var choosedOn: Bool{
        get{
            return isChooseOn
        }set{
            isChooseOn = newValue
            self.setNeedsDisplay()
        }
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
 

        if isChooseOn == false {
            self.InitUnChooseStatus()
        }else{
            self.InitChoosedStatus()
        }


        // Drawing code here.
    }
    
    func InitChoosedStatus() -> Void {
        let color = NSColor.init(red: 106.0/255, green: 125.0/255, blue: 254.0/255, alpha: 1.0)
        let rect = NSInsetRect(self.bounds, 0, 0)
        color.setFill()
        let selectionPath = NSBezierPath.init(roundedRect: rect, xRadius: 0, yRadius: 0)
        selectionPath.fill()
        if self.title != nil {
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.setParagraphStyle(NSParagraphStyle.default)
            paraStyle.alignment = .center
            let fontValue = NSFont.init(name: "Verdana", size: 14)
            let fontKey = NSAttributedString.Key.font
            
            let color = NSColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            let colorKey = NSAttributedString.Key.foregroundColor
            
            let paramStyleKey = NSAttributedString.Key.paragraphStyle
            
            let dict2:Dictionary = [fontKey : fontValue as Any, colorKey : color , paramStyleKey : paraStyle] as [NSAttributedString.Key  : Any]
            
            let btnString = NSAttributedString.init(string: self.title, attributes: dict2)
            btnString.draw(in: NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height))
            
        }
    }
    
    func InitUnChooseStatus() -> Void {
        
        let color = NSColor.init(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        let rect = NSInsetRect(self.bounds, 0, 0)
        color.setFill()
        let selectionPath = NSBezierPath.init(roundedRect: rect, xRadius: 0, yRadius: 0)
        selectionPath.fill()
        if self.title != nil {
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.setParagraphStyle(NSParagraphStyle.default)
            paraStyle.alignment = .center
            let fontValue = NSFont.init(name: "Verdana", size: 14)
            let fontKey = NSAttributedString.Key.font
            
            let color = NSColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            let colorKey = NSAttributedString.Key.foregroundColor
            
            let paramStyleKey = NSAttributedString.Key.paragraphStyle
            
            let dict2:Dictionary = [fontKey : fontValue as Any, colorKey : color , paramStyleKey : paraStyle] as [NSAttributedString.Key  : Any]
            
            let btnString = NSAttributedString.init(string: self.title, attributes: dict2)
            btnString.draw(in: NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height))
            
        }
    }

    
}
