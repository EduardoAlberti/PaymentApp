//
//  EACardIssuer.m
//  PaymentApp
//
//  Created by Eduardo on 11/16/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EACardIssuer.h"

@implementation EACardIssuer
@synthesize cardIssuerId, name, thumbnailURLString, supportedInstallments;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        // For code simplicity, I assume that all fields are mandatory and can't be <null>
        self.cardIssuerId = dictionary[@"id"];
        self.name = dictionary[@"name"];
        self.thumbnailURLString = dictionary[@"secure_thumbnail"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@ name: %@ thumbnail: %@",self.cardIssuerId, self.name, self.thumbnailURLString];
}
@end
