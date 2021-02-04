//
//  CameraView.h
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import <UIKit/UIKit.h>
#import "PreviewView.h"
#import "OverLayerView.h"


NS_ASSUME_NONNULL_BEGIN

@interface CameraView : UIView

@property (nonatomic, strong) PreviewView   *previewView;
@property (nonatomic, strong) OverLayerView *overLayerView;

@end

NS_ASSUME_NONNULL_END
