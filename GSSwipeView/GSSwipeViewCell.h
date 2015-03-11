//
//  GSSwipeViewCell.h
//  tinder
//
//  Created by kuxing on 15/3/9.
//  Copyright (c) 2015年 yangyanan. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIView (Label)

- (void)constructBorderedLabelWithText:(NSString *)text
								 color:(UIColor *)color
								 angle:(CGFloat)angle;

@end
@implementation UIView (Label)

- (void)constructBorderedLabelWithText:(NSString *)text
								 color:(UIColor *)color
								 angle:(CGFloat)angle {
	self.layer.borderColor = color.CGColor;
	self.layer.borderWidth = 5.f;
	self.layer.cornerRadius = 10.f;
	
	UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	label.text = [text uppercaseString];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack"
								 size:30.f];
	label.textColor = color;
	[self addSubview:label];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(label)]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(label)]];
	
	
	self.transform = CGAffineTransformRotate(CGAffineTransformIdentity,
											 angle*(M_PI/180.0));
}

@end

@interface GSSwipeViewCell : UIView
@end
