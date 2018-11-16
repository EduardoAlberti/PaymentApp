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
NSString * const EAAPIManagerIssuersResutlsNotification = @"com.ea.networking.PaymentApp.IssuersResutls";
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

- (void)requestIssuersByPayMethodID:(NSString  * _Nonnull)payMethodID
{
    NSDictionary *parameters = @{
                                 @"public_key":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIPublicKey"],
                                 @"payment_method_id":payMethodID
                                 };
    
    [self GET:@"v1/payment_methods/card_issuers"
   parameters:parameters
     progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          [[NSNotificationCenter defaultCenter] postNotificationName:EAAPIManagerIssuersResutlsNotification object:responseObject userInfo:nil];
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"error: %@",error);
      }];
}

- (void)requestInstallmentsMessageForAmount:(NSNumber * _Nonnull)amount
                            withPayMethodID:(NSString  * _Nonnull)payMethodID
                                andIssuerID:(NSNumber * _Nonnull)issuerID
{
    NSDictionary *parameters = @{
                                 @"public_key":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIPublicKey"],
                                 @"payment_method_id":payMethodID,
                                 @"amount":amount,
                                 @"issuer.id":issuerID
                                 };
    
    [self GET:@"v1/payment_methods/installments"
   parameters:parameters
     progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          [[NSNotificationCenter defaultCenter] postNotificationName:EAAPIManagerInstallmentsMessageResutlsNotification object:responseObject userInfo:nil];
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"error: %@",error);
      }];
}

@end

