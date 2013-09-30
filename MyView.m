//
//  MyView.m
//  ViewandTouches
//
//  Created by Sviatoslav Lytovka on 9/26/13.
//  Copyright (c) 2013 Lytovka. All rights reserved.
//

#import "MyView.h"


@implementation MyView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {}
    return self;
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate didChooseView: self];
}

@end
