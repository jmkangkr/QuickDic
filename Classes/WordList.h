//
//  WordList.h
//  QuickDic
//
//  Created by Donut on 11. 9. 25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface WordList : UITableViewController 
<NSFetchedResultsControllerDelegate> {
	NSPredicate*		searchPredicate;
	
@private
	NSArray*			searchedWords_;

@private
    NSFetchedResultsController*	fetchedResultsController_;
    NSManagedObjectContext*		managedObjectContext_;
}

@property (nonatomic, retain) NSPredicate*			searchPredicate;

@property (nonatomic, retain) NSArray*				searchedWords;

@property (nonatomic, retain) NSManagedObjectContext*		managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController*	fetchedResultsController;

@end
