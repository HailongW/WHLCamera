//
//  CameraController.m
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import "CameraController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "NSFileManager+Additions.h"

NSString *const ThumbnailCreatedNotification = @"ThumbnailCreated";

@interface CameraController () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
@property (nonatomic, strong) NSURL *outputURL;




@end

@implementation CameraController

- (BOOL)setupSession:(NSError **)error {
    
    //创建捕捉会话，AVCaptureSession 是捕捉场景的中心枢纽
    self.captureSession = [[AVCaptureSession alloc] init];
    
    /*
     AVCaptureSessionPresetHigh
     AVCaptureSessionPresetMedium
     AVCaptureSessionPresetLow
     AVCaptureSessionPreset640x480
     AVCaptureSessionPreset1280x720
     AVCaptureSessionPresetPhoto
     */
    
    //设置图像的分辨率
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //拿到默认视频捕捉设备，iOS 系统默认返回后置摄像头
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //为会话添加捕捉设备，必须将设备封装成AVCaptureDeviceInput对象
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    
    //判断videoInput 是否有效
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            //将videoInput 添加到captureSession 中
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    }else {
        return NO;
    }
    
    //选择默认音频捕捉设备 即返回一个内置麦克风
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    //为这个设备创建一个捕捉设备输入
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    
    //判断audioInput 是否有效
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            //将audioInput 添加到 captureSession 中
            [self.captureSession addInput:audioInput];
        }
    }else {
        return NO;
    }
    
    //AVCapturePhotoOutput 从摄像头捕捉图像图片
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    //配置字典希望捕捉到JPEG 格式的图片
    self.imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    
    //输出连接，判断连接是否可用，可用则添加到输出连接中去
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    //创建一个AVCaptureMovieFileOutput 实例，用于将Quidk Time 电影录制到文件系统
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    
    //输出连接 判断是否可用， 可用则添加到输出连接中去
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    self.videoQueue = dispatch_queue_create("videoQueue", NULL);
    
    return YES;
}

- (void)startSession {
    //检查是否处于运行状态
    if (![self.captureSession isRunning]) {
        //使用同步调用会耗费一定的时间，因此用异步的方式处理
        dispatch_async(self.videoQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    //检查是否处于运行状态
    if ([self.captureSession isRunning]) {
        //使用异步方式，停止运行
        dispatch_async(self.videoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}


#pragma mark - 配置摄像头支持的方法 Device Configuration
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)positon {
    //获取可用视频设备
//    AVCaptureDeviceType;
    NSArray *deviceTypes = @[AVCaptureDeviceTypeBuiltInMicrophone, AVCaptureDeviceTypeBuiltInWideAngleCamera];
    AVCaptureDeviceDiscoverySession *captureDevice = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:positon];
    NSArray *devices = [captureDevice devices];
    
    //遍历可用的视频设备 并返回position 值
    for (AVCaptureDevice *device in devices) {
        if (device.position == positon) {
            return device;
        }
    }
    return nil;
    
}

//返回当前捕捉会话对应的摄像头的device属性
- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

//返回当前未激活的摄像头
- (AVCaptureDevice *)inactiveCamera {
    //通过查找当前激活摄像头的反向摄像头获得，如果设备只有1个摄像头，则返回nil
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

//判断是否有超过1个摄像头可用
- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

//可用视频捕捉设备的数量
- (NSInteger)cameraCount {
    NSArray *deviceTypes = @[AVCaptureDeviceTypeBuiltInMicrophone, AVCaptureDeviceTypeBuiltInWideAngleCamera];
    AVCaptureDeviceDiscoverySession *captureDevice = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    return [[captureDevice devices] count];
    
}

//切换摄像头
- (BOOL)switchCameras {
    //判断是否有多个摄像头
    if (![self canSwitchCameras]) {
        return NO;
    }
    //获取当前设备的反向设备
    NSError *error;
    AVCaptureDevice *device = [self inactiveCamera];
    //将输入设备封装成 AVCaptureDeviceInput
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (captureDeviceInput) {
        //标注原配置变化开发
        [self.captureSession beginConfiguration];
        //将捕捉会话中原本的捕捉输入设备移除
        [self.captureSession removeInput:self.activeVideoInput];
        
        //判断新的设备是否能加入
        if ([self.captureSession canAddInput:captureDeviceInput]) {
            [self.captureSession addInput:captureDeviceInput];
            self.activeVideoInput = captureDeviceInput;
        }else {
            //如果新设备无法加入，将原本的视频捕捉设备重新加入到捕捉会话中
            [self.captureSession addInput:self.activeVideoInput];
        }
        //配置完成后，AVCaptureSession commitCongiguration 会分批的将所有变更整合到一起
        [self.captureSession commitConfiguration];
        
    }else {
        //创建AVCaptureDeviceInput 出现错误，则通知委托代理来处理该错误
        if ([self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
            [self.delegate deviceConfigurationFailedWithError:error];
            return NO;
        }
    }
    return YES;
    
}

/*
    AVCapture Device 定义了很多方法，让开发者控制ios设备上的摄像头。可以独立调整和锁定摄像头的焦距、曝光、白平衡。对焦和曝光可以基于特定的兴趣点进行设置，使其在应用中实现点击对焦、点击曝光的功能。
    还可以让你控制设备的LED作为拍照的闪光灯或手电筒的使用
    
    每当修改摄像头设备时，一定要先测试修改动作是否能被设备支持。并不是所有的摄像头都支持所有功能，例如牵制摄像头就不支持对焦操作，因为它和目标距离一般在一臂之长的距离。但大部分后置摄像头是可以支持全尺寸对焦。尝试应用一个不被支持的动作，会导致异常崩溃。所以修改摄像头设备前，需要判断是否支持
 
 
 */

#pragma mark - Foceus Methods 点击聚焦方法的实现
- (BOOL)cameraSupportsTapToFocus {
    //返回激活状态的摄像头是否支持兴趣点聚焦
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    
    //是否支持兴趣对焦和自动对焦模式
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        //锁定设备准备配置，如果获得了锁
        if ([device lockForConfiguration:&error]) {
            //将focusPointOfInterest属性设置CGPoint
            device.focusPointOfInterest = point;
            //focusMode 设置为AVCaptureFocusModeAutoFocus
            device.focusMode = AVCaptureFocusModeAutoFocus;
            
            //释放锁
            [device unlockForConfiguration];
        }else {
            //错误时返回错误代理处理
            if ([self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                [self.delegate deviceConfigurationFailedWithError:error];
            }
        }
    }
}

#pragma mark - Exposure Methods 点击曝光的方法实现
- (BOOL)cameraSupportsTapToExpose {
    //询问设备是否对一个兴趣点进行曝光
    return [[self activeCamera] isExposurePointOfInterestSupported];
}


static const NSString *cameraAdjustingExposureContext;
- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode =  AVCaptureExposureModeContinuousAutoExposure;
    //判断当前摄像头是否支持 AVCaptureExposureModeContinuousAutoExposure 模式
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            //配置期望值
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            //判断设备是否支持锁定曝光的模式
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                
                //使用kvo 确定设备的adjustingExposure属相的状态
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&cameraAdjustingExposureContext];

            }
            [device unlockForConfiguration];
        }else {
            if ([self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                [self.delegate deviceConfigurationFailedWithError:error];
            }
        }
    }
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //判断上下文context是否是CameraAdjustingExposureContext
    if (context == &cameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        //判断设备是否不再调整曝光等级，确认设备的exposureMode是否可以设置为AVCaptureExposureModeLocked
        if (device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            //移除作为adjustingExposure 的self，就不会得到后续变更的通知
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&cameraAdjustingExposureContext];
             //异步方式回到主队列
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    //修改exposureMode
                    device.exposureMode = AVCaptureExposureModeLocked;
                    //释放该锁定
                    [device unlockForConfiguration];
                }else {
                    if ([self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                        [self.delegate deviceConfigurationFailedWithError:error];
                    }
                }
            });
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//重新设置对焦和曝光
- (void)resetFocusAndExposureModes {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    //获取对象兴趣点和连续自动对焦模式是否被支持
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canRestExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    //捕捉设备空间左上角（0，0），右下角（1，1） 中心点则（0.5，0.5）
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    //锁定设备配置设备
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            //焦点可设，则修改
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canRestExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        //释放锁定设备
        [device unlockForConfiguration];
    }else {
        if ([self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
    
}
  
#pragma mark - Flash and  Torch model  闪光灯和手电筒
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

//闪光灯模式
- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}

//设置闪光灯
- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    //获取会话设备
    AVCaptureDevice *device = [self activeCamera];
    //判断是否支持闪光灯模式
    if ([device isFlashModeSupported:flashMode]) {
        //如果支持则锁定设备
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }else {
            if ([self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                [self.delegate deviceConfigurationFailedWithError:error];
            }
        }
    }
}

//是否支持手电筒
- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

//手电筒模式
- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    //获取会话设备
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }else {
            if ([self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                [self.delegate deviceConfigurationFailedWithError:error];
            }
        }
    }
}

#pragma mark - Image Capture Methods 拍摄静态图片
/*
    AVCaptureStillImageOutput 是AVCaptureOutput的子类。用于捕捉图片
 */
- (void)captureStillImage {
    //获取连接
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    //程序只支持纵向，但是如果用户横向拍照时，需要调整结果照片的方向
    //判断是否支持设置视频方向
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    //定义一个handler 块，会返回1个图片的NSData数据
    id handler = ^(CMSampleBufferRef sampleBuffer, NSError *error){
        if (sampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            //重点：捕捉图片成功后，将图片传递出去
            [self writeImageToAssetsLibrary:image];
        }
    };
}

//获取方向值
- (AVCaptureVideoOrientation)currentVideoOrientation {
    AVCaptureVideoOrientation videoOrientation;
  //获取UIDevice 的orientation
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return videoOrientation;
}

/*
    Assets Library 框架
    用来让开发者通过代码方式访问iOS photo
    注意：会访问到相册，需要修改plist 权限。否则会导致项目崩溃
 */

- (void)writeImageToAssetsLibrary:(UIImage *)image {

    //创建ALAssetsLibrary  实例
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    
    //参数1:图片（参数为CGImageRef 所以image.CGImage）
    //参数2:方向参数 转为NSUInteger
    //参数3:写入成功、失败处理
    [library writeImageToSavedPhotosAlbum:image.CGImage
                             orientation:(NSUInteger)image.imageOrientation
                         completionBlock:^(NSURL *assetURL, NSError *error) {
                             //成功后，发送捕捉图片通知。用于绘制程序的左下角的缩略图
                             if (!error)
                             {
                                 [self postThumbnailNotifification:image];
                             }else
                             {
                                 //失败打印错误信息
                                 id message = [error localizedDescription];
                                 NSLog(@"%@",message);
                             }
                         }];
}
    
- (void)postThumbnailNotifification:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ThumbnailCreatedNotification object:image];
    });
}

#pragma mark - video capture methods 捕捉视频
//判断是否录制状态
- (BOOL)isRecording {
    return self.movieOutput.isRecording;
}

//开始录制
- (void)startRecording {
    if (![self isRecording]) {
        AVCaptureConnection *connection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        //判断是否支持设置VideoOrientation 属性
        if ([connection isVideoOrientationSupported]) {
            //支持则修改当先视频方向
            connection.videoOrientation = [self currentVideoOrientation];
        }
        
        //判断是否支持视频稳定 可以显著提高视频的质量。只会在录制视频文件涉及
        if ([connection isVideoStabilizationSupported]) {
//            connection.enablesVideoStabilizationWhenAvailable = YES;
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        AVCaptureDevice *device = [self activeCamera];
        //摄像头可以进行平滑对焦模式操作。即减慢摄像头镜头对焦速度。当用户移动拍摄时摄像头会尝试快速自动对焦。
        if ([device isSmoothAutoFocusEnabled]) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            }else {
                if ([self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                    [self.delegate deviceConfigurationFailedWithError:error];
                }
            }
        }
        //查找写入捕捉视频的唯一文件系统URL.
        self.outputURL = [self uniqueURL];
        
    }
}

//写入视频唯一文件系统URL
- (NSURL *)uniqueURL {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //temporaryDirectoryWithTemplateString  可以将文件写入的目的创建一个唯一命名的目录；
    NSString *dirPath = [fileManager temporaryDirectoryWithTemplateString:@"camera.XXXXXX"];
    
    if (dirPath) {
        
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"camera_movie.mov"];
        return  [NSURL fileURLWithPath:filePath];
        
    }
    
    return nil;
    
}

//停止录制
- (void)stopRecording {
    if ([self isRecording]) {
        [self.movieOutput stopRecording];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if (error) {
        if ([self.delegate respondsToSelector:@selector(mediaCaptureFailedWidthError:)]) {
            [self.delegate mediaCaptureFailedWidthError:error];
        }
    }else {
        //写入相册
        [self writeVideoToAssetsLibrary:outputFileURL];
    }
    self.outputURL = nil;
}

- (void)writeVideoToAssetsLibrary:(NSURL *)vidoeURL {
    //ALAssetsLibrary 实例 提供写入视频的接口
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    //写资源库写入前，检查视频是否可被写入 （写入前尽量养成判断的习惯）
    if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:vidoeURL]) {
        //创建blcok
        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [photoLibrary performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:vidoeURL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"已将视频保存至相册");
            } else {
                NSLog(@"未能保存视频到相册");
            }
        }];
    }
}

//获取视频左下角缩略图
- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {

    //在videoQueue 上，
    dispatch_async(self.videoQueue, ^{
        
        //建立新的AVAsset & AVAssetImageGenerator
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        
        //设置maximumSize 宽为100，高为0 根据视频的宽高比来计算图片的高度
        imageGenerator.maximumSize = CGSizeMake(100.0f, 0.0f);
        
        //捕捉视频缩略图会考虑视频的变化（如视频的方向变化），如果不设置，缩略图的方向可能出错
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        //获取CGImageRef图片 注意需要自己管理它的创建和释放
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
        
        //将图片转化为UIImage
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        //释放CGImageRef imageRef 防止内存泄漏
        CGImageRelease(imageRef);
        
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //发送通知，传递最新的image
            [self postThumbnailNotifification:image];
            
        });
        
    });
    
}



@end
