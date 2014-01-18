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
    __weak IBOutlet UILabel *highScoreLabel;
    
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
    int level;
    int highScore;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    level = 0;
    lives = 2;
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
    
    
    [self startTimer];
    [self loadGame];
    [self randomizeLabelColors];
    
    
}

-(void)loadGame
{
    columns = 5+level;
    rows = 1+level;
    livesLabel.text = [NSString stringWithFormat:@"%i", lives];
    
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < columns; j++)
        {
            block = [BlockView new];
            block.frame = CGRectMake(j*(screenFrame.size.width/columns),i*(screenFrame.size.height/25)+(screenFrame.size.height/12), screenFrame.size.width/columns, screenFrame.size.height/25);
            block.strength = arc4random_uniform(level+1)+1;
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
    if ([self shouldSetNewHighScore]) {
        int oldHighScore = highScore;
        highScore = scoreLabel.text.intValue;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NEW HIGH SCORE" message:[NSString stringWithFormat:@"Old High Score: %i\nNew High Score: %i",oldHighScore,highScore] delegate:self cancelButtonTitle:@"Play Again" otherButtonTitles: nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GAME OVER" message:@"You lose!" delegate:self cancelButtonTitle:@"Play Again" otherButtonTitles: nil];
        [alert show];
    }
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
    [collisionBehavior addItem:ballView];
    ballView.alpha = 1.0;
    [dynamicAnimator removeBehavior:ballSnapBehavior];
    pushBehavior.active = YES;
}

-(void)randomizeLabelColors
{
    for (UILabel *label in self.view.subviews) {
        if([label isKindOfClass:[BlockView class]] || [label isKindOfClass:[BallView class]])
        {
            [UIView animateWithDuration:.5 animations:^{
                label.backgroundColor = [UIColor colorWithHue:(arc4random()%256/256.0) saturation:1 brightness:1 alpha:1];
            }];
        }
    }
}

-(BOOL)shouldSetNewHighScore
{
    if (scoreLabel.text.intValue > highScore) {
        return YES;
    } else
        return NO;
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
        [collisionBehavior removeItem:ballView];
        [dynamicAnimator updateItemUsingCurrentState:ballView];
    }
}


-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    [self randomizeLabelColors];
    if ([item1 isKindOfClass:[BlockView class]]) {
        scoreLabel.text = [NSString stringWithFormat:@"%i", scoreLabel.text.intValue +10];
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
        
        scoreLabel.text = [NSString stringWithFormat:@"%i", scoreLabel.text.intValue +10];
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
        level ++; //makes the the next level have 1 extra row, 1 extra column and blocks can have 1 greater max strength
        [self startGame];
    }
}

#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    scoreLabel.text = @"0";
    level = 0;
    lives = 2;
    for (BlockView * blockView in self.view.subviews) {
        if ([blockView isKindOfClass:[BlockView class]]){
        [blockView removeFromSuperview];
        [collisionBehavior removeItem:blockView];
        }
    }
    [self startGame];
}





@end
