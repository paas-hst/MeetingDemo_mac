//
//  FspUtils.m
//  FspClient
//
//  Created by admin on 2018/5/18.
//  Copyright © 2018年 hst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FspUtils.h"

BOOL FspStringIsEmpty(NSString* str)
{
    if (!str) {
        return YES;
    }
    
    return str.length == 0;
}
