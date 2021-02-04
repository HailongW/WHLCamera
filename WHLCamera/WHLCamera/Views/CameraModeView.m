//
//  CameraModeView.m
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import "CameraModeView.h"
#import "CaptureButton.h"
#import <CoreText/CoreText.h>

@interface CameraModeView ()

@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, strong) CATextLayer *videoTextLayer;
@property (nonatomic, strong) CATextLayer *photoTextLayer;
@property (nonatomic, strong) UIView *labelContainerView;
@property (nonatomic, strong) CaptureButton *captureButton;
@property (nonatomic, assign) BOOL maxLeft;
@property (nonatomic, assign) BOOL maxRight;
@property (nonatomic) CGFloat videoStringWidth;

@end

@implementation CameraModeView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.maxRight = YES;
    self.cameraMode = CameraModeVideo;
    CGSize size = [@"VIDEO" sizeWithAttributes:[self fontAttributes]];
    self.videoStringWidth = size.width;
    [self.labelContainerView.layer addSublayer:self.videoTextLayer];
    [self.labelContainerView.layer addSublayer:self.photoTextLayer];
    [self addSubview:self.labelContainerView];
    self.labelContainerView.centerY += 8.0f;
    UISwipeGestureRecognizer *rightRecoginzer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode:)];
    UISwipeGestureRecognizer *leftRecoginzer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode:)];
    leftRecoginzer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:rightRecoginzer];
    [self addGestureRecognizer:leftRecoginzer];
    [self addSubview:self.captureButton];
    [self addSubview:self.thumbnailButton];
    
    [self.captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(68);
        make.height.mas_equalTo(68);
    }];
    [self.thumbnailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.captureButton.mas_centerY);
        make.left.equalTo(self).offset(40);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(45);
    }];
    
    
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.foregroundColor.CGColor);
    CGRect circleRect = CGRectMake(CGRectGetMidX(rect) - 4.0f, 2.0f, 6.0f, 6.0f);
    CGContextFillEllipseInRect(context, circleRect);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.labelContainerView.frameX = CGRectGetMidX(self.bounds) - (self.videoStringWidth / 2.0);
}

#pragma mark - private methods

- (CATextLayer *)textLayerWidthTitle:(NSString *)title {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = [[NSAttributedString alloc] initWithString:title attributes:[self fontAttributes]];
    return textLayer;
}

- (NSDictionary *)fontAttributes {
    return @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:17.0f],
             NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)switchMode:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft && !self.maxLeft) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.labelContainerView.frameX -= 62;
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
                [CATransaction disableActions];
                self.photoTextLayer.foregroundColor = self.foregroundColor.CGColor;
                self.videoTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
            } completion:^(BOOL finished) {}
        ];
        } completion:^(BOOL finished) {
            self.cameraMode = CameraModePhoto;
            self.maxLeft = YES;
            self.maxRight = NO;
        }];
    }else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight && !self.maxRight) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.labelContainerView.frameX += 62;
            self.videoTextLayer.foregroundColor = self.foregroundColor.CGColor;
            self.photoTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
        } completion:^(BOOL finished) {
            self.maxRight = YES;
            self.maxLeft = NO;
        }];
    }
}

#pragma mark - setter methods
- (void)setCameraMode:(CameraMode)cameraMode {
    if (_cameraMode != cameraMode) {
        _cameraMode = cameraMode;
        if (_cameraMode == CameraModePhoto) {
            self.captureButton.selected = NO;
            self.captureButton.captureButtonMode = CaptureButtonModePhoto;
            self.layer.backgroundColor = [UIColor blackColor].CGColor;
        }else {
            self.captureButton.captureButtonMode = CaptureButtonModeVideo;
            self.layer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - getter methods
- (UIColor *)foregroundColor {
    if (!_foregroundColor) {
        _foregroundColor = [UIColor colorWithRed:1.000 green:0.734 blue:0.006 alpha:1.000];
    }
    return _foregroundColor;
}

- (CATextLayer *)videoTextLayer {
    if (!_videoTextLayer) {
        _videoTextLayer = [self textLayerWidthTitle:@"Video"];
        _videoTextLayer.foregroundColor = self.foregroundColor.CGColor;
        _videoTextLayer.frame = CGRectMake(0.0f, 0.0f, 40.0f, 20.0f);
    }
    return _videoTextLayer;
}

- (CATextLayer *)photoTextLayer {
    if (!_photoTextLayer) {
        _photoTextLayer = [self textLayerWidthTitle:@"Photo"];
        _photoTextLayer.frame = CGRectMake(60.0f, 0.0f, 50.0f, 20.0f);
    }
    return _photoTextLayer;
}

- (UIView *)labelContainerView {
    if (!_labelContainerView) {
        CGRect rect = CGRectMake(0.0f, 0.0f, 120.0f, 20.0f);
        _labelContainerView = [[UIView alloc] initWithFrame:rect];
        _labelContainerView.backgroundColor = [UIColor clearColor];
    }
    return _labelContainerView;
}

- (UIButton *)thumbnailButton {
    if (!_thumbnailButton) {
        _thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _thumbnailButton;
}

- (CaptureButton *)captureButton {
    if (!_captureButton) {
        _captureButton = [CaptureButton captureButton];
    }
    return _captureButton;
}


@end
