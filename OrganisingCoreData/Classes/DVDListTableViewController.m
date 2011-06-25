//
//  DVDListTableViewController.m
//  OrganisingCoreData
//
//  Created by Chris Miles on 21/06/11.
//  Copyright 2011 Chris Miles. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "DVDListTableViewController.h"
#import "DVDDetailViewController.h"
#import "MODVD+Management.h"
#import "MOPerson.h"


@interface DVDListTableViewController ()
@property (nonatomic, retain)	NSFetchedResultsController		*tableFetchedResultsController;
@end


@implementation DVDListTableViewController

@synthesize person;
@synthesize tableFetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	MODVD *dvd = [self.tableFetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = dvd.title;
}


#pragma mark - UIControl actions

- (void)addAction:(id)sender
{
	AddEditDVDViewController *addDVDViewController = [[[AddEditDVDViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	addDVDViewController.delegate = self;
	addDVDViewController.owner = self.person;
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:addDVDViewController] autorelease];
	[self presentModalViewController:navigationController animated:YES];
}


#pragma mark - AddDVDViewControllerDelegateDelegate methods

- (void)addDVDViewControllerDidFinish:(AddEditDVDViewController *)addDVDViewController
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark NSFetchedResultsController set up

- (NSFetchedResultsController *)fetchedResultsControllerWithDelegate:(id)controllerDelegate
{
	NSString *cacheName = [NSString stringWithFormat:@"DVDAll%@", self.person.name];
	//[NSFetchedResultsController deleteCacheWithName:cacheName];	// DEBUG
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"DVD" inManagedObjectContext:defaultManagedObjectContext()]];
	
    // Add a sort descriptor. Mandatory.
    NSSortDescriptor *sortDescriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:nil] autorelease];
    NSArray *descriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    [fetchRequest setSortDescriptors:descriptors];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner == %@", self.person];
	fetchRequest.predicate = predicate;
	
    // Init the fetched results controller
    NSError *error;
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
															initWithFetchRequest:fetchRequest
															managedObjectContext:defaultManagedObjectContext()
															sectionNameKeyPath:nil
															cacheName:cacheName];
	fetchedResultsController.delegate = controllerDelegate;
	
    if (![fetchedResultsController performFetch:&error]) {
        DLog(@"Error %@", [error localizedDescription]);
	}
	
    [fetchRequest release];
	
	return [fetchedResultsController autorelease];
}

- (NSFetchedResultsController *)tableFetchedResultsController {
	if (nil == tableFetchedResultsController) {
		self.tableFetchedResultsController = [self fetchedResultsControllerWithDelegate:self];
	}
	return tableFetchedResultsController;
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[(UITableView *)self.view beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[(UITableView *)self.view insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
									withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[(UITableView *)self.view deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
									withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
	UITableView *tableView = (UITableView *)self.view;
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath]
					atIndexPath:indexPath
					   animated:YES];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[(UITableView *)self.view endUpdates];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = [NSString stringWithFormat:@"%@'s DVDs", self.person.name];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)] autorelease];
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	
	[self setToolbarItems:[NSArray arrayWithObjects:self.editButtonItem, nil]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger sectionCount = [[self.tableFetchedResultsController sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rowCount;
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.tableFetchedResultsController sections] objectAtIndex:section];
	rowCount = [sectionInfo numberOfObjects];
	return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DVDListTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	[self configureCell:cell atIndexPath:indexPath animated:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		MODVD *dvd = [self.tableFetchedResultsController objectAtIndexPath:indexPath];
		deleteManagedObjectFromDefaultMOC(dvd);
		commitDefaultMOC();
    }   
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MODVD *dvd = [self.tableFetchedResultsController objectAtIndexPath:indexPath];

	DVDDetailViewController *viewController = [[[DVDDetailViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	viewController.dvd = dvd;
	[self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - Memory management

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
	[person release];
	[tableFetchedResultsController release];
	
    [super dealloc];
}


@end
