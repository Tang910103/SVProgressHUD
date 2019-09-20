//
//  XCViewController.m
//  XCProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2019 Sam Vermette and contributors. All rights reserved.
//

#import "XCViewController.h"
#import "XCProgressHUD.h"

@interface XCViewController()

@property (nonatomic, readwrite) NSUInteger activityCount;
@property (weak, nonatomic) IBOutlet UIButton *popActivityButton;

@end

@implementation XCViewController


#pragma mark - XCViewController lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.activityCount = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [XCProgressHUD dismiss];
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
        [self dismiss];
    }
}

#pragma mark - Show Methods Sample

- (void)show {
    if ([XCProgressHUD sharedView].defaultAnimationType == SVProgressHUDAnimationTypeFlat) {
        [XCProgressHUD showLoadingHUD];
    } else {
        [XCProgressHUD showWithStatus:@"加载中..."];
    }
    self.activityCount++;
}

- (void)showWithStatus {
    [XCProgressHUD showToast:@"文本内容，不超过14个字位符文本内容"];
    self.activityCount++;
}

static float progress = 0.0f;
- (IBAction)defaultStyle:(UIButton *)sender {
    [XCProgressHUD defaultStyle];
}

- (IBAction)showWithProgress:(id)sender {
    progress = 0.0f;
    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
    self.activityCount++;
}

- (void)increaseProgress {
    progress += 0.05f;
    
    [XCProgressHUD showProgress:progress];
    if(progress < 1.0f){
        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
    } else {
        if (self.activityCount > 1) {
            [self performSelector:@selector(popActivity) withObject:nil afterDelay:0.4f];
        } else {
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4f];
        }
    }
}

#pragma mark - Dismiss Methods Sample

- (void)dismiss {
    [XCProgressHUD dismiss];
    self.activityCount = 0;
}

- (IBAction)popActivity {
    [XCProgressHUD popActivity];
    
    if (self.activityCount != 0) {
        self.activityCount--;
    }
}

- (IBAction)showInfoWithStatus {
    [XCProgressHUD showInfoWithStatus:@"警示内容"];
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
        [XCProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    } else {
        [XCProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    }
}

- (IBAction)changeAnimationType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [XCProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    } else {
        [XCProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    }
}

- (IBAction)changeMaskType:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    if(segmentedControl.selectedSegmentIndex == 0){
        [XCProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    } else if(segmentedControl.selectedSegmentIndex == 1){
        [XCProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    } else if(segmentedControl.selectedSegmentIndex == 2){
        [XCProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    } else if(segmentedControl.selectedSegmentIndex == 3){
        [XCProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    } else {
        [XCProgressHUD setBackgroundLayerColor:[[UIColor redColor] colorWithAlphaComponent:0.4]];
        [XCProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
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
