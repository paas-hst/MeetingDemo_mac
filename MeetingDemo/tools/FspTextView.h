//
//  FMTextView.h
//  FastMeeting
//
//  Created by Loki-mac on 15/8/10.
//  Copyright (c) 2015年 Loki-mac. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface FspTextView : NSTextView
{
    NSAttributedString *placeHolderString;
}

@property (nonatomic, strong, readonly)RACSubject *onEnterSginal;
@end
