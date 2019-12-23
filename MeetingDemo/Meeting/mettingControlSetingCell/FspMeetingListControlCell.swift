//
//  NSMeetingListControlCell.swift
//  MeetingDemo
//
//  Created by 张涛 on 2019/4/19.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class FspMeetingListControlCell: NSTableCellView {

    
    @IBOutlet weak var bgView: NSView!
    @IBOutlet weak var cellImageIcon: NSImageView!
    @IBOutlet weak var cellUserIdText: NSTextField!
    @IBOutlet weak var cellMuteBtn: FspMeetingControlBtn!
    @IBOutlet weak var cellVideoBtn: FspMeetingControlBtn!
    @IBOutlet weak var cellScreenShareBtn: FspMeetingControlBtn!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        

  
        // Drawing code here.
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

      
        
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)


    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
       
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cellImageIcon.image = NSImage(named: NSImage.Name("Group"))
        self.cellMuteBtn.setImageForNormal(image: NSImage(named: NSImage.Name("group_mic_not_selected"))!)
        self.cellMuteBtn.setImageForSelected(image: NSImage(named: NSImage.Name("group_mic_selected"))!)
        self.cellVideoBtn.setImageForNormal(image: NSImage(named: NSImage.Name("group_cam_not_selected"))!)
        self.cellVideoBtn.setImageForSelected(image: NSImage(named: NSImage.Name("group_cam_selected"))!)
        self.cellScreenShareBtn.setImageForNormal(image: NSImage(named: NSImage.Name("group_share_not_selected"))!)
        self.cellScreenShareBtn.setImageForSelected(image: NSImage(named: NSImage.Name("group_share_selected"))!)
        
        self.cellMuteBtn.isSelected = false
        self.cellVideoBtn.isSelected = false
        self.cellScreenShareBtn.isSelected = false
    }
    
    @IBAction func cellMuteBtnDidClick(_ sender: Any) {
        //self.cellMuteBtn!.isSelected = !self.cellMuteBtn!.isSelected
        if self.cellMuteBtn!.isSelected == true {
            print("麦克风开启")
        }else{
            print("麦克风关闭")
        }
    }
    @IBAction func cellVideoBtnDidClick(_ sender: Any) {
       // self.cellVideoBtn!.isSelected = !self.cellVideoBtn!.isSelected
        if self.cellVideoBtn!.isSelected == true {
            print("视频开启")
        }else{
            print("视频关闭")
        }
    }
    @IBAction func cellScreenShareBtnDidClick(_ sender: Any) {
       // self.cellScreenShareBtn!.isSelected = !self.cellScreenShareBtn!.isSelected
        if self.cellScreenShareBtn!.isSelected == true {
            print("屏幕共享开启")
        }else{
            print("屏幕共享关闭")
        }
    }
    
}
