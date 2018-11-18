//
//  EAPaymentProcessDelegate.h
//  PaymentApp
//
//  Created by Eduardo on 11/17/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EAPaymentProcessDelegate <NSObject>
- (void)paymentStep:(UIViewController * _Nonnull)paymentStepViewController didEndWithResult:(NSDictionary * _Nonnull)resultData;

@optional
- (void)paymentStepDidCancel:(UIViewController * _Nonnull)paymentStepViewController;
@end
