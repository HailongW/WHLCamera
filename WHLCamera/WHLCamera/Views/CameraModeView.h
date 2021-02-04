//
//  CameraModeView.h
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CameraMode) {
    CameraModePhoto = 0,
    CameraModeVideo = 1
};

@interface CameraModeView : UIControl

@property (nonatomic) CameraMode cameraMode;
@property (nonatomic, strong) UIButton *thumbnailButton;

@end

NS_ASSUME_NONNULL_END
