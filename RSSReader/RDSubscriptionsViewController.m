//
//  feedsTableViewController.m
//  RSSReader
//
//  Created by Ramya Krishna on 11/3/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import "RDSubscriptionsViewController.h"
#import "RDDatabaseManager.h"

@interface RDSubscriptionsViewController ()

@property (strong,nonatomic) UILabel *messageLabel;
@property (strong,nonatomic) RDCustomLabel *loadingLabel;
@property (strong,nonatomic) NSMutableArray *subscriptionsArray;
@property (strong,nonatomic) NSMutableArray *filteredSubscriptionsArray;
@property (strong,nonatomic) NSMutableArray *categoryfeedlist;
@property (strong,nonatomic) NSMutableArray *customFeedsArray;
@property (nonatomic) BOOL feedsLoaded;
@property (strong,nonatomic) NSMutableArray *subscriptionList;
@end

@implementation RDSubscriptionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _feedsLoaded=false;
    self.navigationItem.leftBarButtonItem=self.editButtonItem;
    self.tableView.allowsSelection = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:YES];
    self.tableView.allowsSelection = NO;
    self.searchDisplayController.active = false;
    [self showLoadingLabel];
    _feedsLoaded=false;
    NSString *selectSql = [[NSString alloc] initWithFormat:@"SELECT feed_id FROM Subscription"];
    
    RDDatabaseManager *database = [RDDatabaseManager initInstance];
    if(database)
    {
        self.subscriptionList = [database findFeedDataWithSQL:selectSql];
    }
    
    if(self.subscriptionList==nil)
    {
        self.subscriptionList=[[NSMutableArray alloc] init];
    }
    
    if(_subscriptionsArray==nil)
        _subscriptionsArray=[[NSMutableArray alloc] init];
    else
        [_subscriptionsArray removeAllObjects];
    
    
    if(_categoryfeedlist==nil)
        _categoryfeedlist=[[NSMutableArray alloc] init];
    else
        [_categoryfeedlist removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:@"feeds"];
    
    [query selectKeys:@[@"feed_id",@"feed_title",@"feed_url",@"feed_image",@"category_id",@"category_pointer.category_name"]];
    [query whereKey:@"feed_id" containedIn:self.subscriptionList];
    [query includeKey:@"category_pointer"];
    [query orderByAscending:@"category_id"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [_subscriptionsArray addObjectsFromArray:objects];
            [self getSubscribedFeedsPerCategory];
            [self getCustomFeeds];
            _feedsLoaded=true;
            [self.tableView reloadData];
            [self hideLoadingLabel];
            self.tableView.allowsSelection = YES;
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*Traversing the subscriptionsArray and creating Array of arrays. Each array contains feed dictionary corresponding to specific category */
-(void) getSubscribedFeedsPerCategory
{

    for (NSDictionary *feedDictionary in _subscriptionsArray) {
        bool foundCategory = NO;
        NSNumber *categoryId = [feedDictionary objectForKey:@"category_id"];
        for (NSMutableArray *feedPerCategorySubArray in _categoryfeedlist) {
            NSNumber *categoryIdCompared = [feedPerCategorySubArray[0] objectForKey:@"category_id"];
            if (categoryId  == categoryIdCompared)
            {
                foundCategory = YES;
                [feedPerCategorySubArray addObject:feedDictionary];
                break;
            }
        }
    
        if (foundCategory == NO)
        {
            NSMutableArray *newfeedPerCategorySubArray = [[NSMutableArray alloc] initWithObjects:feedDictionary, nil];
            [_categoryfeedlist addObject:newfeedPerCategorySubArray];
        }
    }
}

-(void)showLoadingLabel
{
    self.loadingLabel = [[RDCustomLabel alloc] initWithFrame:CGRectMake(40, 130, 250, 80)];
    self.loadingLabel.text = @"Loading your subscriptions";
    self.loadingLabel.textColor = [UIColor whiteColor];
    self.loadingLabel.backgroundColor=[UIColor blackColor];
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.font = [UIFont fontWithName:@"helvetica" size:18];
    [ self.tableView addSubview:self.loadingLabel];
    self.loadingLabel.hidden = NO;
}

-(void)hideLoadingLabel
{
   self.loadingLabel.hidden = YES;
}

-(void) showMessageLabel
{
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.messageLabel.text = @"You have no subscriptions. Please click on + to subscribe";
    self.messageLabel.textColor = [UIColor blackColor];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [self.messageLabel sizeToFit];
    self.tableView.backgroundView = self.messageLabel;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.messageLabel.hidden = NO;
}

-(void) hideMessageLabel
{
   self.messageLabel.hidden = YES;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
}



/* given a section index and row index retrieving feed title */
-(NSString*) getFeedTitleAtRow:(NSInteger)rowIndex atSection:(NSInteger)sectionIndex
{
    NSString *feedTitle;
    NSArray *feedsInACategory=[_categoryfeedlist objectAtIndex:sectionIndex];
    feedTitle =[[feedsInACategory objectAtIndex:rowIndex] objectForKey:@"feed_title"];
    return feedTitle;
}

/* given a section index and row index retrieving feed url */
-(NSString*) getFeedUrlAtRow:(NSInteger)rowIndex atSection:(NSInteger)sectionIndex
{
    NSString *feedUrlstring;
    NSArray *feedsInACategory=[_categoryfeedlist objectAtIndex:sectionIndex];
    feedUrlstring =[[feedsInACategory objectAtIndex:rowIndex] objectForKey:@"feed_url"];
    return feedUrlstring;
}

/* given a section index retrieving section title */
-(NSString*) getCategoryTitlteAtSection:(NSInteger)sectionIndex
{
    NSString *categoryTitle;
    NSArray *feedsInACategory=[_categoryfeedlist objectAtIndex:sectionIndex];
    NSDictionary *firstFeed=[feedsInACategory objectAtIndex:0];
    categoryTitle =[firstFeed objectForKey:@"category_pointer"][@"category_name"];
    return categoryTitle;
}

/* given a section, checking if it is a custom section */
-(BOOL) isCustomSection:(NSInteger)sectionIndex
{
    if( sectionIndex == _categoryfeedlist.count)
        return YES;
    else
        return NO;
}


/* filter all feeds on title based on search string   */
-(void)filterFeedsWithString:(NSString*)searchString
{
    if([_filteredSubscriptionsArray count] > 0)
    {
        [_filteredSubscriptionsArray removeAllObjects];
    }
    NSString *key=@"feed_title";
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",key,searchString];
    _filteredSubscriptionsArray= [NSMutableArray arrayWithArray:[_subscriptionsArray filteredArrayUsingPredicate:predicate]];
    NSMutableArray *filteredCustomArray= [[NSMutableArray alloc] init];
    if(_customFeedsArray.count > 0)
    {
        filteredCustomArray = [NSMutableArray arrayWithArray:[_customFeedsArray filteredArrayUsingPredicate:predicate]];
        if(filteredCustomArray.count > 0)
        {
            [_filteredSubscriptionsArray addObjectsFromArray:filteredCustomArray];
        }
    }
}

#pragma mark - UISearchDisplayController delegate methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterFeedsWithString:searchString];
    
    return YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if(_subscriptionList.count > 0 ||
       _customFeedsArray.count > 0)
    {
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


#pragma mark - sqlite transactions

/* Retrive custom feeds from sqlite */
-(void)getCustomFeeds
{
    NSString *selectSql = @"SELECT feed_title, feed_url FROM CustomSubscription";
    RDDatabaseManager *database = [RDDatabaseManager initInstance];
    if(database)
    {
        _customFeedsArray = [database findCustomFeedDataWithSQL:selectSql];
    }
}


/* deleting custom feeds from sqlite  */
-(void) deleteCustomFeedAtRow:(NSInteger)rowIndex
{
    NSString *customFeedUrl = [_customFeedsArray[rowIndex] objectForKey:@"feed_url"];
    [_customFeedsArray removeObjectAtIndex:rowIndex];
    RDDatabaseManager *database = [RDDatabaseManager initInstance];
    NSString *deleteSql = [[NSString alloc] initWithFormat:@"DELETE FROM CustomSubscription where   feed_url=('%@')", customFeedUrl ];
    [database saveRSSDataWithSQL:deleteSql];
    
}

/* deleting feed_id from sqlite */
-(void) deleteFeedAtRow:(NSInteger)rowIndex atSection:(NSInteger)sectionIndex
{
    NSNumber *feedid=[[[_categoryfeedlist objectAtIndex:sectionIndex ] objectAtIndex:rowIndex] objectForKey:@"feed_id"];
    [[_categoryfeedlist objectAtIndex:sectionIndex] removeObjectAtIndex:rowIndex];
    [self.subscriptionList removeObject:feedid];
    if(self.subscriptionList.count == 0)
    {
        [_subscriptionsArray removeAllObjects];
    }
    RDDatabaseManager *database = [RDDatabaseManager initInstance];
    NSString *deleteSql = [[NSString alloc] initWithFormat:@"DELETE FROM Subscription where   feed_id=(%@)", feedid];
    [database saveRSSDataWithSQL:deleteSql];
    
}

#pragma mark - Table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount=0;
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        sectionCount =1;
    }
    else
    {
       if(_customFeedsArray.count>0)
       {
         sectionCount= _categoryfeedlist.count +1;
       }
       else
       {
         sectionCount= _categoryfeedlist.count;
       }
    
      if(sectionCount ==0 && _feedsLoaded)
      {
        [self showMessageLabel];
      }
      else
      {
        [self hideMessageLabel];
      }
    }
    return sectionCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount=0;
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return _filteredSubscriptionsArray.count;
    }
    else
    {
      if([self isCustomSection:section])
      {
        rowsCount= _customFeedsArray.count;
      }
      else
      {
        rowsCount= [[_categoryfeedlist objectAtIndex:section] count];

      }
    }
    return rowsCount;
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *section_title;
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return @"Search Results";
    }
    else
    {
      if([self isCustomSection:section])
      {
        section_title=@"Custom Feeds";
      }
      else
      {
         if([[_categoryfeedlist objectAtIndex:section] count] >0)
         {
            section_title=[self getCategoryTitlteAtSection:section];
         }
      }
    }
    return section_title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"subscriptionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UIImage *transparentImage=[UIImage imageNamed:@"transparent.png"];
    cell.imageView.image=transparentImage;
    
    /* if table view is in search display mode */
    if(self.searchDisplayController.active)
    {
      if(_filteredSubscriptionsArray.count > 0)
      {
        NSString *feedTitle= [[_filteredSubscriptionsArray objectAtIndex:indexPath.row ] objectForKey:@"feed_title" ];
        PFFile *file=[[_filteredSubscriptionsArray objectAtIndex:indexPath.row] objectForKey:@"feed_image"];
        NSNumber *feedid=[[_filteredSubscriptionsArray objectAtIndex:indexPath.row ] objectForKey:@"feed_id" ];
        
        if(feedid == NULL)
        {
          cell.imageView.image=[UIImage imageNamed:@"customicon.png"];
        }
        [file getDataInBackgroundWithBlock:^(NSData *imageData,NSError *error)
         {
             if (!error) {
                 UIImage *tempImage=[UIImage imageWithData:imageData];
                 cell.imageView.image=tempImage;
             }
             else {
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
         }];
        cell.textLabel.text=feedTitle;
      }
    }
    else
    {
        /* if section is custom feeds section */
        if([self isCustomSection:indexPath.section])
        {
            NSString *customFeedTitle=[_customFeedsArray[indexPath.row] objectForKey:@"feed_title"];
            cell.textLabel.text=customFeedTitle;
            cell.imageView.image=[UIImage imageNamed:@"customicon.png"];
            return cell;
        }
        /* for all other sections */
        if(_subscriptionsArray.count>0)
        {
          NSString *feedTitle= [self getFeedTitleAtRow:indexPath.row
                                         atSection:indexPath.section];
          PFFile *file=[[[_categoryfeedlist objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row] objectForKey:@"feed_image"];
          [file getDataInBackgroundWithBlock:^(NSData *imageData,NSError *error)
          {
               if (!error)
               {
                 UIImage *tempImage=[UIImage imageWithData:imageData];
                 cell.imageView.image=tempImage;
               }
               else
               {
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
               }
         }];
          cell.textLabel.text=feedTitle;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
      
      if([self isCustomSection:indexPath.section])
      {
          [self deleteCustomFeedAtRow:indexPath.row];
      }
      else
      {
          [self deleteFeedAtRow:indexPath.row atSection:indexPath.section];
      }
    
            [self.tableView reloadData];
    
    }  
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqual:@"segueToFeeds"])
    {
        NSString *feedUrlString;
        RDRSSItemsTableViewController *destination=[segue destinationViewController];
        NSIndexPath *indexPath=[self.tableView indexPathForSelectedRow];
        
        if(self.searchDisplayController.active)
        {
            if(_filteredSubscriptionsArray.count > 0)
            {
                indexPath =self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow;
                feedUrlString=[[_filteredSubscriptionsArray objectAtIndex:indexPath.row] objectForKey:@"feed_url"];
            }
            [_filteredSubscriptionsArray removeAllObjects];
        }
        else
        {
          if([self isCustomSection:indexPath.section])
          {
            feedUrlString=[_customFeedsArray[indexPath.row]
                           objectForKey:@"feed_url"];
          }
          else
          {
             feedUrlString=[self getFeedUrlAtRow:indexPath.row
                                       atSection:indexPath.section];
          }
        }
        destination.itemUrlString=feedUrlString;
    }
}



@end
