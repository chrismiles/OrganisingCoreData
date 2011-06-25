//
//  ModelUtil.m
//
//  Created by Chris Miles on 17/02/11.
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

#import "ModelUtil.h"


NSManagedObjectContext *
defaultManagedObjectContext()
{
	NSManagedObjectContext *moc = nil;
	
	id appDelegate = [[UIApplication sharedApplication] delegate];
	if ([appDelegate respondsToSelector:@selector(managedObjectContext)]) {
		moc = [appDelegate managedObjectContext];
	}
	
	return moc;
}

BOOL
commitDefaultMOC()
{
	NSManagedObjectContext *moc = defaultManagedObjectContext();
	NSError *error = nil;
	if (![moc save:&error]) {
		// Save failed
		NSLog(@"Core Data Save Error: %@, %@", error, [error userInfo]);
		return NO;
	}
	return YES;
}

void
rollbackDefaultMOC()
{
	NSManagedObjectContext *moc = defaultManagedObjectContext();
	[moc rollback];
}

void
deleteManagedObjectFromDefaultMOC(NSManagedObject *managedObject)
{
	NSManagedObjectContext *moc = defaultManagedObjectContext();
	[moc deleteObject:managedObject];
}

NSArray *
fetchManagedObjects(NSString *entityName, NSPredicate *predicate, NSArray *sortDescriptors, NSManagedObjectContext *moc)
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
	
	// Add a sort descriptor. Mandatory.
	[fetchRequest setSortDescriptors:sortDescriptors];
	fetchRequest.predicate = predicate;
	
	NSError *error;
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
	
	if (fetchResults == nil) {
		// Handle the error.
		NSLog(@"executeFetchRequest failed with error: %@", [error localizedDescription]);
	}
	
	[fetchRequest release];
	
	return fetchResults;
}

NSManagedObject *
fetchManagedObject(NSString *entityName, NSPredicate *predicate, NSArray *sortDescriptors, NSManagedObjectContext *moc)
{
	NSArray *fetchResults = fetchManagedObjects(entityName, predicate, sortDescriptors, moc);
	
	NSManagedObject *managedObject = nil;
	
	if (fetchResults && [fetchResults count] > 0) {
		// Found record
		managedObject = [fetchResults objectAtIndex:0];
	}
	
	return managedObject;	
}
