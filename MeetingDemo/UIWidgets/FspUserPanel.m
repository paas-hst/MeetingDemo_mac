//
//  FspUserPanel.m
//  FspClient
//
//  Created by admin on 2018/5/18.
//  Copyright © 2018年 hst. All rights reserved.
//

#import "FspManager.h"
#import "FspTextField.h"
#import "GRProgressIndicator.h"
#import "FspUserPanel.h"

@interface FspUserViewController : NSViewController

@property (weak) IBOutlet NSTextField *renderView;
@property (weak) IBOutlet FspTextField *textVideoInfo;
@property (weak) IBOutlet NSImageView *ivAudioState;
@property (weak) IBOutlet GRProgressIndicator *pbAudioEnergy;
@property (weak) IBOutlet NSImageView *ivAudioEnergyBg;

@end

@implementation FspUserViewController

-(void)viewDidLoad
{
    [_renderView setHidden:YES];
    [_textVideoInfo setHidden:YES];
    [_textVideoInfo setBackgroundImage:[NSImage imageNamed:@"video_stat_bg"]];
    
    [_ivAudioState setHidden:YES];
    [_pbAudioEnergy setHidden:YES];
    [_ivAudioEnergyBg setHidden:YES];
    
    _pbAudioEnergy.minValue = 0;
    _pbAudioEnergy.maxValue = 100;
        
    [_pbAudioEnergy startAnimation:nil];
    _pbAudioEnergy.theme = GRProgressIndicatorThemeGreen;
}

-(void)viewWillDisappear
{
    [_pbAudioEnergy stopAnimation:nil];
}

@end

@interface FspUserPanel()
{
    FspUserViewController* _userViewController;
    FspRenderMode _currentRenderMode;
    BOOL _isAudioOpened;
    
    NSRect originFrame;
    NSRect fullScreenFrame;
}
@end

#define MENU_TAG_RENDER_MODE_SCALE_FILL 100
#define MENU_TAG_RENDER_MODE_CROP_FILL 101
#define MENU_TAG_RENDER_MODE_FIT_CENTER 102

@implementation FspUserPanel

-(NSView*) renderView
{
    return _userViewController.renderView;    
}

-(FspRenderMode) currentRenderMode
{
    return _currentRenderMode;    
}




- (instancetype)initWithCoder:(NSCoder*)coder
{    
    self = [super initWithCoder:coder];
    
    _currentRenderMode = MENU_TAG_RENDER_MODE_FIT_CENTER;
    [self setAudioState:NO];
    
    if (self) {        
        _userViewController = [[FspUserViewController alloc] initWithNibName:@"FspUserView" bundle:nil];
 
        [_userViewController.view setFrame:[self bounds]];        
        [self addSubview:_userViewController.view];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor colorWithRed:(float)0x51/0xff green:(float)0x59/0xff blue:(float)0x6c/0xff alpha:1.0]setFill]; 
    NSRectFill(self.bounds); 
}

-(void) startRender:(NSString*)userId videoId:(NSString*)videoId
{
    _userid = userId;
    _videoid = videoId;
    
    [_userViewController.renderView setHidden:NO];
    [_userViewController.textVideoInfo setHidden:NO];     

    //mac 暂不支持渲染模式设置
    
    /*
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    
    NSMenuItem* itemScaleFill = [theMenu insertItemWithTitle:@"  视频平铺显示" action:@selector(onVideoMenuItem:) keyEquivalent:@"" atIndex:0];    
    [itemScaleFill setTag:MENU_TAG_RENDER_MODE_SCALE_FILL];
    if (_currentRenderMode == FSP_RENDERMODE_SCALE_FILL) {
        [itemScaleFill setImage:[NSImage imageNamed:@"checkbox_sel.png"]];
    } else {
        [itemScaleFill setImage:[NSImage imageNamed:@"checkbox.png"]];
    }
    
    NSMenuItem* itemCropFill = [theMenu insertItemWithTitle:@"  视频等比裁剪显示" action:@selector(onVideoMenuItem:) keyEquivalent:@"" atIndex:1];
    [itemCropFill setTag:MENU_TAG_RENDER_MODE_FIT_CENTER];
    if (_currentRenderMode == FSP_RENDERMODE_CROP_FILL) {
        [itemCropFill setImage:[NSImage imageNamed:@"checkbox_sel.png"]];
    } else {
        [itemCropFill setImage:[NSImage imageNamed:@"checkbox.png"]];
    }
    
    NSMenuItem* itemFitCenter = [theMenu insertItemWithTitle:@"  视频等比居中显示" action:@selector(onVideoMenuItem:) keyEquivalent:@"" atIndex:2];
    [itemFitCenter setTag:MENU_TAG_RENDER_MODE_CROP_FILL];
    if (_currentRenderMode == FSP_RENDERMODE_CROP_FILL) {
        [itemFitCenter setImage:[NSImage imageNamed:@"checkbox_sel.png"]];
    } else {
        [itemFitCenter setImage:[NSImage imageNamed:@"checkbox.png"]];
    }
    
    [_videoViewController.view setMenu:theMenu];
    */
}

-(void) stopRender
{
    if (!_isAudioOpened) {
        _userid = nil;
        [_userViewController.textVideoInfo setHidden:YES];
        _userViewController.textVideoInfo.stringValue = @"";
    }
    
    _videoid = nil;
    [_userViewController.renderView setHidden:YES];
    
    [_userViewController.view setMenu:nil];
}

-(void) setAudioState:(BOOL)isAudioOpened
{
    _isAudioOpened = isAudioOpened;
    
    if (_isAudioOpened) {
        [_userViewController.ivAudioState setHidden:NO];
        [_userViewController.pbAudioEnergy setHidden:NO];
        [_userViewController.ivAudioEnergyBg setHidden:NO];
    } else {
        [_userViewController.ivAudioState setHidden:YES];
        [_userViewController.pbAudioEnergy setHidden:YES];
        [_userViewController.ivAudioEnergyBg setHidden:YES];
    }
}

-(void) updateStatsInfo
{
    if (_userid == nil) {
        return;
    }
    
    FspManager* fspM = [FspManager instance];
    
    if (_videoid == nil) {
        _userViewController.textVideoInfo.stringValue = self.userid;
    } else {
        FspVideoStatsInfo* statsInfo = [fspM.fsp_engine getVideoStats:_userid videoId:_videoid];
        if (statsInfo != nil) {
            _userViewController.textVideoInfo.stringValue = [NSString stringWithFormat:@"%@: %@", self.userid, [statsInfo description]];
        }
    }
        
    if (_isAudioOpened) {
        _userViewController.pbAudioEnergy.doubleValue = [fspM.fsp_engine getRemoteAudioEnergy:self.userid];
    }
}

- (void) onVideoMenuItem:(NSMenuItem *)menuItem
{
    NSInteger itemTag = menuItem.tag;
    if (MENU_TAG_RENDER_MODE_SCALE_FILL == itemTag) {
        [self setRenderMode:FSP_RENDERMODE_SCALE_FILL];        
    } else if (MENU_TAG_RENDER_MODE_CROP_FILL == itemTag) {
        [self setRenderMode:FSP_RENDERMODE_CROP_FILL];
    } else if (MENU_TAG_RENDER_MODE_FIT_CENTER == itemTag) {
        [self setRenderMode:FSP_RENDERMODE_FIT_CENTER];
    }
}

- (void) setRenderMode:(FspRenderMode)renderMode
{
    FspManager *fspM = [FspManager instance];
    FspErrCode errCode = [fspM.fsp_engine setRenderMode:self.renderView mode:renderMode];
    
    if (errCode == FSP_ERR_OK) {
        _currentRenderMode = renderMode;
    }
}

@end
