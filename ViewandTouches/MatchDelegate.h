//
//  MatchDelegate.h
//  ViewandTouches
//
//  Created by Sviatoslav Lytovka on 9/26/13.
//  Copyright (c) 2013 Lytovka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyView.h>

@protocol MatchDelegate <NSObject>
-(void) didChooseView:(MyView*) view;

@end
