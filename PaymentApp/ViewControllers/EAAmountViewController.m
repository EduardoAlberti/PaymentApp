//
//  EAAmountViewController.m
//  PaymentApp
//
//  Created by Eduardo on 11/17/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "EAAmountViewController.h"

// Helpers
#import "UIView+Additions.h"

@interface EAAmountViewController ()
@property (nonatomic, strong) UILabel *instructionLabel;
@property (nonatomic, strong) UITextField *amountTextField;
@end

@implementation EAAmountViewController
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
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - User Actions

- (void)nextButtonPressed
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    [self goNextStepWithAmount:[formatter numberFromString:self.amountTextField.text]];
}

#pragma mark - Setup UI

- (void)setupUI
{
    self.title = NSLocalizedString(@"TXT_AMOUNT", @"Title for amount payment step");
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TXT_NEXT", @"Title for next step button") style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonPressed)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self addInstructionLabel];
    [self addAmountTextField];
    [self setupContraints];
}

- (void)setupContraints
{
    [self.instructionLabel.leftAnchor constraintEqualToAnchor:self.amountTextField.leftAnchor].active = YES;
    [self.instructionLabel.bottomAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    [self.amountTextField centerHorizontally];
    [self.amountTextField.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.8].active = YES;
    [self.amountTextField.topAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)addInstructionLabel
{
    self.instructionLabel = [UILabel new];
    self.instructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.instructionLabel.text = NSLocalizedString(@"TXT_INSERT_AMOUNT", @"Instruction for amount input label");
    
    [self.view addSubview:self.instructionLabel];
}

- (void)addAmountTextField
{
    self.amountTextField = [UITextField new];
    self.amountTextField.placeholder = @"1000";
    self.amountTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.amountTextField.textAlignment = NSTextAlignmentLeft;
    self.amountTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.amountTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:self.amountTextField];
}

#pragma mark - TextField Delegate Methods

- (void)textFieldDidChange:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = ![textField.text isEqualToString:@""];
}

#pragma mark - Result

- (void)goNextStepWithAmount:(NSNumber * _Nonnull)amount
{
    if (!amount) {
        NSLog(@"Invalid amount");
        return;
    }
    
    NSDictionary *result = @{@"amount":amount};
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentStep:didEndWithResult:)]) {
        [self.delegate paymentStep:self didEndWithResult:result];
    }
}

@end
