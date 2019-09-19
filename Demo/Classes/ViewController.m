//
//  ViewController.m
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2019 Sam Vermette and contributors. All rights reserved.
//

#import "ViewController.h"
#import "XCProgressHUD.h"
#define SV_APP_EXTENSIONS @"sdf"

@interface ViewController()

@property (nonatomic, readwrite) NSUInteger activityCount;
@property (weak, nonatomic) IBOutlet UIButton *popActivityButton;

@end

@implementation ViewController


#pragma mark - ViewController lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.activityCount = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDWillAppearNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDDidAppearNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDWillDisappearNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDDidDisappearNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:SVProgressHUDDidReceiveTouchEventNotification
                                               object:nil];
    
    [self addObserver:self forKeyPath:@"activityCount" options:NSKeyValueObservingOptionNew context:nil];
}


#pragma mark - Notification handling

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"Notification received: %@", notification.name);
    NSLog(@"Status user info key: %@", notification.userInfo[SVProgressHUDStatusUserInfoKey]);
    
    if([notification.name isEqualToString:SVProgressHUDDidReceiveTouchEventNotification]){
//        [self dismiss];
        NSLog(@"%d",SVProgressHUD.isVisible);
    }
}


#pragma mark - Show Methods Sample

- (void)show {
    [XCProgressHUD showLoadingHUDWithMsg:@"加载中…"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [XCProgressHUD dismiss];
    });
    self.activityCount++;
}

- (void)showWithStatus {
    [XCProgressHUD showToast:@"文本内容，不超过14个字位符文本内容" duration:0.5];
    self.activityCount++;
}

static float progress = 0.0f;

- (IBAction)showWithProgress:(id)sender {
    progress = 0;
    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        progress = 0.5f;
        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
    });
    self.activityCount++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [XCProgressHUD dismiss];
    });
}

- (void)increaseProgress {
//    progress += 0.05f;
    UIView *v = [UIView.alloc initWithFrame:CGRectMake(0, 0, 50, 50)];
    v.backgroundColor = UIColor.redColor;
//    [XCProgressHUD setContainerView:v];
    [XCProgressHUD showProgress:progress];

//    if(progress < 1.0f){
//        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
//    } else {
//        if (self.activityCount > 1) {
//            [self performSelector:@selector(popActivity) withObject:nil afterDelay:0.4f];
//        } else {
//            [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4f];
//        }
//    }
}


#pragma mark - Dismiss Methods Sample

- (void)dismiss {
	[XCProgressHUD dismiss];
    self.activityCount = 0;
}

- (IBAction)popActivity {
    [SVProgressHUD popActivity];
    
    if (self.activityCount != 0) {
        self.activityCount--;
    }
}

- (IBAction)showInfoWithStatus {
    [XCProgressHUD showWarningWithStatus:@"警示内容"];
    self.activityCount++;
}

- (void)showSuccessWithStatus {
	[XCProgressHUD showSuccessWithStatus:@"成功"];
    self.activityCount++;
}

- (void)showErrorWithStatus {
	[XCProgressHUD showErrorWithStatus:@"失败"];
    self.activityCount++;
}


#pragma mark - Styling

- (IBAction)changeStyle:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    } else {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    }
}

- (IBAction)changeAnimationType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    } else {
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    }
}

- (IBAction)changeMaskType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    } else if(segmentedControl.selectedSegmentIndex == 1){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    } else if(segmentedControl.selectedSegmentIndex == 2){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    } else if(segmentedControl.selectedSegmentIndex == 3){
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    } else {
        [SVProgressHUD setBackgroundLayerColor:[[UIColor redColor] colorWithAlphaComponent:0.4]];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    }
}


#pragma mark - Helper

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"activityCount"]){
        unsigned long activityCount = [[change objectForKey:NSKeyValueChangeNewKey] unsignedLongValue];
        [self.popActivityButton setTitle:[NSString stringWithFormat:@"popActivity - %lu", activityCount] forState:UIControlStateNormal];
    }
}

@end
