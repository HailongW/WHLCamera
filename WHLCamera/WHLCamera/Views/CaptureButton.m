//
//  CaptureButton.m
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/27.
//

#define DEFAULT_FRAME CGRectMake(0.0f, 0.0f, 68.0f, 68.0f)
#define LINE_WIDTH 6.0f

#import "CaptureButton.h"

@interface PhotoCaptureButton : UIButton
@end

@interface VideoCaptureButton : UIButton
@end

@interface CaptureButton ()

@property (nonatomic, strong) CALayer *circleLayer;

@end

@implementation CaptureButton

+ (instancetype)captureButton {
    return [[self alloc] initWithCaptureButtonMode:CaptureButtonModeVideo];
}

+ (instancetype)captureButtonWithMode:(CaptureButtonMode)captureButtonMode {
    return [[self alloc] initWithCaptureButtonMode:captureButtonMode];
}

- (instancetype)initWithCaptureButtonMode:(CaptureButtonMode)mode {
    self = [super initWithFrame:DEFAULT_FRAME];
    if (self) {
        _captureButtonMode = mode;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
    [self.layer addSublayer:self.circleLayer];
    
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor); //设置描边颜色
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//设置填充颜色
    CGContextSetLineWidth(context, LINE_WIDTH);
    CGRect insetRect = CGRectInset(rect, LINE_WIDTH/2.0f, LINE_WIDTH/2.0f);
    CGContextStrokeEllipseInRect(context, insetRect);//绘制椭圆
}

#pragma mark - setter methods
- (void)setCaptureButtonMode:(CaptureButtonMode)captureButtonMode {
    if (_captureButtonMode != captureButtonMode) {
        _captureButtonMode = captureButtonMode;
        UIColor *color = (_captureButtonMode == CaptureButtonModeVideo)?[UIColor redColor]:[UIColor whiteColor];
        self.circleLayer.backgroundColor = color.CGColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeAnimation.duration = 2.0f;
    if (highlighted) {
        fadeAnimation.toValue = @0.0f;
    }else {
        fadeAnimation.toValue = @1.0f;
    }
    self.circleLayer.opacity = [fadeAnimation.toValue floatValue];
    [self.circleLayer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.captureButtonMode == CaptureButtonModeVideo) {
        [CATransaction  disableActions];
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        if (selected) {
            scaleAnimation.toValue = @0.6f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width/2.0f);
        }else {
            scaleAnimation.toValue = @1.0f;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width/2.0f);
        }
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[scaleAnimation,radiusAnimation];
        animationGroup.duration = 0.35f;
        animationGroup.beginTime = CACurrentMediaTime() + 0.2f;
        [self.circleLayer setValue:scaleAnimation forKey:@"transform.scale"];
        [self.circleLayer setValue:radiusAnimation forKey:@"cornerRadius"];
        [self.circleLayer addAnimation:animationGroup forKey:@"scaleAndRadiusAnimation"];
    }
}

#pragma mark - getter methods
- (CALayer *)circleLayer {
    if (!_circleLayer) {
        _circleLayer = [[CALayer alloc] init];
        UIColor *circleColor = (self.captureButtonMode == CaptureButtonModeVideo)?[UIColor redColor]:[UIColor whiteColor];
        _circleLayer.backgroundColor = circleColor.CGColor;
        _circleLayer.bounds = CGRectInset(self.bounds, 8.0, 8.0);
        _circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        _circleLayer.cornerRadius = _circleLayer.bounds.size.width/2.0f;
  
    }
    return _circleLayer;
}

@end
