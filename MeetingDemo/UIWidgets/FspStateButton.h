//
//  FspStateButton.h
//  FspClient
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 hst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FspStateButton : NSButton

-(void)setTitle:(NSString *)title;
-(void)setImages:(NSImage*)normal hot:(NSImage*)hot press:(NSImage*)press disable:(NSImage*)disable;
-(void)setTitleColor:(NSColor*)normalColor press:(NSColor*)pressColor;

@end
