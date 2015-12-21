//
//  RDDatabaseManager.h
//  RSSReader
//
//  Created by Ramya Krishna on 11/29/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface RDDatabaseManager : NSObject
@property BOOL isOpen;

+(instancetype) initInstance;
-(BOOL)createTableWithSQL:(NSString*)createSql;
-(BOOL)saveRSSDataWithSQL:(NSString*)insertSQL;
-(void)registerForBackgroundTransitions;
-(void)unregisterForBackgroundTransitions;
-(NSMutableArray*)findFeedDataWithSQL:(NSString*)selectSQL;
-(NSMutableArray*)findCustomFeedDataWithSQL:(NSString*)selectSQL;
@end
