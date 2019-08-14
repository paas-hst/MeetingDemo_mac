//
//  FspSignaling.h
//  FspKit
//
//  Created by 张涛 on 2019/7/26.
//  Copyright © 2019 hst. All rights reserved.
//

#import <Foundation/Foundation.h>

//官方保留的videoid,代表特定类型的广播，广播时不能取这些值
/**
 * @brief 屏幕共享
 */
extern NSString * _Nonnull const FSP_RESERVED_VIDEOID_SCREENSHARE;

/**
 * 错误码集合
 */
typedef NS_ENUM(NSInteger, FspErrCode) {
    FSP_ERR_OK = 0, ///<成功
    
    FSP_ERR_INVALID_ARG = 1,      ///<非法参数
    FSP_ERR_NOT_INITED = 2,       ///<未初始化
    FSP_ERR_OUTOF_MEMORY = 3,     ///<内存不足
    FSP_ERR_DEVICE_FAIL = 4,      ///<访问设备失败
    
    FSP_ERR_CONNECT_FAIL = 30,     ///<网络连接失败
    FSP_ERR_NO_GROUP = 31,         ///<没加入组
    FSP_ERR_TOKEN_INVALID = 32,    ///<认证失败
    FSP_ERR_APP_NOT_EXIST = 33,    ///<app不存在，或者app被删除
    FSP_ERR_USERID_CONFLICT = 34,  ///<相同userid已经加入同一个组，无法再加入
    
    FSP_ERR_NO_BALANCE = 70,         ///<账户余额不足
    FSP_ERR_NO_VIDEO_PRIVILEGE = 71, ///<没有视频权限
    FSP_ERR_NO_AUDIO_PRIVILEGE = 72, ///<没有音频权限
    
    FSP_ERR_NO_SCREEN_SHARE = 73,    ///<当前没有屏幕共享
    
    FSP_ERR_RECVING_SCREEN_SHARE = 74,   ///<当前正在接收屏幕共享
    
    FSP_ERR_SERVER_ERROR = 301,        ///服务内部错误
    FSP_ERR_FAIL = 302              ///<操作失败
};

/**
 * 视频显示缩放模式
 */
typedef NS_ENUM(NSInteger, FspRenderMode) {
    FSP_RENDERMODE_SCALE_FILL = 1, ///<缩放平铺
    FSP_RENDERMODE_CROP_FILL = 2,  ///<等比裁剪显示
    FSP_RENDERMODE_FIT_CENTER = 3 ///<等比居中显示
};

static const NSInteger FSP_INVALID_CAMERA_ID = -1; ///<未定义cameraid
static const NSInteger FSP_INVALID_DEVICE_ID = -1; ///<未定义deviceid

/**
 *@brief 用户状态
 */
typedef NS_ENUM(NSUInteger, FspUsrStatus) {
    FSP_USR_STATUS_ONLINE,  ///在线
    FSP_USR_STATUS_OFFLINE  ///下线
};

/**
 *@brief 用户信息
 */
@interface FspUsrInfo : NSObject
@property (copy, nonatomic) NSString *_Nonnull userId; ///<用户id
@property (assign, nonatomic) FspUsrStatus userStatus; ///<用户状态
@end

/**
 * @brief 视频设备信息
 */
@interface FspVideoDeviceInfo : NSObject
@property (assign, nonatomic) NSInteger cameraId; ///<摄像头id
@property (copy, nonatomic) NSString* _Nullable deviceName; ///<设备名
@end


/**
 * @brief 音频设备信息
 */
@interface FspAudioDeviceInfo : NSObject
@property (assign, nonatomic) NSInteger deviceId; ///<音频设备id
@property (copy, nonatomic) NSString* _Nullable deviceName; ///<设备名
@end


/**
 * 视频统计信息
 */
@interface FspVideoStatsInfo : NSObject
@property (assign, nonatomic) NSInteger width; ///<视频宽,像素
@property (assign, nonatomic) NSInteger height; ///<视频高，像素
@property (assign, nonatomic) NSInteger framerate; ///<帧率
@property (assign, nonatomic) NSInteger bitrate; ///<码率
@end


/**
 * 本地视频profile信息
 */
@interface FspVideoProfile : NSObject
@property (assign, nonatomic) NSInteger width; ///<视频宽,像素
@property (assign, nonatomic) NSInteger height; ///<视频高，像素
@property (assign, nonatomic) NSInteger framerate; ///<帧率

/**
 * 通过width, height, framerate构造profile
 */
+ (FspVideoProfile* _Nullable)profileWith:(NSInteger)width height:(NSInteger)height framerate:(NSInteger)framerate;
@end


/**
 * fspEvent事件类型
 */
typedef NS_ENUM(NSInteger, FspEventType) {
    FSP_EVENT_JOINGROUP = 0,          ///<加入组结果
    FSP_EVENT_CONNECT_LOST = 1,       ///<与fsp服务的连接断开，应用层需要去重新加入组
    FSP_EVENT_RECONNECT_START = 2,    ///<网络断开过，开始重连
    FSP_EVENT_LOGIN_RESULT = 3        ///<登录结果
};

/**
 * 远端视频事件类型
 */
typedef NS_ENUM(NSInteger, FspRemoteVideoEvent) {
    FSP_REMOTE_VIDEO_PUBLISH_STARTED = 0,  ///<远端广播了一路视频
    FSP_REMOTE_VIDEO_PUBLISH_STOPED = 1,   ///<远端停止广播视频
    FSP_REMOTE_VIDEO_FIRST_RENDERED = 2    ///<远端视频第一次显示，加载完成的事件
};

/**
 * 远端音频事件类型
 */
typedef NS_ENUM(NSInteger, FspRemoteAudioEvent) {
    FSP_REMOTE_AUDIO_EVENT_PUBLISHED = 0,     ///<远端用户广播了音频
    FSP_REMOTE_AUDIO_EVENT_PUBLISH_STOPED = 1 ///<远端用户停止了广播音频
};


@protocol FspSignaling <NSObject>

/**
 *@brief 登入
 *@param nToken 访问fsp的令牌，令牌的获取参考fsp鉴权
 *@param nUserId 自身的userId
 *@return 结果错误码
 */
- (FspErrCode)login:(NSString * _Nonnull)nToken userId:(NSString * _Nonnull)nUserId;

/**
 *@brief 登出
 *@return 结果错误码
 */
- (FspErrCode)loginOut;

/**
 *@param nGroupId 加入组的group Id
 *@return  结果错误码
 */
- (FspErrCode)joinGroup:(NSString *_Nonnull)nGroupId;

/**
 * @brief 退出组
 */
- (FspErrCode)leaveGroup;

/**
 *@brief 销毁
 */
- (FspErrCode)destoryFsp;


/**
 *@brief 得到当前所有用户
 *@param nUserIds 如果为空数组 则刷新所有人状态，不为空 刷新指定userid的用户状态
 @param nRequestId 当次的请求id
 */
- (FspErrCode)userStatusRefresh:(NSArray <NSString *> *_Nullable)nUserIds requestId:(unsigned int *_Nonnull)nRequestId;

/**
 *@brief 邀请
 *@param nUsersId 邀请与会人员id数组
 *@param nGroupId 会议的组id
 *@param nExtraMsg 额外信息
 *@param nInviteId 邀请事件id
 *@return 结果错误码
 */
- (FspErrCode)inviteUser:(NSArray <NSString *> *_Nonnull)nUsersId groupId:(NSString *_Nonnull)nGroupId extraMsg:(NSString *_Nullable)nExtraMsg inviteId:(unsigned int *_Nonnull)nInviteId;

/**
 *@brief 接受邀请
 *@param nInviteUserId 邀请与会人员id数组
 *@param nInviteId 邀请的事件id
 *@return 结果错误码
 */
- (FspErrCode)acceptInvite:(NSString *_Nonnull)nInviteUserId inviteId:(int)nInviteId;

/**
 *@brief 拒绝邀请
 *@param nInviteUserId 邀请与会人员id数组
 *@param nInviteId 邀请的事件id
 *@return 结果错误码
 */
- (FspErrCode)rejectInvite:(NSString *_Nonnull)nInviteUserId inviteId:(int)nInviteId;


/**
 *@brief 发送消息（私聊）
 *@param nUserId 目标用户Id
 *@param nMsg    消息内容
 *@param nMsgId  消息id
 *@return 结果错误码
 */
- (FspErrCode)sendUsrMsg:(NSString *_Nonnull)nUserId msg:(NSString *_Nonnull)nMsg msgId:(unsigned int *_Nonnull)nMsgId;

/**
 *@brief 发送消息（群组）
 *@param nMsg    消息内容
 *@param nMsgId  消息id
 *@return 结果错误码
 */
- (FspErrCode)sendGroupMsg:(NSString *_Nonnull)nMsg msgId:(unsigned int *_Nonnull)nMsgId;

@end


/**
 * sdk信令事件回调
 */
@protocol FspEngineSignalingDelegate <NSObject>

#pragma mark signaling event
/*
 *刷新在线列表事件
 *@param errCode 错误码
 *@param nRequestId 请求id 与调用刷新的id成一对一关系
 *@param models 列表
 */
- (void)refreshUserStatusFinished:(FspErrCode)errCode requestId:(uint32_t)nRequestId usrInfo:(NSMutableArray<FspUsrInfo*>*_Nonnull)nUsrInfos;

/*
 *收到邀请事件消息
 *@param nInviteUsrId 邀请者的用户id
 *@param nInviteId 邀请事件id
 *@param nGroupId  群组id
 *@param nMsg  信息
 */
- (void)onInviteIncome:(NSString *_Nonnull)nInviteUsrId inviteId:(int)nInviteId groupId:(NSString *_Nonnull)nGroupId msg:(NSString *_Nullable)nMsg;

/*
 *远端用户已经接受邀请
 *@param RemoteUserId 远端用户id
 *@param nInviteId  邀请事件id
 */
- (void)onInviteAccepted:(NSString *_Nonnull)nRemoteUserId inviteId:(int)nInviteId;
/*
 *远端用户已经拒绝接受邀请
 *@param RemoteUserId 远端用户id
 *@param nInviteId  邀请事件id
 */
- (void)onInviteRejected:(NSString *_Nonnull)nRemoteUserId inviteId:(int)nInviteId;

/*
 *远端用户加入组
 *@param userId 远端用户id
 */
- (void)onGroupUserJoined:(NSString * _Nonnull)userId;

/*
 *远端用户离开组
 *@param userId 远端用户id
 */
- (void)onGroupUserLeaved:(NSString * _Nonnull)userId;

/*
 *组内当前的人员个数（加入组成功后会调用一次）
 *@param user_ids 用户id
 */
- (void)onGroupUsersRefreshed:(NSArray<NSString *> * _Nonnull)user_ids;
@end

/**
 * sdk消息业务回调
 */
@protocol FspEngineMsgDelegate <NSObject>

/*
 *收到远端消息（用户私聊）
 *@param nSrcUserId 远端用户id
 *@param nMsg 消息
 *@param nMsgId  消息事件id
 */
- (void)onReceiveUserMsg:(NSString *_Nonnull)nSrcUserId msg:(NSString *_Nonnull)nMsg msgId:(int)nMsgId;

/*
 *收到远端消息（群组私聊）
 *@param nSrcUserId 远端用户id
 *@param nMsg 消息
 *@param nMsgId  消息事件id
 */
- (void)onReceiveGroupMsg:(NSString *_Nonnull)nSrcUserId msg:(NSString *_Nonnull)nMsg msgId:(int)nMsgId;

@end
