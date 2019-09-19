//
//  XCProgressHUD.m
//  SVProgressHUD
//
//  Created by Mac_mini_crm on 2019/9/18.
//

#import "XCProgressHUD.h"
#import "SVProgressAnimatedView.h"
@interface SVProgressHUD ()
@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) SVProgressAnimatedView *backgroundRingView;
@property (nonatomic, weak, readonly) SVProgressAnimatedView *ringView;
@property (nonatomic, weak, readonly) UIVisualEffectView *hudView;
@property (nonatomic, weak, readonly) UIImageView *imageView;
+ (SVProgressHUD*)sharedView;
@end

@interface XCProgressHUD ()
{
    UIColor *foregroundColor_;
    UIFont *font_;
}
@property (strong, nonatomic) UIImage *loadingImage;
@property (nonatomic, strong) SVProgressAnimatedView *progressBackgroundView;
@property (nonatomic, strong) SVProgressAnimatedView *progressView;
+ (XCProgressHUD*)sharedView;
@end

@implementation XCProgressHUD

#pragma mark --------------- system methods

#define MY_CLASS XCProgressHUD

+ (MY_CLASS *)sharedView
{
    static MY_CLASS *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[super allocWithZone:NULL] init];
    });
    return shareObject;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self sharedView];
        [self setMinimumDismissTimeInterval:60 * 15];
        [self setMaximumDismissTimeInterval:60 * 15];
        [self setCornerRadius:4.0];
        [self setForegroundColor:UIColor.whiteColor];
        [self setBackgroundColor:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]];
        [self setFont:[UIFont systemFontOfSize:16.0]];
        [self setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [self setRingThickness:6.0];
        [self setRingRadius:52.0];
        [self setRingNoTextRadius:52.0];
        [self sharedView]->foregroundColor_ = [self sharedView].foregroundColor;
        [self sharedView]->font_ = [self sharedView].font;

        NSBundle *bundle = [NSBundle bundleForClass:[XCProgressHUD class]];
        NSURL *url = [bundle URLForResource:@"XCProgressHUD" withExtension:@"bundle"];
        if (url) {
            NSBundle *imageBundle = [NSBundle bundleWithURL:url];
            [self setSuccessImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"success" ofType:@"png"]]];
            [self setInfoImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"info" ofType:@"png"]]];
            [self setErrorImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"error" ofType:@"png"]]];
            [self sharedView].loadingImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"loading" ofType:@"png"]];
        }
    });
}

#pragma mark --------------- public methods
+ (void)showImage:(UIImage *)image status:(NSString *)status
{
    [self showImage:image status:status duration:2];
}

+ (void)showImage:(UIImage *)image status:(NSString *)status duration:(NSTimeInterval)duration
{
    if (!image && status.length == 0) return;
    [super showImage:image ? : [UIImage imageNamed:@""] status:status];
    [self dismissWithDelay:duration];
    [self setMinimumSize:CGSizeMake(116, 116)];
}

+ (void)showToast:(NSString *)msg
{
    [self showToast:msg duration:2];
}

+ (void)showToast:(NSString *)msg duration:(NSTimeInterval)duration
{
    [self showImage:nil status:msg duration:duration];
    [self setMinimumSize:CGSizeZero];
}

+ (void)showSuccessWithStatus:(NSString *)string
{
    [self showSuccessWithStatus:string duration:2];
}

+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration
{
    [super showSuccessWithStatus:string];
    [self dismissWithDelay:duration];
}

+ (void)showErrorWithStatus:(NSString *)string
{
    [self showErrorWithStatus:string duration:2];
}

+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration
{
    [super showErrorWithStatus:string];
    [self dismissWithDelay:duration];
}

+ (void)showWarningWithStatus:(NSString *)string
{
    [self showWarningWithStatus:string duration:2];
}

+ (void)showWarningWithStatus:(NSString *)string duration:(NSTimeInterval)duration
{
    [super showInfoWithStatus:string];
    [self dismissWithDelay:duration];
}

+ (void)showLoadingHUDWithMsg:(NSString *)msg
{
    [self showImage:[self sharedView].loadingImage status:msg duration:60 * 100];
    NSTimeInterval animationDuration = 1;
    CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = (id) 0;
    animation.toValue = @(M_PI*2);
    animation.duration = animationDuration;
    animation.timingFunction = linearCurve;
    animation.removedOnCompletion = NO;
    animation.repeatCount = INFINITY;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    [[self sharedView].imageView.layer addAnimation:animation forKey:@"rotate"];
}


+ (void)showProgress:(float)progress
{
    [self showImage:UIImage.new status:[NSString stringWithFormat:@"%.f%%",progress * 100] duration:60 * 100];
    UIFont *f = [UIFont systemFontOfSize:21];
    if ([self sharedView].font != f) {
        [self sharedView]->foregroundColor_ = [self sharedView].foregroundColor;
        [self sharedView]->font_ = [self sharedView].font;
    }
    [self setForegroundColor:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]];
    [self setMinimumSize:CGSizeMake(116, 116)];
    [self setBackgroundColor:UIColor.clearColor];
    [self setFont:f];

    dispatch_async(dispatch_get_main_queue(), ^{
        [super sharedView].ringView.hidden = [super sharedView].backgroundRingView.hidden = YES;
        [self sharedView].statusLabel.center = [self sharedView].progressView.center = [self sharedView].progressBackgroundView.center = [self sharedView].hudView.contentView.center;
        [self sharedView].progressView.strokeEnd = progress;
    });
}

+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(SVProgressHUDDismissCompletion)completion
{
    [super dismissWithDelay:delay completion:^{
        [[self sharedView].imageView.layer removeAllAnimations];
        [[self sharedView] removeProgressView];
    }];
}

#pragma mark --------------- delegate methods

#pragma mark --------------- event response

#pragma mark --------------- private methods

- (void)removeProgressView {
    [SVProgressHUD sharedView].ringView.hidden = [SVProgressHUD sharedView].backgroundRingView.hidden = NO;
    [self setBackgroundColor:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]];
    [self setForegroundColor:self->foregroundColor_];
    [self setFont:self->font_];

    [self.progressBackgroundView removeFromSuperview];
    [self.progressView removeFromSuperview];
}


#pragma mark --------------- property getter
- (SVProgressAnimatedView *)progressView
{
    if(!_progressView) {
        _progressView = [[SVProgressAnimatedView alloc] initWithFrame:CGRectZero];
        _progressView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
    }

    // Update styling
    _progressView.strokeColor = [UIColor colorWithRed:184/255.0 green:7/255.0 blue:34/255.0 alpha:1];
    _progressView.strokeThickness = self.ringThickness;
    _progressView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    
    if (!_progressView.superview) {
        [self.hudView.contentView addSubview:_progressView];
    }
    
    return _progressView;
}

- (SVProgressAnimatedView*)progressBackgroundView
{
    if(!_progressBackgroundView) {
        _progressBackgroundView = [[SVProgressAnimatedView alloc] initWithFrame:CGRectZero];
        _progressBackgroundView.strokeEnd = 1.0f;
    }
    
    // Update styling
    _progressBackgroundView.strokeColor = [UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1];
    _progressBackgroundView.strokeThickness = self.ringThickness;
    _progressBackgroundView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    if (!_progressBackgroundView.superview) {
        [self.hudView.contentView addSubview:_progressBackgroundView];
    }
    return _progressBackgroundView;
}
#pragma mark --------------- property setter
@end
