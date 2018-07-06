//
//  FspStateButton.m
//  FspClient
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 hst. All rights reserved.
//

#import "FspStateButton.h"

@interface FspStateButtonCell : NSButtonCell
{
    BOOL _bMouseEnter;
    
    NSImage *_img_Normal;
    NSImage *_img_Hot;
    NSImage *_img_Press;
    NSImage *_img_Disable;
}

@property (copy) NSColor *color_Normal;
@property (copy) NSColor *color_Press;

-(void)setMouseEnter:(BOOL)bEnter;
-(void)setImages:(NSImage*)normal hot:(NSImage*)hot press:(NSImage*)press disable:(NSImage *)disable;
@end

@implementation FspStateButtonCell

-(id)init
{
    self = [super init];
    
    _bMouseEnter = FALSE;
    
    _color_Normal = [NSColor whiteColor];
    _color_Press  = [NSColor grayColor];
    return self;
}

-(void)setImages:(NSImage *)normal hot:(NSImage *)hot press:(NSImage *)press disable:(NSImage*)disable
{
    _img_Normal = normal;
    _img_Hot = hot;
    _img_Press = press;
    _img_Disable = disable;
}

-(void)setMouseEnter:(BOOL)bEnter
{
    _bMouseEnter = bEnter;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    if(![self isEnabled])
    {
        [_img_Disable drawInRect:frame];
        
        return;
    }
    
    if([self isHighlighted])
    {
        [_img_Press drawInRect:frame];
    }
    else
    {
        if(_bMouseEnter)
            [_img_Hot drawInRect:frame];
        else
            [_img_Normal drawInRect:frame];
    }
}

// Move text a bit to the right to ensure that it is displayed centered
- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    
    [style setAlignment:NSCenterTextAlignment];
    
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:style,
                          NSParagraphStyleAttributeName,
                          self.highlighted ? _color_Press : _color_Normal,
                          NSForegroundColorAttributeName,
                          nil];
    
    [self.title drawInRect:frame withAttributes:attr];
    
    return frame;
}

@end


////////////////////////////////////////////////

@implementation FspStateButton

-(id)initWithFrame:(NSRect)frameRect
{
    if(self = [super initWithFrame:frameRect])
    {
        [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
        
        NSButtonCell *originalCell = [self cell];
        FspStateButtonCell *customCell = [[FspStateButtonCell alloc] init];
        customCell.bezelStyle = originalCell.bezelStyle;
        customCell.font = originalCell.font;
        customCell.title = originalCell.title;
        [customCell setEnabled:originalCell.isEnabled];
        [self setCell:customCell];
        
        NSFont *font = [NSFont systemFontOfSize:14];
        
        [self setFont:font];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
        
        NSButtonCell *originalCell = [self cell];
        FspStateButtonCell *customCell = [[FspStateButtonCell alloc] init];
        customCell.bezelStyle = originalCell.bezelStyle;
        customCell.font = originalCell.font;
        customCell.title = originalCell.title;
        [customCell setEnabled:originalCell.isEnabled];
        [self setCell:customCell];
        
        NSFont *font = [NSFont systemFontOfSize:12];
        
        [self setFont:font];
    }
    return self;
}

-(void)mouseEntered:(NSEvent *)theEvent
{    
    [(FspStateButtonCell*)self.cell setMouseEnter:TRUE];
    [super mouseEntered:theEvent];
    [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [(FspStateButtonCell*)self.cell setMouseEnter:FALSE];
    
    [super mouseExited:theEvent];
    [self setNeedsDisplay:YES];
}

-(void)setTitle:(NSString *)title
{
    NSFont *font = [NSFont systemFontOfSize:12];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    NSInteger titleWidth = [[[NSAttributedString alloc] initWithString:title attributes:attributes] size].width;
    
    NSInteger cellWidth = NSWidth(self.bounds) - 45;
    if(titleWidth > cellWidth)
    {
        NSInteger len = title.length;
        
        for (int i = 0; i < len; i++)
        {
            NSString *temp = [[NSString alloc] initWithFormat:@"%@...",[title substringToIndex:i],nil];
            
            NSInteger width = [[[NSAttributedString alloc] initWithString:temp attributes:attributes] size].width;
            if(width >= cellWidth)
            {
                [super setTitle:temp];
                break;
            }
        }
    }
    else
    {
        [super setTitle:title];
    }
    [super setToolTip:title];
}

-(void)setImages:(NSImage*)normal hot:(NSImage*)hot press:(NSImage*)press disable:(NSImage *)disable
{
    [(FspStateButtonCell*)self.cell setImages:normal
                                          hot:hot
                                        press:press
                                      disable:disable];
}


-(void)setTitleColor:(NSColor *)normalColor press:(NSColor *)pressColor
{
    if(normalColor)
        [(FspStateButtonCell*)self.cell setColor_Normal:normalColor];
    
    if(pressColor)
        [(FspStateButtonCell*)self.cell setColor_Press:pressColor];
}
@end
