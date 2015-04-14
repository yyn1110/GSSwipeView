//
//  GSButton.h
//  tinder
//
//  Created by kuxing on 15/3/10.
//  Copyright (c) 2015年 yangyanan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSButton : UIView
@property (nonatomic,assign)BOOL disable;
- (id)initWithFrame:(CGRect)frame
   withBackGroupImage:(UIImage *)backImg
	   withMidImage:(UIImage *)midImg
	   withTopImage:(UIImage *)topImage
	   withDisImage:(UIImage *)disImage;
- (void)addTarget:(id)target action:(SEL)action ;
- (void)scaleTopImage:(float)scale;
- (void)scaleTopImageNormal;

@end
