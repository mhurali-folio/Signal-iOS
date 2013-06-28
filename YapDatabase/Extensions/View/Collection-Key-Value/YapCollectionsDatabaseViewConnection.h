#import <Foundation/Foundation.h>
#import "YapAbstractDatabaseExtensionConnection.h"
#import "YapDatabaseViewChange.h"

@class YapCollectionsDatabaseView;


@interface YapCollectionsDatabaseViewConnection : YapAbstractDatabaseExtensionConnection

@property (nonatomic, strong, readonly) YapCollectionsDatabaseView *view;

/**
 * Familiar with NSFetchedResultsController?
 * Want an exact list of changes that happend to the view during any number of readwrite transactions?
 * 
 * You're in luck!
 * This is what this method does.
 * 
 * Here's how it works:
 *
**/
- (NSArray *)changesForNotifications:(NSArray *)notifications withGroupToSectionMappings:(NSDictionary *)mappings;

@end
