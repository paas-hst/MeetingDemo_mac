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

@interface LoginWindowController () <FspEngineDelegate>
@property (weak) IBOutlet NSTextField *textGroupId;
@property (weak) IBOutlet NSTextField *textUserId;

@property (weak) IBOutlet FspStateButton *btnLogin;
@property (weak) IBOutlet NSTextField *textLoginInfo;
@end

@implementation LoginWindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.contentView.layer.contents = (id)[NSImage imageNamed:@"login_bg.png"];
    
    [_btnLogin setImages:[NSImage imageNamed:@"login_btn"]
                      hot:[NSImage imageNamed:@"login_btn_hot"]
                    press:[NSImage imageNamed:@"login_btn_pressed"]
                  disable:[NSImage imageNamed:@"login_btn_pressed"]];
    
    
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
    [[FspManager instance] joinGroup:groupId userId:userId];
}

#pragma FspEngineDelegate implement

- (void)fspEvent:(FspEventType)eventType
         errCode:(FspErrCode)errCode
{
    if (eventType == FSP_EVENT_JOINGROUP) {
        [_btnLogin setTitle:@"登陆"];
        [_btnLogin setEnabled:YES];
        
        if (FSP_ERR_OK == errCode) {            
            [self.window orderOut:nil];
            [self close];
            [(AppDelegate*)[[NSApplication sharedApplication] delegate] switchToMain];
            
            [[FspManager instance] removeEventDelegate:self];
        } else {
            [_textLoginInfo setStringValue:@"login fail"];
        }
    }
}

- (void)remoteVideoEvent:(NSString * _Nonnull)userId
                 videoId:(NSString * _Nonnull)videoId
               eventType:(FspRemoteVideoEvent)eventType
{
    
}

@end
