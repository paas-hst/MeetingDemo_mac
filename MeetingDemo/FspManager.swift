//
//  FspManager.swift
//  MacFspNewDemo
//
//  Created by admin on 2019/4/2.
//  Copyright © 2019年 hst. All rights reserved.
//

import Cocoa
import ReactiveObjC

let CONFIG_KEY_USECONFIG = "fspuseconfig_key"
let CONFIG_KEY_APPID = "fspappid_key"
let CONFIG_KEY_SECRECTKEY = "fspsecretkey_key"
let CONFIG_KEY_SERVETADDR = "fspserveraddr_key"

var AppId: String = "925aa51ebf829d49fc98b2fca5d963bc"
var SecretKey: String = "d52be60bb810d17e"
var ServerAddr: String = ""

let FONT_REGULAR  = "PingFangSC-Regular"
var lock = NSLock()

protocol FspManagerRemoteEventDelegate: class {
    func remoteVideoEvent(_ userId: String, videoId: String, eventType: FspRemoteVideoEvent)
    func remoteAudioEvent(_ userId: String, eventType: FspRemoteAudioEvent)
}

protocol FspManagerRemoteSignallingDelegate: class {
    func onInviteIncome(_ InviterUserId: String, inviteId nInviteId: Int32, groupId nGroupId: String, msg message: String?)
    func onInviteAccepted(_ RemoteUserId: String, inviteId nInviteId: Int32)
    func onInviteRejected(_ RemoteUserId: String, inviteId nInviteId: Int32)
}

class FspManager: NSObject,FspEngineDelegate,FspEngineSignalingDelegate,FspEngineMsgDelegate {
    func onReceiveGroupMsg(_ nSrcUserId: String, msg nMsg: String, msgId nMsgId: Int32) {
        if NSApp.keyWindow == nil {
            return
        }
        if NSApp.keyWindow?.windowController == nil {
            return
        }
        if (NSApp.keyWindow?.windowController! .isKind(of: FspMeetingVC.self))! {
            let vc = NSApp.keyWindow?.windowController as! FspWindowVC
            vc.onReceiveGroupMsg(nSrcUserId, msg: nMsg, msgId: nMsgId)
        }
        
    }
    
    func onGroupUserJoined(_ userId: String) {
        print(userId,"进入会议室！")
        DispatchQueue.main.async {
            self.onJoinedSingnal.sendNext(userId as AnyObject)
        }
        
    }
    
    func onGroupUserLeaved(_ userId: String) {
        print(userId,"离开会议室")
        DispatchQueue.main.async {
            self.onLeftSingnal.sendNext(userId as AnyObject)
        }
    }
    
    //初次进入会议室内 组内的成员
    private(set) var curGroupUsers: Array<FspAttendeeModel> = Array<FspAttendeeModel>()
    
    func onGroupUsersRefreshed(_ user_ids: [String]) {
        print("当前群组",user_ids)
        for userId in user_ids {
            let attendeeModel = FspAttendeeModel()
            attendeeModel.useId = userId
            curGroupUsers.append(attendeeModel)
        }
    }
    
    func onReceiveUserMsg(_ nSrcUserId: String, msg nMsg: String, msgId nMsgId: Int32) {
        if NSApp.keyWindow == nil {
            return
        }
        if NSApp.keyWindow?.windowController == nil {
            return
        }
        if (NSApp.keyWindow?.windowController! .isKind(of: FspWindowVC.self))! {
            let vc = NSApp.keyWindow?.windowController as! FspWindowVC
            vc.onReceiveUserMsg(nSrcUserId, msg: nMsg, msgId: nMsgId)
        }
    }
    

    public let onJoinedSingnal: RACSubject<AnyObject> = RACSubject()
    public let onLeftSingnal: RACSubject<AnyObject> = RACSubject()

    //MARK:用户自身的群组id和userid以及事件和信令事件代理
    public var groupID: String?
    public var userID: String?
    
    weak var delegate:  FspManagerRemoteEventDelegate?
    weak var singallingDelegate: FspManagerRemoteSignallingDelegate?
    
    //MARK:事件回调
    func fspEvent(_ eventType: FspEventType, errCode: FspErrCode) {
        if eventType ==  .FSP_EVENT_LOGIN_RESULT {
            if errCode == FspErrCode.FSP_ERR_OK {
                print("登录成功")
                self.switchToOnline(canSwitch: true)
            }else{
                self.switchToOnline(canSwitch: false)
                let str = NSString.init(format: "%d！", Int(Float(errCode.rawValue)))
                let message = "登录失败,错误码为： " + (str as String)
                self.alertMessage(message: message)
            }
        }else if eventType == .FSP_EVENT_JOINGROUP{
            if errCode == FspErrCode.FSP_ERR_OK {
                print("加入组成功")
                self.switchToMainView()
            }else{
                //MARK:测试
                let str = NSString.init(format: "%d！", Int(Float(errCode.rawValue)))
                let message = "加入组,错误码为： " + (str as String)
                self.alertMessage(message: message)
            }
            
        }else if eventType == .FSP_EVENT_CONNECT_LOST{
            print("断开连接,应用层重新加入")
            
        }else {
            print("重连")
        }
    }
    
    func remoteVideoEvent(_ userId: String, videoId: String, eventType: FspRemoteVideoEvent) {
        if self.delegate != nil {
            self.delegate?.remoteVideoEvent(userId, videoId: videoId, eventType: eventType)
        }
    }
    
    func remoteAudioEvent(_ userId: String, eventType: FspRemoteAudioEvent) {
        if self.delegate != nil {
            self.delegate!.remoteAudioEvent(userId, eventType: eventType)
        }
    }
    
    //MARK:信令回调
    func refreshUserStatusFinished(_ errCode: FspErrCode, requestId nRequestId: UInt32, userInfo nUsrInfos: NSMutableArray){
        if NSApp.keyWindow == nil {
            return
        }
        if NSApp.keyWindow?.windowController == nil {
            return
        }
        if (NSApp.keyWindow?.windowController! .isKind(of: FspWindowVC.self))! {
            let vc = NSApp.keyWindow?.windowController as! FspWindowVC
            vc.updateListTableView(dataSourceArr: nUsrInfos)
        }
    }
    
    func onInviteIncome(_ nInviteUsrId: String, inviteId nInviteId: Int32, groupId nGroupId: String, msg nMsg: String?) {
        if self.singallingDelegate != nil {
            self.singallingDelegate?.onInviteIncome(nInviteUsrId, inviteId: nInviteId, groupId: nGroupId, msg: nMsg)
        }
    }
    
    func onInviteAccepted(_ nRemoteUserId: String, inviteId nInviteId: Int32) {
        if self.singallingDelegate != nil {
            self.singallingDelegate?.onInviteAccepted(nRemoteUserId, inviteId: nInviteId)
        }
    }
    
    func onInviteRejected(_ nRemoteUserId: String, inviteId nInviteId: Int32) {
        if self.singallingDelegate != nil {
            self.singallingDelegate?.onInviteRejected(nRemoteUserId, inviteId: nInviteId)
        }
    }

    var requestId = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
    func UserStatusRefresh(userIds: NSArray?) -> FspErrCode {
        if fsp_engine != nil {
            return fsp_engine!.userStatusRefresh((userIds as! [String]), requestId: requestId)
        }
        return FspErrCode.FSP_ERR_OK
    }
    
    
    
    //MARK: 跳转窗口
    func switchToMainView() -> Void {
        let delegate:AppDelegate = NSApp!.delegate as! AppDelegate
        delegate.switchToMainView()
    }
    
    func alertMessage(message: String) -> Void {
        let delegate:AppDelegate = NSApp!.delegate as! AppDelegate
        delegate.alertMessage(message: message)
    }
    
    func switchToOnline(canSwitch:Bool) -> Void {
        DispatchQueue.main.async {
            let delegate:AppDelegate = NSApp!.delegate as! AppDelegate
            delegate.switchToOnline(canSwitch: canSwitch)
        }

    }
    
    func reconnectGroup() -> Void {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            
        }
    }
    

    //当前的模态窗口
    var cur_window: NSWindowController?

    //MARK:刷新用户状态
    var refreshModelTimer: Timer?
    var safePointer = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
    @objc
    func refreshModel(timer: Timer) -> Void {
        _ = self.fsp_engine?.userStatusRefresh(nil, requestId: safePointer)
    }
    
    func startRefresh() -> Void {
        if refreshModelTimer != nil {
            refreshModelTimer?.invalidate()
            refreshModelTimer = nil
        }
        
        refreshModelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.refreshModel(timer: timer)
        })
    }
    
    
    //呼叫用户数组
    var call_userIds = Array<String>()
    
    //MARK: fsp引擎
    private var fsp_engine: FspEngine?
    //MARK: 初始化
    static let manager = FspManager()
    override init() {
        super.init()
        
    }
    
    
    //MARK:登录 methods
    func login(nToken : String, nUserid: String) -> FspErrCode {
        return self.fsp_engine!.login(nToken, userId: nUserid)
    }
    
    func loginOut() -> FspErrCode {
        return self.fsp_engine!.loginOut()
    }
    
    //MARK: 群组 methods
    func joinGroup(nGroup: String) -> FspErrCode {
        return self.fsp_engine!.joinGroup(nGroup)
    }
    
    func leaveGroup() -> FspErrCode {
        return self.fsp_engine!.leaveGroup()
    }
    
    //MARK: Signaling methods
    func userStatusRefresh(nUserIds: NSArray?, nRequestId: UnsafeMutablePointer<UInt32>) -> FspErrCode {
        return self.fsp_engine!.userStatusRefresh(nUserIds as? [String], requestId: nRequestId)
    }

    func inviteUser(nUsersId: Array<String>!, nGroupId: String, nExtraMsg: String, nInviteId: UnsafeMutablePointer<UInt32>) -> FspErrCode {
        return self.fsp_engine!.inviteUser(nUsersId, groupId: nGroupId, extraMsg: nExtraMsg, inviteId: nInviteId)
    }
    
    func acceptInvite(nInviteUserId: String, nInviteId: Int32) -> FspErrCode {
        return self.fsp_engine!.acceptInvite(nInviteUserId, inviteId: nInviteId)
    }
    
    func rejectInvite(nInviteUserId: String, nInviteId: Int32) -> FspErrCode {
        return self.fsp_engine!.rejectInvite(nInviteUserId, inviteId: nInviteId)
    }
    

    
    func initFsp() -> FspErrCode {
        
        var strAppId: String? = ""
        var strSecretKey: String? = ""
        var strServerAddr: String? = ""
        
        let documents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentationDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let document = documents[0]
        let userDefaults = UserDefaults.standard
        let useConfigVal = userDefaults.bool(forKey: CONFIG_KEY_USECONFIG)
        if useConfigVal == true {
            strAppId = userDefaults.string(forKey: CONFIG_KEY_APPID)!
            strSecretKey = userDefaults.string(forKey: CONFIG_KEY_SECRECTKEY)!
            strServerAddr = userDefaults.string(forKey: CONFIG_KEY_SERVETADDR)!
        }else{
            strAppId = AppId
            strSecretKey = SecretKey
            strServerAddr = ServerAddr
        }
        
        if strAppId == nil || strSecretKey == nil || strServerAddr == nil {
            strAppId = AppId
            strSecretKey = SecretKey
            strServerAddr  = ServerAddr
        }
        
        self.fsp_engine = FspEngine.sharedEngine(withAppId: strAppId!, logPath: document, serverAddr: strServerAddr, delegate: self)
        if self.fsp_engine == nil {
            return FspErrCode.FSP_ERR_FAIL
        }
        return FspErrCode.FSP_ERR_OK
    }
    
    func destoryFsp() -> FspErrCode {
        return self.fsp_engine!.destoryFsp()
    }
    
    
    //MARK: Video method
    func getVideoDevices() -> Array<FspVideoDeviceInfo>{
        return self.fsp_engine!.getVideoDevices()
    }
    
    func getVideoStatus(nUserId: String, nVideoId: String) -> FspVideoStatsInfo? {
        return self.fsp_engine!.getVideoStats(nUserId, videoId: nVideoId)
    }
    
    func setRemoteVideoRender(nUserId: String, nVideoId: String, nRenderView: NSView?, nMode: FspRenderMode) -> FspErrCode {
        return self.fsp_engine!.setRemoteVideoRender(nUserId, videoId: nVideoId, renderView: nRenderView, mode: nMode)
    }
    
    func addVideoPreview(nCameraId: Int, nRenderView: NSView, nMode: FspRenderMode) -> FspErrCode {
        return self.fsp_engine!.addVideoPreview(nCameraId, renderView: nRenderView, mode: nMode)
    }
    
    func removeVideoPreview(nCameraId: Int, nRenderView: NSView) -> FspErrCode {
        return self.fsp_engine!.removeVideoPreview(nCameraId, renderView: nRenderView)
    }
    
    
    //MARK: Audio method
    func getSpeakerDevices() -> Array<FspAudioDeviceInfo> {
        return self.fsp_engine!.getSpeakerDevices()
    }
    
    func getCurrentSpeakerDevice() -> Int {
        return self.fsp_engine!.getCurrentSpeakerDevice()
    }
    
    func getCurrentMicrophoneDevice() -> Int {
        return self.fsp_engine!.getCurrentMicrophoneDevice()
    }
    
    func getSpeakerEnergy() -> Int {
        return self.fsp_engine!.getSpeakerEnergy()
    }
    
    func getMicrophoneEnergy() -> Int {
        return self.fsp_engine!.getMicrophoneEnergy()
    }
    
    func getSpeakerVolume() -> Int {
        return self.fsp_engine!.getSpeakerVolume()
    }
    
    func getMicrophoneVolume() -> Int {
        return self.fsp_engine!.getMicrophoneVolume()
        
    }
    
    func setCurrentMicrophoneDevice(nDeviceId: Int) -> Int {
        return self.fsp_engine!.setCurrentMicrophoneDevice(nDeviceId)
    }
    
    func setCurrentSpeakerDevice(nDeviceId: Int) -> Int {
        return self.fsp_engine!.setCurrentSpeakerDevice(nDeviceId)
    }
    
    func setMicrophoneVolume(nVolume: Int) -> FspErrCode {
        return self.fsp_engine!.setMicrophoneVolume(nVolume)
    }
    
    func setSpeakerVolume(nVolume: Int) -> FspErrCode {
        return self.fsp_engine!.setSpeakerVolume(nVolume)
    }
    
    func getMicrophoneDevices() -> Array<FspAudioDeviceInfo> {
        return self.fsp_engine!.getMicrophoneDevices()
    }
    
    func stopPublishAudio() -> FspErrCode{
        return self.fsp_engine!.stopPublishAudio()
    }
    
    func startPublishAudio() -> FspErrCode{
        return self.fsp_engine!.startPublishAudio()
    }
    
    
    
    lazy var dictPublishedVideos: NSMutableDictionary = {
        let dictPublishedVideos = NSMutableDictionary()
        return dictPublishedVideos
    }()
    
    func publishVideo(videoId: String, cameraId: Int) -> FspErrCode? {
        let errCode = self.fsp_engine!.startPublishVideo(videoId, cameraId: cameraId)
        if errCode == FspErrCode.FSP_ERR_OK {
            self.dictPublishedVideos.setObject(videoId, forKey: NSNumber(integerLiteral: cameraId))
        }
        return errCode
    }
    
    func stopPublishVideo(videoId: String) -> FspErrCode? {
        let errCode = self.fsp_engine!.stopPublishVideo(videoId)
        if errCode == FspErrCode.FSP_ERR_OK {
            for cameraKey in dictPublishedVideos.allKeys {
                if videoId == dictPublishedVideos.object(forKey: cameraKey) as! String{
                    dictPublishedVideos.removeObject(forKey: cameraKey)
                    break
                }
            }
        }
        return errCode
    }
    
    func getCameraPublishedVideoId(cameraId: Int) -> String? {
        return dictPublishedVideos.object(forKey: NSNumber(integerLiteral: cameraId)) as? String
    }
    
    func getPublishVideoCount() -> Int {
        return dictPublishedVideos.count
    }
    
    
    func sendUsrMsg(nUserId: String!, nMsg: String!, nMsgId: UnsafeMutablePointer<UInt32>!) -> FspErrCode {
        return self.fsp_engine!.sendUserMsg(nUserId, msg: nMsg, msgId: nMsgId);
    }
    
    func sendGroupMsg(nMsg: String!, nMsgId: UnsafeMutablePointer<UInt32>!) -> FspErrCode {
        return self.fsp_engine!.sendGroupMsg(nMsg, msgId: nMsgId)
    }

}
