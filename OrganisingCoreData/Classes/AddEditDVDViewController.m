//
//  AddDVDViewController.m
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

#import "AddEditDVDViewController.h"
#import "MODVD+Management.h"
#import "MOPerson.h"

@implementation AddEditDVDViewController

@synthesize delegate;
@synthesize dvd;
@synthesize owner;
@synthesize addButton;
@synthesize purchaseDatePicker;
@synthesize titleTextField;


- (void)viewControllerFinished
{
	[delegate addDVDViewControllerDidFinish:self];
}

- (NSString *)titleValue
{
	return [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)updateAddButton
{
	NSString *title = [self titleValue];
	if ([title length] == 0) {
		self.addButton.enabled = NO;
		self.addButton.alpha = 0.5;
	}
	else {
		self.addButton.enabled = YES;
		self.addButton.alpha = 1.0;
	}
}


#pragma mark - UIControl actions

- (void)cancelAction:(id)sender
{
	[self viewControllerFinished];
}

- (IBAction)addButtonAction:(id)sender
{
	NSString *title = [self titleValue];
	if ([title length] > 0) {
		if (self.dvd) {
			self.dvd.title = title;
			self.dvd.purchaseDate = purchaseDatePicker.date;
		}
		else {
			[MODVD insertDVDWithTitle:title purchaseDate:purchaseDatePicker.date owner:self.owner];
		}
		commitDefaultMOC();
	}
	
	[self viewControllerFinished];
}

- (IBAction)titleTextFieldEditingChangedAction:(id)sender
{
	[self updateAddButton];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
	
	if (self.dvd) {
		self.titleTextField.text = self.dvd.title;
		self.purchaseDatePicker.date = self.dvd.purchaseDate;
		
		[self.addButton setTitle:@"Save" forState:UIControlStateNormal];
	}
	
	[self updateAddButton];
}

- (void)viewDidUnload
{
	[self setTitleTextField:nil];
	[self setAddButton:nil];
	[self setPurchaseDatePicker:nil];
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
	[addButton release];
	[dvd release];
	[owner release];
	[purchaseDatePicker release];
	[titleTextField release];
	
    [super dealloc];
}

@end
