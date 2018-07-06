//
//  FspVideoPanel.h
//  FspClient
//
//  Created by admin on 2018/5/18.
//  Copyright © 2018年 hst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FspKit/FspEngine.h"

@interface FspUserPanel : NSView

@property (readonly) NSString* userid;
@property (readonly) NSString* videoid;

@property NSInteger cameraid; ///<如果渲染本地视频，可以用来保存渲染的哪个camera

-(FspRenderMode) currentRenderMode;

-(void) startRender:(NSString*)userId videoId:(NSString*)videoId;
-(void) stopRender;

-(void) setAudioState:(BOOL)isAudioOpened;

-(NSView*) renderView;

-(void) updateStatsInfo;

@end
