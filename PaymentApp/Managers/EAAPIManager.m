//
//  EAApiManager.m
//  PaymentApp
//
//  Created by Eduardo on 11/15/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EAAPIManager.h"

#pragma mark - Manager Notifications

NSString * const EAAPIManagerPaymentMethodsResutlsNotification = @"com.ea.networking.PaymentApp.PaymentMethodsResutls";
NSString * const EAAPIManagerCardIssuersResutlsNotification = @"com.ea.networking.PaymentApp.IssuersResutls";
NSString * const EAAPIManagerInstallmentsMessageResutlsNotification = @"com.ea.networking.PaymentApp.InstallmentsMessageResutls";

#pragma mark - Manager Implementation

@implementation EAAPIManager

+ (id)sharedManager
{
    static EAAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[EAAPIManager alloc] initWithBaseURL:[NSURL URLWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIEndpoint"]]];
    });
    
    return sharedManager;
}

#pragma mark - Requests Methods

- (void)requestPaymentMethods
{
    NSDictionary *parameters = @{@"public_key":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIPublicKey"]};
    
    [self GET:@"/v1/payment_methods"
   parameters:parameters
     progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          [[NSNotificationCenter defaultCenter] postNotificationName:EAAPIManagerPaymentMethodsResutlsNotification object:responseObject userInfo:nil];
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"error: %@",error);
      }];
}

- (void)requestIssuersByPaymentMethodId:(NSString  * _Nonnull)paymentMethodId
{
    if (!paymentMethodId || [paymentMethodId isEqualToString:@""]) {
        NSLog(@"Invalid payment method id");
        return;
    }
    
    __block NSString *blockPaymentMethodId = paymentMethodId;
    
    NSDictionary *parameters = @{
                                 @"public_key":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIPublicKey"],
                                 @"payment_method_id":paymentMethodId
                                 };
    
    [self GET:@"v1/payment_methods/card_issuers"
   parameters:parameters
     progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          [[NSNotificationCenter defaultCenter] postNotificationName:EAAPIManagerCardIssuersResutlsNotification
                                                              object:responseObject
                                                            userInfo:@{@"paymentMethodId":blockPaymentMethodId}];
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"error: %@",error);
      }];
}

- (void)requestInstallmentsMessageForAmount:(NSNumber * _Nonnull)amount
                        withPaymentMethodId:(NSString * _Nonnull)paymentMethodId
                            andCardIssuerId:(NSString * _Nonnull)cardIssuerId
{
    
    if (!paymentMethodId || [paymentMethodId isEqualToString:@""]) {
        NSLog(@"Invalid payment method id");
        return;
        
    }else if (!amount || amount < 0){
        NSLog(@"Invalid amount");
        return;
        
    }else if (!cardIssuerId || [cardIssuerId isEqualToString:@""]){
        NSLog(@"Invalid issuerId id");
        return;
    }
    
    __block NSString *blockPaymentMethodId = paymentMethodId;
    __block NSString *blockCardIssuerId = cardIssuerId;
    
    NSDictionary *parameters = @{
                                 @"public_key":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIPublicKey"],
                                 @"payment_method_id":paymentMethodId,
                                 @"amount":amount,
                                 @"issuer.id":cardIssuerId
                                 };
    
    [self GET:@"v1/payment_methods/installments"
   parameters:parameters
     progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          [[NSNotificationCenter defaultCenter] postNotificationName:EAAPIManagerInstallmentsMessageResutlsNotification
                                                              object:responseObject
                                                            userInfo:@{@"paymentMethodId":blockPaymentMethodId,
                                                                       @"cardIssuerId":blockCardIssuerId}];
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"error: %@",error);
      }];
}

@end

