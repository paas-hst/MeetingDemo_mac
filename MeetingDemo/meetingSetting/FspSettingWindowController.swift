//
//  FspSettingWindowController.swift
//  MacFspNewDemo
//
//  Created by 张涛 on 2019/4/9.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

class FspSettingWindowController: NSWindowController,NSWindowDelegate {

    
    @IBOutlet weak var localRecordBtn: FspMeetingBtn!
    @IBOutlet weak var screenShareBtn: FspMeetingBtn!
    @IBOutlet weak var videoBtn: FspMeetingBtn!
    @IBOutlet weak var audioBtn: FspMeetingBtn!
    
    @IBOutlet weak var homeSeperatorView: NSView!
    @IBOutlet weak var audioSeperatorViewSec: NSView!
    @IBOutlet weak var audioSeperatorView: NSView!
    @IBOutlet weak var audioCancleBtnDidClick: FspStateButton!
    @IBOutlet weak var audioEnsureBtnDidClick: FspStateButton!
    @IBOutlet var audio_settingView: NSView!
    @IBOutlet weak var topButtonBar: NSView!
    @IBOutlet weak var bgView: NSView!
    

    
    @IBAction func localRecordBtnDidClick(_ sender: Any) {
        if localRecordBtn.choosedOn == false {
            localRecordBtn.choosedOn = true
        }
        
        videoBtn.choosedOn = false
        audioBtn.choosedOn = false
        screenShareBtn.choosedOn = false
    }
    @IBAction func screenShareBtnDidClick(_ sender: Any) {
        if screenShareBtn.choosedOn == false {
            screenShareBtn.choosedOn = true
        }
        
        localRecordBtn.choosedOn = false
        videoBtn.choosedOn = false
        audioBtn.choosedOn = false
    }
    @IBAction func videoBtnDidClick(_ sender: Any) {
        if videoBtn.choosedOn == false {
            videoBtn.choosedOn = true
            self.bgView.addSubview(videoView)
            videoView.frame = self.bgView.bounds
        }
        
        localRecordBtn.choosedOn = false
        audioBtn.choosedOn = false
        screenShareBtn.choosedOn = false
        
        audio_settingView.removeFromSuperview()
    }
    @IBAction func audioBtnDidClick(_ sender: Any) {
        if audioBtn.choosedOn == false {
            audioBtn.choosedOn = true
            self.bgView.addSubview(audio_settingView)
            audio_settingView.frame = self.bgView.bounds
        }
        
        screenShareBtn.choosedOn = false
        videoBtn.choosedOn = false
        localRecordBtn.choosedOn = false
        videoView.removeFromSuperview()
    }
    
    var _perSecondTimer : Timer?
    
    override func windowDidLoad() {
        super.windowDidLoad()

        audioBtn.choosedOn = true
        screenShareBtn.choosedOn = false
        localRecordBtn.choosedOn = false
        videoBtn.choosedOn = false
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.InitAudioView()
        self.initVideoView()
        self.videoView.removeFromSuperview()
        
        _perSecondTimer = Timer.init(timeInterval: 0.25, repeats: true, block: { (timer) in
            self.onPerSecondTimer()
        })
        RunLoop.current.add(_perSecondTimer!, forMode: RunLoop.Mode.modalPanel)
        
        /*
        -(IBAction)onMicroBtn:(id)sender
        {
            NSInteger state = [_imgBtn_Micro buttonState];
            if(state == 1 || state == 2)//enable
            {
                BOOL willMute = state == 1;
                
                [_imgBtn_Micro setButtonState:++state];
                
                FMAllocObj(AudioDeviceAdaptor,audioDev);
                [audioDev setCapMute:willMute];
                
                [NSSound applyMuteForMicphone:willMute];
                
                NSInteger volume = 0;
                if(!willMute)
                {
                    volume = [NSSound systemMicphone] * 100;
                }
                
                [_slider_Micro setIntegerValue:volume];
            }
        }
        */
        /*
        -(IBAction)onVolumeBtn:(id)sender
        {
            NSInteger state = [_imgBtn_Volume buttonState];
            if(state == 1 || state == 2)//enable
            {
                BOOL willMute = state == 1;
                
                [_imgBtn_Volume setButtonState:++state];
                
                FMAllocObj(AudioDeviceAdaptor,audioDev);
                [audioDev setPlayMute:willMute];
                
                [NSSound applyMuteForVolume:willMute];
                
                NSInteger volume = 0;
                if(!willMute)
                {
                    volume = [NSSound systemVolume] * 100;
                }
                
                [_slider_Volume setIntegerValue:volume];
            }
        }
        */
        /*
        -(IBAction)onSliderChange:(id)sender
        {
            if(sender == _slider_Micro)
            {
                NSInteger nPos = [_slider_Micro integerValue];
                
                FMAllocObj(AudioDeviceAdaptor,audioDev);
                
                if(audioDev)
                {
                    [audioDev setCapVolume:nPos];
                    
                    if(nPos == 0)
                    {
                        [_imgBtn_Micro setButtonState:2];
                        [NSSound applyMuteForMicphone:true];
                        [audioDev setCapMute:true];
                    }
                    else
                    {
                        [_imgBtn_Micro setButtonState:1];
                        [audioDev setCapMute:false];
                        [NSSound applyMuteForMicphone:false];
                        
                        float volume = nPos / 100.0f;
                        
                        [NSSound setSystemMicphone:volume];
                    }
                    
                    FMAllocObj(AudioParamObj, param);
                    [[[ConfDataContainerAdaptor getInstance] config] ReadAudioParam:param];
                    
                    [param setNCapVolume:nPos];
                    [[[ConfDataContainerAdaptor getInstance]config] WriteAudioParam:param];
                    
                }
            }
            else if(sender == _slider_Volume)
            {
                NSInteger nPos = [_slider_Volume integerValue];
                
                FMAllocObj(AudioDeviceAdaptor,audioDev);
                
                if(audioDev)
                {
                    [audioDev setPlayVolume:nPos];
                    
                    if(nPos == 0)
                    {
                        [_imgBtn_Volume setButtonState:2];
                        [audioDev setPlayMute:true];
                        [NSSound applyMuteForVolume:true];
                    }
                    else
                    {
                        [_imgBtn_Volume setButtonState:1];
                        [audioDev setPlayMute:false];
                        [NSSound applyMuteForVolume:false];
                        
                        float volume = nPos / 100.0f;
                        
                        [NSSound setSystemVolume:volume];
                    }
                    FMAllocObj(AudioParamObj, param);
                    [[[ConfDataContainerAdaptor getInstance] config] ReadAudioParam:param];
                    
                    [param setNPlayVolume:nPos];
                    [[[ConfDataContainerAdaptor getInstance]config] WriteAudioParam:param];
                }
            }
        }

        */
    }
    
    let color = NSColor.init(red: 244.0/255, green: 246.0/255, blue: 248.0/255, alpha: 1.0).cgColor
    let graycolor = NSColor.init(red: 216.0/255, green: 216.0/255, blue: 216.0/255, alpha: 1.0).cgColor
    override func awakeFromNib() {
        super.awakeFromNib()
        self.topButtonBar.wantsLayer = true
        self.topButtonBar.layer?.backgroundColor = .white
        
        self.bgView.wantsLayer = true
        self.bgView.layer?.backgroundColor = NSColor.red.cgColor
        
        self.homeSeperatorView.wantsLayer = true
        self.homeSeperatorView.layer?.backgroundColor = graycolor
    }
    
    //MARK:麦克风页面事件
    @IBOutlet weak var micPhoneComBox: NSComboBox!
    @IBOutlet weak var speakerComBox: NSComboBox!
    @IBOutlet weak var pbMicrophoneEnergy: NSProgressIndicator!
    @IBOutlet weak var pbSpeakerEnergy: NSProgressIndicator!
    @IBOutlet weak var silderMicrophoneVol: NSSlider!
    @IBOutlet weak var sliderSpeakerVol: NSSlider!
    
    //选中麦克风设备
    @IBAction func micPhoneComBoxDidSelected(_ sender: Any) {
        let index_for_combox = micPhoneComBox.indexOfSelectedItem
        let deviceInfo = micPhoneComBox.itemObjectValue(at: index_for_combox) as! FspAudioDeviceInfo
        _ = fsp_manager.setCurrentMicrophoneDevice(nDeviceId: deviceInfo.deviceId)
        cur = deviceInfo.deviceId
    }
    
    @IBAction func speakerComBoxDidSelected(_ sender: Any) {
        let index_for_combox = speakerComBox.indexOfSelectedItem
        let deviceInfo = speakerComBox.itemObjectValue(at: index_for_combox) as! FspAudioDeviceInfo
        _ = fsp_manager.setCurrentSpeakerDevice(nDeviceId: deviceInfo.deviceId)
    }
    
    var cur = 0;
    @IBAction func onSliderMicroPhoneVol(_ sender: Any) {
        let micSlider = sender as! NSSlider
        _ = fsp_manager.setMicrophoneVolume(nVolume: micSlider.integerValue)
        FspTokenFile.setMicroVolume(micSlider.integerValue)
        
    }
    @IBAction func onSliderSpeakerVol(_ sender: Any) {
        let speakerSlider = sender as! NSSlider
        _ = fsp_manager.setSpeakerVolume(nVolume: speakerSlider.integerValue)
        FspTokenFile.setSpeakerVolume(speakerSlider.integerValue)
    }
    
    func onPerSecondTimer() -> Void {
        pbSpeakerEnergy.doubleValue = Double(fsp_manager.getSpeakerEnergy())
        pbMicrophoneEnergy.doubleValue = Double(fsp_manager.getMicrophoneEnergy())
        sliderSpeakerVol.integerValue = fsp_manager.getSpeakerVolume()
        silderMicrophoneVol.integerValue = fsp_manager.getMicrophoneVolume()
    }
    
    func InitAudioView() -> Void {
        
        self.audio_settingView.wantsLayer = true
        self.audio_settingView.layer?.backgroundColor = color
        
        self.audioSeperatorView.wantsLayer = true
        self.audioSeperatorView.layer?.backgroundColor = graycolor
        
        self.audioSeperatorViewSec.wantsLayer = true
        self.audioSeperatorViewSec.layer?.backgroundColor = graycolor
        
        self.audioEnsureBtnDidClick.setImages(NSImage.init(named: NSImage.Name("login_btn")), hot: NSImage.init(named: NSImage.Name("login_btn_hot")), press: NSImage.init(named: NSImage.Name("login_btn_pressed")), disable: NSImage.init(named: NSImage.Name("login_btn_pressed")))
        self.audioCancleBtnDidClick.setImages(NSImage.init(named: NSImage.Name("login_btn")), hot: NSImage.init(named: NSImage.Name("login_btn_hot")), press: NSImage.init(named: NSImage.Name("login_btn_pressed")), disable: NSImage.init(named: NSImage.Name("login_btn_pressed")))
        self.bgView.addSubview(audio_settingView)
        audio_settingView.frame = self.bgView.bounds
        
        let arrMicrophoneDevices = fsp_manager.getMicrophoneDevices()
        for microphoneDevice in arrMicrophoneDevices {
            micPhoneComBox.addItem(withObjectValue: microphoneDevice)
        }
        
        let arrSpeakerDevices = fsp_manager.getSpeakerDevices()
        for speakerDevice in arrSpeakerDevices {
            speakerComBox.addItem(withObjectValue: speakerDevice)
        }
        
        self.updateAudioDeviceSelection()
    }
    
    func updateAudioDeviceSelection() -> Void {
        let curSpeakerDevice = fsp_manager.getCurrentSpeakerDevice()
        let curMicrophoneDevice = fsp_manager.getCurrentMicrophoneDevice()
        if curSpeakerDevice >= 0 {
            for i in 0...speakerComBox.numberOfItems {
                let deviceInfo = (speakerComBox.itemObjectValue(at: i)) as! FspAudioDeviceInfo
                if deviceInfo.deviceId == curSpeakerDevice{
                    speakerComBox.selectItem(at: i)
                    break
                }
            }
        }else{
            let no_speaker = FspAudioDeviceInfo()
            no_speaker.deviceId = -1
            no_speaker.deviceName = "未找到扬声器"
            speakerComBox.addItem(withObjectValue: no_speaker)
            speakerComBox.selectItem(at: 0)
            speakerComBox.isEnabled = false
        }
        

        if curMicrophoneDevice >= 0 {
            for i in 0...micPhoneComBox.numberOfItems {
                let deviceInfo = (micPhoneComBox.itemObjectValue(at: i)) as! FspAudioDeviceInfo
                if deviceInfo.deviceId == curMicrophoneDevice{
                    micPhoneComBox.selectItem(at: i)
                    break
                }
            }
        }else{
            let no_speaker = FspAudioDeviceInfo()
            no_speaker.deviceId = -1
            no_speaker.deviceName = "未找到麦克风"
            micPhoneComBox.addItem(withObjectValue: no_speaker)
            micPhoneComBox.selectItem(at: 0)
            micPhoneComBox.isEnabled = false
        }

    }
    
    //MARK:摄像头页面事件
    @IBOutlet weak var pbCameraPresetCombox: NSComboBox!
    @IBOutlet weak var videoFpsSlider: NSSlider!
    @IBOutlet weak var videoSeperatorView: NSView!
    @IBOutlet var videoView: NSView!
    @IBOutlet weak var videoRenderView: NSView!
    @IBOutlet weak var no_video_status_view: NSView!
    
    @IBOutlet weak var fspDecriptionLabel: NSTextField!
    @IBOutlet weak var pbCameraCombox: NSComboBox!
    var previewCameraId = FSP_INVALID_CAMERA_ID
    
    @IBAction func videoViewCameraSelected(_ sender: Any) {
        
        if sender as? NSComboBox == pbCameraCombox {
            let index_for_combox = pbCameraCombox.indexOfSelectedItem
            let deviceInfo = pbCameraCombox.itemObjectValue(at: index_for_combox) as! FspVideoDeviceInfo
            self.preViewCamera(cameraId: deviceInfo.cameraId)
        }else if sender as? NSComboBox == pbCameraPresetCombox{
            
            let index = pbCameraPresetCombox.indexOfSelectedItem
            print("设置分辨率",index)
            switch index {
            case 0:
                video_width = 1280
                video_height = 720
                video_choose_preset_index = 0
                break
            case 1:
                video_width = 640
                video_height = 480
                video_choose_preset_index = 1
                break
            case 2:
                video_width = 640
                video_height = 360
                video_choose_preset_index = 2
                break
            case 3:
                video_width = 352
                video_height = 288
                video_choose_preset_index = 3
                break
            default:
                video_width = 640
                video_height = 360
                video_choose_preset_index = -1
            }
            let videoID = self.generateVideoId(cameraId: previewCameraId)
            let profile = FspVideoProfile(video_width, height: video_height, framerate: video_fsp)
            fsp_manager.fsp_engine!.setVideoProfile(videoID, profile: profile)
        }else if sender as? NSSlider == videoFpsSlider{
            print("切换帧率")
            fspDecriptionLabel.stringValue = "当前帧率:" + String(videoFpsSlider.intValue)
            video_fsp = Int(videoFpsSlider.intValue)
            let videoID = self.generateVideoId(cameraId: previewCameraId)
            let profile = FspVideoProfile(video_width, height: video_height, framerate: video_fsp)
            fsp_manager.fsp_engine!.setVideoProfile(videoID, profile: profile)
        }
    }
    
    func generateVideoId(cameraId: Int) -> String {
        return NSString(format: "macvideo%d", cameraId) as String
    }
    
    func initVideoView() -> Void {
        
        self.videoView.wantsLayer = true
        self.videoView.layer?.backgroundColor = color
        
        self.videoSeperatorView.wantsLayer = true
        self.videoSeperatorView.layer?.backgroundColor = graycolor
     
        self.bgView.addSubview(videoView)
        videoView.frame = self.bgView.bounds
        
        self.videoRenderView.wantsLayer = true
        self.videoRenderView.layer?.backgroundColor = NSColor.black.cgColor
        
        self.no_video_status_view.wantsLayer = true
        self.no_video_status_view.layer?.backgroundColor = graycolor
        
        let arrVideoDevices = fsp_manager.getVideoDevices()
        for videoDeviceInfo in arrVideoDevices {
            pbCameraCombox.addItem(withObjectValue: videoDeviceInfo)
        }
        
        if arrVideoDevices.count > 0 {
            let videoInfo = arrVideoDevices[0] as FspVideoDeviceInfo
            self.preViewCamera(cameraId: videoInfo.cameraId)
            pbCameraCombox.selectItem(at: 0)
        }
        if video_choose_preset_index == -1 {
            self.pbCameraPresetCombox.selectItem(at: 2)
        }else{
            self.pbCameraPresetCombox.selectItem(at: video_choose_preset_index)
        }
        self.videoViewCameraSelected(pbCameraPresetCombox)
    }
    
    func preViewCamera(cameraId: Int) -> Void {
        if previewCameraId != FSP_INVALID_CAMERA_ID {
           _ = fsp_manager.removeVideoPreview(nCameraId: previewCameraId, nRenderView: videoRenderView)
        }
        
        if fsp_manager.addVideoPreview(nCameraId: cameraId, nRenderView: videoRenderView, nMode: FspRenderMode.FSP_RENDERMODE_SCALE_FILL) == FspErrCode.FSP_ERR_OK {
            previewCameraId = cameraId
        }
    }
    
    func stopPreviewCamera() -> Void {
        if previewCameraId != FSP_INVALID_CAMERA_ID {
           _ = fsp_manager.removeVideoPreview(nCameraId: previewCameraId, nRenderView: videoRenderView)
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        _perSecondTimer?.invalidate()
        
        self.stopPreviewCamera()
        NSApp.stopModal()
    }
    

    @IBAction func ensureBtnDidClick(_ sender: Any) {
        NSApp.stopModal()
        _perSecondTimer?.invalidate()
        self.window?.close()
    }
    @IBAction func cancleBtnDidClick(_ sender: Any) {
        NSApp.stopModal()
        _perSecondTimer?.invalidate()
        self.window?.close()
    }
    
}
