//
//  ViewController.m
//  ViewandTouches
//
//  Created by Jhaybie Basco on 9/26/13.
//  Copyright (c) 2013 Basco. All rights reserved.
//

#import "ViewController.h"
#import "MyView.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *checkMark;
@property (weak, nonatomic) IBOutlet UIImageView *xMark;
@property (weak, nonatomic) IBOutlet UILabel     *timeRemainingLabel;
@property (weak, nonatomic) IBOutlet UILabel     *playerScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel     *highScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel     *totalGamesPlayedLabel;
@property (weak, nonatomic) IBOutlet UIButton    *resetButton;
@property (weak, nonatomic) IBOutlet UIButton    *startButton;

@end

@implementation ViewController
@synthesize checkMark,
            highScoreLabel,
            playerScoreLabel,
            resetButton,
            startButton,
            timeRemainingLabel,
            totalGamesPlayedLabel,
            xMark;

MyView         *firstCard;
MyView         *secondCard;
MyView         *tempView;
int            highScore,
               matchCount,
               missCount,
               timeRemaining,
               totalCards,
               totalCardsOpen,
               totalGamesPlayed;
float          playerScore;
BOOL           isFirstMove;
NSMutableArray *cardArray, *colorArray, *tagArray;
NSTimer        *gameTimer;



-(void) compareCards
{
    [self revealCard: secondCard];
    if (firstCard.tag == secondCard.tag)
    {
        totalCardsOpen+=2;
        isFirstMove=YES;
        if (totalCardsOpen == totalCards)
            [self tellPlayerGameOver];
        else  // totalCardsOpen < totalCards
            [self tellPlayerCardMatch];
    }
    else  // firstCard != secondCard
    {
        isFirstMove=YES;
        [self revealCard: secondCard];
        [self tellPlayerCardMisMatch];
        [self performSelector: @selector(hideCard:)
                   withObject: firstCard
                   afterDelay: 0.25];
        [self performSelector: @selector(hideCard:)
                   withObject: secondCard
                   afterDelay: 0.25];
    }
}


-(void) resetGame
{
    [self generateCardColors: totalCards];
    isFirstMove = YES;
    matchCount = 0;
    missCount = 0;
    playerScore = 0;
    timeRemaining = 60;
    timeRemainingLabel.text = @"01:00";
    totalCardsOpen = 0;
    [resetButton setEnabled: NO];
    [startButton setTitle: @"Start"
                 forState: UIControlStateNormal];
    [self generateCards];
    /*for (MyView* view in self.view.subviews)
    {
        if ([view isKindOfClass: [MyView class]])
        {
            MyView* myview = (MyView*)view;
            myview.backgroundColor = [UIColor lightGrayColor];
            myview.isOpen = NO;
            myview.isPaired = NO;
            myview.delegate = self;
        }
    }*/
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
    [startButton setTitle: @"Pause"
                 forState: UIControlStateNormal];
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


- (void) updateGameTimer: (NSTimer *)timer
{
    timeRemaining--;
    if (timeRemaining >= 0)
    {
        int minutes           = (timeRemaining % 3600) / 60;
        int seconds           = (timeRemaining % 3600) % 60;
        timeRemainingLabel.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
    }
    else
        [self tellPlayerTimeIsUp];
}


- (void) updateScore  // Score is calculated after game is over
{
    float floatTimeRemaining = timeRemaining;
    playerScore = (matchCount * 20 - missCount) * floatTimeRemaining;
    playerScoreLabel.text = [NSString stringWithFormat: @"%0.0f", playerScore];
    if (playerScore >= highScore)
    {
        // Insert method call tellPlayerHighScore
        highScore = playerScore;
        highScoreLabel.text = [NSString stringWithFormat: @"%i", highScore];
    }
}

- (void) drawCards
{
    int x = 0;
    int y = 0;
    int a = 0;
    for (y = 260; y < 465; y += 68)
    {
        for (x = 28; x < 233; x += 68)
        {
            MyView *card = [[MyView alloc] initWithFrame: CGRectMake(x, y, 60, 60)];
            card.tag = (int)tagArray[a];
            card.backgroundColor = [UIColor lightGrayColor];
            card.isOpen = NO;
            card.isPaired = NO;
            card.delegate = self;
            [self.view addSubview: card];
            a++;
        }
    }
}


- (void) generateCards
{
    int x = 0;
    for (int i = 0; i < totalCards; i += 2)
    {
        tagArray[i]     = [NSNumber numberWithInt: x];
        tagArray[i + 1] = [NSNumber numberWithInt: x];
        x++;
    }
    NSUInteger count = [tagArray count];
    for (NSUInteger i = 0; i < count; ++i)
    {
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [tagArray exchangeObjectAtIndex: i
                      withObjectAtIndex: n];
    }
    [self drawCards];
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


-(void) hideCheck
{
    checkMark.hidden=YES;
}


- (void) tellPlayerCardMatch
{
    matchCount++;
    checkMark.hidden = NO;
    [self performSelector:@selector(hideCheck) withObject:nil afterDelay:0.25f];
}


- (void) tellPlayerCardMisMatch
{
    missCount++;
    xMark.hidden=NO;
    [self performSelector:@selector(hideX) withObject:nil afterDelay:0.25];
}


- (void) hideX
{
    xMark.hidden = YES;
}


- (void) tellPlayerGameOver
{
    // Replace with animated .png UIAnimation
    UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Game Over"
                                                      message: @"Good job!"
                                                     delegate: self
                                            cancelButtonTitle: @"Ok"
                                            otherButtonTitles: nil];
    [message show];
    [gameTimer invalidate];
    [self updateScore];
    [resetButton setEnabled: NO];
    [startButton setTitle: @"Start" forState: UIControlStateNormal];
    totalGamesPlayed++;
    totalGamesPlayedLabel.text = [NSString stringWithFormat: @"%i", totalGamesPlayed];
}


- (void) tellPlayerTimeIsUp
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Game Over"
                                                      message: @"You suck!"
                                                     delegate: self
                                            cancelButtonTitle: @"Ok"
                                            otherButtonTitles: nil];
    [message show];
    [gameTimer invalidate];
    [startButton setTitle: @"Start" forState: UIControlStateNormal];
    totalGamesPlayed++;
    totalGamesPlayedLabel.text = [NSString stringWithFormat: @"%i", totalGamesPlayed];
}


- (IBAction)resetPressed: (id)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Game Cancelled"
                                                      message: nil
                                                     delegate: self
                                            cancelButtonTitle: @"Ok"
                                            otherButtonTitles: nil];
    [message show];
    [gameTimer invalidate];
    timeRemaining = 60;
    [self resetGame];
}


- (IBAction) startPressed: (id)sender
{
    if ([startButton.titleLabel.text isEqual: @"Start"])
    {
        [self resetGame];
        [resetButton setEnabled: YES];
        [startButton setTitle: @"Pause"
                     forState: UIControlStateNormal];
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


- (void) viewDidLoad
{
    [super viewDidLoad];
    totalCards = 16;
    tagArray = [[NSMutableArray alloc] init];
    colorArray = [[NSMutableArray alloc] init];
    gameTimer = [[NSTimer alloc] init];
    tempView = [[MyView alloc] init];
    
    highScoreLabel.text = @"0";  // Can be pulled from a file storing highscores from previous games
    totalGamesPlayed = 0;
    totalGamesPlayedLabel.text = @"0";
     
    // Later updates can allow the player to select the difficulty and increase or decrease this number
    // as well as increase or decrease the timer.
    totalCards = 16;
    
    [self resetGame];
}


@end
