//
//  RDCategoriesViewController.h
//  RSSReader
//
//  Created by Ramya Krishna on 11/3/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RDCategoryCell.h"
#import "RDFeedsViewController.h"
#import "RDAutoDiscoveryViewController.h"

@interface RDCategoriesViewController : UICollectionViewController

-(void)getCategories;
@end
