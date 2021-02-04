//
//  CameraController.h
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ThumbnailCreatedNotification;

@protocol CameraControllerDelegate <NSObject>

//发生错误事件时，需要在对象委托上调用一些方法来处理
- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWidthError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

@end

@interface CameraController : NSObject

@property (nonatomic, weak) id<CameraControllerDelegate> delegate;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, readonly) NSInteger cameraCount;
@property (nonatomic, readonly) BOOL cameraHasTorch; //手电筒
@property (nonatomic, readonly) BOOL cameraHasFlash; //闪光灯
@property (nonatomic, readonly) BOOL cameraSupportsTapToFocus;
@property (nonatomic, readonly) BOOL cameraSupportsTapToExpose;
@property (nonatomic) AVCaptureTorchMode torchMode; //手电筒模式
@property (nonatomic) AVCaptureFlashMode flashMode; //闪光灯模式

//设置、配置视频捕捉会话
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

//切换前后摄像头
- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;

//聚焦、曝光、重设聚焦、曝光的方法
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;

//实现捕捉静态图片&视频的功能

//捕捉静态图片
- (void)captureStillImage;

//开始录制视频
- (void)startRecording;

//停止录制视频
- (void)stopRecording;

//获取录制状态
- (BOOL)isRecording;

//获取录制时间
- (void)recordedDuration;


@end

NS_ASSUME_NONNULL_END
