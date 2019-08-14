//
//  tokenFile.h
//  FspNewDemo
//
//  Created by admin on 2019/3/30.
//  Copyright © 2019年 hst. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FspTokenFile : NSObject
+ (NSString *)token:(NSString *)secretKey appid:(NSString *)appid groupID:(NSString *)groupid userid:(NSString *)userid;
+ (void)setMicroVolume:(NSInteger)nPos;
+ (void)setSpeakerVolume:(NSInteger)nPos;
@end

NS_ASSUME_NONNULL_END
