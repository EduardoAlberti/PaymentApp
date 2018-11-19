//
//  EAInstallment.h
//  PaymentApp
//
//  Created by Eduardo on 11/16/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EAInstallment : NSObject
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *recommendedMessage;
@property (nonatomic, strong) NSString *amount;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
