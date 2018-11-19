//
//  EACardIssuer.h
//  PaymentApp
//
//  Created by Eduardo on 11/16/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EACardIssuer : NSObject
@property (nonatomic, strong) NSString *cardIssuerId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *thumbnailURLString;
@property (nonatomic, strong) NSArray *supportedInstallments;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
