//
//  PreviewView.m
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import "PreviewView.h"

#define BOX_BOUNDS CGRectMake(0.0f, 0.0f, 150, 150.0f)

@interface PreviewView ()

@property (nonatomic, strong) UIView *focusBox;
@property (nonatomic, strong) UIView *exposureBox;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UITapGestureRecognizer *singelTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleDoubleTapRecognizer;

@end

@implementation PreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

//设置手势，单击、双击 单击聚焦、双击曝光
- (void)initSubViews {
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self addGestureRecognizer:self.singelTapRecognizer];
    [self addGestureRecognizer:self.doubleTapRecognizer];
    [self addGestureRecognizer:self.doubleDoubleTapRecognizer];
    //当双击手势执行失败后执行单击手势
    [self.singelTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
    [self addSubview:self.focusBox];
    [self addSubview:self.exposureBox];
    
}

+ (Class)layerClass {
    //在uiview 里重写layerCalss 类方法可以让开发者创建视图实例自定义图层
    //重写layerClass方法并返回AVCaptureVideoPreviewLayer类对象
    return [AVCaptureVideoPreviewLayer class];
}

#pragma mark - setter methods
- (void)setSession:(AVCaptureSession *)session {
    /*重写session set方法，在该方法中访问视图的layer属性AVCaptureVideoPreviewLayer 实例，
     并设置AVCaptureSession将捕捉数据直接输出到图层中，并确保与会话状态同步
     */
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
    
}

#pragma mark - getter methods
- (UITapGestureRecognizer *)singelTapRecognizer {
    if (!_singelTapRecognizer) {
        _singelTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingelTap:)];
    }
    return _singelTapRecognizer;
}

- (UITapGestureRecognizer *)doubleTapRecognizer {
    if (!_doubleTapRecognizer) {
        _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelDoubleTap:)];
        _doubleTapRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapRecognizer;
}

- (UITapGestureRecognizer *)doubleDoubleTapRecognizer {
    if (!_doubleDoubleTapRecognizer) {
        _doubleDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleDoubleTap:)];
        _doubleDoubleTapRecognizer.numberOfTapsRequired = 2;
        _doubleDoubleTapRecognizer.numberOfTouchesRequired = 2;
    }
    return _doubleDoubleTapRecognizer;
}

- (UIView *)focusBox {
    if (!_focusBox) {
        _focusBox = [self viewWithColor:[UIColor colorWithRed:0.102 green:0.636 blue:1.000 alpha:1.000]];
    }
    return _focusBox;
}

- (UIView *)exposureBox {
    if (!_exposureBox) {
        _exposureBox = [self viewWithColor:[UIColor colorWithRed:1.000 green:0.421 blue:0.054 alpha:1.000]];
    }
    return _exposureBox;
}

- (AVCaptureSession *)session {
    //返回捕捉会话
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)setTapToFocusEnabled:(BOOL)tapToFocusEnabled {
    _tapToFocusEnabled = tapToFocusEnabled;
    self.singelTapRecognizer.enabled = tapToFocusEnabled;
}

- (void)setTapToExposeEnabled:(BOOL)tapToExposeEnabled {
    _tapToExposeEnabled = tapToExposeEnabled;
    self.doubleTapRecognizer.enabled = tapToExposeEnabled;
}


#pragma mark - private methods
- (void)handleSingelTap:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    [self runBoxAnimationOnView:self.focusBox point:point];
    if ([self.previewViewDelegate respondsToSelector:@selector(tappedToFocusAtPoint:)]) {
        [self.previewViewDelegate tappedToFocusAtPoint:[self captureDevicePointForPoint:point]];
    }
}

- (void)handelDoubleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    [self runBoxAnimationOnView:self.exposureBox point:point];
    if ([self.previewViewDelegate respondsToSelector:@selector(tappedToFocusAtPoint:)]) {
        [self.previewViewDelegate tappedToExposeAtPoint:point];
    }
}

- (void)handleDoubleDoubleTap:(UITapGestureRecognizer *)recognizer {
    [self runResetAnimation];
    if ([self.previewViewDelegate respondsToSelector:@selector(tappedToResetFocusAndExpose)]) {
        [self.previewViewDelegate tappedToResetFocusAndExpose];
    }
}

- (void)runBoxAnimationOnView:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    } completion:^(BOOL finished) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
        });
    }];
}

- (void)runResetAnimation {
    if (!self.tapToExposeEnabled && !self.tapToFocusEnabled) {
        return;
    }
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    CGPoint centerPoint = [previewLayer pointForCaptureDevicePointOfInterest:CGPointMake(0.5f, 0.5f)];
    self.focusBox.center = centerPoint;
    self.exposureBox.center = centerPoint;
    self.exposureBox.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.focusBox.hidden = NO;
    self.exposureBox.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.focusBox.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
        self.exposureBox.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0);
    } completion:^(BOOL finished) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            self.focusBox.hidden = YES;
            self.exposureBox.hidden = YES;
            self.focusBox.transform = CGAffineTransformIdentity;
            self.exposureBox.transform = CGAffineTransformIdentity;
        });
    }];
}

//用于支持该类定义的不同触摸处理方法，将屏幕上坐标系上的触控点转换为摄像头上的坐标点
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [previewLayer captureDevicePointOfInterestForPoint:point];
}

- (UIView *)viewWithColor:(UIColor *)color {
    UIView *view = [[UIView alloc] initWithFrame:BOX_BOUNDS];
    view.backgroundColor = [UIColor clearColor];
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = 5.0f;
    view.hidden = YES;
    return view;
}


@end
