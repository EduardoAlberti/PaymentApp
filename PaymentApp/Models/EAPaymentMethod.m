//
//  EAPaymentMethod.m
//  PaymentApp
//
//  Created by Eduardo on 11/16/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EAPaymentMethod.h"

@implementation EAPaymentMethod
@synthesize paymentMethodId, paymentMethodType, name, thumbnailURLString, supportedCardIssuers;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        // For code simplicity, I assume that all fields are mandatory and can't be <null>
        self.paymentMethodId = dictionary[@"id"];
        self.paymentMethodType = dictionary[@"payment_type_id"];
        self.name = dictionary[@"name"];
        self.thumbnailURLString = dictionary[@"secure_thumbnail"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@ type: %@ name: %@ thumbnail: %@",self.paymentMethodId, self.paymentMethodType, self.name, self.thumbnailURLString];
}
@end
