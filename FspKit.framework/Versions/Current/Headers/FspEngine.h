
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <FspKit/FspSignaling.h>

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
@interface FspEngine : NSObject<FspSignaling>


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
                                      delegate:(id<FspEngineDelegate,FspEngineSignalingDelegate,FspEngineMsgDelegate> _Nullable)delegate;

/**
 * sdk版本信息
 */
+ (NSString* _Nonnull) getVersionInfo;

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
