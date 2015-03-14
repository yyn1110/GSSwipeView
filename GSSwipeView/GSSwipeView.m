//
//  GSSwipeView.m
//  tinder
//
//  Created by kuxing on 15/3/9.
//  Copyright (c) 2015年 yangyanan. All rights reserved.
//
#define ACTION_VIEW_CACHE_COUNT 4
#define SCALE_STRENGTH 4
#define SCALE_MAX .93
#define ROTATION_MAX 1
#define ROTATION_STRENGTH 320
#define ROTATION_ANGLE M_PI/8

#define Card_BY_W 12.0
#define Card_BY_H 4.0
#define Card_Y_PADDING 4.0

#define Card_MOVE_DIS 120

#define Card_MOVE_DIS_X Card_MOVE_DIS/4
static const float MAX_XSCALE_PERCENT = 5.0;



#import "GSSwipeView.h"
@interface GSSwipeView ()

@property (nonatomic,strong) NSMutableArray *cellCache;


@property (nonatomic,strong) NSMutableArray *beginPoints;
@property (nonatomic,assign) CGPoint viewBeginPoint;
@property (nonatomic,assign) CGPoint viewBeginCenter;

@property (nonatomic, readwrite) SwipeViewStyle           style;
@property (nonatomic,assign,readwrite) CGSize cellSize;

@property (nonatomic,strong)UIPanGestureRecognizer *panGesture;

@property (nonatomic,copy) NSString *className;

@end

@implementation GSSwipeView
- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {

		self.style = SwipeViewStyleHorizontal;

		self.beginPoints = [NSMutableArray array];
		self.cellCache = [NSMutableArray array];

	}
	return self;
}
- (instancetype)init
{
	self = [super init];
	if (self) {

		self.style = SwipeViewStyleHorizontal;

		self.beginPoints = [NSMutableArray array];
		self.cellCache = [NSMutableArray array];

	}
	return self;
}
- (instancetype)initWithFrame:(CGRect)frame style:(SwipeViewStyle)style
{
	self = [super initWithFrame:frame];
	if (self) {

		self.style = style;

		self.beginPoints = [NSMutableArray array];
		self.cellCache = [NSMutableArray array];


	}
	return self;
}

- (void)registerCell:(NSString *)aClassName
{
	

	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(cellSizeInSwipeView:)]) {
			self.cellSize  = [self.dataSource cellSizeInSwipeView:self];
	}
	self.className = aClassName;
	BOOL isSetCount = [self.dataSource respondsToSelector:@selector(numberOfCellInSwipeView:)];
	NSInteger numberOfData = 0;
	if (isSetCount) {
		numberOfData = [self.dataSource numberOfCellInSwipeView:self];
	}
	
	NSInteger count = MIN(ACTION_VIEW_CACHE_COUNT, numberOfData);
	for (int i=0; i<count; i++) {
		GSSwipeViewCell *cell= [[NSClassFromString(aClassName) alloc] initWithFrame:CGRectMake(0, 0, 	self.cellSize.width, 	self.cellSize.height)];
		NSAssert(cell != nil, @"cell is nil");
		[self.cellCache addObject:cell];
		cell.clipsToBounds = YES;
		
		cell.backgroundColor = [UIColor whiteColor];
		cell.layer.cornerRadius = 5.f;
		cell.layer.borderWidth = 1.f;
		cell.layer.borderColor = [UIColor colorWithRed:220.f/255.0 green:220/255.0 blue:220/255.0 alpha:1.0].CGColor;
		[self addSubview:cell];
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(GSSwipeView:cellInSwipeView:cellInSwipeViewIndex:)]) {
			[self.dataSource GSSwipeView:self cellInSwipeView:cell cellInSwipeViewIndex:i];
		}
		
	
	}
	
	
	if (self.cellCache.count > 0) {
		self.panGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
		GSSwipeViewCell *lastCell = self.cellCache.lastObject;
		[lastCell addGestureRecognizer:self.panGesture];
	}
	
	
}

- (void)reloadData
{
	[self.beginPoints removeAllObjects];
	if (self.cellCache.count <= ACTION_VIEW_CACHE_COUNT) {
		[self.cellCache removeAllObjects];
		NSAssert(self.className!=nil, @"please call registerCell first");
		[self registerCell:self.className];
	}
	NSInteger count =self.cellCache.count;
	for (NSInteger i=0; i< count; i++) {
		GSSwipeViewCell *cell = self.cellCache[i];
		int idx =count-i-1;
		if (count >2) {
			idx = MIN(idx,2);
		}
		
		int m = (int)(idx * Card_Y_PADDING);
		cell.frame = CGRectMake(0, 0, self.cellSize.width, self.cellSize.height);
		cell.center = CGPointMake(self.center.x, self.center.y+m-count*Card_Y_PADDING-64);
		cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, [self getScaleFactor:idx withDistance:0], 1);
		[self.beginPoints addObject:[NSValue valueWithCGPoint:cell.center]];
	}
	
}

- (void)panGesture:(UIPanGestureRecognizer *)longPress
{
	GSSwipeViewCell *cell = (GSSwipeViewCell *)longPress.view;

	CGPoint nowPoint = [longPress locationInView:self];
	switch (longPress.state) {
 		 case UIGestureRecognizerStateBegan:
		{
			self.viewBeginPoint = nowPoint;
			self.viewBeginCenter = cell.center;
		}
			break;
		case UIGestureRecognizerStateChanged:
		{
			
			float x2 =nowPoint.x - self.viewBeginPoint.x+self.viewBeginCenter.x;
			float y2 = nowPoint.y - self.viewBeginPoint.y + self.viewBeginCenter.y;
			cell.center = CGPointMake(x2, y2);
			float X =nowPoint.x - self.viewBeginPoint.x;
			float sca =sqrtf( powf((X), 2)+powf(nowPoint.y - self.viewBeginPoint.y, 2))/Card_MOVE_DIS;
			
			if (sca<=1) {
			    [self updateChildTransfrom:sca];
				if (X <-Card_MOVE_DIS_X) {
					if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
						[self.delegate GSSwipeView:self withCell:cell distanceProcess:sca withActionType:ActionTypeHate];
					}
				}else if (X  > Card_MOVE_DIS_X){
					if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
						[self.delegate GSSwipeView:self withCell:cell distanceProcess:sca withActionType:ActionTypeLike];
					}
				}else{
					if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
						[self.delegate GSSwipeView:self withCell:cell distanceProcess:sca withActionType:ActionTypeNone];
					}
				}
				
				
			}
		}
			break;
		case UIGestureRecognizerStateEnded: {
			CGPoint nowPoint = [longPress translationInView:self];
			float sca =sqrtf( powf((nowPoint.x - self.viewBeginPoint.x), 2)+powf(nowPoint.y - self.viewBeginPoint.y, 2))/Card_MOVE_DIS;
			[self afterSwipeAction:nowPoint withNowView:cell withDstance:sca];

			break;
		};
		case UIGestureRecognizerStatePossible:break;
		case UIGestureRecognizerStateCancelled:break;
		case UIGestureRecognizerStateFailed:break;
  default:
			break;
	}
}

- (void)swipeLeftAction
{
	if (self.cellCache.count >0) {
		[self leftAction:CGPointMake(0, CGRectGetHeight(self.frame)/2) withNowView:self.cellCache.lastObject];
	}
	
}
- (void)swipeRightAction
{
	if (self.cellCache.count >0) {
		[self rightAction:CGPointMake(0, CGRectGetHeight(self.frame)/2) withNowView:self.cellCache.lastObject];
	}
}

- (void)afterSwipeAction:(CGPoint)nowCenter withNowView:(GSSwipeViewCell *)cell withDstance:(float)distance
{
	
	float x = 0;

	if (self.style == SwipeViewStyleHorizontal) {
		x =nowCenter.x;
	}else if (self.style == SwipeViewStyleVertical){
		x =nowCenter.y;
	}

	if (x > ACTION_MARGIN) {
		[self rightAction:nowCenter withNowView:cell];
	} else if (x < -ACTION_MARGIN) {
		[self leftAction:nowCenter withNowView:cell];
	} else {
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
			[self.delegate GSSwipeView:self withCell:cell  distanceProcess:0 withActionType:ActionTypeNone];
		}

		CGPoint point = [(NSValue *)self.beginPoints.lastObject CGPointValue];
		[UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.7 options:0 animations:^{
			cell.center = point;
		} completion:^(BOOL finished) {
			
		}];
		
		
	[self updateChildTransfrom:0];
		
	}
}
-(void)rightAction:(CGPoint)nowPoint withNowView:(GSSwipeViewCell *)cell
{
	

	CGPoint finishPoint = CGPointMake(500, nowPoint.y);
	
	[UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
		cell.center = finishPoint;
	} completion:^(BOOL finished) {

		[self recoverView:cell];
		
	}];
	
	
	
}

-(void)leftAction:(CGPoint)nowPoint withNowView:(GSSwipeViewCell *)cell
{

	CGPoint finishPoint = CGPointMake(-500, nowPoint.y);
	[UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
		cell.center = finishPoint;
	} completion:^(BOOL finished) {

		[self recoverView:cell];
		
	}];
	
}
- (void)recoverView:(GSSwipeViewCell *)cell
{
	
	
	NSInteger numberOfData = [self.dataSource numberOfCellInSwipeView:self];
	if (self.cellCache.count > numberOfData) {
		[self.cellCache removeObject:cell];
		[cell removeFromSuperview];
		[cell removeGestureRecognizer:self.panGesture];
		GSSwipeViewCell *lastCell = self.cellCache.lastObject;
		[lastCell addGestureRecognizer:self.panGesture];
	}else{
		[cell removeGestureRecognizer:self.panGesture];
		GSSwipeViewCell *firstCell = self.cellCache.firstObject;
		NSValue *firstValue = self.beginPoints.firstObject;
		[self.cellCache removeObject:cell];
		[self.cellCache insertObject:cell atIndex:0];
		[self sendSubviewToBack:cell];
		
		cell.transform = firstCell.transform;
		cell.center = [firstValue CGPointValue];
		GSSwipeViewCell *lastCell = self.cellCache.lastObject;
		[lastCell addGestureRecognizer:self.panGesture];
	}
	
	for (NSInteger i = 0;i<self.cellCache.count;i++) {
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(GSSwipeView:cellInSwipeView:cellInSwipeViewIndex:)]) {
			[self.dataSource GSSwipeView:self cellInSwipeView:cell cellInSwipeViewIndex:i];
		}
	}
	
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeViewEndSwipe:)]) {
		[self.delegate GSSwipeViewEndSwipe:self];
	}

}

- (void)updateChildTransfrom:(float)distance
{
	int count = self.cellCache.count;
	NSInteger j = 0;
	NSInteger k = 1;
	if (count>2) {
		j = 1;
	}else{
		j=0;
	}
	if (count == 3) {
		k = 0;
	}
	
	for (NSInteger i=j; i<count-k; i++) {
		GSSwipeViewCell *cell = self.cellCache[i];
		int idx =count-i-j;
		NSValue *value = self.beginPoints[i];
		cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, [self getScaleFactor:idx withDistance:distance], 1);
		
		cell.center = CGPointMake(cell.center.x, [value CGPointValue].y+[self transY:distance]);
		
	}
	
}
- (float)getScaleFactor:(int)index withDistance:(float)distance
{
	return (100.0f - index*MAX_XSCALE_PERCENT + distance*MAX_XSCALE_PERCENT )/100.0f;
}
- (float)transY:(float)distance
{
	return -1 * Card_Y_PADDING *distance;
}
@end
