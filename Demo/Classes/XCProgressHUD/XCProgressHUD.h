//
//  XCProgressHUD.h
//  SVProgressHUD
//
//  Created by Mac_mini_crm on 2019/9/18.
//

#import "SVProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface XCProgressHUD : SVProgressHUD
+ (void)showToast:(nullable NSString *)msg;
+ (void)showToast:(nullable NSString *)msg duration:(NSTimeInterval)duration;

+ (void)showSuccess;
+ (void)showSuccessWithStatus:(nullable NSString*)string;
+ (void)showSuccessWithStatus:(nullable NSString *)string duration:(NSTimeInterval)duration;

+ (void)showError;
+ (void)showErrorWithStatus:(nullable NSString *)string;
+ (void)showErrorWithStatus:(nullable NSString *)string duration:(NSTimeInterval)duration;

+ (void)showWarning;
+ (void)showWarningWithStatus:(nullable NSString*)string;
+ (void)showWarningWithStatus:(nullable NSString *)string duration:(NSTimeInterval)duration;

+ (void)showImage:(nullable UIImage *)image status:(nullable NSString *)status;

+ (void)showImage:(nullable UIImage *)image status:(nullable NSString *)status duration:(NSTimeInterval)duration;

+ (void)showLoadingHUD;
+ (void)showLoadingHUDWithMsg:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
