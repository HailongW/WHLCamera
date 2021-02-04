//
//  StatusView.h
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import <UIKit/UIKit.h>
#import "FlashControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface StatusView : UIView

@property (nonatomic, strong) FlashControl *flashControl;
@property (nonatomic, strong) UILabel *elapsedTimeLabel;

@end

NS_ASSUME_NONNULL_END
