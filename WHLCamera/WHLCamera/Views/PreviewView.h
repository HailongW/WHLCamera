//
//  PreviewView.h
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PreviewViewDelegate <NSObject>

- (void)tappedToFocusAtPoint:(CGPoint)point; //聚焦
- (void)tappedToExposeAtPoint:(CGPoint)point; //曝光
- (void)tappedToResetFocusAndExpose; //点击重置聚焦和曝光


@end

@interface PreviewView : UIView

//session用来关联AVCaptureVideoPreviewLayer 和 激活AVCaptureSession
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak) id<PreviewViewDelegate> previewViewDelegate;
@property (nonatomic) BOOL tapToFocusEnabled; //是否聚焦
@property (nonatomic) BOOL tapToExposeEnabled; //是否曝光


@end

NS_ASSUME_NONNULL_END
