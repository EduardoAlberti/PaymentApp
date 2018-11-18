//
//  UIView+Additions.m
//  PaymentApp
//
//  Created by Eduardo on 11/17/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView(Additions)

- (void)fillParentViewWithMarginonTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right
{
    if (!self.superview) {
        NSLog(@"No parent to fill");
        return;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor constant:top].active = YES;
    [self.leftAnchor constraintEqualToAnchor:self.superview.leftAnchor constant:left].active = YES;
    [self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor constant:bottom].active = YES;
    [self.rightAnchor constraintEqualToAnchor:self.superview.rightAnchor constant:right].active = YES;
}

- (void)fillParent
{
    [self fillParentViewWithMarginonTop:0 left:0 bottom:0 right:0];
}

- (void)centerHorizontally
{
    if (!self.superview) {
        NSLog(@"No parent to fill");
        return;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.centerXAnchor constraintEqualToAnchor:self.superview.centerXAnchor].active = YES;
}

- (void)centerVertically
{
    if (!self.superview) {
        NSLog(@"No parent to fill");
        return;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.centerYAnchor constraintEqualToAnchor:self.superview.centerYAnchor].active = YES;
}

- (void)centerInParent
{
    [self centerHorizontally];
    [self centerVertically];
}

@end
