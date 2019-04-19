//
//  LoginWindowController.m
//  FspClient
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 hst. All rights reserved.
//

#import "AppDelegate.h"

#import "FspManager.h"
#import "FspUtils.h"

#import "FspStateButton.h"

#import "SettingWindowController.h"
#include "LoginConfigWindowController.h"
#import <AVFoundation/AVFoundation.h>

@interface LoginWindowController () <FspEngineDelegate>
@property (weak) IBOutlet NSTextField *textGroupId;
@property (weak) IBOutlet NSTextField *textUserId;
@property (weak) IBOutlet NSButton *btnConfig;

@property (weak) IBOutlet NSTextField *textVersionInfo;
@property (weak) IBOutlet FspStateButton *btnLogin;
@property (weak) IBOutlet NSTextField *textLoginInfo;
@end

@implementation LoginWindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self checkAudioStatus];
    [self checkVideoStatus];
    
    
    self.window.contentView.layer.contents = (id)[NSImage imageNamed:@"login_bg.png"];
    
    [_btnLogin setImages:[NSImage imageNamed:@"login_btn"]
                      hot:[NSImage imageNamed:@"login_btn_hot"]
                    press:[NSImage imageNamed:@"login_btn_pressed"]
                  disable:[NSImage imageNamed:@"login_btn_pressed"]];
    
    
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[_btnConfig attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:titleRange];
    [_btnConfig setAttributedTitle:colorTitle];
    
    _textVersionInfo.stringValue = [NSString stringWithFormat:@"SdkVersion:  %@", [FspEngine getVersionInfo]];
    [[FspManager instance] addEventDelegate:self];
}

- (IBAction)onBtnLogin:(id)sender {
    NSString* groupId = [_textGroupId stringValue];
    NSString* userId = [_textUserId stringValue];
    
    if (FspStringIsEmpty(groupId) || FspStringIsEmpty(userId)) {
        [_textLoginInfo setStringValue:@"please input login info"];
        return;
    }
    [_btnLogin setTitle:@"正在登陆..."];
    [_btnLogin setEnabled:NO];
    FspErrCode loginCode = [[FspManager instance] joinGroup:groupId userId:userId];
    if (loginCode != FSP_ERR_OK) {
        [self onLoginResult:loginCode];
    }
}

- (IBAction)onBtnConfig:(id)sender {
    LoginConfigWindowController* configWindow = [[LoginConfigWindowController alloc]initWithWindowNibName:@"LoginConfigWindow"];
    [[NSApplication sharedApplication] runModalForWindow:configWindow.window];
}

- (void) onLoginResult:(FspErrCode)errCode{
    [_btnLogin setTitle:@"登陆"];
    [_btnLogin setEnabled:YES];
    
    if (FSP_ERR_OK == errCode) {            
        [self.window orderOut:nil];
        [self close];
        [(AppDelegate*)[[NSApplication sharedApplication] delegate] switchToMain];
        
        [[FspManager instance] removeEventDelegate:self];
    } else {
        if (FSP_ERR_TOKEN_INVALID == errCode) {
            _textLoginInfo.stringValue = @"认证失败";            
        }else if (FSP_ERR_CONNECT_FAIL == errCode) {
            _textLoginInfo.stringValue = @"连接失败";            
        } else if (FSP_ERR_NOT_INITED == errCode) {
            _textLoginInfo.stringValue = @"初始化失败";            
        }else {
            _textLoginInfo.stringValue = [NSString stringWithFormat:@"其他错误, code:%d", errCode];            
        }
    }
}


- (void)checkAudioStatus{
    if (@available(macOS 10.14, *)) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        switch (authStatus) {
            case AVAuthorizationStatusNotDetermined:
                //没有询问是否开启麦克风
                [self requestMic];
                break;
            case AVAuthorizationStatusRestricted:
                //未授权，家长限制
                
                break;
            case AVAuthorizationStatusDenied:
                //玩家未授权
                
                break;
            case AVAuthorizationStatusAuthorized:
                //玩家授权
                
                break;
            default:
                break;
        }
    } else {
        // Fallback on earlier versions
    }
    
}

- (void)requestMic{
    
    if (@available(macOS 10.14, *)) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (granted) {
                NSLog(@"******麦克风准许");
            }else{
                NSLog(@"******麦克风不准许");
            }
        }];
    } else {
        // Fallback on earlier versions
        
    }
    
}

//授权相机
- (void)videoAuthAction
{
    if (@available(macOS 10.14, *)) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            NSLog(@"%@",granted ? @"相机准许":@"相机不准许");
        }];
    } else {
        // Fallback on earlier versions
        
    }
}


- (void) checkVideoStatus
{
    if (@available(macOS 10.14, *)) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (authStatus) {
            case AVAuthorizationStatusNotDetermined:
                //没有询问是否开启相机
                [self videoAuthAction];
                break;
            case AVAuthorizationStatusRestricted:
                //未授权，家长限制
                
                break;
            case AVAuthorizationStatusDenied:
                //未授权
                
                break;
            case AVAuthorizationStatusAuthorized:
                //玩家授权
                
                break;
            default:
                break;
        }
    } else {
        // Fallback on earlier versions
    }
}


#pragma FspEngineDelegate implement

- (void)fspEvent:(FspEventType)eventType
         errCode:(FspErrCode)errCode
{
    if (eventType == FSP_EVENT_JOINGROUP) {
        [self onLoginResult:errCode];
    }
}

- (void)remoteVideoEvent:(NSString * _Nonnull)userId
                 videoId:(NSString * _Nonnull)videoId
               eventType:(FspRemoteVideoEvent)eventType
{
    
}

- (void)remoteAudioEvent:(NSString* _Nonnull)userId
               eventType:(FspRemoteAudioEvent)eventType
{
    
}

@end
