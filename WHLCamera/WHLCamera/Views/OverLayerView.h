//
//  OverLayerView.h
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import <UIKit/UIKit.h>
#import "FlashControl.h"
#import "CameraModeView.h"
#import "StatusView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FlashControlChanged)(FlashControl *sender);
typedef void(^CameraModeChanged)(CameraModeView *sender);
typedef void(^CaptureOrRecord)(UIButton *sender);
typedef void(^SwapCamera)(id sender);

@interface OverLayerView : UIView

@property (nonatomic)  BOOL flashControlHidden;
@property (nonatomic, copy) FlashControlChanged flashControlChanged;
@property (nonatomic, copy) CameraModeChanged cameraModeChanged;
@property (nonatomic, copy) CaptureOrRecord captureOrRecord;
@property (nonatomic, copy) SwapCamera swapCamera;
@property (nonatomic, strong) CameraModeView *cameraModeView;
@property (nonatomic, strong) StatusView *statusView;

@end

NS_ASSUME_NONNULL_END
