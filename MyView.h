//
//  MyView.h
//  ViewandTouches
//
//  Created by Sviatoslav Lytovka on 9/26/13.
//  Copyright (c) 2013 Lytovka. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyView;

@protocol MatchDelegate <NSObject>
- (void) didChooseView:(MyView*) view;
@end

@interface MyView : UIView
@property (strong, nonatomic) id <MatchDelegate> delegate;
@property BOOL isOpen;
@property BOOL isPaired;

@end
