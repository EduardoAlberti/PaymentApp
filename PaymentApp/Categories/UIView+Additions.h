//
//  UIView+Additions.h
//  PaymentApp
//
//  Created by Eduardo on 11/17/18.
//  Copyright © 2018 EA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Additions)
- (void)fillParent;
- (void)fillParentViewWithMarginonTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;
- (void)centerHorizontally;
- (void)centerVertically;
- (void)centerInParent;
@end
