//
//  ViewController.m
//  ViewandTouches
//
//  Created by Sviatoslav Lytovka on 9/26/13.
//  Copyright (c) 2013 Lytovka. All rights reserved.
//

#import "ViewController.h"
#import "MyView.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalGamesPlayedLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation ViewController
@synthesize highScoreLabel,
            playerScoreLabel,
            resetButton,
            startButton,
            timeElapsedLabel,
            totalGamesPlayedLabel;

MyView         *firstCard;
MyView         *secondCard;
MyView         *tempView;
int            highScore,
               matchCount,
               missCount,
               playerScore,
               timeElapsed,
               totalCards,
               totalCardsOpen,
               totalGamesPlayed;
BOOL           isFirstMove;
NSMutableArray *colorArray;
NSTimer        *gameTimer;



- (IBAction)resetPressed: (id)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Game Cancelled"
                                                      message: nil
                                                     delegate: self
                                            cancelButtonTitle: @"Ok"
                                            otherButtonTitles: nil];
    [message show];
    [gameTimer invalidate];
    [self resetGame];
}


- (void) updateGameTimer: (NSTimer *) timer
{
    timeElapsed++;
    int minutes           = (timeElapsed % 3600) / 60;
    int seconds           = (timeElapsed % 3600) % 60;
    timeElapsedLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
}


- (void) updateScore
{
    playerScore = (matchCount - missCount) * (1 / timeElapsed) * 10000;
    playerScoreLabel.text = [NSString stringWithFormat: @"Score %i", playerScore];
    if (playerScore >= highScore)
    {
        highScore = playerScore;
        highScoreLabel.text = [NSString stringWithFormat: @"%i", highScore];
    }
}


- (void) pauseGame  // Hides the face-up cards when game is paused
{
    [startButton setTitle: @"Resume" forState: UIControlStateNormal];
    [gameTimer invalidate];
    for (MyView *view in self.view.subviews)
    {
        if ([view isKindOfClass: [MyView class]])
        {
            MyView *myview = (MyView*)view;
            myview.backgroundColor = [UIColor lightGrayColor];
            myview.delegate = self;
        }
    }
}

- (void) resumeGame  //Reveals face-up cards when game is resumed
{
    [startButton setTitle: @"Pause" forState: UIControlStateNormal];
    gameTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                                 target: self
                                               selector: @selector(updateGameTimer:)
                                               userInfo: nil
                                                repeats: YES];
    for (MyView* view in self.view.subviews)
    {
        if ([view isKindOfClass: [MyView class]])
        {
            MyView* myview = (MyView*)view;
            if (myview.isOpen)
                myview.backgroundColor = colorArray[myview.tag];
            myview.delegate = self;
        }
    }
}


- (IBAction)startPressed: (id)sender
{
    if ([startButton.titleLabel.text isEqual: @"Start"])
    {
        timeElapsed = 0;
        playerScore = 0;
        [resetButton setEnabled: YES];
        [startButton setTitle: @"Pause" forState: UIControlStateNormal];
        gameTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                                     target: self
                                                   selector: @selector(updateGameTimer:)
                                                   userInfo: nil
                                                    repeats: YES];
    }
    else  // Player pauses the game
    {
        if ([startButton.titleLabel.text isEqual: @"Pause"])
            [self pauseGame];
        else  // Player resumes game
            [self resumeGame];
    }
}


- (void) generateCardColors: (int)totalCards
{
    float red   = 0;
    float blue  = 0;
    float green = 0;
    float gap;
    for (int index = 0; index < (totalCards / 2); index++)
    {
        gap = (gap > 128) ? (128) : (gap);
        do  // Terminates once the gap between red-blue-green has been satisfied
        {
            red   = arc4random()%256;
            blue  = arc4random()%256;
            green = arc4random()%256;
        } while ((red - blue   < gap && blue - red   < gap) ||
                 (red - green  < gap && green - red  < gap) ||
                 (blue - green < gap && green - blue < gap));
        UIColor *generatedColor = [UIColor colorWithRed: red / 255.0f
                                                  green: blue / 255.0f
                                                   blue: green / 255.0f
                                                  alpha: 1.0f];
        colorArray[index] = generatedColor;
    }
    return;
}


- (void) shuffleCards
{
    // Insert randomization routine here
}


-(void) resetGame
{
    [gameTimer invalidate];
    
    [self generateCardColors: totalCards];

    
    isFirstMove = YES;
    matchCount = 0;
    missCount = 0;
    playerScore = 0;
    //playerScoreLabel.text = @"0";
    timeElapsed = 0;
    
    totalCardsOpen = 0;
    [resetButton setEnabled: NO];
    [startButton setTitle: @"Start" forState: UIControlStateNormal];
    for (MyView* view in self.view.subviews)
    {
        if ([view isKindOfClass: [MyView class]])
        {
            MyView* myview = (MyView*)view;
            myview.backgroundColor = [UIColor lightGrayColor];
            myview.isOpen = NO;
            myview.isPaired = NO;
            myview.delegate = self;
        }
    }
}


- (void) revealCard: (MyView *)view
{
    view.isOpen = YES;
    view.backgroundColor = colorArray[view.tag];
}


- (void) hideCard: (MyView *)view
{
    view.isOpen = NO;
    view.backgroundColor = [UIColor lightGrayColor];
}


- (void) tellPlayerCardMatch
{
    matchCount++;
    // Replace with animated .png UIAnimation
    NSLog(@"Match!");
}


- (void) tellPlayerCardMisMatch
{
    missCount++;
    // Replace with animated .png UIAnimation
    NSLog(@"Miss!");
}


- (void) tellPlayerGameOver
{
    // Replace with animated .png UIAnimation
    UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Game Over"
                                                      message: nil
                                                     delegate: self
                                            cancelButtonTitle: @"Ok"
                                            otherButtonTitles: nil];
    [message show];
    
    [self updateScore];
    totalGamesPlayed ++;
    totalGamesPlayedLabel.text = [NSString stringWithFormat: @"%i", totalGamesPlayed];
}


-(void) compareCards
{
    
        [self revealCard: secondCard];
        if (firstCard.tag == secondCard.tag)
        {
            totalCardsOpen+=2;
            if (totalCardsOpen == totalCards)
            {
                [self hideCard: firstCard];
                [self hideCard: secondCard];
                [self tellPlayerGameOver];
                [self resetGame];
            }
            else  // totalCardsOpen < totalCards
            {
                [self tellPlayerCardMatch];
            }
            isFirstMove=YES;
        } else  // firstCard != secondCard
        {
            isFirstMove=YES;
            [self tellPlayerCardMisMatch];
            [self hideCard: firstCard];
            [self hideCard: secondCard];
        }
}


-(void) didChooseView: (MyView*) view
{
    if ([startButton.titleLabel.text isEqual: @"Start"])
        playerScore = 0;
    if ([startButton.titleLabel.text isEqual: @"Pause"])
    {
        if (isFirstMove)
            firstCard = view;
        else  // !isFirstMove
            secondCard = view;
        if (isFirstMove && !firstCard.isOpen)
        {
            [self revealCard: view];
            isFirstMove = NO;
        }
        else  // !isFirstMove || firstCard.isOpen
            if (!view.isOpen)
                [self compareCards];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    colorArray = [[NSMutableArray alloc] init];
    gameTimer = [[NSTimer alloc] init];
    highScoreLabel.text = @"0";
    tempView = [[MyView alloc] init];
    totalGamesPlayed = 0;
    totalGamesPlayedLabel.text = @"0";
     
    // Later updates can allow the player to select the difficulty and increase or decrease this number
    totalCards = 16;
    
    [self resetGame];
}


@end
