//
//  GSButton.m
//  tinder
//
//  Created by kuxing on 15/3/10.
//  Copyright (c) 2015年 yangyanan. All rights reserved.
//

#import "GSButton.h"
@interface GSButton()
@property (nonatomic,strong) UIView *maskView;
@property (nonatomic,strong) UIImageView *backGroundImageView;
@property (nonatomic,strong) UIImageView *midImageView;
@property (nonatomic,strong) UIImageView *topImageView;

@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL action;
@end
@implementation GSButton

- (id)initWithFrame:(CGRect)frame
 withBackGroupImage:(UIImage *)backImg
	   withMidImage:(UIImage *)midImg
	   withTopImage:(UIImage *)topImage
{
	self = [super initWithFrame:frame];
	if (self) {
		
		self.backGroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:self.backGroundImageView];
		self.backGroundImageView.userInteractionEnabled = YES;
		
		
		self.midImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:self.midImageView];
		self.midImageView.userInteractionEnabled = YES;
		
		
		self.topImageView = [[UIImageView alloc] initWithFrame:self.midImageView.bounds];
		[self.midImageView addSubview:self.topImageView];

	
		
//		self.maskView = [[UIView alloc] initWithFrame:self.bounds];
//		[self addSubview:self.maskView];
//	
//	
//		self.maskView.userInteractionEnabled = YES;
		self.backGroundImageView.image = backImg;
		self.midImageView.image = midImg;
		self.topImageView.image = topImage;

//		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTap:)];
//		longPress.minimumPressDuration = 0;
//		[self.maskView addGestureRecognizer:longPress];

	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
		[self touchBegan];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

	UITouch *touch = [touches anyObject];
	CGPoint nowPoint = [touch locationInView:self];
	if (CGRectContainsPoint(self.bounds, nowPoint)) {
		[self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:YES];
	}
	[self touchEnd];
}
- (void)maskViewTap:(UILongPressGestureRecognizer *)longPress
{
	if (self.disable) {
		return;
	}
	switch (longPress.state) {
	  case UIGestureRecognizerStateBegan:
		{
			NSLog(@"UIGestureRecognizerStateBegan");
			[self touchBegan];
		}
			break;
		case UIGestureRecognizerStateChanged:
		{
			CGPoint nowPoint = [longPress locationInView:self];
			NSLog(@" x %f y %f",nowPoint.x,nowPoint.y);
		}
			break;
		case UIGestureRecognizerStateEnded:
		{
			CGPoint nowPoint = [longPress locationInView:self];
			if (CGRectContainsPoint(self.bounds, nowPoint)) {
    		[self.target performSelectorOnMainThread:self.action withObject:self waitUntilDone:YES];
			}
			
			NSLog(@"UIGestureRecognizerStateEnded");
			
			[self touchEnd];
		}
			break;
  default:
			break;
	}
}
- (void)touchEnd
{
	
	[UIView animateWithDuration:0.1 animations:^{
		CGAffineTransform transform = CGAffineTransformIdentity;
		CGAffineTransform scaleTransform = CGAffineTransformScale(transform, 1, 1);
		
		self.midImageView.transform = scaleTransform;
	}];
}
- (void)touchBegan
{

	[UIView animateWithDuration:0.1 animations:^{
		CGAffineTransform transform = CGAffineTransformIdentity;
		CGAffineTransform scaleTransform = CGAffineTransformScale(transform, 0.8, 0.8);
		
		self.midImageView.transform = scaleTransform;
	}];
}
- (void)addTarget:(id)target action:(SEL)action
{
	self.target =target;
	self.action = action;
}
- (void)scaleTopImage:(float)scale
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	
	CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale+1, scale+1);
	
	self.topImageView.transform = scaleTransform;
}
- (void)scaleTopImageNormal
{
	[UIView animateWithDuration:0.1 animations:^{
		CGAffineTransform transform = CGAffineTransformIdentity;
		CGAffineTransform scaleTransform = CGAffineTransformScale(transform, 1, 1);
		
		self.topImageView.transform = scaleTransform;
	}];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
