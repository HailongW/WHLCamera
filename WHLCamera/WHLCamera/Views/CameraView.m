//
//  CameraView.m
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import "CameraView.h"

@implementation CameraView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self addSubview:self.previewView];
    [self addSubview:self.overLayerView];
}

#pragma mark - getter methods
- (PreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[PreviewView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _previewView;
}
- (OverLayerView *)overLayerView {
    if (!_overLayerView) {
        _overLayerView = [[OverLayerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _overLayerView;
}

@end
