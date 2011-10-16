//
//  WordList.h
//  QuickDic
//
//  Created by Donut on 11. 9. 25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FetchedResultsTableViewController.h"

@interface WordList : FetchedResultsTableViewController {
	NSPredicate*		searchPredicate;
}

@property (nonatomic, retain) NSPredicate*			searchPredicate;
@end
