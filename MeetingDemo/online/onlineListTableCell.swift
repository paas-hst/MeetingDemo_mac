//
//  onlineListTableCell.swift
//  MacFspNewDemo
//
//  Created by 张涛 on 2019/4/4.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class onlineListTableCell: NSTableCellView {

    

    @IBOutlet weak var cellChooseImage: NSImageView!
    @IBOutlet weak var cellImageIcon: NSImageView!
    @IBOutlet weak var cellTextLabel: NSTextField!
    @IBOutlet weak var CellStatusView: NSView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.CellStatusView.wantsLayer = true
        self.CellStatusView.layer?.backgroundColor = NSColor.init(red: 93.0/255, green: 222.0/255, blue: 125.0/255, alpha: 1.0).cgColor
        self.CellStatusView.layer?.cornerRadius = 4
        // Drawing code here.
    }
    
    override var backgroundStyle: NSView.BackgroundStyle{
        get{
            
            return .normal
        }set{
            
        }
    }
    
}
