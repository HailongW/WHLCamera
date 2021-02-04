//
//  CaptureButton.h
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CaptureButtonMode) {
    CaptureButtonModePhoto = 0, //default
    CaptureButtonModeVideo = 1
};

@interface CaptureButton : UIButton

@property (nonatomic) CaptureButtonMode captureButtonMode;

+ (instancetype)captureButton;
+ (instancetype)captureButtonWithMode:(CaptureButtonMode)captureButtonMode;

@end

NS_ASSUME_NONNULL_END
