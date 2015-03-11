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
#define ACTION_MARGIN 120

#define ACTION_PROCESS_DIS 20

#define ACTION_MOVE_DISTANCE 300
typedef NS_ENUM(NSInteger, SwipeDirectType) {
	SwipeDirectTypeLeft,
	SwipeDirectTypeRight,
	SwipeDirectTypeTop,
	SwipeDirectTypeBottom,
};


typedef NS_ENUM(NSInteger,ActionType) {
	ActionTypeNone,
	ActionTypeHate,
	ActionTypeLike,
};

typedef NS_ENUM(NSInteger, SwipeViewStyle) {
	SwipeViewStyleHorizontal,
	SwipeViewStyleVertical,
};

@protocol GSSwipeViewDelegate;
@protocol GSSwipeViewDataSource;





#import "GSSwipeViewCell.h"
@interface GSSwipeView : UIView
- (instancetype)initWithFrame:(CGRect)frame style:(SwipeViewStyle)style;
@property (nonatomic, readonly) SwipeViewStyle           style;
@property (nonatomic,assign) id<GSSwipeViewDelegate> delegate;
@property (nonatomic,assign) id<GSSwipeViewDataSource> dataSource;
@property (nonatomic,assign) float headerHeight;

@property (nonatomic,assign,readonly) CGSize cellSize;
@property (nonatomic,strong) UIColor *cellColor;

- (void)reloadData;

- (void)registerCellClass:(Class)aClass;

- (void)beginUpdates;

- (void)endUpdates;

- (void)swipeLeftAction;
- (void)swipeRightAction;

@end
@protocol GSSwipeViewDelegate <NSObject>
@optional
- (void)GSSwipeViewBeginSwipe:(GSSwipeView *)swipeView;
- (void)GSSwipeViewEndSwipe:(GSSwipeView *)swipeView ;
- (void)GSSwipeViewTouchEnd:(GSSwipeView *)swipeView ;
- (void)GSSwipeView:(GSSwipeView *)swipeView withCell:(GSSwipeViewCell *)cell distanceProcess:(float)process withActionType:(ActionType)type;
- (void)GSSwipeView:(GSSwipeView *)swipeView recoverOriginal:(GSSwipeViewCell *)cell withIndex:(NSInteger )index;
- (void)GSSwipeView:(GSSwipeView *)swipeView willMoveTopCell:(GSSwipeViewCell *)cell withActionType:(ActionType)type;





@end

@protocol GSSwipeViewDataSource <NSObject>
@required

- (NSInteger)numberOfCellInSwipeView:(GSSwipeView *)swipeView;

- (void)GSSwipeView:(GSSwipeView *)swipeView cellInSwipeView:(GSSwipeViewCell *)cell cellInSwipeViewIndex:(NSInteger )index;

@optional


- (CGSize)cellSizeInSwipeView:(GSSwipeView *)swipeView ;

@end