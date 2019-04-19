//
//  LoginConfigWindowController.m
//  MeetingDemo
//
//  Created by admin on 2019/1/23.
//  Copyright © 2019年 hst. All rights reserved.
//

#import "LoginConfigWindowController.h"
#import "FspManager.h"
#import "UIWidgets/FspStateButton.h"

@interface LoginConfigWindowController ()
{
    int _appidClickCount;
}
@property (weak) IBOutlet NSButton *checkUseConfig;
@property (weak) IBOutlet NSTextField *textAppid;
@property (weak) IBOutlet NSTextField *textSecrectKey;
@property (weak) IBOutlet NSTextField *textServerAddr;
@property (weak) IBOutlet FspStateButton *btnCancel;
@property (weak) IBOutlet FspStateButton *btnConfirm;

@end

@implementation LoginConfigWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    _appidClickCount = 0;
    self.window.contentView.layer.contents = (id)[NSImage imageNamed:@"login_bg.png"];
    
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[_checkUseConfig attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:titleRange];
    [_checkUseConfig setAttributedTitle:colorTitle];
    
    [_btnCancel setImages:[NSImage imageNamed:@"login_btn"]
                     hot:[NSImage imageNamed:@"login_btn_hot"]
                   press:[NSImage imageNamed:@"login_btn_pressed"]
                 disable:[NSImage imageNamed:@"login_btn_pressed"]];
    
    [_btnConfirm setImages:[NSImage imageNamed:@"login_btn"]
                     hot:[NSImage imageNamed:@"login_btn_hot"]
                   press:[NSImage imageNamed:@"login_btn_pressed"]
                 disable:[NSImage imageNamed:@"login_btn_pressed"]];
    
    _textServerAddr.hidden = YES;
    [self loadSavedConfig:NO];
}

-(void) windowWillClose:(NSNotification *)notification {

    [NSApp stopModal];
}

- (void) loadSavedConfig:(BOOL)isFromUi
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (isFromUi == NO) {
        BOOL useConfigVal = [userDefaults boolForKey:CONFIG_KEY_USECONFIG];
        _checkUseConfig.state = useConfigVal;
    }
    
    if (_checkUseConfig.state) {
        _textAppid.stringValue = [userDefaults stringForKey:CONFIG_KEY_APPID];
        _textSecrectKey.stringValue = [userDefaults stringForKey:CONFIG_KEY_SECRECTKEY];
        _textServerAddr.stringValue = [userDefaults stringForKey:CONFIG_KEY_SERVETADDR];
    }
}

- (IBAction)onClickAppid:(id)sender {
    _appidClickCount++;
    if (_appidClickCount > 5) {
        _textServerAddr.hidden = NO;
    }
}

- (IBAction)onBtnUseConfig:(id)sender {
    if (_checkUseConfig.state) {
        _textAppid.enabled = YES;
        _textSecrectKey.enabled = YES;
        _textServerAddr.enabled = YES;
        
        [self loadSavedConfig:YES];
    } else {
        _textAppid.stringValue = @"";
        _textAppid.enabled = NO;
        
        _textSecrectKey.stringValue = @"";
        _textSecrectKey.enabled = NO;
        
        _textServerAddr.stringValue = @"";
        _textServerAddr.enabled = NO;
    }
}

- (IBAction)onBtnCancel:(id)sender {
    [NSApp stopModal];
    [self.window close];
}

- (IBAction)onBtnConfirm:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_checkUseConfig.state forKey:CONFIG_KEY_USECONFIG];
    
    if (_checkUseConfig.state) {
        [userDefaults setObject:_textAppid.stringValue forKey:CONFIG_KEY_APPID];
        [userDefaults setObject:_textSecrectKey.stringValue forKey:CONFIG_KEY_SECRECTKEY];
        [userDefaults setObject:_textServerAddr.stringValue forKey:CONFIG_KEY_SERVETADDR];
    }
    [userDefaults synchronize];
    
    [NSApp stopModal];
    [self.window close];
}

@end
