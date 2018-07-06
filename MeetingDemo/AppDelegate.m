//
//  AppDelegate.m
//  FspClient
//
//  Created by admin on 2018/4/17.
//  Copyright © 2018年 hst. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

//TODO dellac fspManager

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[FspManager instance] initFsp];
    
    _loginWindowC = [[LoginWindowController alloc]initWithWindowNibName:@"LoginWindow"];    
    [_loginWindowC.window orderFront:nil];
    [[_loginWindowC window] center];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[FspManager instance] destroy];
}

- (void)switchToMain {
    _mainWindowC = [[MainWindowController alloc]initWithWindowNibName:@"MainWindow"];    
    [_mainWindowC.window orderFront:nil];
    [[_mainWindowC window] center];
    
    _loginWindowC = nil;
}


@end
