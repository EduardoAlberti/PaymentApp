//
//  EAInstallmentsViewController.m
//  PaymentApp
//
//  Created by Eduardo on 11/17/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EAInstallmentsViewController.h"

// Helpers
#import "UIView+Additions.h"
#import "UIImageView+AFNetworking.h"

// Managers
#import "EADataManager.h"

// Constants
NSString * const kSupportedInstallmentsKeyPath = @"supportedInstallments";
NSString * const kInstallmentCellIdentifier = @"installmentCell";

@interface EAInstallmentsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) EAPaymentMethod *paymentMethod;
@property (nonatomic, strong) EACardIssuer *cardIssuer;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) EAInstallment *selectedInstallment;

@end

@implementation EAInstallmentsViewController
@synthesize delegate;

#pragma mark - Native Methods

- (instancetype)initWithDelegate:(id <EAPaymentProcessDelegate> _Nonnull)_delegate
                andPaymentMethod:(EAPaymentMethod * _Nonnull)_paymentMethod
                   andCardIssuer:(EACardIssuer * _Nonnull)_cardIssuer
                       andAmount:(NSNumber * _Nonnull)_amount
{
    self = [super init];
    if (self) {
        self.delegate = _delegate;
        self.paymentMethod = _paymentMethod;
        self.cardIssuer = _cardIssuer;
        self.amount = _amount;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    
    [self.cardIssuer addObserver:self
                      forKeyPath:kSupportedInstallmentsKeyPath
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    if (self.cardIssuer.supportedInstallments) {
        [self hideActivityIndicator];
        
    }else{
        [[EADataManager sharedManager] getInstallmentsForAmount:self.amount
                                            withPaymentMethodId:self.paymentMethod.paymentMethodId
                                                andCardIssuerId:self.cardIssuer.cardIssuerId];
    }
}

- (void)dealloc
{
    [self.cardIssuer removeObserver:self forKeyPath:kSupportedInstallmentsKeyPath];
}

#pragma mark - Data Manager Updates Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kSupportedInstallmentsKeyPath]) {
        [self hideActivityIndicator];
        [self.tableView reloadData];
    }
}

#pragma mark - User Actions

- (void)backButtonPressed
{
    self.cardIssuer.supportedInstallments = nil;
    [self backToPreviousStep];
}

- (void)nextButtonPressed
{
    [self goNextStepWithInstallment:self.selectedInstallment];
}

#pragma mark - Table Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cardIssuer.supportedInstallments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kInstallmentCellIdentifier];
    EAInstallment *insallment = [self.cardIssuer.supportedInstallments objectAtIndex:indexPath.row];
    cell.textLabel.text = insallment.recommendedMessage;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedInstallment = [self.cardIssuer.supportedInstallments objectAtIndex:indexPath.row];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - UI Handlers

- (void)hideActivityIndicator
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

#pragma mark - Setup UI

- (void)setupUI
{    
    self.title = NSLocalizedString(@"TXT_INSTALLMENTS", @"Title for installments step");
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TXT_BACK", @"Title for back button") style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TXT_NEXT", @"Title for next step button") style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonPressed)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self addTableView];
    [self addActivityIndicatorView];
    [self setupConstraints];
}

- (void)setupConstraints
{
    [self.tableView fillParent];
    [self.activityIndicatorView centerInParent];
}

- (void)addTableView
{
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kInstallmentCellIdentifier];
    
    [self.view addSubview:self.tableView];
}

- (void)addActivityIndicatorView
{
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorView startAnimating];
    
    [self.view addSubview:self.activityIndicatorView];
}

#pragma mark - Result

- (void)backToPreviousStep
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentStepDidCancel:)]) {
        [self.delegate paymentStepDidCancel:self];
    }
}

- (void)goNextStepWithInstallment:(EAInstallment * _Nonnull)installment
{
    if (!installment) {
        NSLog(@"Invalid installment");
        return;
    }
    
    NSDictionary *result = @{@"installment":installment};
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentStep:didEndWithResult:)]) {
        [self.delegate paymentStep:self didEndWithResult:result];
    }
}

@end
