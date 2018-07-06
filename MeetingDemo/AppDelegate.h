//
//  AppDelegate.h
//  FspClient
//
//  Created by admin on 2018/4/17.
//  Copyright © 2018年 hst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FspManager.h"
#import "MainWindowController.h"
#import "LoginWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) LoginWindowController *loginWindowC;
@property (strong) MainWindowController *mainWindowC;

- (void)switchToMain;

@end

