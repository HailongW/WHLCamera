//
//  FlashControl.h
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FlashControlDelegate <NSObject>

@optional
- (void)flashControlWillExpand;
- (void)flashControlDidExpend;
- (void)flashControlWillCollapse;
- (void)flashControlDidCollapse;

@end

@interface FlashControl : UIControl

@property (nonatomic) NSInteger selectedMode;
@property (nonatomic, strong) id<FlashControlDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
