//
//  RDDatabaseManager.m
//  RSSReader
//
//  Created by Ramya Krishna on 11/29/14.
//  Copyright (c) 2014 Ramya Krishna. All rights reserved.
//

#import "RDDatabaseManager.h"
static NSString* const databaseName=@"RDRSSReader.db";
static sqlite3 *database;
@implementation RDDatabaseManager
+(instancetype) initInstance
{
    static dispatch_once_t once;
    static id instance = nil;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (NSString *) databasePath
{
    NSString *appHome = NSHomeDirectory();
    NSString *documents = [appHome stringByAppendingPathComponent:@"Documents"];
    return [documents stringByAppendingPathComponent:databaseName];
}
- (BOOL) open
{
    if (self.isOpen) return YES;
    self.isOpen = YES;
    if (sqlite3_open([[self databasePath] UTF8String], &database) != SQLITE_OK)
    {
        [self close];
        self.isOpen = NO;
    }
    return self.isOpen;
}
-(void)close
{
    if(!self.isOpen)
        return;
    sqlite3_close(database);
    database=NULL;
}
-(BOOL)createTableWithSQL:(NSString*)createSql
{
    if(![self open])
        return NO;
    char *errorMsg;
    if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        [self close];
        return NO;
    }
    return YES;
}
-(BOOL)saveRSSDataWithSQL:(NSString*)insertSQL
{
    if (![self open]) return NO;
    sqlite3_stmt *insert;
    if (sqlite3_prepare_v2(database, [insertSQL UTF8String], -1, &insert, nil) != SQLITE_OK)
        return NO;
    if (sqlite3_step(insert) != SQLITE_DONE)
        return NO;
    sqlite3_finalize(insert);
    return YES;
}
-(NSMutableArray*)findFeedDataWithSQL:(NSString*)selectSQL
{
    if (![self open])
        return NO;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *read;
    if(sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &read, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(read) == SQLITE_ROW)
        {
            int feedId =sqlite3_column_int(read, 0);
            NSNumber *feed_id=[NSNumber numberWithInt:feedId];
            [array addObject:feed_id];
        }
    }
    else
    {
        return NULL;
    }
    sqlite3_finalize(read);
    
    return array;

}

-(NSMutableArray*)findCustomFeedDataWithSQL:(NSString*)selectSQL
{
    if (![self open])
        return NO;
    
    NSMutableArray *customFeedsArray = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *read;
    if(sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &read, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(read) == SQLITE_ROW)
        {
            NSMutableDictionary *customFeedDictionary=[[NSMutableDictionary alloc] init];
            NSString *feedTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(read, 0)];
            NSString *feedUrl = [NSString stringWithUTF8String:(char *)sqlite3_column_text(read,
                                                                                           1)];
            [customFeedDictionary setObject:feedTitle forKey:@"feed_title"];
            [customFeedDictionary setObject:feedUrl forKey:@"feed_url"];
            [customFeedsArray addObject:customFeedDictionary];
        }
    }
    else
    {
        return NULL;
    }
    sqlite3_finalize(read);
    
    return customFeedsArray;
    
}


-(void)registerForBackgroundTransitions
{
    UIApplication *application=[UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:application];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:application];
    
}
-(void)unregisterForBackgroundTransitions
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)applicationWillResignActive:(NSNotification*)notification
{
    [self close];
}
-(void)applicationWillEnterForeground:(NSNotification*)notification
{
    [self open];
}

-(void)dealloc
{
    [self unregisterForBackgroundTransitions];
}



@end
