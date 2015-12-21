//
//  RDRSSEntityWebViewController.h
//  RSSReader
//
//  Created by Ramya Krishna on 11/22/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "RDCustomLabel.h"

@interface RDWebViewController : UIViewController<UIActionSheetDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playPreviousButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playNextButton;
@property (nonatomic) NSInteger rowIndex;
@property (strong,nonatomic) NSMutableArray *urlArray;

- (IBAction)playPreviousFeed:(id)sender;
- (IBAction)openInSafari:(UIBarButtonItem *)sender;
- (IBAction)playNextFeed:(id)sender;
-(void)loadWebView;
-(void)showStatusLabel;
-(void)hideStatusLabel;

@end
