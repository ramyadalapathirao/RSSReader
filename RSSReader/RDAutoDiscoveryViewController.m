//
//  RDAutoDiscoveryViewController.m
//  RSSReader
//
//  Created by Ramya Krishna on 11/23/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import "RDAutoDiscoveryViewController.h"


@interface RDAutoDiscoveryViewController ()

@property (nonatomic) NSURLConnection *URLConnection;
@property (strong,nonatomic) NSMutableData *dataRecieved;
@property (strong,nonatomic) NSDictionary *linkFound;
@property (strong,nonatomic) NSURL *rssLink;
@property (nonatomic) BOOL autodiscovery;

@end

@implementation RDAutoDiscoveryViewController

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)subscribe:(UIButton *)sender
{
    [self.view endEditing:YES];
    NSString *inputUrl=[[_customFeedURLField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([_customFeedNameField.text isEqualToString:@""])
    {
        
        UIAlertView *inputErrorAlert=[[UIAlertView alloc] initWithTitle:@"Input Error" message:@"Please enter the name of the website or blog" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [inputErrorAlert show];
        return;
        
    }
    if([inputUrl isEqualToString:@""])
    {
        UIAlertView *inputErrorAlert=[[UIAlertView alloc] initWithTitle:@"Input Error" message:@"Please enter a valid url" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [inputErrorAlert show];
        return;
        
    }
    
    if(!([inputUrl hasPrefix:@"http://"] ||[inputUrl hasPrefix:@"https://"]))
    {
        inputUrl=[@"http://" stringByAppendingString:inputUrl];
    }
    NSURL *url=[NSURL URLWithString:inputUrl];
    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:url];
    _URLConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    _statusLabel.text=@"Searching...";
   
}

#pragma mark-NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{

    if([[response MIMEType] hasSuffix:@"xml"])
    {
        
       // NSLog(@"the url entered is a rss link. Just Parse it");
        _autodiscovery=false;
        _rssLink=[response URL];
        
    }
    else
    {
          _dataRecieved=[[NSMutableData alloc] init];
       // NSLog(@"the url entered is a web page. Do Autorecovery");
        _autodiscovery=true;
    }
    
}


- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    /* if the url entered is not a rss link find rss link */
    if(_autodiscovery)
    {
        
      [_dataRecieved appendData:data];
      [self findRSSLink];
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if(_rssLink==nil)
    {
        UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not find rss link"                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errorAlert show];
        _statusLabel.text=@"";
        _customFeedURLField.text=@"";
        _customFeedNameField.text=@"";
    }
    else
    {
        [self addCustomFeedWithTitle:_customFeedNameField.text andUrl:[NSString stringWithFormat:@"%@",_rssLink]];
    }
    
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    
    NSString *connectionError=[error localizedDescription];
    UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:@"Connection Error" message:connectionError  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    _statusLabel.text=@"";
    
}

#pragma mark-Auto Discovery Methods

-(void)addCustomFeedWithTitle:(NSString *)feedTitle andUrl:(NSString *)feedUrl
{
    RDDatabaseManager *database = [RDDatabaseManager initInstance];
    
    NSString *const createCustomSubscriptionSql = @"CREATE TABLE IF NOT EXISTS CustomSubscription (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,feed_title TEXT,feed_url TEXT UNIQUE)";
    [database createTableWithSQL:createCustomSubscriptionSql];
    
    NSString *insertSql = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO CustomSubscription (feed_title,feed_url) VALUES ('%@','%@')", feedTitle,feedUrl];
    [database saveRSSDataWithSQL:insertSql];
    
    _statusLabel.text=@"";
    UIAlertView *successAlert=[[UIAlertView alloc] initWithTitle:@"RSS Link Found" message:@"Subscription added to your custom feed list"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [successAlert show];
    _customFeedNameField.text=@"";
    _customFeedURLField.text=@"";
}

/* searching for link with rel="alternate" and type="application/rss+xml" (or) type="application/atom+xml" */
-(void)findRSSLink
{
    BOOL isAlternate=false;
    BOOL isRss=false;
    BOOL isAtom=false;
    NSString *beginString=@"<link ";
    NSString *endString=@">";
    NSInteger dataRecievedLength=[_dataRecieved length];
    NSString *pageSource=[[NSString alloc] initWithBytesNoCopy:(void *)[_dataRecieved bytes] length:dataRecievedLength encoding:NSUTF8StringEncoding freeWhenDone:NO];
    NSScanner *htmlScanner=[NSScanner scannerWithString:pageSource];
    [htmlScanner setCaseSensitive:NO];
	[htmlScanner setCharactersToBeSkipped:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    while ([htmlScanner scanUpToString:beginString intoString:nil]) {
		NSString * linkString = nil;
		if ([htmlScanner scanUpToString:endString intoString:&linkString])
        {
            //NSLog(@"link is:%@",linkString);
			_linkFound = [self getLinkAttributesFromString:linkString];
			NSString * relation = [_linkFound valueForKey:@"rel"];
			NSString * mediaType = [_linkFound valueForKey:@"type"];
            if([relation caseInsensitiveCompare:@"alternate"] == NSOrderedSame)
            {
                
                isAlternate=true;
            }
            if(mediaType && [mediaType caseInsensitiveCompare:@"application/rss+xml"] == NSOrderedSame)
            {
                
                isRss=true;
            }
            if(mediaType && [mediaType caseInsensitiveCompare:@"application/atom+xml"] == NSOrderedSame)
            {
                
                isAtom=true;
            }
            if(isAlternate && (isAtom || isRss))
            {
                break;
            }
            
            else
            {
                _linkFound=nil;
            }
            isAlternate = false;
            isRss = false;
            isAtom = false;
		}
	}
    _rssLink=[_linkFound valueForKey:@"href"];
    
}

/* searching for attributes of a link(rel,type,href) and storing in a dictionary  */
- (NSDictionary *) getLinkAttributesFromString:(NSString *) linkTag
{
	NSMutableDictionary * linkAttributesDictionary = [[NSMutableDictionary alloc] init];
	NSString * keyString = nil;
	NSString * valueString = nil;
	NSString *beginString=@"=\"";
    NSString *endString=@"\"";
	NSScanner * linkScanner = [NSScanner scannerWithString:linkTag];
	[linkScanner setCaseSensitive:NO];
	[linkScanner setCharactersToBeSkipped:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[linkScanner scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:nil];
	
	while([linkScanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&keyString])
    {
		if([linkScanner scanString:beginString intoString:nil] && [linkScanner scanUpToString:endString intoString:&valueString])
        {
           
                [linkAttributesDictionary setObject:valueString forKey:keyString];
          
		}   
		[linkScanner scanUpToCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:nil];
	}
	return linkAttributesDictionary;
}

#pragma mark-textfield delegate method

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self.view endEditing:YES];
}

- (IBAction)cancel:(UIButton *)sender
{
    [self.view endEditing:YES];
   _statusLabel.text=@"";
    _customFeedURLField.text=@"";
    _customFeedNameField.text=@"";
}
@end
