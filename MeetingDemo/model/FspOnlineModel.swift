//
//  FspOnlineModel.swift
//  MacFspNewDemo
//
//  Created by 张涛 on 2019/4/4.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

enum statusType {
    case statusTypeOnline
    case statusTypeOffline
}

class FspOnlineModel: NSObject {
    
    var user_id: String = "测试"
    var status: statusType = statusType.statusTypeOnline
    override init() {
        super.init()
    }
    
}
