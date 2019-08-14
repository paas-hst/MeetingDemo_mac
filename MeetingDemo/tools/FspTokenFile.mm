//
//  tokenFile.m
//  FspNewDemo
//
//  Created by admin on 2019/3/30.
//  Copyright © 2019年 hst. All rights reserved.
//

#import "FspTokenFile.h"
#import "fsp_token.h"
#include <CoreAudio/CoreAudio.h>
#import <AppKit/AppKit.h>
#import "ISSoundAdditions.h"

@implementation FspTokenFile
+ (NSString *)token:(NSString *)secretKey appid:(NSString *)appid groupID:(NSString *)groupid userid:(NSString *)userid{
    fsp::tools::AccessToken token([secretKey UTF8String]);
    token.app_id = [appid UTF8String];
    token.group_id = [groupid UTF8String];
    token.user_id = [userid UTF8String];
    token.expire_time = 0;
    std::string strToken = token.Build();
    NSString *tokenStr = [NSString stringWithUTF8String:strToken.c_str()];
    return tokenStr;
}

+ (void)setMicroVolume:(NSInteger)nPos{
    if (nPos == 0) {
        [NSSound applyMuteForMicphone:true];
        
    }else{
        [NSSound applyMuteForMicphone:false];
        float volume = nPos / 100.f;
        [NSSound setSystemMicphone:volume];
    }
}

+ (void)setSpeakerVolume:(NSInteger)nPos{
    if (nPos == 0) {
        [NSSound applyMuteForVolume:true];
        
    }else{
        [NSSound applyMuteForVolume:false];
        float volume = nPos / 100.0f;
        [NSSound setSystemVolume:volume];
    }
}


@end
