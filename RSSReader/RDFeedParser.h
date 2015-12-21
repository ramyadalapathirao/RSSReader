//
//  RDFeedParser.h
//  RSSReader
//
//  Created by Ramya Krishna on 12/9/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDRSSItem.h"


@interface RDFeedParser : NSObject<NSXMLParserDelegate>

@property (strong,nonatomic) void (^onCompletion)(NSMutableArray *,NSMutableArray *);
@property (strong,nonatomic) void (^onFailure)(NSString *);

-(id)initWithMaxNumberOfItemsPerFeed:(int)maxItems;

@end
