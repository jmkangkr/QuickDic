//
//  WordList.m
//  QuickDic
//
//  Created by Donut on 11. 9. 25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WordList.h"
#import "log.h"

@interface WordList ()
- (unsigned int)numberOfWordsInDictionary;
- (BOOL)initializeDictionaryDatabase;
- (BOOL)initializeDictionaryDatabaseWithRawFile:(NSString*)rawFile;

- (void)insertNewWord:(NSString*)word;

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

- (void)filterContentForSearchText:(NSString*)aSearchText scope:(NSString*)scope;

@end

@implementation WordList

@synthesize	searchPredicate;

@synthesize	searchedWords		= searchedWords_;

@synthesize fetchedResultsController	= fetchedResultsController_;
@synthesize managedObjectContext		= managedObjectContext_;

#pragma mark -
#pragma mark searched Words
- (NSArray*)searchedWords {
	if(searchedWords_ != nil) {
		return searchedWords_;
	}
	
	self.searchedWords = [self.fetchedResultsController fetchedObjects];
	
	return searchedWords_;
}

#pragma mark -
#pragma mark WordList
- (unsigned int)numberOfWordsInDictionary {
	int wordCount = 0;
	
	for(id <NSFetchedResultsSectionInfo> si in [self.fetchedResultsController sections]) {
		wordCount += [si numberOfObjects];
	}
	
	return wordCount;
}

- (BOOL)initializeDictionaryDatabase {
	NSString* rawFile = [[NSBundle mainBundle] pathForResource:@"wordlist.60" ofType:@"txt"];
	
	return [self initializeDictionaryDatabaseWithRawFile:rawFile];
}

- (BOOL)initializeDictionaryDatabaseWithRawFile:(NSString*)rawDictionaryFilePath {
	static const int	MAX_WORD = 512;
	FILE*				file;
	char				line[MAX_WORD];
	char*				token;
	BOOL				success = TRUE;
#if defined(DEBUG)
	int					count = 0;
#endif
	
	file = fopen(rawDictionaryFilePath.UTF8String, "r");
	
	if(file == NULL) {
		success = FALSE;
		goto END;
	}
	
	while (TRUE) {
		char*		acquired;
		
		acquired = fgets(line, MAX_WORD, file);
		
		if(acquired != NULL) {
			token = strtok(line, "\t\n\r ");
			if(token != NULL && strlen(token) > 1) {
#if defined(DEBUG)
				count += 1;
#endif
				VLog(@"%s", token);
				[self insertNewWord:[NSString stringWithUTF8String:token]];
			}
		} else {
			if (ferror(file)) {
				success = FALSE;
			}
			goto END;
		}
	}
	
END:
#if defined(DEBUG)
	VLog(@"%d word entries are created.", count);
#endif
	fclose(file);
	return success;
}


- (void)insertNewWord:(NSString*) word {
	NSManagedObjectContext* context = [self.fetchedResultsController managedObjectContext];
    NSManagedObject* newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];

    [newManagedObject setValue:word forKey:@"name"];
	[newManagedObject setValue:nil forKey:@"searched"];

    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    NSManagedObject* managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[managedObject valueForKey:@"name"] description];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	unsigned int wordCount;
	
	wordCount = [self numberOfWordsInDictionary];
	
	VLog(@"Number of words in the dictionary: %d", wordCount);
	
	if(0 == wordCount) {
		[self initializeDictionaryDatabase];
	}
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.searchedWords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WordCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)aSearchText scope:(NSString*)scope
{
	NSUInteger length = [aSearchText length];
	
	if(length <= 0)
		return;
	
	NSMutableString* regex = [[NSMutableString alloc] initWithCapacity:(length * 3 + 2 + 2)];
	
	[regex appendFormat:@"^%c", [aSearchText characterAtIndex:0]];
	for(NSUInteger i = 1; i < length; i++ ) {
		[regex appendFormat:@".*%c", [aSearchText characterAtIndex:i]];
	}
	[regex appendFormat:@".*$"];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name MATCHES[cd] %@", regex];
	
	self.searchPredicate = predicate;
	
	[regex release];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchString:(NSString*)searchString
{
    [self filterContentForSearchText:searchString 
							   scope:[[self.searchDisplayController.searchBar scopeButtonTitles] 
									  objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
	
	self.fetchedResultsController = nil;
	self.searchedWords = nil;
	
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
	NSFetchRequest*			fetchRequest	= 
								[[NSFetchRequest alloc] init];
	NSEntityDescription*	entity			= 
								[NSEntityDescription entityForName:@"Word" 
											inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	
	NSSortDescriptor*		nameDescriptor	= 
								[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray*				sortDescriptors	= 
								[[NSArray alloc] initWithObjects:nameDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	[fetchRequest setPredicate:self.searchPredicate];
	
	NSFetchedResultsController*	aFetchedResultsController = 
				[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
													managedObjectContext:self.managedObjectContext 
													  sectionNameKeyPath:nil
															   cacheName:nil];
	
	self.fetchedResultsController		= aFetchedResultsController;
	aFetchedResultsController.delegate	= self;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[nameDescriptor release];
	[sortDescriptors release];
	
	NSError *error = nil;
    if (![fetchedResultsController_ performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	return fetchedResultsController_;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	self.searchPredicate = nil;
	
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;
}


- (void)dealloc {
	[self.searchPredicate release];
	
	[fetchedResultsController_ release];
	[managedObjectContext_ release];
	
    [super dealloc];
}


@end

