//
//  RDFeedsViewController.m
//  RSSReader
//
//  Created by Ramya Krishna on 11/16/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import "RDFeedsViewController.h"
#import "RDDatabaseManager.h"


@interface RDFeedsViewController ()

@property (strong,nonatomic) NSMutableArray *feedsArray;
@property (strong,nonatomic) NSMutableArray *selectedFeedsArray;

@end

@implementation RDFeedsViewController

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
    self.title=_category_title;
    self.feedsArray=[[NSMutableArray alloc] init];
    self.selectedFeedsArray=[[NSMutableArray alloc] init];
    self.tableView.allowsMultipleSelection=YES;
    [self getFeedsPerCategory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getFeedsPerCategory
{
    PFQuery *query = [PFQuery queryWithClassName:@"feeds"];
    [query whereKey:@"category_id" equalTo:_category_id];
    [query selectKeys:@[@"feed_id",@"feed_title",@"feed_image"]];
    [query orderByAscending:@"feed_id"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [self.feedsArray addObjectsFromArray:objects];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            //[self.tableView reloadData];
            
        }
        else
        {
            UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",[error userInfo]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
        }
    }];

    
}

- (IBAction)subscribeToFeeds:(UIBarButtonItem *)sender
{
    
    for(int i=0;i< [self.selectedFeedsArray count];i++)
    {
      int feed=[[self.selectedFeedsArray objectAtIndex:i] intValue];
      NSNumber *feedId=[[self.feedsArray objectAtIndex:feed] objectForKey:@"feed_id"];
      [self addFeedToSubscription:feedId];
    }
    [self.selectedFeedsArray removeAllObjects];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [self.feedsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"feedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(self.feedsArray.count>0)
    {
        NSString *feedTitle=[[self.feedsArray objectAtIndex:indexPath.row] objectForKey:@"feed_title"];
        UIImage *transparentImage=[UIImage imageNamed:@"transparent.png"];
        
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image=transparentImage;
        PFFile *file=[[self.feedsArray objectAtIndex:indexPath.row] objectForKey:@"feed_image"];
        
        [file getDataInBackgroundWithBlock:^(NSData *imageData,NSError *error)
         {
             if (!error) {
                 UIImage *feedImage=[UIImage imageWithData:imageData];
                 cell.imageView.image=feedImage;
                 
             } else {
                 
                 UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",[error userInfo]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [errorAlert show];
             }
         }];
        
        
        cell.textLabel.text=feedTitle;
        if([self.selectedFeedsArray containsObject:[NSNumber numberWithInteger:indexPath.row]])
        {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.selectedFeedsArray containsObject:[NSNumber numberWithInteger:indexPath.row]])
    {
        [self.selectedFeedsArray removeObject:[NSNumber numberWithInteger:indexPath.row]];
    }
    else
    {
        [self.selectedFeedsArray addObject:[NSNumber numberWithInteger:indexPath.row]];
    }
    //[self.tableView reloadData];
   [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}



#pragma mark - Database insertion method

/* inserting subscribed feed_id to sqlite   */
-(void)addFeedToSubscription:(NSNumber*)feedId
{
    NSString *const createSubscriptionSql = @"CREATE TABLE IF NOT EXISTS Subscription (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,feed_id INTEGER UNIQUE)";
    RDDatabaseManager *database = [RDDatabaseManager initInstance];
    [database createTableWithSQL:createSubscriptionSql];
    NSString *insertSql = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO Subscription (feed_id) VALUES (%@)", feedId];
    [database saveRSSDataWithSQL:insertSql];
}
@end
