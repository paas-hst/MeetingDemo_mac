//
//  FspManager.h
//  FspClient
//
//  Created by admin on 2018/4/16.
//  Copyright © 2018年 hst. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FspKit/FspEngine.h"

#define CONFIG_KEY_USECONFIG @"fspuseconfig_key"
#define CONFIG_KEY_APPID @"fspappid_key"
#define CONFIG_KEY_SECRECTKEY @"fspsecretkey_key"
#define CONFIG_KEY_SERVETADDR @"fspserveraddr_key"

@interface FspManager : NSObject<FspEngineDelegate>

@property FspEngine* fsp_engine;

@property NSString* myGroupId;
@property NSString* myUserId;

+ (instancetype) instance;

- (Boolean) initFsp;
- (void) destroy;

- (void) addEventDelegate:(id<FspEngineDelegate>)delegate;
- (void) removeEventDelegate:(id<FspEngineDelegate>)delegate;

- (NSString*) getCameraPublishedVideoId:(NSInteger)cameraId;

- (NSInteger) getPublishVideoCount;

#pragma proxy to FspEngine
- (FspErrCode) joinGroup:(NSString * _Nonnull)grouplId
                  userId:(NSString * _Nonnull)userId;

- (FspErrCode) publishVideo:(NSString*)videoId
                   cameraId:(NSInteger)cameraId;

- (FspErrCode) stopPublishVideo:(NSString*)videoId;

@end
