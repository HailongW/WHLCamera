//
//  ViewController.m
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import "ViewController.h"
#import "CameraController.h"
#import "StatusView.h"
#import "PreviewView.h"
#import "OverLayerView.h"
#import "CameraModeView.h"
#import "CameraView.h"

@interface ViewController ()

@property (nonatomic) CameraMode cameraMode;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CameraController *cameraController;
@property (nonatomic, strong) CameraView *cameraView;




@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = self.cameraView;
    self.cameraMode = CameraModeVideo;
    self.cameraController = [[CameraController alloc] init];
    [self bindingEnvents];
}

- (void)bindingEnvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateThumbnail:) name:ThumbnailCreatedNotification object:nil];
    
    self.cameraView.overLayerView.flashControlChanged = ^(FlashControl * _Nonnull sender) {
        NSInteger mode = [(FlashControl *)sender selectedMode];
        if (self.cameraMode == CameraModePhoto) {
        
        }else {
            
        }
    };
    self.cameraView.overLayerView.cameraModeChanged = ^(CameraModeView * _Nonnull sender) {
        
    };
    self.cameraView.overLayerView.swapCamera = ^(id  _Nonnull sender) {
        
    };
    self.cameraView.overLayerView.captureOrRecord = ^(UIButton * _Nonnull sender) {
        
    };
}

- (void)updateThumbnail:(NSNotification *)notification {
    UIImage *image = notification.object;
    UIButton *thumbnailButton = self.cameraView.overLayerView.cameraModeView.thumbnailButton;
    [thumbnailButton setBackgroundImage:image forState:UIControlStateNormal];
    thumbnailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    thumbnailButton.layer.borderWidth = 1.0f;
}

#pragma mark - getter methods

- (CameraView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[CameraView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _cameraView;
}




@end
