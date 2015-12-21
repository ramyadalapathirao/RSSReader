//
//  RDCustomLabel.m
//  RSSReader
//
//  Created by Ramya Krishna on 11/27/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import "RDCustomLabel.h"

@implementation RDCustomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.edgeinsets=UIEdgeInsetsMake(20, 10, 20, 10);
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeinsets)];
}


@end
