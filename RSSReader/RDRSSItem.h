//
//  RDRSSEntity.h
//  RSSReader
//
//  Created by Ramya Krishna on 11/21/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDRSSItem : NSObject
@property (strong,nonatomic) NSMutableDictionary *elements;
@property (strong,nonatomic) NSMutableString *title;
@property (strong,nonatomic) NSMutableString *link;
@property (strong,nonatomic) NSMutableString *pubDate;
@end
