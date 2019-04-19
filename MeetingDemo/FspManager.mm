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
    
    NSString* _strAppId;
    NSString* _strSecretKey;
    NSString* _strServerAddr;
}
@end

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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL useConfigVal = [userDefaults boolForKey:CONFIG_KEY_USECONFIG];
    
    if (useConfigVal) {
        _strAppId = [userDefaults stringForKey:CONFIG_KEY_APPID];
        _strSecretKey = [userDefaults stringForKey:CONFIG_KEY_SECRECTKEY];
        _strServerAddr = [userDefaults stringForKey:CONFIG_KEY_SERVETADDR];
    } else {
        _strAppId = @"925aa51ebf829d49fc98b2fca5d963bc";
        _strSecretKey = @"d52be60bb810d17e";
        _strServerAddr = @"";
    }
    
    self.fsp_engine = [FspEngine sharedEngineWithAppId:_strAppId logPath:documentPath serverAddr:_strServerAddr delegate:self];
    if (nil == self.fsp_engine) {
        return NO;
    }
    
    return YES;
}

-(void)destroy
{
    [self.fsp_engine leaveGroup];
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
    fsp::tools::AccessToken token([_strSecretKey UTF8String]);
    
    token.app_id = [_strAppId UTF8String];
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
