//
//  EADataManager.h
//  PaymentApp
//
//  Created by Eduardo on 11/16/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import <Foundation/Foundation.h>

// Models
#import "EAPaymentMethod.h"
#import "EACardIssuer.h"
#import "EAInstallment.h"

@interface EADataManager : NSObject
@property (nonatomic, strong, getter = getPaymentMethods) NSArray *paymentMethods;

+ (id)sharedManager;

- (NSArray * _Nullable)getPaymentMethods;
- (NSArray * _Nullable)getCardIssuersForPaymentMethodId:(NSString * _Nonnull)paymentMethodId;
- (NSArray * _Nullable)getInstallmentsForAmount:(NSNumber * _Nonnull)amount
                            withPaymentMethodId:(NSString * _Nonnull)paymentMethodId
                                andCardIssuerId:(NSString * _Nonnull)cardIssuerId;
@end
