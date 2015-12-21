//
//  RDCategoriesViewController.m
//  RSSReader
//
//  Created by Ramya Krishna on 11/3/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import "RDCategoriesViewController.h"

@interface RDCategoriesViewController ()

@property (strong,nonatomic) NSMutableArray *categoriesArray;

@end

@implementation RDCategoriesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Categories";
    self.categoriesArray=[[NSMutableArray alloc] init];
    [self getCategories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* Retrieving categories from parse database */
-(void)getCategories
{
    PFQuery *query = [PFQuery queryWithClassName:@"category"];
    [query orderByAscending:@"category_id"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            [self.categoriesArray addObjectsFromArray:objects];
            [self.collectionView reloadData];
            
        }
        else
        {
            UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",[error userInfo]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
        }
    }];
 
}

#pragma mark - collectionView Data Source and Delegate Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.categoriesArray count];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   RDCategoryCell  *cell =(RDCategoryCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
    PFFile *file=[[self.categoriesArray objectAtIndex:indexPath.row] objectForKey:@"category_image"];
    [file getDataInBackgroundWithBlock:^(NSData *imageData,NSError *error)
     {
         if (!error)
         {
             UIImage *categoryImage=[UIImage imageWithData:imageData];
             cell.categoryImage.image=categoryImage;
             
         }
         else
         {
             UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",[error userInfo]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [errorAlert show];
         }
     }];
    
    cell.categoryName.text=[[self.categoriesArray objectAtIndex:indexPath.row] objectForKey:@"category_name"];
    
    return cell;
    
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *categoryChosen=[[self.categoriesArray objectAtIndex:indexPath.row] objectForKey:@"category_name"];
    if([categoryChosen isEqualToString:@"Custom"])
    {
        [self performSegueWithIdentifier:@"autoDiscoverySegue" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"browseFeedSegue" sender:nil];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath=[self.collectionView indexPathsForSelectedItems][0];
    if([[segue identifier] isEqualToString:@"browseFeedSegue"])
    {
     RDFeedsViewController *destinationViewController= [segue destinationViewController];
      destinationViewController.category_id=[[self.categoriesArray objectAtIndex:indexPath.row] objectForKey:@"category_id"];
        destinationViewController.category_title=[[self.categoriesArray objectAtIndex:indexPath.row] objectForKey:@"category_name"];
    }

}


@end
