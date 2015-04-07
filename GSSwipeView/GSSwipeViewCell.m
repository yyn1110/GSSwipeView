//
//  GSSwipeViewCell.m
//  tinder
//
//  Created by kuxing on 15/3/9.
//  Copyright (c) 2015年 yangyanan. All rights reserved.
//

#import "GSSwipeViewCell.h"
@interface GSSwipeViewCell ()


@end
@implementation GSSwipeViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    }
    return self;
}

@end
