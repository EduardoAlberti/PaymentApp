//
//  EAInstallmentsViewController.h
//  PaymentApp
//
//  Created by Eduardo on 11/17/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import <UIKit/UIKit.h>

// Protocols
#import "EAPaymentProcessDelegate.h"

// Models
#import "EAPaymentMethod.h"
#import "EACardIssuer.h"
#import "EAInstallment.h"

@interface EAInstallmentsViewController : UIViewController
@property (nonatomic, weak) id <EAPaymentProcessDelegate> delegate;

- (instancetype)initWithDelegate:(id <EAPaymentProcessDelegate> _Nonnull)delegate
                andPaymentMethod:(EAPaymentMethod * _Nonnull)paymentMethod
                   andCardIssuer:(EACardIssuer * _Nonnull)cardIssuer
                       andAmount:(NSNumber * _Nonnull)amount;
@end
