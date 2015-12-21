//
//  RDRSSEntityTableViewController.h
//  RSSReader
//
//  Created by Ramya Krishna on 11/21/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDWebViewController.h"
#import "RDFeedParser.h"
#define kdefaultItemsPerFeed 30

@interface RDRSSItemsTableViewController : UITableViewController<NSXMLParserDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (strong,nonatomic) NSString *itemUrlString;
@property (weak, nonatomic) IBOutlet UISearchBar *feedsSearchBar;

-(void)getRSSFeeds;
-(NSNumber*)getMaxNumberofItemsPerFeed;
-(void)filterItemsWithString:(NSString*)searchString;
-(void)setUpRefreshControl;
-(int)mapItemIndexFromFilteredArrayIndex: (NSInteger) filteredIndex;
@end
