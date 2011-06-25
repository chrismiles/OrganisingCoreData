//
//  DVDDetailViewController.m
//  OrganisingCoreData
//
//  Created by Chris Miles on 22/06/11.
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

#import "DVDDetailViewController.h"
#import "MODVD+Management.h"
#import "MOPerson.h"

@implementation DVDDetailViewController

@synthesize dvd;
@synthesize ownerNameLabel;
@synthesize purchaseDateLabel;
@synthesize titleLabel;


- (void)configureLabels
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	
	self.titleLabel.text = self.dvd.title;
	self.purchaseDateLabel.text = [dateFormatter stringFromDate:self.dvd.purchaseDate];
	self.ownerNameLabel.text = self.dvd.owner.name;
}


#pragma mark - UIControl actions

- (void)editAction:(id)sender
{
	AddEditDVDViewController *viewController = [[[AddEditDVDViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	viewController.delegate = self;
	viewController.dvd = self.dvd;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	[self presentModalViewController:navController animated:YES];
}


#pragma mark - AddDVDViewControllerDelegateDelegate methods

- (void)addDVDViewControllerDidFinish:(AddEditDVDViewController *)addDVDViewController
{
	[self configureLabels];
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"DVD";
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)] autorelease];
	
	[self configureLabels];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
	[dvd release];
	[ownerNameLabel release];
	[purchaseDateLabel release];
    [titleLabel release];
	
    [super dealloc];
}


@end
