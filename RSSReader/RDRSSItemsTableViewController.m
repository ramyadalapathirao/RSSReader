//
//  RDRSSEntityTableViewController.m
//  RSSReader
//
//  Created by Ramya Krishna on 11/21/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import "RDRSSItemsTableViewController.h"

@interface RDRSSItemsTableViewController ()

  @property (strong,nonatomic) NSMutableArray *feedItemsArray;
  @property (strong,nonatomic)  NSMutableArray *feedLinksArray;
  @property (strong,nonatomic)  NSMutableArray *filteredItemsArray;
  @property (strong,nonatomic) NSXMLParser *parser;
  @property (strong,nonatomic)  NSNumber *oldMaxItemsPerFeed;

@end

@implementation RDRSSItemsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.filteredItemsArray=[[NSMutableArray alloc] init];
    [self setUpRefreshControl];
    self.tableView.bounces=YES;
    [self getRSSFeeds];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.searchDisplayController.active = false;
}


-(void)getRSSFeeds
{
    NSURL *url=[NSURL URLWithString:_itemUrlString];
    int maxItemsPerFeed=[[self getMaxNumberofItemsPerFeed] intValue];
    RDFeedParser *feedParser=[[RDFeedParser alloc] initWithMaxNumberOfItemsPerFeed:maxItemsPerFeed];
    feedParser.onCompletion=^(NSMutableArray *itemsArray,NSMutableArray *linksArray)
    {
        self.feedItemsArray=[NSMutableArray arrayWithArray:itemsArray];
        self.feedLinksArray=[NSMutableArray arrayWithArray:linksArray];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
        
    };
    
    feedParser.onFailure = ^(NSString *errorString)
    {
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    };
    
    self.parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate=feedParser;
    self.parser.shouldProcessNamespaces=false;
    self.parser.shouldReportNamespacePrefixes=false;
    self.parser.shouldResolveExternalEntities=false;
    [self.parser parse];
}

/* retrieving maximum number of item per feed from settings */

-(NSNumber*)getMaxNumberofItemsPerFeed
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSNumber* itemsCount=[[NSUserDefaults standardUserDefaults] objectForKey:@"items_per_feed"];
    if(itemsCount)
    {
        return  itemsCount;
    }
    return [NSNumber numberWithInt:kdefaultItemsPerFeed];
}


-(void)setUpRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(getRSSFeeds)
                  forControlEvents:UIControlEventValueChanged];

}

/* Search for an item with key as title based on search string */

-(void)filterItemsWithString:(NSString*)searchString
{
    if([self.filteredItemsArray count] > 0)
    {
      [self.filteredItemsArray removeAllObjects];
    }
    NSString *key=@"title";
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",key,searchString];
    _filteredItemsArray = [NSMutableArray arrayWithArray:[_feedItemsArray filteredArrayUsingPredicate:predicate]];
    
}

/* Mapping filteredArray index to feedArray index based on title */
 
-(int)mapItemIndexFromFilteredArrayIndex: (NSInteger) filteredIndex
{
    int itemIndex=0;
    NSString *filteredTitle =[[_filteredItemsArray objectAtIndex:filteredIndex] objectForKey:@"title"];
    for(itemIndex=0;itemIndex< _feedItemsArray.count ;itemIndex++)
    {
        NSString* itemTitle = [[_feedItemsArray objectAtIndex:itemIndex]
                               objectForKey:@"title"];
        if([filteredTitle isEqualToString:itemTitle])
        {
            break;
        }
        
    }
    return itemIndex;
}

#pragma mark - UISearchDisplayController delegate methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterItemsWithString:searchString];
    
    return YES;
}


#pragma mark - Notification Methods

- (void)appDidBecomeActive:(NSNotification *)notification
{
    NSNumber *newMaxItemsPerFeed=[self getMaxNumberofItemsPerFeed];
    if(newMaxItemsPerFeed != self.oldMaxItemsPerFeed)
    {
        [self getRSSFeeds];
        self.oldMaxItemsPerFeed=newMaxItemsPerFeed;
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if tableView is in searchDisplay mode
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.filteredItemsArray count];
    }
    else
    {
        return [self.feedItemsArray count];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"itemCell";
    NSDictionary *feedDictionary= NULL;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if(self.searchDisplayController.active)
    {
       if([self.filteredItemsArray count] >0)
       {
        feedDictionary=[self.filteredItemsArray objectAtIndex:indexPath.row];
       }
    }
    else
    {
        if(self.feedItemsArray.count>0)
        {
            feedDictionary=[self.feedItemsArray objectAtIndex:indexPath.row];
        }
    }
    
    if(feedDictionary != NULL)
    {
      NSString *feedTitle=[feedDictionary objectForKey:@"title"];
      NSString *feedTitletrimmedString = [feedTitle stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
      cell.textLabel.text = feedTitletrimmedString;
      NSString *feedDate=[feedDictionary objectForKey:@"pubdate"];
      NSString *feedDatetrimmedString = [feedDate stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
      cell.detailTextLabel.text=feedDatetrimmedString;
    }
    
    cell.textLabel.numberOfLines=0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    cell.detailTextLabel.textColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.6 alpha:0.7];
    
    return cell;
}

#pragma mark - Table view Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *text=[[_feedItemsArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    NSString *trimmedText= [text stringByTrimmingCharactersInSet:
    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    

    NSString *dateString=[[_feedItemsArray objectAtIndex:indexPath.row] objectForKey:@"pubdate"];
    NSString *dateTrimmedString = [dateString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    UIFont *cellTextFont = [UIFont fontWithName:@"Helvetica" size:16.0];
    UIFont *cellDetailTextFont = [UIFont fontWithName:@"Helvetica" size:12.0];
    
    NSAttributedString *attributedText =[[NSAttributedString alloc]initWithString:trimmedText
                                                                       attributes:@
                                         {
                                         NSFontAttributeName: cellTextFont
                                         }];
    
    NSAttributedString *attributedDateString =[[NSAttributedString alloc]initWithString:
                                               dateTrimmedString             attributes:@
                                               {
                                                    NSFontAttributeName:          cellDetailTextFont
                                               }];
    
    CGRect celltextRect = [attributedText boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                             context:nil];
    CGRect cellDetailTextRect = [attributedDateString boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                             context:nil];
    return (celltextRect.size.height+cellDetailTextRect.size.height+30);
    
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RDWebViewController *destination=[segue destinationViewController];
    destination.urlArray=_feedLinksArray;

    if(self.searchDisplayController.active)
    {
        NSIndexPath *filteredArrayIndexPath=[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        destination.rowIndex=[self mapItemIndexFromFilteredArrayIndex
                              :filteredArrayIndexPath.row];
        [_filteredItemsArray removeAllObjects];
        
    }
    else
    {
        NSIndexPath *indexPath=[self.tableView indexPathForSelectedRow];
        destination.rowIndex=indexPath.row;
    }

}


@end
