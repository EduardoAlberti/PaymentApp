//
//  EAPaymentMethod.h
//  PaymentApp
//
//  Created by Eduardo on 11/16/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EAPaymentMethod : NSObject
@property (nonatomic, strong) NSString *paymentMethodId;
@property (nonatomic, strong) NSString *paymentMethodType;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *thumbnailURLString;
@property (nonatomic, strong) NSArray *supportedCardIssuers;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
