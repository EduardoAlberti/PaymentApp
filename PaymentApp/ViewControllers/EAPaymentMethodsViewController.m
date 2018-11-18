//
//  EAPaymentMethodsViewController.m
//  PaymentApp
//
//  Created by Eduardo on 11/17/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EAPaymentMethodsViewController.h"

// Helpers
#import "UIView+Additions.h"
#import "UIImageView+AFNetworking.h"

// Managers
#import "EADataManager.h"

// Models
#import "EAPaymentMethod.h"


// Constants
NSString * const kPaymentMethodsKeyPath = @"paymentMethods";
NSString * const kPaymentMethodCellIdentifier = @"paymentMethodCell";

@interface EAPaymentMethodsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) EAPaymentMethod *selectedPaymentMethod;
@end

@implementation EAPaymentMethodsViewController
@synthesize delegate;

#pragma mark - Native Methods

- (instancetype)initWithDelegate:(id <EAPaymentProcessDelegate> _Nonnull)_delegate
{
    self = [super init];
    if (self) {
        self.delegate = _delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    
    [[EADataManager sharedManager] addObserver:self
                                    forKeyPath:kPaymentMethodsKeyPath
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
    
    if ([[EADataManager sharedManager] getPaymentMethods]) {
        [self hideActivityIndicator];
        
    }
}

- (void)dealloc
{
    [[EADataManager sharedManager] removeObserver:self forKeyPath:kPaymentMethodsKeyPath];
}

#pragma mark - Data Manager Updates Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kPaymentMethodsKeyPath]) {
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
    [self goNextStepWithPaymentMethod:self.selectedPaymentMethod];
}

#pragma mark - Table Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[EADataManager sharedManager] getPaymentMethods] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPaymentMethodCellIdentifier];
    EAPaymentMethod *paymentMethod = [[[EADataManager sharedManager] getPaymentMethods] objectAtIndex:indexPath.row];
    cell.textLabel.text = paymentMethod.name;
    
    typeof(cell) __weak weakCell = cell;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: paymentMethod.thumbnailURLString]];
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
    self.selectedPaymentMethod = [[[EADataManager sharedManager] getPaymentMethods] objectAtIndex:indexPath.row];
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
    self.title = NSLocalizedString(@"TXT_PAYMENT_METHODS", @"Title for payment methods step");
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TXT_BACK", @"Title for back button") style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TXT_NEXT", @"Title for next step button") style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonPressed)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self addPaymentMethodsTableView];
    [self addActivityIndicatorView];
    [self setupConstraints];
}

- (void)setupConstraints
{
    [self.tableView fillParent];
    [self.activityIndicatorView centerInParent];
}

- (void)addPaymentMethodsTableView
{
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kPaymentMethodCellIdentifier];
    
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

- (void)goNextStepWithPaymentMethod:(EAPaymentMethod * _Nonnull)paymentMethod
{
    if (!paymentMethod) {
        NSLog(@"Invalid payment method");
        return;
    }
    
    NSDictionary *result = @{@"paymentMethod":paymentMethod};
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentStep:didEndWithResult:)]) {
        [self.delegate paymentStep:self didEndWithResult:result];
    }
}
@end
