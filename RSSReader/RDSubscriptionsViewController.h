//
//  feedsTableViewController.h
//  RSSReader
//
//  Created by Ramya Krishna on 11/3/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RDRSSItemsTableViewController.h"
#import "RDCustomLabel.h"

@interface RDSubscriptionsViewController : UITableViewController

-(void) getSubscribedFeedsPerCategory;

-(void)showMessageLabel;
-(void)hideMessageLabel;
-(void)showLoadingLabel;
-(void)hideLoadingLabel;
-(NSString*) getFeedTitleAtRow:(NSInteger)rowIndex atSection:(NSInteger)sectionIndex;
-(NSString*) getFeedUrlAtRow:(NSInteger)rowIndex atSection:(NSInteger)sectionIndex;
-(NSString*) getCategoryTitlteAtSection:(NSInteger)sectionIndex;
-(BOOL) isCustomSection:(NSInteger)sectionIndex;
-(void)filterFeedsWithString:(NSString*)searchString;
-(void)getCustomFeeds;
-(void) deleteCustomFeedAtRow:(NSInteger)rowIndex;
-(void) deleteFeedAtRow:(NSInteger)rowIndex atSection:(NSInteger)sectionIndex;


@end
