//
//  SettingWindowController.m
//  FspClient
//
//  Created by admin on 2018/5/21.
//  Copyright © 2018年 hst. All rights reserved.
//

#import "FspManager.h"

#import "FspStateButton.h"
#import "GRProgressIndicator.h"
#import "SettingWindowController.h"

@interface SettingWindowController ()
{    
    NSInteger _previewCameraId;
    NSTimer* _perSecondTimer;
}

@property (weak) IBOutlet NSComboBox *cbMicrophone;
@property (weak) IBOutlet NSComboBox *cbSpeaker;
@property (weak) IBOutlet NSComboBox *cbCamera;
@property (weak) IBOutlet NSSlider *sliderSpeakerVol;
@property (weak) IBOutlet NSSlider *sliderMicVol;
@property (weak) IBOutlet GRProgressIndicator *pbSpeakerEnergy;
@property (weak) IBOutlet GRProgressIndicator *pbMicrophoneEnergy;
@property (weak) IBOutlet FspStateButton *btnCancel;
@property (weak) IBOutlet FspStateButton *btnConfirm;
@property (weak) IBOutlet NSTextField *tfRenderView;
@end

@implementation SettingWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    _previewCameraId = FSP_INVALID_CAMERA_ID;
    
    self.window.contentView.layer.contents = (id)[NSImage imageNamed:@"set_bg.png"];
    
    [_btnCancel setImages:[NSImage imageNamed:@"set_bluebtn"]
                      hot:[NSImage imageNamed:@"set_bluebtn_hot"]
                    press:[NSImage imageNamed:@"set_bluebtn_pressed"]
                  disable:[NSImage imageNamed:@"set_bluebtn_pressed"]];
    
    [_btnConfirm setImages:[NSImage imageNamed:@"set_bluebtn"]
                       hot:[NSImage imageNamed:@"set_bluebtn_hot"]
                     press:[NSImage imageNamed:@"set_bluebtn_pressed"]
                   disable:[NSImage imageNamed:@"set_bluebtn_pressed"]];
    
    _pbSpeakerEnergy.minValue = 0;
    _pbSpeakerEnergy.maxValue = 100;
    
    [_pbSpeakerEnergy startAnimation:nil];
    _pbSpeakerEnergy.theme = GRProgressIndicatorThemeGreen;
    
    
    _pbMicrophoneEnergy.minValue = 0;
    _pbMicrophoneEnergy.maxValue = 100;
    
    [_pbMicrophoneEnergy startAnimation:nil];
    _pbMicrophoneEnergy.theme = GRProgressIndicatorThemeGreen;
    
    FspManager* fspM = [FspManager instance];
    
    //将设备信息加到ui中
    NSArray<FspAudioDeviceInfo*>* arrMicrophoneDevices = [fspM.fsp_engine getMicrophoneDevices];
    for (FspAudioDeviceInfo* microphoneDevice in arrMicrophoneDevices) {
        [_cbMicrophone addItemWithObjectValue:microphoneDevice];
    }
    
    NSArray<FspAudioDeviceInfo*>* arrSpeakerDevices = [fspM.fsp_engine getSpeakerDevices];
    for (FspAudioDeviceInfo* speakerDevice in arrSpeakerDevices) {
        [_cbSpeaker addItemWithObjectValue:speakerDevice];
    }
        
    NSArray<FspVideoDeviceInfo*>* arrVideoDevices = [fspM.fsp_engine getVideoDevices];
    for (FspVideoDeviceInfo* videoDeviceInfo in arrVideoDevices) {
        [_cbCamera addItemWithObjectValue:videoDeviceInfo];
    }
    
    if ([arrVideoDevices count] > 0) {
        [self previewCamera:[arrVideoDevices firstObject].cameraId];
        [_cbCamera selectItemAtIndex:0];
    }
    
    [self updateAudioDeviceSelection];
    [self.window makeFirstResponder:_btnCancel];
    
    _perSecondTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self onPerSecondTimer];
    }];
    [[NSRunLoop currentRunLoop] addTimer:_perSecondTimer forMode:NSModalPanelRunLoopMode];
}

-(void) windowWillClose:(NSNotification *)notification {
    [_perSecondTimer invalidate];
    
    [_pbSpeakerEnergy stopAnimation:nil];
    [_pbMicrophoneEnergy stopAnimation:nil];
    
    [self stopPreviewCamera];
    
    [NSApp stopModal];
}

- (IBAction)onCbCamera:(id)sender {
    NSInteger index_for_combox = [_cbCamera indexOfSelectedItem]; 
    FspVideoDeviceInfo* deviceinfo = [_cbCamera itemObjectValueAtIndex:index_for_combox];
    [self previewCamera:deviceinfo.cameraId];
}

- (IBAction)onCbSpeakerDevice:(id)sender {
    FspManager* fspM = [FspManager instance];
    
    NSInteger index_for_combox = [_cbSpeaker indexOfSelectedItem]; 
    FspAudioDeviceInfo* deviceinfo = [_cbSpeaker itemObjectValueAtIndex:index_for_combox];
    [fspM.fsp_engine setCurrentSpeakerDevice:deviceinfo.deviceId];
}

- (IBAction)onCbMicrophoneDevice:(id)sender {
    FspManager* fspM = [FspManager instance];
    
    NSInteger index_for_combox = [_cbMicrophone indexOfSelectedItem]; 
    FspAudioDeviceInfo* deviceinfo = [_cbMicrophone itemObjectValueAtIndex:index_for_combox];
    [fspM.fsp_engine setCurrentMicrophoneDevice:deviceinfo.deviceId];
}

- (IBAction)onSliderSpeakerVol:(id)sender {
    FspManager* fspM = [FspManager instance];
    [fspM.fsp_engine setSpeakerVolume:_sliderSpeakerVol.integerValue];
}

- (IBAction)onSliderMicrophoneVol:(id)sender {
    FspManager* fspM = [FspManager instance];
    [fspM.fsp_engine setMicrophoneVolume:_sliderMicVol.integerValue];
}

- (IBAction)onBtnCancel:(id)sender {
    [NSApp stopModal];
    [self.window close];
}

- (IBAction)onBtnConfirm:(id)sender {
    [NSApp stopModal];
    [self.window close];
}

///每秒定时器
-(void) onPerSecondTimer
{
    FspManager* fspM = [FspManager instance];
    _pbSpeakerEnergy.doubleValue = [fspM.fsp_engine getSpeakerEnergy];
    _pbMicrophoneEnergy.doubleValue = [fspM.fsp_engine getMicrophoneEnergy];       
    
    _sliderSpeakerVol.integerValue = [fspM.fsp_engine getSpeakerVolume];
    _sliderMicVol.integerValue = [fspM.fsp_engine getMicrophoneVolume];
}

- (void)updateAudioDeviceSelection
{
    FspManager* fspM = [FspManager instance];
    
    NSInteger curSpeakerDevice = [fspM.fsp_engine getCurrentSpeakerDevice];
    NSInteger curMicrophoneDevice = [fspM.fsp_engine getCurrentMicrophoneDevice];
    
    for (int i = 0; i < [_cbSpeaker numberOfItems]; i++) {
        FspAudioDeviceInfo* deviceInfo = [_cbSpeaker itemObjectValueAtIndex:i];
        if (deviceInfo.deviceId == curSpeakerDevice) {
            [_cbSpeaker selectItemAtIndex:i];
            break;
        }
    }
    
    for (int i = 0; i < [_cbMicrophone numberOfItems]; i++) {
        FspAudioDeviceInfo* deviceInfo = [_cbMicrophone itemObjectValueAtIndex:i];
        if (deviceInfo.deviceId == curMicrophoneDevice) {
            [_cbMicrophone selectItemAtIndex:i];
            break;
        }
    }
}

- (void)previewCamera:(NSInteger)cameraId
{    
    FspManager* fspM = [FspManager instance];
    
    if (_previewCameraId != FSP_INVALID_CAMERA_ID) {
        [fspM.fsp_engine removeVideoPreview:_previewCameraId renderView:_tfRenderView];    
    }
    
    if ([fspM.fsp_engine addVideoPreview:cameraId renderView:_tfRenderView] == FSP_ERR_OK) {
        _previewCameraId = cameraId;
    }
}

-(void)stopPreviewCamera
{
    FspManager* fspM = [FspManager instance];
    if (_previewCameraId != FSP_INVALID_CAMERA_ID) {
        [fspM.fsp_engine removeVideoPreview:_previewCameraId renderView:_tfRenderView];    
    }
}
@end
