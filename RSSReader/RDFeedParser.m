//
//  RDFeedParser.m
//  RSSReader
//
//  Created by Ramya Krishna on 12/9/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import "RDFeedParser.h"
@interface RDFeedParser ()

@property (strong,nonatomic) RDRSSItem *item;
@property (nonatomic) BOOL isAtom;
@property (nonatomic) int maxItemsPerFeed;
@property (strong,nonatomic) NSMutableArray *itemsArray;
@property (strong,nonatomic) NSMutableArray *linksArray;
@property (strong,nonatomic) NSString* element;

@end


@implementation RDFeedParser

-(id)initWithMaxNumberOfItemsPerFeed:(int)maxItems
{
    self = [super init];
    if (self)
    {
        _maxItemsPerFeed=maxItems;
    }
    
    return  self;
}

#pragma mark - NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //NSLog(@"found file and started parsing");
    self.itemsArray=[[NSMutableArray alloc] init];
    self.linksArray=[[NSMutableArray alloc] init];
	
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %li )", (long)[parseError code]];
    
    _onFailure(errorString);
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _element=elementName;
    //support for RSS 2.0
    if([elementName isEqualToString:@"item"])
    {
        self.item=[[RDRSSItem alloc] init];
        self.item.elements=[[NSMutableDictionary alloc] init];
        self.item.title=[[NSMutableString alloc] init];
        self.item.link=[[NSMutableString alloc] init];
        self.item.pubDate=[[NSMutableString alloc] init];
    }
    //Support for Atom 1.0 format
    if([elementName isEqualToString:@"entry"])
    {
        _isAtom=true;
        self.item=[[RDRSSItem alloc] init];
        self.item.elements=[[NSMutableDictionary alloc] init];
        self.item.title=[[NSMutableString alloc] init];
        self.item.link=[[NSMutableString alloc] init];
        self.item.pubDate=[[NSMutableString alloc] init];
        
    }
    if([elementName hasPrefix:@"link"] && _isAtom && _item.link != NULL)
    {
        NSLog(@"link:%@",[attributeDict objectForKey:@"href"]);
        [self.item.link appendString:[attributeDict objectForKey:@"href"]];
    }
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if([elementName isEqualToString:@"item"])
    {
        
        [[self.item elements] setObject:_item.title forKey:@"title"];
        [[self.item elements] setObject:_item.link forKey:@"link"];
        [[self.item elements] setObject:_item.pubDate forKey:@"pubdate"];
        if([self.itemsArray count] < _maxItemsPerFeed)
        {
            [self.itemsArray addObject:[_item elements]];
            [self.linksArray addObject:_item.link];
        }
        self.item = NULL;
    }
    if([elementName isEqualToString:@"entry"])
    {
        _isAtom=false;
        [[self.item elements] setObject:_item.title forKey:@"title"];
        [[self.item elements] setObject:_item.link forKey:@"link"];
        [[self.item elements] setObject:_item.pubDate forKey:@"pubdate"];
        if([self.itemsArray count] < _maxItemsPerFeed)
        {
            [self.itemsArray addObject:[_item elements]];
            [self.linksArray addObject:_item.link];
        }
        self.item = NULL;
    }
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([_element isEqualToString:@"title"])
    {
        [self.item.title appendString:string];
    }
    if([_element isEqualToString:@"link"] && !_isAtom)
        
    {
        [self.item.link appendString:string];
    }
    if([_element isEqualToString:@"pubDate"] || [_element isEqualToString:@"published"])
        
    {
        [self.item.pubDate appendString:string];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    if(_onCompletion)
    {
    _onCompletion(self.itemsArray,self.linksArray);
    }

}


@end
