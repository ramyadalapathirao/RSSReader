//
//  RDAutoDiscoveryViewController.h
//  RSSReader
//
//  Created by Ramya Krishna on 11/23/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDDatabaseManager.h"

@interface RDAutoDiscoveryViewController : UIViewController<NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *customFeedNameField;
@property (weak, nonatomic) IBOutlet UITextField *customFeedURLField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)subscribe:(UIButton *)sender;
- (IBAction)cancel:(UIButton *)sender;
-(void)addCustomFeedWithTitle:(NSString *)feedTitle andUrl:(NSString *)feedUrl;
-(void)findRSSLink;
- (NSDictionary *) getLinkAttributesFromString:(NSString *) linkTag;

@end
