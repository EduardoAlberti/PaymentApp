//
//  EAApiManager.h
//  PaymentApp
//
//  Created by Eduardo on 11/15/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

#pragma mark - Manager Signatures

@interface EAAPIManager : AFHTTPSessionManager
+ (id)sharedManager;
- (void)requestPaymentMethods;
- (void)requestIssuersByPaymentMethodId:(NSString  * _Nonnull)paymentMethodId;
- (void)requestInstallmentsMessageForAmount:(NSNumber * _Nonnull)amount
                        withPaymentMethodId:(NSString * _Nonnull)paymentMethodId
                            andCardIssuerId:(NSString * _Nonnull)cardIssuerId;
@end

#pragma mark - Manager Notifications

FOUNDATION_EXPORT NSString * const EAAPIManagerPaymentMethodsResutlsNotification;
FOUNDATION_EXPORT NSString * const EAAPIManagerCardIssuersResutlsNotification;
FOUNDATION_EXPORT NSString * const EAAPIManagerInstallmentsMessageResutlsNotification;
