//
//  GSSwipeViewCell.h
//  tinder
//
//  Created by kuxing on 15/3/9.
//  Copyright (c) 2015年 yangyanan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,ActionType) {
	ActionTypeNone=-1,
	ActionTypeHate=0,
	ActionTypeLike=1,
};
@interface GSSwipeViewCell : UIView<UIDynamicItem>
@property (nonatomic,assign,readwrite) ActionType actionType;
@end
