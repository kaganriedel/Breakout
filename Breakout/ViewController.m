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

@interface ViewController () <UICollisionBehaviorDelegate, UIAlertViewDelegate>
{
    __weak IBOutlet BallView *ballView;
    __weak IBOutlet PaddleView *paddleView;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UILabel *livesLabel;
    __weak IBOutlet UILabel *scoreLabel;
    
    UIDynamicAnimator *dynamicAnimator;
    UIPushBehavior *pushBehavior;
    UICollisionBehavior *collisionBehavior;
    UIDynamicItemBehavior *paddleDynamicBehavior;
    UIDynamicItemBehavior *ballDynamicBehavior;
    UISnapBehavior *ballSnapBehavior;
    
    BlockView *block;
    CGRect screenFrame;
    int timerCounter;
    int columns;
    int rows;
    int lives;
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
    paddleDynamicBehavior.density = 1000000;
    
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
    scoreLabel.text = @"0";
}

-(void)loadEasyGame
{
    columns = 10;
    rows = 3;
    lives = 2;
    livesLabel.text = [NSString stringWithFormat:@"%i", lives];
    
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < columns; j++)
        {
            block = [BlockView new];
            block.frame = CGRectMake(j*(screenFrame.size.width/columns),i*(screenFrame.size.height/25)+(screenFrame.size.height/12), screenFrame.size.width/columns, screenFrame.size.height/25);
            block.strength = arc4random_uniform(3)+1;
            block.startingStrength = block.strength;
            [self addBlockAttributesToView];
        }
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

-(void)gameOver
{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GAME OVER" message:@"You lose!" delegate:self cancelButtonTitle:@"Play Again" otherButtonTitles: nil];
        [alert show];
}

-(void)startTimer
{
    imageView.alpha = 1.0;
    ballView.alpha = 0.0;
    imageView.image = [UIImage imageNamed:@"Three.png"];
    timerCounter = 3;
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTimer:) userInfo:nil repeats:YES];
}
                      
-(void)countDownTimer:(NSTimer*)timer
{
    timerCounter --;
    switch (timerCounter) {
        case 2:
            imageView.image = [UIImage imageNamed:@"Two.png"];
            break;
        case 1: imageView.image = [UIImage imageNamed:@"One.png"];
            break;
        default:
            imageView.alpha = 0;
            break;
    }
    if (timerCounter <=0)
    {
        imageView.alpha = 0;
        [timer invalidate];
        [self startBallMoving];
    }
}

-(void)startBallMoving;
{
    ballView.alpha = 1.0;
    [dynamicAnimator removeBehavior:ballSnapBehavior];
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

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark UICollisionBehaviorDelegate

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (ballView.center.y >= 550) {
        lives --;
        livesLabel.text = [NSString stringWithFormat:@"%i", lives];
        if (lives == 0)
        {
            [self gameOver];
        } else {
            [self startTimer];
        }
        ballSnapBehavior = [[UISnapBehavior alloc] initWithItem:ballView snapToPoint:CGPointMake(160, 284)];
        [dynamicAnimator addBehavior:ballSnapBehavior];
        [dynamicAnimator updateItemUsingCurrentState:ballView];
        
    }
}


-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    
    [self randomizeLabelColors];
    if ([item1 isKindOfClass:[BlockView class]]) {
        scoreLabel.text = [NSString stringWithFormat:@"%i", scoreLabel.text.intValue +1];
        ((BlockView*)item1).strength --;
        [UIView animateWithDuration:.8 animations:^{
            ((BlockView*)item1).alpha -= 1.0/((BlockView*)item1).startingStrength;
        }];
        if (((BlockView*)item1).strength == 0)
        {
            [collisionBehavior removeItem:item1];
            [dynamicAnimator updateItemUsingCurrentState:item1];
        }
    } else if ([item2 isKindOfClass:[BlockView class]]) {
        scoreLabel.text = [NSString stringWithFormat:@"%i", scoreLabel.text.intValue +1];
        ((BlockView*)item2).strength --;
        [UIView animateWithDuration:.8 animations:^{
            ((BlockView*)item2).alpha -= 1.0/((BlockView*)item2).startingStrength;
        }];
        if (((BlockView*)item2).strength == 0) {
            [collisionBehavior removeItem:item2];
            [dynamicAnimator updateItemUsingCurrentState:item2];
        }
    }
    if ([self shouldStartAgain]==YES) {
        [self startGame];
    }
}

#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self startGame];
}





@end
