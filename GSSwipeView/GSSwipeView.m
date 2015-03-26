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
#define Card_Y_PADDING 4.0

#define Card_MOVE_DIS 120

#define Card_MOVE_DIS_X Card_MOVE_DIS/3
#define Card_MOVE_SPEED 1
#define Card_Delay_Time 0.3
static const float MAX_XSCALE_PERCENT = 5.0;
#define HEIGHT_TOP_PADDING 30


#import "GSSwipeView.h"

#import "GSButton.h"

@interface GSSwipeView ()<UIDynamicItem>
@property (nonatomic,assign) BOOL draggingView;
@property (nonatomic,strong) NSMutableArray *cellCache;
@property (nonatomic,strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic,strong) NSMutableArray *beginPoints;
@property (nonatomic,assign) CGPoint viewBeginPoint;
@property (nonatomic,assign) CGPoint viewBeginCenter;
@property (nonatomic, readwrite) SwipeViewStyle           style;
@property (nonatomic,assign,readwrite) CGSize cellSize;
@property (nonatomic,copy) NSString *className;
@property (nonatomic,strong) UIPushBehavior *pushBehavior;
@property (nonatomic,strong) GSButton *likeButton;
@property (nonatomic,strong) GSButton *hateButton;
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;



@property (nonatomic,assign) CGPoint endVectorPoint;



@end

@implementation GSSwipeView

- (instancetype)initWithFrame:(CGRect)frame style:(SwipeViewStyle)style withSuperView:(UIView *)superView
{
	self = [super initWithFrame:frame];
	if (self) {

		self.style = style;

		self.beginPoints = [NSMutableArray array];
		self.cellCache = [NSMutableArray array];

		self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
		float w = frame.size.width;
		float h = frame.size.height;
		GSButton *likeButton = [[GSButton alloc] initWithFrame:CGRectMake(w/2 + 20, h-104-10, 104, 104) withBackGroupImage:[UIImage imageNamed:@"miao_bg_like"] withMidImage:[UIImage imageNamed:@"miao_like"] withTopImage:[UIImage imageNamed:@"miao_like_y"]];
		likeButton.translatesAutoresizingMaskIntoConstraints =NO;
		self.likeButton = likeButton;
		[likeButton addTarget:self action:@selector(likeButtonClick:) ];
	
		GSButton *hateButton = [[GSButton alloc] initWithFrame:CGRectMake(w/2-104-20, h-104-10, 104, 104) withBackGroupImage:[UIImage imageNamed:@"miao_bg_hate"] withMidImage:[UIImage imageNamed:@"miao_hate"] withTopImage:[UIImage imageNamed:@"miao_hate_x"]];

		self.hateButton = hateButton;
		[hateButton addTarget:self action:@selector(hateButtonClick:) ];
	}
	return self;
}
- (void)registerCell:(Class )aClass
{
	
	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
	if (self.dataSource && [self.dataSource respondsToSelector:@selector(cellSizeInSwipeView:)]) {
			self.cellSize  = [self.dataSource cellSizeInSwipeView:self];
	}
	self.className = NSStringFromClass(aClass);
	BOOL isSetCount = [self.dataSource respondsToSelector:@selector(numberOfCellInSwipeView:)];
	NSInteger numberOfData = 0;
	if (isSetCount) {
		numberOfData = [self.dataSource numberOfCellInSwipeView:self];
	}
	
	NSInteger count = MIN(ACTION_VIEW_CACHE_COUNT, numberOfData);
	for (int i=0; i<count; i++) {
		GSSwipeViewCell *cell= [[aClass alloc] initWithFrame:CGRectMake(0, 0, self.cellSize.width, self.cellSize.height)];
	
		NSAssert(cell != nil, @"cell is nil");
		[self.cellCache addObject:cell];
		cell.clipsToBounds = YES;
		
		cell.backgroundColor = [UIColor whiteColor];
		cell.layer.cornerRadius = 5.f;
		cell.layer.borderWidth = 1.f;
		cell.layer.borderColor = [UIColor colorWithRed:220.f/255.0 green:220/255.0 blue:220/255.0 alpha:1.0].CGColor;

		
		
	
	

		
		
	
	}
	if (self.cellCache.count>0) {
		GSSwipeViewCell *cell = self.cellCache.lastObject;
		UIPanGestureRecognizer *panGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
		self.panGesture = panGesture;
		[cell addGestureRecognizer:panGesture];
		
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
		self.tapGesture = tapGesture;
		[cell addGestureRecognizer:tapGesture];
	}
	
}

- (void)reloadData
{
	if (self.cellCache.count == ACTION_VIEW_CACHE_COUNT) {
		return;
	}
	[self.beginPoints removeAllObjects];
	if (self.cellCache.count <= ACTION_VIEW_CACHE_COUNT) {
		[self.cellCache removeAllObjects];
		NSAssert(self.className!=nil, @"please call registerCell first");
		[self registerCell:NSClassFromString(self.className)];
	}
	
	[self addSubview:self.hateButton];
	[self addSubview:self.likeButton];

	[self.animator removeAllBehaviors];
	float scrW = [UIScreen mainScreen].bounds.size.width;
	float scrH = [UIScreen mainScreen].bounds.size.height;
	NSInteger count =self.cellCache.count;

	for (NSInteger i=0; i< count; i++) {
		GSSwipeViewCell *cell = self.cellCache[i];

		int idx =count-i-1;
		if (count >2) {
			idx = MIN(idx,2);
		}
		int m = (int)(idx * Card_Y_PADDING);
		cell.frame = CGRectMake(powf(-1, idx)*scrW, powf(-1, idx)*(-scrH), self.cellSize.width, self.cellSize.height);
		CGPoint center = CGPointMake(self.center.x, HEIGHT_TOP_PADDING+CGRectGetHeight(cell.frame)/2+m-count*Card_Y_PADDING);
		cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, [self getScaleFactor:idx withDistance:0], 1);
		cell.center = center;
		[self addSubview:cell];
		[self.beginPoints addObject:[NSValue valueWithCGPoint:center]];
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(GSSwipeView:cellInSwipeView:cellInSwipeViewIndex:)]) {
			[self.dataSource GSSwipeView:self cellInSwipeView:cell cellInSwipeViewIndex:count-1-i];
		}
	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeViewEndLoadingMoreData:)]) {
		[self.delegate GSSwipeViewEndLoadingMoreData:self];
	}
}
- (void)likeButtonClick:(GSButton *)button
{
	
	[self swipeRightAction];
}
- (void)hateButtonClick:(GSButton *)button
{
	[self swipeLeftAction];
}
- (void)tapGesture:(UITapGestureRecognizer *)tap
{

	
	if (!_draggingView) {
		GSSwipeViewCell *cell = (GSSwipeViewCell *)tap.view;
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withSelectCell:)]) {
			[self.delegate GSSwipeView:self withSelectCell:cell];
		}
	}
	

}
- (void)panGesture:(UIPanGestureRecognizer *)longPress
{
	GSSwipeViewCell *cell = (GSSwipeViewCell *)longPress.view;

	CGPoint nowPoint = [longPress locationInView:self];
	
	if (longPress.state == UIGestureRecognizerStateBegan && !_draggingView) {
		self.userInteractionEnabled = NO;
		[self sendSubviewToBack:self.likeButton];
		[self sendSubviewToBack:self.hateButton];
		if (self.cellCache.count >=2) {
			GSSwipeViewCell *nextCell = self.cellCache[self.cellCache.count-2];
			if (self.dataSource && [self.dataSource respondsToSelector:@selector(GSSwipeView:cellInSwipeView:cellInSwipeViewIndex:)]) {
				[self.dataSource GSSwipeView:self cellInSwipeView:nextCell cellInSwipeViewIndex:1];
				[self.dataSource GSSwipeView:self cellInSwipeView:cell cellInSwipeViewIndex:0];
			}
			
		}
		if (self.cellCache.count==1)
		{
			
			if (self.dataSource && [self.dataSource respondsToSelector:@selector(GSSwipeView:cellInSwipeView:cellInSwipeViewIndex:)]) {
				[self.dataSource GSSwipeView:self cellInSwipeView:cell cellInSwipeViewIndex:0];
			}
		}
		
		UIOffset offset = UIOffsetZero;
		if (CGRectContainsPoint(CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height/2), nowPoint)) {
			offset = UIOffsetMake(0, -10);
		}else{
			offset = UIOffsetMake(0, 10);
		}
		self.viewBeginPoint = nowPoint;
		self.viewBeginCenter = cell.center;
		_draggingView = YES;
		[self.animator removeAllBehaviors];
		UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:cell offsetFromCenter:offset attachedToAnchor:cell.center];
		[self.animator addBehavior:attachmentBehavior];
		self.attachmentBehavior = attachmentBehavior;
		__weak GSSwipeView *weakSelf = self;
		[attachmentBehavior setAction:^{
			GSSwipeViewCell *cell =(GSSwipeViewCell *)(weakSelf.attachmentBehavior.items[0]);
			[weakSelf updateLocation:cell.center withBeginPoint:weakSelf.viewBeginCenter withCell:cell];
		}];
	} else if (longPress.state == UIGestureRecognizerStateChanged && _draggingView) {
		float x2 =nowPoint.x - self.viewBeginPoint.x+self.viewBeginCenter.x;
		float y2 = nowPoint.y - self.viewBeginPoint.y + self.viewBeginCenter.y;
		CGPoint center =CGPointMake(x2, y2);
		[self.attachmentBehavior setAnchorPoint:center];
		float X =nowPoint.x - self.viewBeginPoint.x;
		float x_sca = fabs(X)*2/Card_MOVE_DIS_X;
		if (X <-Card_MOVE_DIS_X) {
			cell.actionType =ActionTypeHate;
			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)] && x_sca <=1) {
				[self.delegate GSSwipeView:self withCell:cell distanceProcess:x_sca withActionType:ActionTypeHate];
			}
		}else if (X  > Card_MOVE_DIS_X){

			cell.actionType =ActionTypeLike;
			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)] && x_sca <=1) {
				[self.delegate GSSwipeView:self withCell:cell distanceProcess:x_sca withActionType:ActionTypeLike];
			}
		}else{
			cell.actionType =ActionTypeNone;
			if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)] && x_sca <=1) {
				[self.delegate GSSwipeView:self withCell:cell distanceProcess:x_sca withActionType:ActionTypeNone];
			}
		}
		
		
		
		
		
		
	}else if (longPress.state == UIGestureRecognizerStateEnded) {
		float sca =sqrtf( powf((nowPoint.x - self.viewBeginPoint.x), 2)+powf(nowPoint.y - self.viewBeginPoint.y, 2))/Card_MOVE_DIS;
		float x2 =nowPoint.x - self.viewBeginPoint.x+self.viewBeginCenter.x;
		float y2 = nowPoint.y - self.viewBeginPoint.y + self.viewBeginCenter.y;
		self.userInteractionEnabled = YES;
		[self.animator removeAllBehaviors];
		self.endVectorPoint = [longPress translationInView:self];
		GSSwipeViewCell *nextCell = nil;
		GSSwipeViewCell *bottomCell = nil;
		if (self.cellCache.count>=2) {
			nextCell = self.cellCache[self.cellCache.count-2];
		}else if (self.cellCache.count == 1){
			nextCell = self.cellCache.firstObject;
		}
		if (self.cellCache.count >0) {
			bottomCell = self.cellCache.firstObject;
		}
		[self afterSwipeAction:CGPointMake(x2, y2)
				   withNowCell:cell withNextCell:nextCell
				 withBottomCell:bottomCell
				   withDstance:sca needUpdate:NO];
		_draggingView = NO;
		
	
	}
	
}



- (void)swipeLeftAction
{
	if (self.cellCache.count >0) {
		[self.animator removeAllBehaviors];
		GSSwipeViewCell *nextCell = nil;
		GSSwipeViewCell *bottomCell = nil;
		if (self.cellCache.count>=2) {
			nextCell = self.cellCache[self.cellCache.count-2];
		}else if (self.cellCache.count == 1){
			nextCell = self.cellCache.firstObject;
		}
		if (self.cellCache.count >0) {
			bottomCell = self.cellCache.firstObject;
		}
		GSSwipeViewCell *nowCell =self.cellCache.lastObject;
		nowCell.actionType =ActionTypeHate;
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)] ) {
			if (nowCell) {
  			  [self.delegate GSSwipeView:self withCell:nowCell distanceProcess:1 withActionType:ActionTypeHate];
				[self leftAction:CGPointMake(0, CGRectGetHeight(self.frame)/2)
					 withNowCell:nowCell
					withNextCell:nextCell
				  withBottomCell:bottomCell
					  needUpdate:YES];
			}
			
		}
		
		
	}
	
}
- (void)swipeRightAction
{
	if (self.cellCache.count >0) {
		[self.animator removeAllBehaviors];
		GSSwipeViewCell *nextCell = nil;
		GSSwipeViewCell *bottomCell = nil;
		if (self.cellCache.count>=2) {
			nextCell = self.cellCache[self.cellCache.count-2];
		}else if (self.cellCache.count == 1){
			nextCell = self.cellCache.firstObject;
		}
		if (self.cellCache.count >0) {
			bottomCell = self.cellCache.firstObject;
		}
		
		GSSwipeViewCell *nowCell =self.cellCache.lastObject;
		nowCell.actionType =ActionTypeLike;
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)] ) {
			[self.delegate GSSwipeView:self withCell:nowCell distanceProcess:1 withActionType:ActionTypeLike];
		}
		
		[self rightAction:CGPointMake(0, CGRectGetHeight(self.frame)/2)
			  withNowCell:nowCell
			 withNextCell:nextCell
		 withBottomCell:bottomCell
			   needUpdate:YES];

	}
}

- (void)afterSwipeAction:(CGPoint)nowCenter
			 withNowCell:(GSSwipeViewCell *)cell
			withNextCell:(GSSwipeViewCell *)nextCell
			withBottomCell:(GSSwipeViewCell *)bottomCell
			 withDstance:(float)distance needUpdate:(BOOL)need
{
	
	float x = 0;

		x =nowCenter.x;
	if (x > ACTION_MARGIN*3) {
		[self.animator removeAllBehaviors];
		[self rightAction:nowCenter withNowCell:cell withNextCell:nextCell withBottomCell:bottomCell needUpdate:need];
	} else if (x < ACTION_MARGIN) {
		[self.animator removeAllBehaviors];
		[self leftAction:nowCenter withNowCell:cell withNextCell:nextCell withBottomCell:bottomCell needUpdate:need];
	} else {
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:withCell:distanceProcess:withActionType:)]) {
			[self.delegate GSSwipeView:self withCell:cell  distanceProcess:0 withActionType:ActionTypeNone];
		}
		UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:cell snapToPoint:self.viewBeginCenter];
		snapBehavior.damping = 0.5f;  //剧列程度
		[self.animator addBehavior:snapBehavior];
		__weak GSSwipeView *weakSelf = self;
		[snapBehavior setAction:^{
			[weakSelf updateLocation:cell.center withBeginPoint:weakSelf.viewBeginCenter withCell:cell];
		}];
	}
}
-(void)rightAction:(CGPoint)nowPoint
	   withNowCell:(GSSwipeViewCell *)cell
	 withNextCell:(GSSwipeViewCell *)nextCell
	withBottomCell:(GSSwipeViewCell *)bottomCell
		needUpdate:(BOOL)need
{
	
	
	[cell removeGestureRecognizer:self.tapGesture];
	[cell removeGestureRecognizer:self.panGesture];
	if (nextCell) {
		[nextCell addGestureRecognizer:self.tapGesture];
		[nextCell addGestureRecognizer:self.panGesture];
		

	}
	float ix = self.endVectorPoint.x;
	float iy = self.endVectorPoint.y;
	if (ix ==0) {
		ix = 1;
	}
	if ( iy ==0) {
		iy = 1;
	}
	if (need) {
		ix= 1;
		iy = 1;
		self.viewBeginCenter = cell.center;
		[UIView animateWithDuration:Card_Delay_Time animations:^{
			cell.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (M_PI/36)*2);
		}];
		
	}
	UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[cell] mode:UIPushBehaviorModeInstantaneous];
	[self.animator addBehavior:pushBehavior];
	self.pushBehavior = pushBehavior;
	
	pushBehavior.pushDirection = CGVectorMake(Card_MOVE_SPEED*100*ix/fabs(ix), Card_MOVE_SPEED*100*iy/fabs(iy));
	__weak GSSwipeView *weakSelf = self;
	[pushBehavior setAction:^{
		[weakSelf updateLocation:cell.center withBeginPoint:weakSelf.viewBeginCenter withCell:cell];
	}];
	

	[self sendBackNowCell:cell];

}

- (void)sendBackNowCell:(GSSwipeViewCell *)nowCell
{
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeViewEndSwipe:withCell:)]) {
		[self.delegate GSSwipeViewEndSwipe:self withCell:nowCell];
	}
	NSInteger numberOfData = [self.dataSource numberOfCellInSwipeView:self];
	if (numberOfData < ACTION_VIEW_CACHE_COUNT) {
		[nowCell removeGestureRecognizer:self.tapGesture];
		[nowCell removeGestureRecognizer:self.panGesture];
	}
	[self performSelector:@selector(removePushAnimation:) withObject:nowCell afterDelay:Card_Delay_Time];

}
- (void)removePushAnimation:(GSSwipeViewCell *)nowCell
{
	[self sendSubviewToBack:nowCell];
	NSInteger numberOfData = [self.dataSource numberOfCellInSwipeView:self];
	if (numberOfData >= ACTION_VIEW_CACHE_COUNT)
	{
		if (self.cellCache.count >0) {
			GSSwipeViewCell *bottomCell = self.cellCache.firstObject;
			nowCell.center = bottomCell.center;
			nowCell.transform = bottomCell.transform;
			[self.cellCache removeObject:nowCell];
			[self.cellCache insertObject:nowCell atIndex:0];
		}
		
	}else{
		if (self.cellCache.count >0) {
			[self.cellCache removeLastObject];
			[nowCell removeFromSuperview];
		}
		
	}
	if (numberOfData == MAX_DATA_CACHE || numberOfData == 0) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(GSSwipeView:startLoadingWithCount:)]) {
			[self.delegate GSSwipeView:self startLoadingWithCount:numberOfData];
		}
	}

	[self.animator removeBehavior:self.pushBehavior];
}
-(void)leftAction:(CGPoint)nowPoint
	  withNowCell:(GSSwipeViewCell *)cell
	 withNextCell:(GSSwipeViewCell *)nextCell
withBottomCell:(GSSwipeViewCell *)bottomCell
	   needUpdate:(BOOL)need
{
	[cell removeGestureRecognizer:self.tapGesture];
	[cell removeGestureRecognizer:self.panGesture];
	if (nextCell) {
		
		[nextCell addGestureRecognizer:self.tapGesture];
		[nextCell addGestureRecognizer:self.panGesture];
		
		
	}
	int i = 1;
	float ix = self.endVectorPoint.x;
	float iy = self.endVectorPoint.y;
	if (ix ==0	){
		ix =1;
	}
	if(iy ==0){
		ix =1;
	}
	if (need) {
		i = -1;
		ix = 1;
		iy = 1;
		self.viewBeginCenter = cell.center;
		[UIView animateWithDuration:Card_Delay_Time animations:^{
			cell.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -(M_PI/36)*2);
		}];
	}
	
	UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[cell] mode:UIPushBehaviorModeInstantaneous];
	pushBehavior.active = YES;
	self.pushBehavior = pushBehavior;
	__weak GSSwipeView *weakSelf = self;
	
	[pushBehavior setAction:^{
		[weakSelf updateLocation:cell.center withBeginPoint:weakSelf.viewBeginCenter withCell:cell];
	}];
	
	pushBehavior.pushDirection = CGVectorMake(Card_MOVE_SPEED *(100)*ix/fabs(ix)*i, Card_MOVE_SPEED*100*iy/fabs(iy));
	[self.animator addBehavior:pushBehavior];
	
	
	[self sendBackNowCell:cell];

	
}


- (void)updateLocation:(CGPoint)nowPoint withBeginPoint:(CGPoint)beginPoint withCell:(GSSwipeViewCell *)cell
{
	float sca =sqrtf( powf((nowPoint.x-beginPoint.x), 2)+powf(nowPoint.y - beginPoint.y, 2))/(Card_MOVE_DIS);

	
	if (sca<=1) {
		[self updateChildTransfrom:sca];
		
	}
	
}


- (void)stopPush
{
//	[self.pushBehavior setActive:NO];
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
