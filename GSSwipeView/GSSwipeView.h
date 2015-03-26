//
//  GSSwipeView.h
//  tinder
//
//  Created by kuxing on 15/3/9.
//  Copyright (c) 2015年 yangyanan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "GSButton.h"
#define ACTION_MARGIN 	[UIScreen mainScreen].bounds.size.width/4

#define ACTION_PROCESS_DIS 20

#define ACTION_MOVE_DISTANCE 12
#define ACTION_MOVE_X_DISTANCE 300
typedef NS_ENUM(NSInteger, SwipeDirectType) {
	SwipeDirectTypeLeft,
	SwipeDirectTypeRight,
	SwipeDirectTypeTop,
	SwipeDirectTypeBottom,
};




typedef NS_ENUM(NSInteger, SwipeViewStyle) {
	SwipeViewStyleHorizontal,
	SwipeViewStyleVertical,
};

@protocol GSSwipeViewDelegate;
@protocol GSSwipeViewDataSource;





#import "GSSwipeViewCell.h"
@interface GSSwipeView : UIView
- (instancetype)initWithFrame:(CGRect)frame style:(SwipeViewStyle)style withSuperView:(UIView *)superView;
@property (nonatomic, readonly) SwipeViewStyle           style;
@property (nonatomic,assign) id<GSSwipeViewDelegate> delegate;
@property (nonatomic,assign) id<GSSwipeViewDataSource> dataSource;
@property (nonatomic,assign) float headerHeight;

@property (nonatomic,assign,readonly) CGSize cellSize;

@property (nonatomic,strong) UIColor *cellColor;

- (void)reloadData;
- (void)swipeLeftAction;
- (void)swipeRightAction;


- (void)registerCell:(Class )aClass;

@end
@protocol GSSwipeViewDelegate <NSObject>
@optional
- (void)GSSwipeViewEndSwipe:(GSSwipeView *)swipeView withCell:(GSSwipeViewCell *)cell;
- (void)GSSwipeView:(GSSwipeView *)swipeView withCell:(GSSwipeViewCell *)cell distanceProcess:(float)process withActionType:(ActionType)type;
- (void)GSSwipeView:(GSSwipeView *)swipeView withSelectCell:(GSSwipeViewCell *)cell;
- (void)GSSwipeView:(GSSwipeView *)swipeView startLoadingWithCount:(NSInteger)dataCount;
- (void)GSSwipeViewEndLoadingMoreData:(GSSwipeView *)swipeView;
@end

@protocol GSSwipeViewDataSource <NSObject>
@required
- (NSInteger)numberOfCellInSwipeView:(GSSwipeView *)swipeView;
- (void)GSSwipeView:(GSSwipeView *)swipeView cellInSwipeView:(GSSwipeViewCell *)cell cellInSwipeViewIndex:(NSInteger)index;
- (CGSize)cellSizeInSwipeView:(GSSwipeView *)swipeView;
@end