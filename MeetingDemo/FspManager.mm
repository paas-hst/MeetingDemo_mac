//
//  FspManager.m
//  FspClient
//
//  Created by admin on 2018/4/16.
//  Copyright © 2018年 hst. All rights reserved.
//

#import "FspManager.h"
#include "Token/fsp_token.h"

@interface FspManager() <FspEngineDelegate>
{
    NSMutableArray* _arrEventDelegates;
    NSMutableDictionary* _dictPublishedVideos;
}
@end

#define APP_ID ""
#define APP_SECRET_KEY ""

@implementation FspManager

+ (instancetype)instance {
    static FspManager *s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[FspManager alloc] init];
    });
    
    return s_instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _arrEventDelegates = [[NSMutableArray alloc] init];
        _dictPublishedVideos = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    _arrEventDelegates = nil;
    _dictPublishedVideos = nil;
}

-(Boolean) initFsp
{
    NSArray * documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString * documentPath = [documentPaths objectAtIndex:0];
    
    self.fsp_engine = [FspEngine sharedEngineWithAppId:@APP_ID logPath:documentPath serverAddr:@"" delegate:self];
    if (nil == self.fsp_engine) {
        return NO;
    }
    
    return YES;
}

-(void)destroy
{
    [self.fsp_engine leaveGroup];
    [FspEngine destroy];
}

-(void) addEventDelegate:(id<FspEngineDelegate>)delegate
{
    [_arrEventDelegates addObject:delegate];
}

-(void) removeEventDelegate:(id<FspEngineDelegate>)delegate
{
    [_arrEventDelegates removeObject:delegate];
}

- (NSString*) getCameraPublishedVideoId:(NSInteger)cameraId
{
    return [_dictPublishedVideos objectForKey:[NSNumber numberWithInteger:cameraId]];
}

- (NSInteger) getPublishVideoCount
{
    return [_dictPublishedVideos count];
}

#pragma proxy to FspEngine
- (FspErrCode)joinGroup:(NSString * _Nonnull)grouplId
                 userId:(NSString * _Nonnull)userId
{
    //生成token的代码应该在服务器， demo中直接生成token不是 正确的做法
    fsp::tools::AccessToken token(APP_SECRET_KEY);
    
    token.app_id = APP_ID;
    token.group_id = [grouplId UTF8String];
    token.user_id = [userId UTF8String];
    token.expire_time = 0;
    
    std::string strToken = token.Build();    
    
    self.myGroupId = grouplId;
    self.myUserId = userId;
    return [self.fsp_engine joinGroup:[NSString stringWithUTF8String:strToken.c_str()] groupId:grouplId userId:userId];
}

- (FspErrCode) publishVideo:(NSString*)videoId
                   cameraId:(NSInteger)cameraId
{
    FspErrCode errCode = [self.fsp_engine startPublishVideo:videoId cameraId:cameraId];
    if (errCode == FSP_ERR_OK) {
        [_dictPublishedVideos setObject:videoId forKey:[NSNumber numberWithInteger:cameraId]];
    }
    
    return errCode;
}

- (FspErrCode) stopPublishVideo:(NSString*)videoId
{
    FspErrCode errCode = [self.fsp_engine stopPublishVideo:videoId];
    if (errCode == FSP_ERR_OK) {
        for(NSNumber *cameraKey in _dictPublishedVideos.allKeys) {
            if ([videoId isEqualToString:[_dictPublishedVideos objectForKey:cameraKey]]) {
                [_dictPublishedVideos removeObjectForKey:cameraKey];
                break;
            }
        }
    }
    return errCode;
}

#pragma mark FspEngineDelegate implement

- (void)fspEvent:(FspEventType)eventType
         errCode:(FspErrCode)errCode
{
    dispatch_async(dispatch_get_main_queue(),^{
        for (id<FspEngineDelegate> fspDelegate in _arrEventDelegates)
        {
            [fspDelegate fspEvent:eventType errCode:errCode];
        }        
    });
}

- (void)remoteVideoEvent:(NSString *)userId videoId:(NSString *)videoId eventType:(FspRemoteVideoEvent)eventType
{
    dispatch_async(dispatch_get_main_queue(),^{
        for (id<FspEngineDelegate> fspDelegate in _arrEventDelegates)
        {
            [fspDelegate remoteVideoEvent:userId videoId:videoId eventType:eventType];
        }
        
    });
}

- (void)remoteAudioEvent:(NSString* _Nonnull)userId
               eventType:(FspRemoteAudioEvent)eventType
{
    dispatch_async(dispatch_get_main_queue(),^{
        for (id<FspEngineDelegate> fspDelegate in _arrEventDelegates)
        {
            [fspDelegate remoteAudioEvent:userId eventType:eventType];
        }
        
    });
}

@end
