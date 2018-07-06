//
//  FspTextEdit.m
//  FastMeeting
//
//  Created by Loki-mac on 15/4/22.
//  Copyright (c) 2015年 Loki-mac. All rights reserved.
//

#import "FspTextField.h"

@interface FspTextField()
{
    NSImage *_imgBackground;
}
@end

@implementation FspTextField

-(void)setBackgroundImage:(NSImage*)bg
{
    _imgBackground = bg;
}

- (void)awakeFromNib
{
    [self setDrawsBackground:NO];
    self.bezeled = NO;
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];  
    
    if (_imgBackground != nil) {
        [_imgBackground drawInRect:rect];
    }    
}

@end
