//
//  StatusView.m
//  WHLCamera
//
//  Created by 王海龙 on 2021/1/26.
//

#import "StatusView.h"

@interface StatusView ()

@property (nonatomic, strong) UIButton *switchButton;

@end

@implementation StatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self addSubview:self.flashControl];
    [self addSubview:self.elapsedTimeLabel];
    [self addSubview:self.switchButton];
    [self addConstraintForSubViews];
    self.alpha = 0.5;
}

- (void)addConstraintForSubViews {
    [self.flashControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.centerY.equalTo(self.mas_centerY).offset(0);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(48);
    }];
    [self.elapsedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(82);
    }];
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self);
        make.width.mas_equalTo(56);
        make.height.mas_equalTo(48);
    }];
}

- (void)flashControlAction:(FlashControl *)flashControl {
    
}

#pragma mark - getter methods
- (FlashControl *)flashControl {
    if (!_flashControl) {
        _flashControl = [[FlashControl alloc] init];
        [_flashControl addTarget:self action:@selector(flashControlAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashControl;
}

- (UILabel *)elapsedTimeLabel {
    if (!_elapsedTimeLabel) {
        _elapsedTimeLabel = [[UILabel alloc] init];
    }
    return _elapsedTimeLabel;
}

- (UIButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_switchButton setBackgroundImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];
    }
    return _switchButton;
}




@end
