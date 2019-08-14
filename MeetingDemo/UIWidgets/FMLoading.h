//
//  FMLoading.h
//  FastMeeting
//
//  Created by Loki-mac on 15/4/24.
//  Copyright (c) 2015年 Loki-mac. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FMLoading : NSView
{
    NSImage *_img;
}

-(void)setLoadingImage:(NSImage*)img;
-(void)startLoading;
-(void)stopLoading;
@end
