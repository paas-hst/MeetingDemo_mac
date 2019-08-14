//
//  FMLoading.m
//  FastMeeting
//
//  Created by Loki-mac on 15/4/24.
//  Copyright (c) 2015年 Loki-mac. All rights reserved.
//

#import "FMLoading.h"

@interface FMLoading()
{
    BOOL      _bAnimating;
    NSInteger _angle;
    NSInteger _subNumber;
}

//-(NSImage *)rotateImage;
@end

@implementation FMLoading

-(void)awakeFromNib
{
    if(self)
    {
        _bAnimating = FALSE;
        _angle = 360;
        _subNumber = 15;
        
        _img = [NSImage imageNamed:@"img-loading"];
    }
}

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self)
    {
        _bAnimating = FALSE;
        _angle = 360;
        _subNumber = 15;
        
        _img = [NSImage imageNamed:@"img-loading"];
    }
    
    return self;
}

- (void) changeAngle:(id) sender
{
    if (_bAnimating)
    {
        [[self class] cancelPreviousPerformRequestsWithTarget:self
                                                     selector:@selector(changeAngle:)
                                                       object:nil];
        if (_angle > _subNumber)
        {
            _angle -= _subNumber;
        }
        else
        {
            _angle = 360;
        }
        
        [self performSelector:@selector(changeAngle:)
                   withObject:nil
                   afterDelay:0.1f];
        
        
        [self display];
    }
}

- (void)startLoading
{
    if (!_bAnimating)
    {
        _bAnimating = YES;
        [self performSelector:@selector(changeAngle:)
                   withObject:nil
                   afterDelay:0.1f];
    }    
}

- (void)stopLoading
{
    if (_bAnimating)
    {
        _bAnimating = NO;
        [[self class] cancelPreviousPerformRequestsWithTarget:self
                                                     selector:@selector(changeAngle:)
                                                       object:nil];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    NSImage* temp = [self rotateImage];
    if(temp)
    {
        [temp drawInRect:self.bounds];
    }
}

-(NSImage *)rotateImage
{
    NSImage * psourceImage = [_img copy];
    
    NSSize srcSize = [psourceImage size];
    float srcw = srcSize.width;
    float srch= srcSize.height;
    
    if((!psourceImage) || srcSize.width == 0 || srcSize.height == 0)
    {
        return nil;
    }
    unsigned int degres = _angle % 360;
    float rotateDeg = degres;
    NSRect rotateRect;
    
    rotateRect = NSMakeRect(0.5*(srcw -srch), 0.5*(srch-srcw), srch, srcw);
    
    [psourceImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [[NSGraphicsContext currentContext] setShouldAntialias:YES];
    [psourceImage unlockFocus];
    
    //rotate image
    NSSize roSize= NSMakeSize(rotateRect.size.width, rotateRect.size.height);
    
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:[psourceImage size]];
    [rotatedImage lockFocus];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:(0.5 * srcSize.width) yBy: ( 0.5 * srcSize.height)];  //按中心图片旋转
    [transform rotateByDegrees:rotateDeg];                   //旋转度数，rotateByRadians：使用弧度
    [transform translateXBy:(-0.5 * srcSize.width) yBy: (- 0.5 * srcSize.height)];
    [transform concat];
    [psourceImage drawInRect:rotateRect fromRect:NSMakeRect(0,0, srcSize.width ,srcSize.height) operation:NSCompositeCopy fraction:1.0];
    
    [rotatedImage unlockFocus];
    [rotatedImage setScalesWhenResized:YES];
    [rotatedImage setSize:roSize];
    //release
    return rotatedImage;
}

-(void)setLoadingImage:(NSImage *)img
{
    _img = img;
}
@end
