//
//  FspMsgModel.swift
//  MeetingDemo
//
//  Created by 张涛 on 2019/5/7.
//  Copyright © 2019 hst. All rights reserved.
//

import Cocoa

enum FspMsgModelType {
    case ByUser
    case ByRemoteUser
    case BySystem
}


class FspMsgModel: NSObject {
    

    private(set) var calendarString : String!
    var descriptionString: String?
    var time_user_info_Str: String?
    var  msgType: FspMsgModelType?
    
    
    override init() {
        super.init()
        calendarString = getCalendar()
    }
    
    func getCalendar() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: date)
        return dateStr
    }
}
