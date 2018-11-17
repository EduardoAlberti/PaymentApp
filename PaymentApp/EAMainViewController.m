//
//  EAMainViewController.m
//  PaymentApp
//
//  Created by Eduardo on 11/15/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EAMainViewController.h"

// Managers
#import "EADataManager.h"
#import "EACardIssuer.h"

@interface EAMainViewController ()
@property (nonatomic, strong, readonly) EAPaymentMethod *currentPaymentMethod;
@property (nonatomic, strong, readonly) EACardIssuer *currentCardIssuer;
@end

@implementation EAMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObserverForObject:[EADataManager sharedManager] withKeyPath:@"paymentMethods"];
    
    [[EADataManager sharedManager] getPaymentMethods];
}

#pragma mark - Data Manager Updates Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"paymentMethods"]) {
        [self setCurrentPaymentMethod:[[[EADataManager sharedManager] paymentMethods] firstObject]];
        [[EADataManager sharedManager] getCardIssuersForPaymentMethodId:self.currentPaymentMethod.paymentMethodId];
        
    }else if ([keyPath isEqualToString:@"supportedCardIssuers"]){
        [self setCurrentCardIssuer:[self.currentPaymentMethod.supportedCardIssuers firstObject]];
        [[EADataManager sharedManager] getInstallmentsForAmount:@(100000) withPaymentMethodId:self.currentPaymentMethod.paymentMethodId andCardIssuerId:self.currentCardIssuer.cardIssuerId];
        
    }else if ([keyPath isEqualToString:@"supportedInstallments"]){
        NSLog(@"%@",self.currentCardIssuer.supportedInstallments);
    }
}

#pragma mark - Selection Handlers

- (void)setCurrentPaymentMethod:(EAPaymentMethod *)selectedPaymentMethod
{
    if (self.currentPaymentMethod) {
        [self removeObserverForObject:self.currentPaymentMethod withKeyPath:@"supportedCardIssuers"];
    }
    _currentPaymentMethod = selectedPaymentMethod;
    [self addObserverForObject:self.currentPaymentMethod withKeyPath:@"supportedCardIssuers"];
}

- (void)setCurrentCardIssuer:(EACardIssuer *)selectedCardIssuer
{
    if (self.currentCardIssuer) {
        [self removeObserverForObject:self.currentCardIssuer withKeyPath:@"supportedInstallments"];
    }
    _currentCardIssuer = selectedCardIssuer;
    [self addObserverForObject:self.currentCardIssuer withKeyPath:@"supportedInstallments"];
}

#pragma mark - Observers Handlers

- (void)addObserverForObject:(id)object withKeyPath:(NSString *)keyPath
{
    [object addObserver:self
             forKeyPath:keyPath
                options:NSKeyValueObservingOptionNew
                context:nil];
}

- (void)removeObserverForObject:(id)object withKeyPath:(NSString *)keyPath
{
    [object addObserver:self
             forKeyPath:keyPath
                options:NSKeyValueObservingOptionNew
                context:nil];
}

@end
