//
//  EAMainViewController.m
//  PaymentApp
//
//  Created by Eduardo on 11/15/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EAMainViewController.h"

// Helpers
#import "UIView+Additions.h"

// Managers
#import "EADataManager.h"
#import "EACardIssuer.h"

// Protocols
#import "EAPaymentProcessDelegate.h"

// ViewControllers
#import "EAAmountViewController.h"
#import "EAPaymentMethodsViewController.h"
#import "EACardIssuersViewController.h"
#import "EAInstallmentsViewController.h"

// Constants
static const float kPaymentButtonWidth = 150;
static const float kPaymentButtonHeight = 60;

@interface EAMainViewController () <EAPaymentProcessDelegate>
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) EAPaymentMethod *currentPaymentMethod;
@property (nonatomic, strong) EACardIssuer *currentCardIssuer;
@property (nonatomic, strong) EAInstallment *currentInstallment;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIButton *paymentButton;

@end

@implementation EAMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
    [[EADataManager sharedManager] getPaymentMethods];
}

- (void)cleanup
{
    self.currentPaymentMethod = nil;
    self.currentCardIssuer = nil;
    self.currentInstallment = nil;
    self.amount = nil;
}

- (void)newPaymentButtonPressed
{
    [self cleanup];
    [self addNavigationController];
}

#pragma mark - UI

- (void)setupUI
{
    self.view.backgroundColor = UIColor.whiteColor;
    [self addPaymentButton];
    [self addNavigationController];
    [self setupConstraints];
}

- (void)addNavigationController
{
    EAAmountViewController *amountViewController = [[EAAmountViewController alloc] initWithDelegate:self];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:amountViewController];
    self.navigationController.navigationItem.hidesBackButton = YES;
    [self addChildViewController:self.navigationController];
    [self.view addSubview:self.navigationController.view];
    
    
    [self.navigationController.view fillParent];
}

- (void)setupConstraints
{
    [self.paymentButton centerInParent];
    [self.paymentButton.widthAnchor constraintEqualToConstant:kPaymentButtonWidth].active = YES;
    [self.paymentButton.heightAnchor constraintEqualToConstant:kPaymentButtonHeight].active = YES;
}

- (void)addPaymentButton
{
    self.paymentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.paymentButton.layer.cornerRadius = 5;
    self.paymentButton.backgroundColor = [UIColor colorWithRed: 0.153 green: 0.492 blue: 0.209 alpha: 1];
    [self.paymentButton setTitle:NSLocalizedString(@"TXT_NEW_PAYMENT", @"New payment button title") forState:UIControlStateNormal];
    [self.paymentButton addTarget:self action:@selector(newPaymentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.paymentButton];
}

#pragma mark - Payment Process Protocol Methods

- (void)paymentStepDidCancel:(UIViewController *)paymentStepViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)paymentStep:(UIViewController *)paymentStepViewController didEndWithResult:(NSDictionary *)resultData
{
    if ([paymentStepViewController isKindOfClass:[EAAmountViewController class]]) {
        self.amount = resultData[@"amount"];
        EAPaymentMethodsViewController *paymentMethodsViewController = [[EAPaymentMethodsViewController alloc] initWithDelegate:self];
        [self.navigationController pushViewController:paymentMethodsViewController animated:YES];
        
    }else if ([paymentStepViewController isKindOfClass:[EAPaymentMethodsViewController class]]){
        self.currentPaymentMethod = resultData[@"paymentMethod"];
        EACardIssuersViewController *paymentMethodsViewController = [[EACardIssuersViewController alloc] initWithDelegate:self
                                                                                                        andPaymentMethod:self.currentPaymentMethod];
        [self.navigationController pushViewController:paymentMethodsViewController animated:YES];
        
    }else if ([paymentStepViewController isKindOfClass:[EACardIssuersViewController class]]){
        self.currentCardIssuer = resultData[@"cardIssuer"];
        EAInstallmentsViewController *installmentsViewController = [[EAInstallmentsViewController alloc] initWithDelegate:self
                                                                                                         andPaymentMethod:self.currentPaymentMethod
                                                                                                            andCardIssuer:self.currentCardIssuer
                                                                                                                andAmount:self.amount];
        [self.navigationController pushViewController:installmentsViewController animated:YES];
        
    }else if ([paymentStepViewController isKindOfClass:[EAInstallmentsViewController class]]){
        self.currentInstallment = resultData[@"installment"];
        [self.navigationController.view removeFromSuperview];
        [self.navigationController removeFromParentViewController];
        self.navigationController = nil;
        
        NSString *summary = [NSString stringWithFormat:NSLocalizedString(@"TXT_SUMMARY_MESSAGE", @"Summary payment process message"),self.amount, self.currentPaymentMethod.name, self.currentCardIssuer.name, self.currentInstallment.recommendedMessage];
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TXT_SUMMARY", @"Summary alert title") message:summary preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

@end
