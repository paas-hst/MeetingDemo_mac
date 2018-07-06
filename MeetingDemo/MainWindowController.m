//
//  MainWindowController.m
//  FspClient
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 hst. All rights reserved.
//

#import "FspStateButton.h"
#import "FspUserPanel.h"

#import "FspManager.h"
#import "FspUtils.h"

#import "MainWindowController.h"
#import "SettingWindowController.h"

@interface MainWindowController () <FspEngineDelegate>
{
    NSArray<FspUserPanel*>* _arrUserPanels;
    BOOL _isAudioPublishing;
    NSTimer* _perSecondTimer;
}
@property (weak) IBOutlet FspStateButton *btnToolbarMic;
@property (weak) IBOutlet FspStateButton *btnToolbarVideo;
@property (weak) IBOutlet FspStateButton *btnToolbarSetting;
@property (weak) IBOutlet FspUserPanel *userPanel1;
@property (weak) IBOutlet FspUserPanel *userPanel2;
@property (weak) IBOutlet FspUserPanel *userPanel3;
@property (weak) IBOutlet FspUserPanel *userPanel4;
@property (weak) IBOutlet FspUserPanel *userPanel5;
@property (weak) IBOutlet FspUserPanel *userPanel6;

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];    
    
    _isAudioPublishing = NO;
    _arrUserPanels = [NSArray arrayWithObjects:_userPanel1, _userPanel2, _userPanel3, _userPanel4, _userPanel5, _userPanel6, nil];
    
    self.window.contentView.wantsLayer = YES;  
    self.window.contentView.layer.backgroundColor = [NSColor colorWithRed:(float)0x30/0xff green:(float)0x34/0xff blue:(float)0x3e/0xff alpha:1.0].CGColor; 
    
    [self setToolBarMicState:NO];
    [self setToolBarVideoState:NO];
    
    [_btnToolbarSetting setImages:[NSImage imageNamed:@"toolbar_settings.png"]
                              hot:[NSImage imageNamed:@"toolbar_settings_hot"]
                            press:[NSImage imageNamed:@"toolbar_settings_pressed"]
                          disable:[NSImage imageNamed:@"toolbar_settings_pressed"]];
    
    FspManager* fspM = [FspManager instance];
    [fspM addEventDelegate:self];
    
    _perSecondTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self onPerSecondTimer];
    }];
    
    self.window.title = [NSString stringWithFormat:@"%@ : %@", fspM.myGroupId, fspM.myUserId];
    
    [self.window makeKeyWindow];
}

-(void) windowWillClose:(NSNotification *)notification {
    [_perSecondTimer invalidate];
    [NSApp terminate:nil];
}

- (IBAction)onBtnToolbarMic:(id)sender {
    FspManager* fspM = [FspManager instance];
    if (_isAudioPublishing) {
        FspErrCode fspErr = [fspM.fsp_engine stopPublishAudio];
        if (fspErr == FSP_ERR_OK) {
            _isAudioPublishing = NO;
            [self setToolBarMicState:NO];
        }else {
            NSLog(@"stop publish audio fail :%d\n", fspErr);
        }
    } else {
        FspErrCode fspErr = [fspM.fsp_engine startPublishAudio];
        if (fspErr == FSP_ERR_OK) {
            _isAudioPublishing = YES;
            [self setToolBarMicState:YES];
        }else {
            NSLog(@"start publish audio fail :%d\n", fspErr);
        }
    }    
}

- (IBAction)onBtnToolbarVideo:(id)sender {
    FspManager* fspM = [FspManager instance];    
    NSArray<FspVideoDeviceInfo*>* arrVideoDevices = [fspM.fsp_engine getVideoDevices];
    
    if (arrVideoDevices.count <= 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"确定"];
        alert.messageText = @"错误";
        alert.informativeText = @"没有视频设备";
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        return;
    }
    
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    
    NSInteger nItemIndex = 0;
    for (FspVideoDeviceInfo* videoDeviceInfo in arrVideoDevices) {
        NSString* menuTitle = [NSString stringWithFormat:@"  摄像头(%@)", videoDeviceInfo.deviceName];
        NSMenuItem* videoMenuItem = [theMenu insertItemWithTitle:menuTitle action:@selector(onMenuItemVideo:) keyEquivalent:@"" atIndex:nItemIndex];
        [videoMenuItem setTag:videoDeviceInfo.cameraId];
        if ([fspM getCameraPublishedVideoId:videoDeviceInfo.cameraId] == nil) {            
            [videoMenuItem setImage:[NSImage imageNamed:@"checkbox.png"]];
        } else {
            [videoMenuItem setImage:[NSImage imageNamed:@"checkbox_sel.png"]];
        }
        nItemIndex++;
    }
    
    NSPoint locationInWindow;
    locationInWindow.x = _btnToolbarVideo.frame.origin.x;
    locationInWindow.y = _btnToolbarVideo.frame.origin.y + _btnToolbarVideo.frame.size.height + theMenu.size.height;
    
    int eventType = NSLeftMouseDown;
    
    NSEvent *fakeMouseEvent = [NSEvent mouseEventWithType:eventType 
                                                 location:locationInWindow
                                            modifierFlags:0
                                                timestamp:0
                                             windowNumber:[self.window windowNumber]
                                                  context:[self.window graphicsContext]
                                              eventNumber:0
                                               clickCount:0
                                                 pressure:0];
    
    [NSMenu popUpContextMenu:theMenu withEvent:fakeMouseEvent forView:self.window.contentView];
}

///toolbar 设置按钮
- (IBAction)onBtnToolbarSetting:(id)sender {
    SettingWindowController* settingWindow = [[SettingWindowController alloc]initWithWindowNibName:@"SettingWindow"];
    [[NSApplication sharedApplication] runModalForWindow:settingWindow.window];
}

- (void) onMenuItemVideo:(NSMenuItem *)menuItem {
    NSInteger nCameraId = [menuItem tag];
    FspManager* fspM = [FspManager instance];
    
    if ([fspM getCameraPublishedVideoId:nCameraId] == nil) {
        //广播视频
        NSString* videoId = [self generateVideoId:nCameraId];
        FspUserPanel* myPanel = [self ensureUserPanel:fspM.myUserId videoId:videoId];
        if (myPanel == nil) {
            NSLog(@"have not more video panel\n");
            return;
        }
        
        FspErrCode fspErr = [fspM publishVideo:videoId cameraId:nCameraId];
        if (fspErr != FSP_ERR_OK) {
            NSLog(@"start publish video fail :%d\n", fspErr);
            return;
        }
        
        [myPanel startRender:fspM.myUserId videoId:videoId];
        myPanel.cameraid = nCameraId;
        [fspM.fsp_engine addVideoPreview:nCameraId renderView:[myPanel renderView]];
        
        //成功广播了一路视频就改变toolbar的视频按钮状态
        [self setToolBarVideoState:YES];
    }
    else {
        //停止视频广播 
        NSString* videoId = [self generateVideoId:nCameraId];
        [fspM stopPublishVideo:videoId];
        
        FspUserPanel* myPanel = [self ensureUserPanel:fspM.myUserId videoId:videoId];
        if (myPanel != nil) {
            [fspM.fsp_engine removeVideoPreview:myPanel.cameraid renderView:[myPanel renderView]];
            [myPanel stopRender];
        }
        
        if ([fspM getPublishVideoCount] <= 0) {
            //一路视频都没广播，改变toolbar的时视频按钮状态
            [self setToolBarVideoState:NO]; 
        }
    }
}

///查找与userId对应的userpanel, 如果videoId为nil, 说明只用在显示音频状态
//同一用户的音频和视频用同一个view
-(FspUserPanel*) ensureUserPanel:(NSString*)userId videoId:(NSString*)videoId
{
    FspUserPanel* firstFreeView = nil;
    FspUserPanel* firstSameUserView = nil;
    for (FspUserPanel* userPanel in _arrUserPanels) {
        if ([userPanel.userid isEqualToString:userId]) {
            if ([userPanel.videoid isEqualToString:videoId]) {
                return userPanel;
            } else if (firstSameUserView == nil && 
                       (videoId.length <= 0 || userPanel.videoid.length <= 0)) {
                firstSameUserView = userPanel;
            }
        }
        
        if (firstFreeView == nil && FspStringIsEmpty(userPanel.userid)) {
            firstFreeView = userPanel;
        }
    }
    if (firstSameUserView != nil) {
        return firstSameUserView;
    }
    return firstFreeView;
}

-(void) setToolBarMicState:(BOOL)isOpened
{
    if (isOpened) {
        [_btnToolbarMic setImages:[NSImage imageNamed:@"toolbar_mic_open.png"]
                              hot:[NSImage imageNamed:@"toolbar_mic_open_hot"]
                            press:[NSImage imageNamed:@"toolbar_mic_open_pressed"]
                          disable:[NSImage imageNamed:@"toolbar_mic_open_pressed"]];
    } else {
        [_btnToolbarMic setImages:[NSImage imageNamed:@"toolbar_mic.png"]
                              hot:[NSImage imageNamed:@"toolbar_mic_hot"]
                            press:[NSImage imageNamed:@"toolbar_mic_pressed"]
                          disable:[NSImage imageNamed:@"toolbar_mic_pressed"]];
    }
}

/**
 * 设置底部toolbar视频按钮的显示状态
 * @param isOpened YES,视频打开状态， NO 视频关闭状态
 */
-(void) setToolBarVideoState:(BOOL)isOpened
{
    if (isOpened) {
        [_btnToolbarVideo setImages:[NSImage imageNamed:@"toolbar_cam_open.png"]
                                hot:[NSImage imageNamed:@"toolbar_cam_open_hot"]
                              press:[NSImage imageNamed:@"toolbar_cam_open_pressed"]
                            disable:[NSImage imageNamed:@"toolbar_cam_open_pressed"]];
    } else {
        [_btnToolbarVideo setImages:[NSImage imageNamed:@"toolbar_cam.png"]
                                hot:[NSImage imageNamed:@"toolbar_cam_hot"]
                              press:[NSImage imageNamed:@"toolbar_cam_pressed"]
                            disable:[NSImage imageNamed:@"toolbar_cam_pressed"]];
    }
}

///每秒定时器
- (void) onPerSecondTimer
{
    for (FspUserPanel* userPanel in _arrUserPanels) {
        [userPanel updateStatsInfo];
    }
}

- (NSString*) generateVideoId:(NSInteger)cameraId
{
    return [NSString stringWithFormat:@"macvideo%d", (int)cameraId];
}

#pragma FspEngineDelegate implement

- (void)fspEvent:(FspEventType)eventType
         errCode:(FspErrCode)errCode
{
    
}

- (void)remoteVideoEvent:(NSString * _Nonnull)userId
                 videoId:(NSString * _Nonnull)videoId
               eventType:(FspRemoteVideoEvent)eventType
{
    FspUserPanel* userpanel = [self ensureUserPanel:userId videoId:videoId];
    if (userpanel == nil) {
        NSLog(@"have not more user panel\n");
        return;
    }
    
    FspManager* fspM = [FspManager instance];
    
    if (eventType == FSP_REMOTE_VIDEO_PUBLISH_STARTED) {
        [userpanel startRender:userId videoId:videoId];
        
        [fspM.fsp_engine handleRemoteVideo:userId videoId:videoId operation:FSP_REMOTE_VIDEO_OPEN];
        [fspM.fsp_engine setRemoteVideoRender:userId videoId:videoId renderView:[userpanel renderView]];
        
    } else if (eventType == FSP_REMOTE_VIDEO_PUBLISH_STOPED) {
        [userpanel stopRender];
    }
}

- (void)remoteAudioEvent:(NSString* _Nonnull)userId
               eventType:(FspRemoteAudioEvent)eventType
{
    FspUserPanel* userpanel = [self ensureUserPanel:userId videoId:nil];
    if (userpanel == nil) {
        NSLog(@"have not more user panel\n");
        return;
    }
    
    if (eventType == FSP_REMOTE_VIDEO_PUBLISH_STARTED) {
        [userpanel setAudioState:YES];
    } else if (eventType == FSP_REMOTE_AUDIO_EVENT_PUBLISH_STOPED) {
        [userpanel setAudioState:NO];
    }
}

@end
