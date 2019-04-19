
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


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
 * fspEvent回到事件类型
 */
typedef NS_ENUM(NSInteger, FspEventType) {
    FSP_EVENT_JOINGROUP = 0 ///<加入组结果
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

/**
 * sdk回调事件和异步结果
 */
@protocol FspEngineDelegate <NSObject>

/**
 * sdk回调事件和异步结果
 */
- (void)fspEvent:(FspEventType)eventType
         errCode:(FspErrCode)errCode;

/**
 * 远端用户视频事件
 *
 * @param userId 远端视频所属的user id
 * @param videoId 远端视频所属的video id
 * @param eventType 事件类型
 */

- (void)remoteVideoEvent:(NSString * _Nonnull)userId
                 videoId:(NSString * _Nonnull)videoId
               eventType:(FspRemoteVideoEvent)eventType;

/**
 * 远端用户音频事件
 * @param userId 远端用户的userid
 * @param eventType 事件类型
 */
- (void)remoteAudioEvent:(NSString* _Nonnull)userId
               eventType:(FspRemoteAudioEvent)eventType;

@end

/**
 * @brief sdk对外核心接口
 */
@interface FspEngine : NSObject


/**
 * 初始化FspEngineKit对象
 * @param appId 分配的appid
 * @param logPath 日志目录
 * @param serverAddr 私有化部署的服务地址，一般填空字符串
 * @param delegate 事件回调实现
 * @return FspEngineKit对象
 */
+ (instancetype _Nonnull)sharedEngineWithAppId:(NSString* _Nonnull)appId
                                       logPath:(NSString* _Nullable)logPath
                                    serverAddr:(NSString* _Nullable)serverAddr
                                      delegate:(id<FspEngineDelegate> _Nullable)delegate;

/**
 * sdk版本信息
 */
+ (NSString* _Nonnull) getVersionInfo;

#pragma mark Group methods

/**
 * 加入组
 * @param token 访问fsp的令牌,令牌的获取参考fsp鉴权
 * @param grouplId 登录组的id
 * @param userId 自身的userId 
 * @return 结果错误码
 */
- (FspErrCode)joinGroup:(NSString * _Nullable)token
                groupId:(NSString * _Nonnull)grouplId
                 userId:(NSString * _Nonnull)userId;


/**
 * @brief 退出组
 */
- (FspErrCode)leaveGroup;


#pragma mark Video method

/**
 * @brief 视频设备列表
 */
- (NSArray<FspVideoDeviceInfo*> * _Nonnull)getVideoDevices;

/**
 * 本地视频增加预览渲染
 * @param cameraId 哪个摄像头
 * @param renderView 渲染窗口
 * @param mode 缩放模式
 * @return 结果错误码
 */
- (FspErrCode)addVideoPreview:(NSInteger)cameraId
                   renderView:(NSView* _Nonnull)renderView
                         mode:(FspRenderMode)mode;

/**
 * 本地视频删除预览渲染
 * @param cameraId 哪个摄像头
 * @param renderView 渲染窗口，通过 viewer 唯一标识
 * @return 结果错误码
 */
- (FspErrCode)removeVideoPreview:(NSInteger)cameraId
                      renderView:(NSView* _Nonnull)renderView;


/**
 * 开始广播视频
 * @param videoId 视频id, 支持同时广播多路视频时， videoId标识每路视频
 * @param cameraId 这路视频对应用哪个摄像头, cameraId 为 VideoDeviceInfo.camera_id
 * @return 结果错误码
 */
- (FspErrCode)startPublishVideo:(NSString * _Nonnull)videoId
                       cameraId:(NSInteger)cameraId;

/**
 * 停止广播视频
 * @param videoId 哪路视频
 */
- (FspErrCode)stopPublishVideo:(NSString * _Nonnull)videoId;


/**
 * 设置本地的视频profile
 * @param videoId 设置哪路视频的profile
 * @param profile profile信息
 */
- (FspErrCode) setVideoProfile:(NSString* _Nonnull)videoId profile:(FspVideoProfile* _Nullable)profile;

/**
 * 设置远端用户视频的渲染窗口
 * @param userId 视频用户id
 * @param videoId 视频的video id
 * @param renderView 渲染窗口, 传nil则关闭远端视频
 * @param mode 缩放模式
 */
- (FspErrCode)setRemoteVideoRender:(NSString * _Nonnull)userId
                           videoId:(NSString * _Nonnull)videoId
                        renderView:(NSView* _Nullable)renderView
                              mode:(FspRenderMode)mode;


/**
 * 设置视频渲染的拉伸模式
 * @param renderView 哪个renderview
 * @param mode 设置的mode
 */
- (FspErrCode) setRenderMode:(NSView* _Nonnull)renderView
                        mode:(FspRenderMode)mode;

/**
 * 获取视频统计信息
 * @param userId 远端用户id
 * @param videoId 远端视频id
 * @return 如果失败，返回nil
 */
- (FspVideoStatsInfo* _Nullable)getVideoStats:(NSString* _Nonnull)userId
                                     videoId:(NSString* _Nonnull)videoId;


#pragma mark Audio method

/**
 * 音频扬声器设备列表
 */
- (NSArray<FspAudioDeviceInfo*> * _Nonnull)getSpeakerDevices;

/**
 * 音频麦克风设备列表
 */
- (NSArray<FspAudioDeviceInfo*> * _Nonnull)getMicrophoneDevices;

/**
 * 获取当前扬声器设备
 * @return 设备id
 */
- (NSInteger)getCurrentSpeakerDevice;

/**
 * 设置当前扬声器设备
 * @param deviceId 设备id
 */
- (NSInteger)setCurrentSpeakerDevice:(NSInteger)deviceId;

/**
 * 获取当前麦克风设备
 * @return 设备id
 */
- (NSInteger)getCurrentMicrophoneDevice;

/**
 * 设置当前麦克风设备
 * @param deviceId 设备id
 */
- (NSInteger)setCurrentMicrophoneDevice:(NSInteger)deviceId;

/**
 * 获取扬声器音量
 * @return 音量， 范围： 0 - 100
 */
- (NSInteger)getSpeakerVolume;

/**
 * 获取麦克风音量
 * @return 音量， 范围： 0 - 100
 */
- (NSInteger)getMicrophoneVolume;


/**
 * 设置扬声器音量
 * @param volume 音量值， 范围： 0 - 100
 */
- (FspErrCode)setSpeakerVolume:(NSInteger)volume;


/**
 * 设置麦克风音量
 * @param volume 音量值， 范围： 0 - 100
 */
- (FspErrCode)setMicrophoneVolume:(NSInteger)volume;


/**
 * 获取扬声器能量值
 * @return 能量值， 范围： 0 - 100
 */
- (NSInteger)getSpeakerEnergy;

/**
 * 获取麦克风能量值
 * @return 能量值， 范围： 0 - 100
 */
- (NSInteger)getMicrophoneEnergy;

/**
 * 开始广播音频
 */
- (FspErrCode)startPublishAudio;

/**
 * 停止广播音频
 */
- (FspErrCode)stopPublishAudio;

/**
 * 开关远端音频
 * @param userId 远端用户id
 * @param mute YES关闭远端音频，NO打开
 */
- (FspErrCode)muteRemoteAudio:(NSString * _Nonnull)userId
                         mute:(BOOL)mute;

/**
 * 获取远端用户的声音能量值
 * @param userId 对应的远端用户id
 * @return 能量值 范围： 0 - 100
 */
- (NSInteger)getRemoteAudioEnergy:(NSString* _Nonnull)userId;

@end
