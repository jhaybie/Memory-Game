//
//  ViewController.h
//  ViewandTouches
//
//  Created by Sviatoslav Lytovka on 9/26/13.
//  Copyright (c) 2013 Lytovka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyView.h"

@interface ViewController : UIViewController <MatchDelegate,
                                              UIAlertViewDelegate,
                                              UIActionSheetDelegate>

- (void) updateGameTimer: (NSTimer *) timer;

@end
