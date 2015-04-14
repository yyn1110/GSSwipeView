//
//  GSSwipeView.m
//  tinder
//
//  Created by kuxing on 15/3/9.
//  Copyright (c) 2015年 yangyanan. All rights reserved.
//

#define MAX_DATA_CACHE 4

#define ACTION_VIEW_CACHE_COUNT 4
#define SCALE_STRENGTH 4
#define SCALE_MAX .93
#define ROTATION_MAX 1
#define ROTATION_STRENGTH 320
#define ROTATION_ANGLE M_PI/8

#define Card_BY_W 12.0
#define Card_BY_H 4.0
#define Card_Y_PADDING 5.0

#define Card_MOVE_DIS 120

#define Card_MOVE_DIS_X Card_MOVE_DIS/3
#define Card_MOVE_SPEED 1.2
#define Card_Delay_Time 0.35
#define Card_Out_Time 0.3


#define SPEED_6P 2

static const float MAX_XSCALE_PERCENT = 5.0;
#define HEIGHT_TOP_PADDING 12


#import "GSSwipeView.h"

#import "GSButton.h"

@interface GSSwipeView ()<UIDynamicItem,UIGestureRecognizerDelegate>
@property (nonatomic,assign) BOOL draggingView;
@property (nonatomic,strong) NSMutableArray *cellCache;
@property (nonatomic,strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic,strong) NSMutableArray *beginPoints;
@property (nonatomic,strong) NSMutableArray *beginTransForms;
@property (nonatomic,assign) CGPoint viewBeginPoint;
@property (nonatomic,assign) CGPoint viewBeginCenter;
@property (nonatomic, readwrite) SwipeViewStyle           style;
@property (nonatomic,assign,readwrite) CGSize cellSize;
@property (nonatomic,copy) NSString *className;
@property (nonatomic,strong) UIPushBehavior *pushBehavior;

@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic,strong) UIPanGestureRecognizer *disPanGesture;


@property (nonatomic,assign) int index;

@property (nonatomic,assign) CGPoint endVectorPoint;



@end

@implementation GSSwipeView
{
    UIOffset offset;
}

- (instancetype)initWithFrame:(CGRect)frame style:(SwipeViewStyle)style withSuperView:(UIView *)superView
{
	self = [super initWithFrame:frame];
	if (self) {

		self.style = style;

		self.beginPoints = [NSMutableArray array];
		self.beginTransForms = [NSMutableArray array];
		self.cellCache = [NSMutableArray array];

		self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
		self.index = ACTION_VIEW_CACHE_COUNT-1;
		UIPanGestureRecognizer *panGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
				self.panGesture = panGesture;
		panGesture.maximumNumberOfTouches=1;
		panGesture.minimumNumberOfTouches=1;
		
		
//		panGesture.delegate = self;
		[self addGestureRecognizer:panGesture];
		
		UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
		self.tapGesture = tapGesture;
		tapGesture.numberOfTapsRequired =1;
		tapGesture.numberOfTouchesRequired=1;
		tapGesture.delegate = self;
		[self addGestureRecognizer:tapGesture];
	}
	return self;
}


- (void)tapGesture:(UITapGestureRecognizer *)tap
{
	if (self.disable) {
		return;
	}
	GSSwipeViewCell *topCell = self.cellCache.lastObject;
		CGPoint point = [tap locationInView:self];
		if (CGRectContainsPoint(topCell.frame, point)) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withSelectCell:)]) {
				[self.delegate GSSwipeView:self withSelectCell:topCell];
			}
		}
}
- (void)registerCell:(Class )aClass
{

	self.className = NSStringFromClass(aClass);
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(cellSizeInSwipeView:)]) {
		self.cellSize  = [self.dataSource cellSizeInSwipeView:self];
	}
	
}



- (void)showAllViews
{
	
	
}
- (void)reloadData
{
	
	
	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
	
	
	
	[self.cellCache removeAllObjects];
	[self.beginPoints removeAllObjects];
	[self.beginTransForms removeAllObjects];
	
	NSInteger numberCount = [self.dataSource numberOfCellInSwipeView:self];
	
	
	
	int minCount = MIN(numberCount, ACTION_VIEW_CACHE_COUNT);
	
	
	for (int i=0;i<minCount;i++) {
		GSSwipeViewCell *cell= [[NSClassFromString(self.className) alloc] initWithFrame:CGRectMake(0, 0, self.cellSize.width, self.cellSize.height)];
		[self.cellCache addObject:cell];
		NSAssert(cell != nil, @"cell is nil");

		
		cell.clipsToBounds = YES;
		cell.backgroundColor = [UIColor whiteColor];
		cell.layer.cornerRadius = 13.f;
		cell.layer.borderWidth = 1.f;
		cell.layer.borderColor = [UIColor colorWithRed:220.f/255.0 green:220/255.0 blue:220/255.0 alpha:1.0].CGColor;
		
		
		
		NSInteger idx =minCount-i-1;
		if (minCount >2) {
			idx = MIN(idx,2);
		}
		int m = (int)(idx * Card_Y_PADDING);
		
		cell.frame = CGRectMake(0, 0, self.cellSize.width, self.cellSize.height);
		CGPoint center = CGPointMake(self.center.x, HEIGHT_TOP_PADDING+CGRectGetHeight(cell.frame)/2+m);
		//
		cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, [self getScaleFactor:idx withDistance:0], 1);
		cell.center = center;
		
		[self.beginTransForms addObject:[NSValue valueWithCGAffineTransform:cell.transform ]];
		[self.beginPoints addObject:[NSValue valueWithCGPoint:center]];
		
		
		[self addSubview:cell];
		

		
		
	}
	

	for (int i=0; i<minCount; i++) {
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(GSSwipeView:cellInSwipeView:cellInSwipeViewIndex:)]) {
			GSSwipeViewCell *cell = self.cellCache[minCount -1-i];
			[self.dataSource GSSwipeView:self cellInSwipeView:cell cellInSwipeViewIndex:i];
		}
	}
}
- (void)setDisable:(BOOL)disable
{
	_disable = disable;
	if (disable) {
		[self removeGestureRecognizer:self.tapGesture];
		[self removeGestureRecognizer:self.panGesture];
	}else{
		[self addGestureRecognizer:self.tapGesture];
		[self addGestureRecognizer:self.panGesture];
	}
}
- (void)hateButtonClick:(GSButton *)button
{
	[self swipeLeftAction];
}

- (void)panGesture:(UIPanGestureRecognizer *)longPress
{
	
	if (self.disable) {
		return;
	}
	if (self.cellCache.count ==0)
    {
		return;
	}
	
	
	GSSwipeViewCell *cell = (GSSwipeViewCell *)self.cellCache.lastObject;
	CGPoint nowPoint = [longPress locationInView:self];
    
//	if (!CGRectContainsPoint(cell.frame, nowPoint))
//    {
//		return ;
//	}
	
	if (longPress.state == UIGestureRecognizerStateBegan )
    {
        NSLog(@"begin");
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeViewTouchBegin:)])
        {
			[self.delegate GSSwipeViewTouchBegin:self];
		}
		
	

		offset = UIOffsetZero;
		if (CGRectContainsPoint(CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height/2), nowPoint))
        {
			offset = UIOffsetMake(0, -10);
		}else
        {
			offset = UIOffsetMake(0, 10);
		}
        
		self.viewBeginPoint = nowPoint;
		self.viewBeginCenter = cell.center;
		_draggingView = YES;
		[self.animator removeAllBehaviors];
		UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:cell offsetFromCenter:offset attachedToAnchor:CGPointMake(cell.center.x, cell.center.y+offset.vertical)];
        attachmentBehavior.damping = 0.0;
		[self.animator addBehavior:attachmentBehavior];
		self.attachmentBehavior = attachmentBehavior;
		__weak GSSwipeView *weakSelf = self;
        
		[attachmentBehavior setAction:^{
			GSSwipeViewCell *cell =(GSSwipeViewCell *)(weakSelf.attachmentBehavior.items[0]);
			[weakSelf updateLocation:cell.center withBeginPoint:weakSelf.viewBeginCenter withCell:cell];
		}];
        
	} else if (longPress.state == UIGestureRecognizerStateChanged )
    {
        NSLog(@"change");
		float x2 =nowPoint.x - self.viewBeginPoint.x+self.viewBeginCenter.x;
		float y2 = nowPoint.y - self.viewBeginPoint.y + self.viewBeginCenter.y+offset.vertical;
		CGPoint center =CGPointMake(x2, y2);
		[self.attachmentBehavior setAnchorPoint:center];
		float X =nowPoint.x - self.viewBeginPoint.x;
		float x_sca = fabs(X)*2/Card_MOVE_DIS_X;
        
		if (X <-Card_MOVE_DIS_X)
        {
			cell.actionType =ActionTypeHate;
			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)] && x_sca <=1)
            {
				[self.delegate GSSwipeView:self withCell:cell distanceProcess:x_sca withActionType:ActionTypeHate];
			}
		}else if (X  > Card_MOVE_DIS_X)
        {

			cell.actionType =ActionTypeLike;
			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)] && x_sca <=1)
            {
				[self.delegate GSSwipeView:self withCell:cell distanceProcess:x_sca withActionType:ActionTypeLike];
			}
		}else
        {
			cell.actionType =ActionTypeNone;
			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)] && x_sca <=1)
            {
				[self.delegate GSSwipeView:self withCell:cell distanceProcess:x_sca withActionType:ActionTypeNone];
			}
		}
	}else if (longPress.state == UIGestureRecognizerStateEnded )
    {
        NSLog(@"End");
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeViewTouchEnd:)])
        {
			[self.delegate GSSwipeViewTouchEnd:self];
		}
		
		float sca =sqrtf( powf((nowPoint.x - self.viewBeginPoint.x), 2)+powf(nowPoint.y - self.viewBeginPoint.y, 2))/Card_MOVE_DIS;
		float x2 =nowPoint.x - self.viewBeginPoint.x+self.viewBeginCenter.x;
		float y2 = nowPoint.y - self.viewBeginPoint.y + self.viewBeginCenter.y;

		[self.animator removeAllBehaviors];
		self.endVectorPoint = nowPoint;
	
		[self afterSwipeAction:CGPointMake(x2, y2)
				   withNowCell:cell
				   withDstance:sca needUpdate:NO];
		
		
	
	}else{
		[self.animator removeAllBehaviors];
		[self afterSwipeAction:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
				   withNowCell:cell
				   withDstance:1 needUpdate:NO];
	}
	
}



- (void)swipeLeftAction
{
	
	
	[self leftActionWithFrom:NO];
}
- (void)leftActionWithFrom:(BOOL)fromGeture
{
	
	[self.animator removeAllBehaviors];
	GSSwipeViewCell *cell = self.cellCache.lastObject;
	if (fromGeture) {
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
			[self.delegate GSSwipeView:self withCell:cell distanceProcess:1 withActionType:ActionTypeHate];
		}
		CGPoint center  =cell.center;
		[UIView animateWithDuration:Card_Out_Time delay:0 options:0 animations:^{
			cell.center = CGPointMake(-2*CGRectGetWidth(self.frame), center.y);
//			cell.transform = CGAffineTransformMakeRotation(M_PI/180 *20);
			[self updateChildTransfrom:1];
		} completion:^(BOOL finished) {
			
			[self endAnimation:ActionTypeHate withCell:cell];
			
		}];
		
		
		
		
	}else{
		
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
			[self.delegate GSSwipeView:self withCell:cell distanceProcess:1 withActionType:ActionTypeHate];
		}
		CGPoint center  =cell.center;
		[UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
			cell.center = CGPointMake(center.x+10, center.y);
			
		} completion:^(BOOL finished) {
			
			[UIView animateWithDuration:Card_Out_Time delay:0 options:0 animations:^{
				cell.center = CGPointMake(-2*CGRectGetWidth(self.frame), center.y);
				cell.transform = CGAffineTransformMakeRotation(M_PI/180 *20);
				[self updateChildTransfrom:1];
			} completion:^(BOOL finished) {
				
				[self endAnimation:ActionTypeHate withCell:cell];
				
			}];
		}];
	}
}
- (void)rightActionWithFrom:(BOOL)fromGeture
{
	[self.animator removeAllBehaviors];
	GSSwipeViewCell *cell = self.cellCache.lastObject;
	if (fromGeture) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
			[self.delegate GSSwipeView:self withCell:cell distanceProcess:1 withActionType:ActionTypeLike];
		}
		CGPoint center  =cell.center;
		[UIView animateWithDuration:Card_Out_Time delay:0 options:0 animations:^{
			cell.center = CGPointMake(2*CGRectGetWidth(self.frame), center.y);
//			cell.transform = CGAffineTransformMakeRotation(-M_PI/180 *20);
			[self updateChildTransfrom:1];
		} completion:^(BOOL finished) {
			
			[self endAnimation:ActionTypeLike withCell:cell];
			
		}];
	}else{
		
		
		
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
			[self.delegate GSSwipeView:self withCell:cell distanceProcess:1 withActionType:ActionTypeLike];
		}
		CGPoint center  =cell.center;
		[UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
			cell.center = CGPointMake(center.x-10, center.y);
			
		} completion:^(BOOL finished) {
			
			[UIView animateWithDuration:Card_Out_Time delay:0 options:0 animations:^{
				cell.center = CGPointMake(2*CGRectGetWidth(self.frame), center.y);
				cell.transform = CGAffineTransformMakeRotation(-M_PI/180 *20);
				[self updateChildTransfrom:1];
			} completion:^(BOOL finished) {
				
				[self endAnimation:ActionTypeLike withCell:cell];
				
			}];
		}];
		
	}
}
- (void)swipeRightAction
{
	
	[self rightActionWithFrom:NO];
	
	

	
}

- (void)endAnimation:(ActionType)type withCell:(GSSwipeViewCell *)cell
{
	NSInteger numberCount = [self.dataSource numberOfCellInSwipeView:self];
	if (numberCount >0) {
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeViewWillEndSwipe:withCell:withActionType:)]) {
			[self.delegate GSSwipeViewWillEndSwipe:self withCell:cell withActionType:type];
		}
		numberCount = [self.dataSource numberOfCellInSwipeView:self];
		if (numberCount == 4 || numberCount == 0) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:startLoadingWithCount:)]) {
				[self.delegate GSSwipeView:self startLoadingWithCount:numberCount];
			}
		}
		
		
		
		[self reloadData];
	}else{
	
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:startLoadingWithCount:)]) {
			[self.delegate GSSwipeView:self startLoadingWithCount:numberCount];
		}
	
	}

}
- (void)afterSwipeAction:(CGPoint)nowCenter
			 withNowCell:(GSSwipeViewCell *)cell
			 withDstance:(float)distance needUpdate:(BOOL)need
{
	
	float x = 0;

		x =nowCenter.x;
	if (x > ACTION_MARGIN*3) {
		[self.animator removeAllBehaviors];
		[self rightActionWithFrom:YES];

	} else if (x < ACTION_MARGIN) {
		[self.animator removeAllBehaviors];
		[self leftActionWithFrom:YES];

	} else {
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
			[self.delegate GSSwipeView:self withCell:cell  distanceProcess:0 withActionType:ActionTypeNone];
		}
		NSValue *topValue = self.beginPoints.lastObject;
		UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:cell snapToPoint:[topValue CGPointValue]];
		snapBehavior.damping = 0.8;  //剧列程度
		[self.animator addBehavior:snapBehavior];
		__weak GSSwipeView *weakSelf = self;
		[snapBehavior setAction:^{
			[weakSelf updateLocation:cell.center withBeginPoint:weakSelf.viewBeginCenter withCell:cell];
		}];

	}
}



- (void)updateLocation:(CGPoint)nowPoint withBeginPoint:(CGPoint)beginPoint withCell:(GSSwipeViewCell *)cell
{
	float sca =sqrtf( powf((nowPoint.x-beginPoint.x), 2)+powf(nowPoint.y - beginPoint.y, 2))/(Card_MOVE_DIS);
	if (sca<=1) {
		[self updateChildTransfrom:sca];
		
	}
	
}




- (void)updateChildTransfrom:(float)distance
{
	

	
	
	int count  =self.cellCache.count;
	for (int i=1; i<count-1; i++) {
		GSSwipeViewCell *cell = self.cellCache[i];
		int idx =count-i-1;
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
