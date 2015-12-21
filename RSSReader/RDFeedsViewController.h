//
//  RDFeedsViewController.h
//  RSSReader
//
//  Created by Ramya Krishna on 11/16/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RDSubscriptionsViewController.h"

@interface RDFeedsViewController : UITableViewController
@property (strong,nonatomic) NSNumber *category_id;
@property (strong,nonatomic) NSString *category_title;

- (IBAction)subscribeToFeeds:(UIBarButtonItem *)sender;
-(void)addFeedToSubscription:(NSNumber*)feedId;
-(void)getFeedsPerCategory;
@end
