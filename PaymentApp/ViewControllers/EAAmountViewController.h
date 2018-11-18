//
//  EAAmountViewController.h
//  PaymentApp
//
//  Created by Eduardo on 11/17/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import <UIKit/UIKit.h>

// Protocols
#import "EAPaymentProcessDelegate.h"

@interface EAAmountViewController : UIViewController
@property (nonatomic, weak) id <EAPaymentProcessDelegate> delegate;

- (instancetype)initWithDelegate:(id <EAPaymentProcessDelegate> _Nonnull)delegate;
@end
