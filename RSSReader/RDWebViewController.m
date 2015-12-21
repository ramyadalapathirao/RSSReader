//
//  RDRSSEntityWebViewController.m
//  RSSReader
//
//  Created by Ramya Krishna on 11/22/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import "RDWebViewController.h"

@interface RDWebViewController ()

@property (strong,nonatomic) NSURL *feedUrl;
@property (nonatomic) BOOL animate;
@property (nonatomic) BOOL animate_left_to_right;
@property (nonatomic) BOOL animate_right_to_left;
@property (strong,nonatomic) RDCustomLabel *statusLabel;

@end

@implementation RDWebViewController

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
    _animate=false;
    if(_rowIndex+1==_urlArray.count)
    {
        self.playNextButton.enabled=NO;
    }
    if(_rowIndex == 0)
    {
        self.playPreviousButton.enabled=NO;
    }
    self.navigationController.toolbarHidden=NO;
    [self loadWebView];
    
}

-(void)loadWebView
{
    NSString *feedUrlString=[_urlArray objectAtIndex:_rowIndex];
    _feedUrl=[NSURL URLWithString:[feedUrlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:_feedUrl];
    [self.webView loadRequest:urlRequest];
    
}


-(void)showStatusLabel
{
    self.statusLabel = [[RDCustomLabel alloc] initWithFrame:CGRectMake(70, 200, 200, 50)];
    self.statusLabel.text = @"Loading web page";
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.backgroundColor=[UIColor blackColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont fontWithName:@"helvetica" size:18];
    [ self.webView addSubview:self.statusLabel];
    self.statusLabel.hidden = NO;
}

-(void)hideStatusLabel
{
    self.statusLabel.hidden = YES;
}


-(void)viewWillDisappear:(BOOL)animated
{
   self.navigationController.toolbarHidden=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)playNextFeed:(id)sender
{
    if(!(_rowIndex+1==_urlArray.count))
    {
        _rowIndex++;
        if(_rowIndex+1==_urlArray.count)
        {
            self.playNextButton.enabled=NO;
        }
        if(_rowIndex>0)
        {
            self.playPreviousButton.enabled=YES;
        }
        _animate=false;
        _animate_right_to_left = true;
        [self loadWebView];
    }
    else
    {
        self.playNextButton.enabled=NO;
    }
}
- (IBAction)playPreviousFeed:(id)sender
{
    if(!(_rowIndex-1<0))
    {
        _rowIndex--;
        if(_rowIndex==0)
        {
            self.playPreviousButton.enabled=NO;
        }
        if(_rowIndex-1<_urlArray.count)
        {
            self.playNextButton.enabled=YES;
        }
        _animate=false;
        _animate_left_to_right = true;
        [self loadWebView];
        //animate_left_to_right = false;
    }
    else
    {
        self.playPreviousButton.enabled=NO;
    }
    
}


#pragma mark-Action sheet delegate methods

- (IBAction)openInSafari:(UIBarButtonItem *)sender
{
    UIActionSheet *action= [[UIActionSheet alloc] initWithTitle:@"Options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Open in Safari", @"Share with Facebook",@"Tweet this page",nil];
    [action showInView:[UIApplication sharedApplication].keyWindow];
    
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex==0)
    {
        [[UIApplication sharedApplication] openURL:_feedUrl];
    }
    if(buttonIndex==1)
    {
        SLComposeViewController *controller = [SLComposeViewController         composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:[_feedUrl absoluteString]];
        [self presentViewController:controller animated:YES completion:Nil];
    }
    if(buttonIndex==2)
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[_feedUrl absoluteString]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    
}


#pragma mark-web view delegate methods

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    
    if(!_animate)
    {
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setDuration:0.8f];
        animation.startProgress = 0.3;
        animation.endProgress   = 1;
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setType:kCATransitionPush];
        
        if(_animate_left_to_right)
        {
            [animation setSubtype:kCATransitionFromLeft];
        }
        else
        {
            [animation setSubtype:kCATransitionFromRight];
        }
        [[self.webView layer] addAnimation:animation forKey:@"WebPageCurl"];
        _animate=true;
        [self showStatusLabel];
    }
    
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(!webView.loading)
    {
        [self hideStatusLabel];
        _animate_left_to_right = false;
        _animate_right_to_left = false;
    }
}

@end
