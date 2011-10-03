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
@end

@implementation WordList

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
	fclose(file);
	return success;
}


- (void)insertNewWord:(NSString*) word {
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	
	
	if(0 == [self numberOfWordsInDictionary]) {
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
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;//number of sections;
}
*/

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;//<#number of rows in section#>;
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
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
								[NSEntityDescription entityForName:@"Searched" 
											inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	
	NSSortDescriptor*		nameDescriptor	= 
								[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray*				sortDescriptors	= 
								[[NSArray alloc] initWithObjects:nameDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
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
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

