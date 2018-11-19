//
//  EAInstallment.m
//  PaymentApp
//
//  Created by Eduardo on 11/16/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EAInstallment.h"

@implementation EAInstallment
@synthesize number, recommendedMessage, amount;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        // For code simplicity, I assume that all fields are mandatory and can't be <null>
        self.number = dictionary[@"installments"];
        self.recommendedMessage = dictionary[@"recommended_message"];
        self.amount = dictionary[@"installment_amount"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"installments: %@ message: %@ amount: %@",self.number, self.recommendedMessage, self.amount];
}
@end
