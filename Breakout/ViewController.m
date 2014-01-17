//
//  ViewController.m
//  Breakout
//
//  Created by Kagan Riedel on 1/16/14.
//  Copyright (c) 2014 Kagan Riedel. All rights reserved.
//

#import "ViewController.h"
#import "PaddleView.h"
#import "BallView.h"
#import "BlockView.h"

@interface ViewController () <UICollisionBehaviorDelegate>
{
    __weak IBOutlet BallView *ballView;
    __weak IBOutlet PaddleView *paddleView;
    
    UIDynamicAnimator *dynamicAnimator;
    UIPushBehavior *pushBehavior;
    UICollisionBehavior *collisionBehavior;
    UIDynamicItemBehavior *paddleDynamicBehavior;
    UIDynamicItemBehavior *ballDynamicBehavior;
    BlockView *block;
    CGRect screenFrame;
    
    int columns;
    NSTimer *ballTimer;
    int timerCounter;

}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startGame];
    
}

-(void)startGame
{
    screenFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width , self.view.frame.size.height);
    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    pushBehavior = [[UIPushBehavior alloc] initWithItems:@[ballView] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.active = NO;
    pushBehavior.magnitude = 0.1;
    pushBehavior.pushDirection = CGVectorMake(0.5, 1.0);
    
    [dynamicAnimator addBehavior:pushBehavior];
    
    collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[ballView, paddleView]];
    collisionBehavior.collisionDelegate = self;
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    
    [dynamicAnimator addBehavior:collisionBehavior];
    
    paddleDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[paddleView]];
    paddleDynamicBehavior.allowsRotation = NO;
    paddleDynamicBehavior.elasticity = 1.0;
    paddleDynamicBehavior.friction = 0.0;
    paddleDynamicBehavior.resistance = 0.0;
    paddleDynamicBehavior.density = 10000;
    
    [dynamicAnimator addBehavior:paddleDynamicBehavior];
    
    ballDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[ballView]];
    ballDynamicBehavior.allowsRotation = NO;
    ballDynamicBehavior.elasticity = 1.0;
    ballDynamicBehavior.friction = 0.0;
    ballDynamicBehavior.resistance = 0.0;
    ballDynamicBehavior.density = 10.0;
    
    [dynamicAnimator addBehavior:ballDynamicBehavior];
    ballView.center = CGPointMake(160, 284);
    [dynamicAnimator updateItemUsingCurrentState:ballView];
    [self loadEasyGame];
    [self randomizeLabelColors];
    [self startTimer];
    
}

-(void)loadEasyGame
{
    columns = 8;
    
    //Row 1
    for (int i = 0; i<columns; i++)
    {
        block = [BlockView new];
        block.frame = CGRectMake(i*(screenFrame.size.width/columns),(screenFrame.size.height/12), screenFrame.size.width/columns, screenFrame.size.height/25);
        [self addBlockAttributesToView];
    }
    //Row 2
    for (int i = 0; i<columns; i++)
    {
        block = [BlockView new];
        block.frame = CGRectMake(i*(screenFrame.size.width/columns),(screenFrame.size.height/12)+screenFrame.size.height/25, screenFrame.size.width/columns, screenFrame.size.height/25);
        [self addBlockAttributesToView];
    }
    //Row 3
    for (int i = 0; i<columns; i++)
    {
        block = [BlockView new];
        block.frame = CGRectMake(i*(screenFrame.size.width/columns),(screenFrame.size.height/12)+(screenFrame.size.height/25)*2, screenFrame.size.width/columns, screenFrame.size.height/25);
        [self addBlockAttributesToView];
    }
}

-(void)addBlockAttributesToView
{
    [self.view addSubview:block];
    [paddleDynamicBehavior addItem:block];
    [collisionBehavior addItem:block];
    [dynamicAnimator updateItemUsingCurrentState:block];
}

- (IBAction)dragPaddle:(UIPanGestureRecognizer*)panGestureRecognizer
{
    paddleView.center = CGPointMake([panGestureRecognizer locationInView:self.view].x , paddleView.center.y);
    [dynamicAnimator updateItemUsingCurrentState:paddleView];
}

-(BOOL)shouldStartAgain
{
    if (collisionBehavior.items.count < 3)
    {
        return YES;
    }
    else return NO;
}



-(void)startTimer
{
    timerCounter = 3;
    ballTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTimer:) userInfo:nil repeats:YES];
}
                      
-(void)countDownTimer:(NSTimer*)timer
{
    NSLog(@"counted down");
    timerCounter --;
    if (timerCounter <=0)
    {
        [timer invalidate];
        [self startBallMoving];
    }
}

-(void)startBallMoving;
{
    pushBehavior.active = YES;
    
}

-(void)randomizeLabelColors
{
    for (UILabel *label in self.view.subviews) {
        [UIView animateWithDuration:.5 animations:^{
            label.backgroundColor = [UIColor colorWithHue:(arc4random()%256/256.0) saturation:1 brightness:1 alpha:1];
        }];
    }
}

#pragma mark UICollisionBehaviorDelegate methods

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (ballView.center.y >= 550) {
        ballView.center = CGPointMake(160, 284);
        [dynamicAnimator updateItemUsingCurrentState:ballView];
        
        [self startTimer];
    }
}


-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    
    [self randomizeLabelColors];
    if ([item1 isKindOfClass:[BlockView class]]) {
        [collisionBehavior removeItem:item1];
        [UIView animateWithDuration:.8 animations:^{
            
            ((BlockView*)item1).alpha = 0;
        }];
        [dynamicAnimator updateItemUsingCurrentState:item1];
    } else if ([item2 isKindOfClass:[BlockView class]]) {
        [collisionBehavior removeItem:item2];
        [dynamicAnimator updateItemUsingCurrentState:item2];
        [UIView animateWithDuration:.8 animations:^{
            ((BlockView*)item2).alpha = 0;
        }];
        
    }
    if ([self shouldStartAgain]==YES) {
        [self startGame];
    }
}



@end
