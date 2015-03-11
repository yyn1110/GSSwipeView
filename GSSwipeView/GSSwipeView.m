//
//  GSSwipeView.m
//  tinder
//
//  Created by kuxing on 15/3/9.
//  Copyright (c) 2015年 yangyanan. All rights reserved.
//
#define ACTION_VIEW_CACHE_COUNT 5
#define SCALE_STRENGTH 4
#define SCALE_MAX .93
#define ROTATION_MAX 1
#define ROTATION_STRENGTH 320
#define ROTATION_ANGLE M_PI/8

#define Card_BY_W 8.0
#define Card_BY_H 4.0
#define Card_Y_PADDING 13.0





#import "GSSwipeView.h"
@interface GSSwipeView ()
@property (nonatomic,strong) NSMutableArray *viewDataSource;
@property (nonatomic,strong) NSMutableArray *originalCenterCache;
@property (nonatomic, readwrite) SwipeViewStyle           style;
@property (nonatomic,assign,readwrite) CGSize cellSize;
@property (nonatomic,assign) CGPoint originalPoint;
@property (nonatomic,strong)UIPanGestureRecognizer *pressGesture;
@property (nonatomic,assign) NSInteger cursor;

@property (nonatomic,assign) Class cellClass;

@property (nonatomic,assign) BOOL isAnimating;

@end

@implementation GSSwipeView
- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.style = SwipeViewStyleHorizontal;
		self.viewDataSource = [NSMutableArray array];
		self.originalCenterCache = [NSMutableArray array];

	}
	return self;
}
- (instancetype)init
{
	self = [super init];
	if (self) {
		self.style = SwipeViewStyleHorizontal;
		self.viewDataSource = [NSMutableArray array];
		self.originalCenterCache = [NSMutableArray array];
	}
	return self;
}
- (instancetype)initWithFrame:(CGRect)frame style:(SwipeViewStyle)style
{
	self = [super initWithFrame:frame];
	if (self) {
		self.style = style;
		self.viewDataSource = [NSMutableArray array];
		self.originalCenterCache = [NSMutableArray array];

	}
	return self;
}
- (void)registerCellClass:(Class)aClass
{
	self.cellClass = aClass;
	BOOL isSetSize = [self.dataSource respondsToSelector:@selector(cellSizeInSwipeView:)];
	if (isSetSize) {
	self.cellSize = [self.dataSource cellSizeInSwipeView:self];
	}
	[self.originalCenterCache removeAllObjects];
	float w = CGRectGetWidth(self.bounds);
	float h = CGRectGetHeight(self.bounds);
	for (int i=0; i<ACTION_VIEW_CACHE_COUNT; i++) {
		float cellW =self.cellSize.width-(ACTION_VIEW_CACHE_COUNT-i)*Card_BY_W;
		float cellH =self.cellSize.height;
		CGPoint center = CGPointMake(w/2, h/2-i*Card_BY_H+(ACTION_VIEW_CACHE_COUNT-1)*Card_BY_H);
		GSSwipeViewCell *cell = [[aClass alloc] initWithFrame:CGRectMake(center.x-cellW/2, center.y-cellH/2, cellW, cellH)];

		[self.viewDataSource insertObject:cell atIndex:0];
		cell.clipsToBounds = YES;
		
		cell.backgroundColor = [UIColor whiteColor];
		cell.layer.cornerRadius = 5.f;
		cell.layer.borderWidth = 1.f;
		cell.layer.borderColor = [UIColor colorWithRed:220.f/255.0 green:220/255.0 blue:220/255.0 alpha:1.0].CGColor;

		[self addSubview:cell];
//		cell.center = self.center;
		UIPanGestureRecognizer *pressGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
		[cell addGestureRecognizer:pressGesture];
		
		NSLog(@"center %@  frame %@ w %f h %f",NSStringFromCGPoint(center),NSStringFromCGRect(cell.frame),w ,h );
//		[self.originalCenterCache addObject:[NSValue valueWithCGRect:cell.frame]];
		[self.originalCenterCache insertObject:[NSValue valueWithCGRect:cell.frame] atIndex:0];
		
	}

	
	
	
}
- (void)beginUpdates
{

}

- (void)endUpdates
{

}

- (void)reloadData
{
	
	self.cursor = 0;

	NSInteger count = self.viewDataSource.count;

	self.cellSize = CGSizeZero;
	BOOL isSetSize = [self.dataSource respondsToSelector:@selector(cellSizeInSwipeView:)];
	BOOL isSetCount = [self.dataSource respondsToSelector:@selector(numberOfCellInSwipeView:)];
	if (isSetSize) {
		self.cellSize = [self.dataSource cellSizeInSwipeView:self];

	}else{
	}
	
	
	
	NSInteger numberOfData = 0;
	NSInteger processCount = 0;
	if (self.dataSource  && isSetCount) {
		numberOfData = [self.dataSource numberOfCellInSwipeView:self];
		processCount = (numberOfData>ACTION_VIEW_CACHE_COUNT)?ACTION_VIEW_CACHE_COUNT:numberOfData;
		for (NSInteger i=0; i<processCount; i++) {
			GSSwipeViewCell *cell = self.viewDataSource[i];
			[self.dataSource GSSwipeView:self cellInSwipeView:cell cellInSwipeViewIndex:i];
		}
		
		
	}
	
	for (NSInteger i =0; i <count;i++ ) {
		
		GSSwipeViewCell *cell = self.viewDataSource[i];
		if (i>=processCount) {
			cell.hidden = YES;
		}
	}
	
//	[UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//		for (NSInteger i=0; i<self.originalCenterCache.count; i++) {
//			NSValue *value = self.originalCenterCache[i];
//			GSSwipeViewCell *cell = self.viewDataSource[i];
//			cell.frame =[value CGRectValue];
//		}
//	} completion:^(BOOL finished) {
//		
//	}];
	
}

- (void)panGesture:(UIPanGestureRecognizer *)longPress
{
	GSSwipeViewCell *cell = (GSSwipeViewCell *)longPress.view;
	if ([self.viewDataSource indexOfObject:cell] !=0) {
		return;
	}
	CGPoint nowPoint = [longPress translationInView:self];

	switch (longPress.state) {
 		 case UIGestureRecognizerStateBegan:
		{

			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeViewBeginSwipe:)]) {
			    [self.delegate GSSwipeViewBeginSwipe:self];
			}
			
			self.originalPoint = cell.center;

			if (self.dataSource && [self.dataSource respondsToSelector:@selector(GSSwipeView:cellInSwipeView:cellInSwipeViewIndex:)]) {
				NSInteger numberOfData = [self.dataSource numberOfCellInSwipeView:self];
				NSInteger processCount = (numberOfData>ACTION_VIEW_CACHE_COUNT)?ACTION_VIEW_CACHE_COUNT:numberOfData;
				for (NSInteger i=0; i<processCount; i++) {
					GSSwipeViewCell *processCell = self.viewDataSource[i];
					[self.dataSource GSSwipeView:self cellInSwipeView:processCell cellInSwipeViewIndex:i];
				}
				
			}
			
			

			
		}
			break;
		case UIGestureRecognizerStateChanged:
		{
			
			
			
			cell.center = CGPointMake(self.originalPoint.x + nowPoint.x, self.originalPoint.y + nowPoint.y);

			float X = 0;
			if (self.style == SwipeViewStyleHorizontal) {
			    X=cell.center.x-self.originalPoint.x;
			}else if (self.style == SwipeViewStyleVertical){
				X=cell.center.y-self.originalPoint.y;
			}
			
			float sca = fabsf(X)/ACTION_MOVE_DISTANCE;
			
			
			if (sca <=1) {
				if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell: distanceProcess:withActionType:)]) {
					float x = cell.center.x;
					
					if (self.style == SwipeViewStyleHorizontal) {
						x =cell.center.x;
					}else if (self.style == SwipeViewStyleVertical){
						x =cell.center.y;
					}
					if (X >ACTION_PROCESS_DIS) {
						[self.delegate GSSwipeView:self withCell:cell  distanceProcess:sca withActionType:ActionTypeLike];
					}else if (X <-ACTION_PROCESS_DIS){
						[self.delegate GSSwipeView:self withCell:cell  distanceProcess:sca withActionType:ActionTypeHate];
					}else{
					
						[self.delegate GSSwipeView:self withCell:cell  distanceProcess:0 withActionType:ActionTypeNone];
					}
					
				}
			}

			CGFloat rotationStrength = MIN(nowPoint.x / ROTATION_STRENGTH, ROTATION_MAX);
			

			CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
			

			CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
			

			cell.center = CGPointMake(self.originalPoint.x + nowPoint.x, self.originalPoint.y + nowPoint.y);
			

			CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
//			CGAffineTransform transform = CGAffineTransformIdentity;
			

//			CGAffineTransform scaleTransform = CGAffineTransformScale(transform, 1, 1);
			
			cell.transform = transform;

			
		}
			break;
		
		case UIGestureRecognizerStateEnded: {

			CGPoint nowPoint = [longPress translationInView:self];
			[self afterSwipeAction:nowPoint withNowView:cell];
			self.isAnimating = NO;
			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeViewTouchEnd:)]) {
			    [self.delegate GSSwipeViewTouchEnd:self];
			}
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
	
	if (self.isAnimating) {
		return;
	}
	
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(GSSwipeView:cellInSwipeView:cellInSwipeViewIndex:)]) {
		NSInteger numberOfData = [self.dataSource numberOfCellInSwipeView:self];
		NSInteger processCount = (numberOfData>ACTION_VIEW_CACHE_COUNT)?ACTION_VIEW_CACHE_COUNT:numberOfData;
		for (NSInteger i=0; i<processCount; i++) {
			GSSwipeViewCell *processCell = self.viewDataSource[i];
			[self.dataSource GSSwipeView:self cellInSwipeView:processCell cellInSwipeViewIndex:i];
		}
		
	}

	
	GSSwipeViewCell *topCell =self.viewDataSource.firstObject;
	CGAffineTransform transform = CGAffineTransformMakeRotation(-0.14);
	CGAffineTransform scaleTransform = CGAffineTransformScale(transform, 0.93, 0.93);
	topCell.transform = scaleTransform;
	[self afterSwipeAction:CGPointMake(-ACTION_MARGIN-10, CGRectGetMinY(self.frame)) withNowView:topCell];
}
- (void)swipeRightAction
{
	if (self.isAnimating) {
		return;
	}
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(GSSwipeView:cellInSwipeView:cellInSwipeViewIndex:)]) {
		NSInteger numberOfData = [self.dataSource numberOfCellInSwipeView:self];
		NSInteger processCount = (numberOfData>ACTION_VIEW_CACHE_COUNT)?ACTION_VIEW_CACHE_COUNT:numberOfData;
		for (NSInteger i=0; i<processCount; i++) {
			GSSwipeViewCell *processCell = self.viewDataSource[i];
			[self.dataSource GSSwipeView:self cellInSwipeView:processCell cellInSwipeViewIndex:i];
		}
		
	}
	GSSwipeViewCell *topCell =self.viewDataSource.firstObject;
	CGAffineTransform transform = CGAffineTransformMakeRotation(0.14);
	CGAffineTransform scaleTransform = CGAffineTransformScale(transform, 0.93, 0.93);
	topCell.transform = scaleTransform;
	[self afterSwipeAction:CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame)) withNowView:topCell];
}

- (void)afterSwipeAction:(CGPoint)nowCenter withNowView:(GSSwipeViewCell *)cell
{
	
	self.isAnimating = YES;
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
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:recoverOriginal:withIndex:)]) {
			[self.delegate GSSwipeView:self recoverOriginal:cell withIndex:0];
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
			[self.delegate GSSwipeView:self withCell:cell  distanceProcess:0 withActionType:ActionTypeNone];
		}
		
		[UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
			cell.center = self.originalPoint;
			cell.transform = CGAffineTransformMakeRotation(0);
			for (NSInteger i=0; i<self.viewDataSource.count; i++) {
				GSSwipeViewCell *cell = self.viewDataSource[i];
				NSValue *value =self.originalCenterCache[i];
				cell.frame =[value CGRectValue];
			}
		} completion:^(BOOL finished) {
			
		}];
	}
}
-(void)rightAction:(CGPoint)nowPoint withNowView:(GSSwipeViewCell *)cell
{
	
	
	if (self.style == SwipeViewStyleHorizontal) {
		CGPoint finishPoint = CGPointMake(500, 2*nowPoint.y +self.originalPoint.y);
		[UIView animateWithDuration:0.25
						 animations:^{
							 cell.center = finishPoint;
							 cell.transform = CGAffineTransformMakeRotation(0);
						 }completion:^(BOOL complete){
							[self animationEnd:cell withDirectType:SwipeDirectTypeRight];
						 }];
	}else if (self.style == SwipeViewStyleVertical){
	
		CGPoint finishPoint = CGPointMake(2*nowPoint.x +self.originalPoint.x, CGRectGetMaxY(self.frame)+self.cellSize.height+10);
		[UIView animateWithDuration:0.25
						 animations:^{
							 cell.center = finishPoint;
							 cell.transform = CGAffineTransformMakeRotation(0);
						 }completion:^(BOOL complete){
							[self animationEnd:cell withDirectType:SwipeDirectTypeBottom];
						 }];
	}
	
	
}

-(void)leftAction:(CGPoint)nowPoint withNowView:(GSSwipeViewCell *)cell
{
	
	
	if (self.style == SwipeViewStyleHorizontal) {
		CGPoint finishPoint = CGPointMake(-500, 2*nowPoint.y +self.originalPoint.y);
		[UIView animateWithDuration:0.25
					 animations:^{
						 cell.center = finishPoint;
						 cell.transform = CGAffineTransformMakeRotation(0);
					 }completion:^(BOOL complete){
						[self animationEnd:cell withDirectType:SwipeDirectTypeLeft];
					 }];
	}else if (self.style == SwipeViewStyleVertical){
		
		
		
		CGPoint finishPoint = CGPointMake(2*nowPoint.x +self.originalPoint.x, -self.cellSize.height-10);
		[UIView animateWithDuration:0.25
						 animations:^{
							 cell.center = finishPoint;
							 cell.transform = CGAffineTransformMakeRotation(0);
						 }completion:^(BOOL complete){
							 [self animationEnd:cell withDirectType:SwipeDirectTypeTop];
						 }];
	}
}
- (void)animationEnd:(GSSwipeViewCell *)cell withDirectType:(SwipeDirectType)type
{
	self.cursor++;
	NSInteger numberOfData = [self.dataSource numberOfCellInSwipeView:self];
	GSSwipeViewCell *lastCell = self.viewDataSource.lastObject;
	cell.frame = lastCell.frame;
	[self.viewDataSource removeObject:cell];
	
	[self.viewDataSource addObject:cell];
	[self sendSubviewToBack:cell];
	if (numberOfData > ACTION_VIEW_CACHE_COUNT) {
		
		cell.hidden = NO;
		
	}else{
		cell.hidden = YES;
	
	}
	
	[UIView animateWithDuration:0.1 animations:^{
		for (NSInteger i=0; i<self.viewDataSource.count; i++) {
			GSSwipeViewCell *cell = self.viewDataSource[i];
			NSValue *value =self.originalCenterCache[i];
			cell.frame =[value CGRectValue];
		}
	}];
	
	self.isAnimating = NO;
	if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeViewEndSwipe:)]) {
		[self.delegate GSSwipeViewEndSwipe:self];
	}
	if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
		[self.delegate GSSwipeView:self withCell:cell  distanceProcess:0 withActionType:ActionTypeNone];
	}
	
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
