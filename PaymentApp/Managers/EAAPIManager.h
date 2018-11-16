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
- (void)requestIssuersByPayMethodID:(NSString  * _Nonnull)payMethodID;
- (void)requestInstallmentsMessageForAmount:(NSNumber * _Nonnull)amount
                            withPayMethodID:(NSString  * _Nonnull)payMethodID
                                andIssuerID:(NSNumber * _Nonnull)issuerID;
@end

#pragma mark - Manager Notifications

FOUNDATION_EXPORT NSString * const EAAPIManagerPaymentMethodsResutlsNotification;
FOUNDATION_EXPORT NSString * const EAAPIManagerIssuersResutlsNotification;
FOUNDATION_EXPORT NSString * const EAAPIManagerInstallmentsMessageResutlsNotification;
