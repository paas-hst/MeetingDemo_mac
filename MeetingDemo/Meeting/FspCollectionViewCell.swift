//
//  FspCollectionViewCell.swift
//  MacFspNewDemo
//
//  Created by 张涛 on 2019/4/8.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

protocol FspCollectionViewCellDelegate: class {
    func doubleClickEventSendOut(clickGesture: NSClickGestureRecognizer)
}

class FspCollectionViewCell: NSView {

    weak var delegate: FspCollectionViewCellDelegate?
    
    @IBOutlet weak var backView: NSView!
    @IBOutlet weak var renderView: NSView!
    @IBOutlet weak var maskView: NSView!
    @IBOutlet weak var userid_view: NSView!
    @IBOutlet weak var userid_text: NSTextField!
    @IBOutlet weak var videoStatusView: NSView!
    @IBOutlet weak var videoStatusText: NSTextField!
    @IBOutlet weak var Btn: NSButton!
    @IBOutlet weak var noVideoStatusView: NSView!
    
    public var isFullScreen: Bool?
    public var normalFrame: NSRect?
    
    public var isVideoUsed: Bool? = false
    public var isAudioUsed: Bool? = false
    
    public var video_Id: String?
    public var user_Id: String?
    
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let color = NSColor.init(red: 240.0/255, green: 243.0/255, blue: 246.0/255, alpha: 1.0).cgColor
        
        let blackColor = NSColor.init(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.3).cgColor
        
        
        self.backView.wantsLayer = true
        self.backView.layer?.backgroundColor = color
        
        self.renderView.wantsLayer = true
        self.renderView.layer?.backgroundColor = color
        
        
        self.maskView.wantsLayer = true
        self.maskView.layer?.backgroundColor = NSColor.clear.cgColor
        
        
        self.userid_view.wantsLayer = true
        self.userid_view.layer?.backgroundColor = blackColor
        self.userid_view.layer?.cornerRadius = 10
        
        self.videoStatusView.wantsLayer = true
        self.videoStatusView.layer?.backgroundColor = blackColor
        self.videoStatusView.layer?.cornerRadius = 10
        
        self.noVideoStatusView.wantsLayer = true
        self.noVideoStatusView.layer?.backgroundColor = color
        
        //self.noVideoStatusView.layer?.isHidden = true
        
        let click = NSClickGestureRecognizer(target: self, action: #selector(click(clickGesture:)))
        click.numberOfClicksRequired = 2
        self.addGestureRecognizer(click)
        
        self.RenderFitView.wantsLayer = true
        self.RenderFitView.layer?.backgroundColor = NSColor.clear.cgColor
        // Drawing code here.
    }

    @objc
    func click(clickGesture: NSClickGestureRecognizer) -> Void {
        if self.delegate != nil{
            self.delegate?.doubleClickEventSendOut(clickGesture: clickGesture)
        }
        
    }
    
    //MARK:自动隐藏
    var timer: Timer?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        isFullScreen = false
        let color = NSColor.init(red: 240.0/255, green: 243.0/255, blue: 246.0/255, alpha: 1.0).cgColor
        self.backView.wantsLayer = true
        self.backView.layer?.backgroundColor = color
        
        RenderFitView.isHidden = true
        RenderFitBtn.isHidden = false
    }
    
    //MARK: 渲染填充模式
    @IBOutlet weak var RenderFitView: NSView!
    @IBOutlet weak var RenderFitBtn: NSButton!
    
    @IBOutlet weak var Render_Complete_Btn: FspMeetingBtn!
    @IBOutlet weak var Render_Geometric_Ratio_Cutting_Btn: FspMeetingBtn!
    @IBOutlet weak var Render_Tile_Stretching_Btn: FspMeetingBtn!
    
    @IBAction func showVideoRenderFieViewBtnDidClick(_ sender: Any) {
        RenderFitView.isHidden = false
        RenderFitBtn.isHidden = true
        self.resetTimer()
    }
    
    func resetTimer() -> Void {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer  = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            self.resetViewStatus()
        }
    }
    
    @objc
    func resetViewStatus() -> Void {
        RenderFitView.isHidden = true
        RenderFitBtn.isHidden = false
    }
    
    @IBAction func completeBtnDidClick(_ sender: Any) {
        Render_Complete_Btn.choosedOn = true
        Render_Geometric_Ratio_Cutting_Btn.choosedOn = false
        Render_Tile_Stretching_Btn.choosedOn = false
        self.resetTimer()
    }
    
    @IBAction func geometricRatioBtnDidClick(_ sender: Any) {
        Render_Complete_Btn.choosedOn = false
        Render_Geometric_Ratio_Cutting_Btn.choosedOn = true
        Render_Tile_Stretching_Btn.choosedOn = false
        self.resetTimer()
    }
    
    @IBAction func tileStrenchingBtnDidClick(_ sender: Any) {
        Render_Complete_Btn.choosedOn = false
        Render_Geometric_Ratio_Cutting_Btn.choosedOn = false
        Render_Tile_Stretching_Btn.choosedOn = true
        self.resetTimer()
    }
    
    
    
    override func viewDidMoveToSuperview() {
        
    }
    
    override func viewDidMoveToWindow() {
        Render_Complete_Btn.choosedOn = true
        Render_Geometric_Ratio_Cutting_Btn.choosedOn = false
        Render_Tile_Stretching_Btn.choosedOn = false
    }
    
    
    
    func loadNibView() -> Void {
        Bundle.main.loadNibNamed("FspCollectionViewCell", owner: self, topLevelObjects: nil)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.pressure == 1 {
            //print("单击")
        }
        
        if event.pressure == 2 {
            //print("双击")
        }
    }
    
    func upateStatus() -> Void {
    
        if isVideoUsed == false && isAudioUsed == false {
            self.video_Id = nil
            self.user_Id = nil
            return
        }
        self.userid_text.stringValue = user_Id!
        
        if video_Id == nil {
            self.userid_text.stringValue = user_Id!
        }else{
            let statusInfo = fsp_manager.getVideoStatus(nUserId: user_Id!, nVideoId: video_Id!)
            if statusInfo != nil{
                self.videoStatusText.stringValue = NSString(format: "%@: %@", statusInfo!.description) as String
            }
        }
       
        if isAudioUsed == true {
          // print("如果音量开启")
        }
      
    }
    
    deinit {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }

   
}
