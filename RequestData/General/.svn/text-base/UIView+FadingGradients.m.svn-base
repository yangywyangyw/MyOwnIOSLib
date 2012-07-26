//
//  UIView+FadingGradients.m
//  funMatch_iPad
//
//  Created by 谈 文钊 on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+FadingGradients.h"

@implementation UIView (FadingGradients)

- (void)addFadingCradientsInRect:(CGRect)fadingRect isTop:(BOOL)isTop
{
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    
    if (isTop) {
        maskLayer.colors = [NSArray arrayWithObjects:
                            (id)innerColor,
                            (id)outerColor, nil];
    } else {
        maskLayer.colors = [NSArray arrayWithObjects:
                            (id)outerColor,  
                            (id)innerColor, nil];
    }
    
    maskLayer.frame = fadingRect;
    
    [self.layer addSublayer:maskLayer];
}

@end
