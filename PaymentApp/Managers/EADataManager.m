//
//  EADataManager.m
//  PaymentApp
//
//  Created by Eduardo on 11/16/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EADataManager.h"

// Managers
#import "EAAPIManager.h"

@implementation EADataManager
@synthesize paymentMethods;

#pragma mark - Initialization

+ (id)sharedManager
{
    static EADataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[EADataManager alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addAPINotificationsObservers];
    }
    return self;
}

- (void)addAPINotificationsObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePaymentMethodsResultNotification:)
                                                 name:EAAPIManagerPaymentMethodsResutlsNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCardIssuersResutlsNotification:)
                                                 name:EAAPIManagerCardIssuersResutlsNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInstallmentsMessageResutlsNotification:)
                                                 name:EAAPIManagerInstallmentsMessageResutlsNotification
                                               object:nil];
}

#pragma mark - Manager Methods

- (NSArray * _Nullable)getPaymentMethods
{
    if (!paymentMethods) {
        [self updatePaymentMethods];
    }
    return paymentMethods;
}

- (NSArray * _Nullable)getCardIssuersForPaymentMethodId:(NSString * _Nonnull)paymentMethodId
{
    if (!paymentMethodId || [paymentMethodId isEqualToString:@""]) {
        NSLog(@"Invalid payment method id");
        return nil;
    }
    
    EAPaymentMethod *paymentMethod = [self findPaymentMethodWithId:paymentMethodId];
    if (!paymentMethod.supportedCardIssuers) {
        [self updateCardIssuersForPaymentMethod:paymentMethod.paymentMethodId];
    }
    return paymentMethod.supportedCardIssuers;
}

- (NSArray * _Nullable)getInstallmentsForAmount:(NSNumber * _Nonnull)amount
                            withPaymentMethodId:(NSString * _Nonnull)paymentMethodId
                                andCardIssuerId:(NSString * _Nonnull)cardIssuerId
{
    
    if (!paymentMethodId || [paymentMethodId isEqualToString:@""]) {
        NSLog(@"Invalid payment method id");
        return nil;
        
    }else if (!cardIssuerId || [cardIssuerId isEqualToString:@""]){
        NSLog(@"Invalid issuerId id");
        return nil;
    }
    
    EAPaymentMethod *paymentMethod = [self findPaymentMethodWithId:paymentMethodId];
    EACardIssuer *cardIssuer = [self findCardIssuerForPaymentMethod:paymentMethod withId:cardIssuerId];
    
    if (!cardIssuer.supportedInstallments) {
        [self updateInstallmentsForAmount:amount withPaymentMethodId:paymentMethodId andCardIssuerId:cardIssuerId];
    }
    return cardIssuer.supportedInstallments;
}

- (void)updatePaymentMethods
{
    [[EAAPIManager sharedManager] requestPaymentMethods];
}

- (void)updateCardIssuersForPaymentMethod:(NSString * _Nonnull)paymentMethodId
{
    [[EAAPIManager sharedManager] requestIssuersByPaymentMethodId:paymentMethodId];
}

- (void)updateInstallmentsForAmount:(NSNumber * _Nonnull)amount
                withPaymentMethodId:(NSString * _Nonnull)paymentMethodId
                    andCardIssuerId:(NSString * _Nonnull)cardIssuerId
{
    [[EAAPIManager sharedManager] requestInstallmentsMessageForAmount:amount withPaymentMethodId:paymentMethodId andCardIssuerId:cardIssuerId];
}

#pragma Mark - API Notifications Handlers

- (void)handlePaymentMethodsResultNotification:(NSNotification *)notification
{
    NSMutableArray *list = [NSMutableArray new];
    NSArray *data = notification.object;
    EAPaymentMethod *tempPaymentMethod;
    
    for (NSDictionary *paymentMethodData in data) {
        tempPaymentMethod = [[EAPaymentMethod alloc] initWithDictionary:paymentMethodData];
        [list addObject:tempPaymentMethod];
    }
    
    self.paymentMethods = [NSArray arrayWithArray:list];
}

- (void)handleCardIssuersResutlsNotification:(NSNotification *)notification
{
    NSString *paymentMethodId = notification.userInfo[@"paymentMethodId"];
    NSPredicate *paymentMethodPredicate = [NSPredicate predicateWithFormat:@"paymentMethodId == %@" , paymentMethodId];
    EAPaymentMethod *paymentMethod = [[self.paymentMethods filteredArrayUsingPredicate:paymentMethodPredicate] firstObject];
    
    NSArray *data = notification.object;
    
    NSMutableArray *list = [NSMutableArray new];
    EACardIssuer *tempCardIssuer;
    
    for (NSDictionary *cardIssuerData in data) {
        tempCardIssuer = [[EACardIssuer alloc] initWithDictionary:cardIssuerData];
        [list addObject:tempCardIssuer];
    }
    
    paymentMethod.supportedCardIssuers = [NSArray arrayWithArray:list];
}

- (void)handleInstallmentsMessageResutlsNotification:(NSNotification *)notification
{
    NSString *paymentMethodId = notification.userInfo[@"paymentMethodId"];
    NSString *cardIssuerId = notification.userInfo[@"cardIssuerId"];
    
    EAPaymentMethod *paymentMethod = [self findPaymentMethodWithId:paymentMethodId];
    EACardIssuer *cardIssuer = [self findCardIssuerForPaymentMethod:paymentMethod withId:cardIssuerId];
    
    NSArray *resutls = notification.object;
    NSDictionary *data = [resutls firstObject];
    NSArray *installments = data[@"payer_costs"];
    
    NSMutableArray *list = [NSMutableArray new];
    EAInstallment *tempInstallment;
    
    for (NSDictionary *installmentData in installments) {
        tempInstallment = [[EAInstallment alloc] initWithDictionary:installmentData];
        [list addObject:tempInstallment];
    }
    
    cardIssuer.supportedInstallments = [NSArray arrayWithArray:list];
}

#pragma mark - Helpers Methods

- (EAPaymentMethod *)findPaymentMethodWithId:(NSString *)paymentMethodId
{
    NSPredicate *paymentMethodPredicate = [NSPredicate predicateWithFormat:@"paymentMethodId == %@" , paymentMethodId];
    return [[self.paymentMethods filteredArrayUsingPredicate:paymentMethodPredicate] firstObject];
}

- (EACardIssuer *)findCardIssuerForPaymentMethod:(EAPaymentMethod *)paymentMethod withId:(NSString *)cardIssuerId
{
    NSPredicate *cardIssuerPredicate = [NSPredicate predicateWithFormat:@"cardIssuerId == %@" , cardIssuerId];
    return [[paymentMethod.supportedCardIssuers filteredArrayUsingPredicate:cardIssuerPredicate] firstObject];
}

@end
