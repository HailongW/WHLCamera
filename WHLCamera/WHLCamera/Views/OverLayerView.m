//
//  OverLayerView.m
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import "OverLayerView.h"

@interface OverLayerView ()

@end

@implementation OverLayerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.statusView];
    [self addSubview:self.cameraModeView];
    
}

#pragma mark private methods
- (void)modeChanged:(CameraModeView *)cameraModeVIew {
    BOOL photoModeEnabled = cameraModeVIew.cameraMode == CameraModePhoto;
    UIColor *color = photoModeEnabled?[UIColor blackColor]: [UIColor colorWithWhite:0.0f alpha:0.5f];
    CGFloat opacity = photoModeEnabled?0.0f:1.0f;
    self.statusView.layer.backgroundColor =  color.CGColor;
    self.statusView.elapsedTimeLabel.layer.opacity = opacity;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.statusView pointInside:[self convertPoint:point toView:self.statusView] withEvent:event] ||
        [self.cameraModeView pointInside:[self.cameraModeView convertPoint:point toView:self.cameraModeView] withEvent:event]) {
        return YES;
    }
    return NO;
}

#pragma mark - getter methods
- (CameraModeView *)cameraModeView {
    if (!_cameraModeView) {
        _cameraModeView = [[CameraModeView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 150, SCREEN_WIDTH, 150)];
        [_cameraModeView addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _cameraModeView;
}

- (StatusView *)statusView {
    if (!_statusView) {
        _statusView = [[StatusView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 48)];
    }
    return _statusView;
}

- (void)setFlashControlHidden:(BOOL)flashControlHidden {
    if (_flashControlHidden != flashControlHidden) {
        _flashControlHidden = flashControlHidden;
        self.statusView.flashControl.hidden = flashControlHidden;
    }
}

@end
