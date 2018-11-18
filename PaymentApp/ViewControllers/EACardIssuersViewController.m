//
//  EACardIssuersViewController.m
//  PaymentApp
//
//  Created by Eduardo on 11/17/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EACardIssuersViewController.h"

// Helpers
#import "UIView+Additions.h"
#import "UIImageView+AFNetworking.h"

// Managers
#import "EADataManager.h"

// Constants
NSString * const kSupportedCardIssuersKeyPath = @"supportedCardIssuers";
NSString * const kCardIssuerCellIdentifier = @"cardIssuerCell";

@interface EACardIssuersViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) EAPaymentMethod *paymentMethod;
@property (nonatomic, strong) EACardIssuer *selectedCardIssuer;

@end

@implementation EACardIssuersViewController
@synthesize delegate;

#pragma mark - Native Methods

- (instancetype)initWithDelegate:(id <EAPaymentProcessDelegate> _Nonnull)_delegate
                andPaymentMethod:(EAPaymentMethod * _Nonnull)_paymentMethod
{
    self = [super init];
    if (self) {
        self.delegate = _delegate;
        self.paymentMethod = _paymentMethod;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    
    [self.paymentMethod addObserver:self
                         forKeyPath:kSupportedCardIssuersKeyPath
                            options:NSKeyValueObservingOptionNew
                            context:nil];
    
    if (self.paymentMethod.supportedCardIssuers) {
        [self hideActivityIndicator];
        
    }else{
        [[EADataManager sharedManager] getCardIssuersForPaymentMethodId:self.paymentMethod.paymentMethodId];
    }
}

- (void)dealloc
{
    [self.paymentMethod removeObserver:self forKeyPath:kSupportedCardIssuersKeyPath];
}

#pragma mark - Data Manager Updates Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kSupportedCardIssuersKeyPath]) {
        [self hideActivityIndicator];
        [self.tableView reloadData];
    }
}

#pragma mark - User Actions

- (void)backButtonPressed
{
    [self backToPreviousStep];
}

- (void)nextButtonPressed
{
    [self goNextStepWithCardIssuer:self.selectedCardIssuer];
}

#pragma mark - Table Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.paymentMethod.supportedCardIssuers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCardIssuerCellIdentifier];
    EACardIssuer *cardIssuer = [self.paymentMethod.supportedCardIssuers objectAtIndex:indexPath.row];
    cell.textLabel.text = cardIssuer.name;
    
    typeof(cell) __weak weakCell = cell;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: cardIssuer.thumbnailURLString]];
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                       weakCell.imageView.image = image;
                                       [weakCell layoutSubviews];
                                   } failure:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCardIssuer = [self.paymentMethod.supportedCardIssuers objectAtIndex:indexPath.row];
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
    self.title = NSLocalizedString(@"TXT_CARD_ISSUERS", @"Title for card issuers step");
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCardIssuerCellIdentifier];
    
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

- (void)goNextStepWithCardIssuer:(EACardIssuer * _Nonnull)cardIssuer
{
    if (!cardIssuer) {
        NSLog(@"Invalid card issuer");
        return;
    }
    
    NSDictionary *result = @{@"cardIssuer":cardIssuer};
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentStep:didEndWithResult:)]) {
        [self.delegate paymentStep:self didEndWithResult:result];
    }
}
@end
