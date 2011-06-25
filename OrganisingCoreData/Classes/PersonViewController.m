//
//  LoginViewController.m
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

#import <QuartzCore/QuartzCore.h>
#import "PersonViewController.h"
#import "DVDListTableViewController.h"
#import "MOPerson+Management.h"
#import "UIView+CMExtras.h"


@implementation PersonViewController
@synthesize loginContainerView;
@synthesize registerContainerView;
@synthesize loginUsernameTextField;
@synthesize registerUsernameTextField;
@synthesize registerNameTextField;
@synthesize loginButton;
@synthesize registerButton;
@synthesize viewModeSegmentedControl;


- (void)changeViewMode:(PersonViewMode)viewMode animated:(BOOL)animated
{
	UIView *viewOn;
	UIView *viewOff;
	CGFloat offX;
	
	if (PersonViewModeLogin == viewMode) {
		viewOn = self.loginContainerView;
		viewOff = self.registerContainerView;
		offX = CGRectGetMaxX(self.view.bounds) + CGRectGetMidX(self.view.bounds);
	}
	else {
		viewOn = self.registerContainerView;
		viewOff = self.loginContainerView;
		offX = -CGRectGetMidX(self.view.bounds);
	}
	
	[self.view addSubview:viewOn];
	
	void (^viewChanges)(void) = ^{
		viewOn.center = CGPointMake(roundf(CGRectGetMidX(self.view.bounds)), viewOn.center.y);
		viewOff.center = CGPointMake(offX, viewOff.center.y);
	};
	
	void (^completion)(BOOL) = ^(BOOL finished) {
		[viewOff removeFromSuperview];
	};
	
//	if (animated) {
//		[UIView beginAnimations:nil context:nil];
//	}
//	
//	viewOn.center = CGPointMake(roundf(CGRectGetMidX(self.view.bounds)), viewOn.center.y);
//	viewOff.center = CGPointMake(offX, viewOff.center.y);
//	
//	if (animated) {
//		[UIView commitAnimations];
//	}
	
	if (animated) {
		[UIView animateWithDuration:0.2 delay:0.0 options:0 animations:viewChanges completion:completion];
	}
	else {
		viewChanges();
		completion(YES);
	}
	
	currentViewMode = viewMode;
}

- (NSString *)loginUsernameValue
{
	return [self.loginUsernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)registerUsernameValue
{
	return [self.registerUsernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)registerNameValue
{
	return [self.registerNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)configureLoginButton
{
	NSString *username = [self loginUsernameValue];
	if ([username length] == 0) {
		self.loginButton.enabled = NO;
		self.loginButton.alpha = 0.5;
	}
	else {
		self.loginButton.enabled = YES;
		self.loginButton.alpha = 1.0;
	}
}

- (void)configureRegisterButton
{
	NSString *username = [self registerUsernameValue];
	NSString *name = [self registerNameValue];
	if ([username length] == 0 || [name length] == 0) {
		self.registerButton.enabled = NO;
		self.registerButton.alpha = 0.5;
	}
	else {
		self.registerButton.enabled = YES;
		self.registerButton.alpha = 1.0;
	}
}


#pragma mark - UIControl actions

- (IBAction)modeSegmentValueChangedAction:(UISegmentedControl *)segmentedControl
{
	PersonViewMode selectedViewMode = (PersonViewMode)segmentedControl.selectedSegmentIndex;
	if (selectedViewMode != currentViewMode) {
		[self changeViewMode:selectedViewMode animated:YES];
	}
}

- (IBAction)loginUsernameTextFieldEditingChanged:(id)sender
{
	[self configureLoginButton];
}

- (IBAction)loginButtonAction:(id)sender
{
	[self.loginUsernameTextField resignFirstResponder];
	
	NSString *username = [self loginUsernameValue];
	if ([username length] > 0) {
		MOPerson *person = [MOPerson personWithUsername:username];
		if (person) {
			DVDListTableViewController *viewController = [[[DVDListTableViewController alloc] initWithNibName:nil bundle:nil] autorelease];
			viewController.person = person;
			[self.navigationController pushViewController:viewController animated:YES];
		}
		else {
			[self.loginContainerView shake];
		}
	}
}

- (IBAction)registerTextFieldEditingChanged:(id)sender
{
	[self configureRegisterButton];
}

- (IBAction)registerButtonAction:(id)sender {
	[self.registerUsernameTextField resignFirstResponder];
	[self.registerNameTextField resignFirstResponder];
	
	NSString *username = [self registerUsernameValue];
	NSString *name = [self registerNameValue];
	if ([username length] > 0 && [name length] > 0) {
		MOPerson *person = [MOPerson insertPersonWithUsername:username name:name];
		
		if (person && commitDefaultMOC()) {
			DVDListTableViewController *viewController = [[[DVDListTableViewController alloc] initWithNibName:nil bundle:nil] autorelease];
			viewController.person = person;
			[self.navigationController pushViewController:viewController animated:YES];
		}
		else {
			NSLog(@"Creation of Person managed object failed");
		}
	}
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.registerUsernameTextField) {
		[self.registerNameTextField becomeFirstResponder];
	}
	else {
		[textField resignFirstResponder];
	}
	
	return YES;
}


#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
	NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	CGRect keyboardFrame = [self.view.window convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.view];
	
	CGFloat centerY = roundf((CGRectGetMaxY(self.view.bounds)-CGRectGetHeight(keyboardFrame))/2);
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
	[UIView setAnimationBeginsFromCurrentState:YES];	// prevent a view jump when switching between fields
	self.loginContainerView.center = CGPointMake(self.loginContainerView.center.x, centerY);
	self.registerContainerView.center = CGPointMake(self.registerContainerView.center.x, centerY);
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
	self.loginContainerView.center = CGPointMake(self.loginContainerView.center.x, roundf(CGRectGetMidY(self.view.bounds)));
	self.registerContainerView.center = CGPointMake(self.registerContainerView.center.x, roundf(CGRectGetMidY(self.view.bounds)));
	[UIView commitAnimations];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];

	self.loginContainerView.layer.cornerRadius = 10.0;
	self.loginContainerView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
	self.loginContainerView.layer.shadowRadius = 3.0;
	self.loginContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.loginContainerView.layer.shadowOpacity = 0.7;
	
	self.registerContainerView.layer.cornerRadius = 10.0;
	self.registerContainerView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
	self.registerContainerView.layer.shadowRadius = 3.0;
	self.registerContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.registerContainerView.layer.shadowOpacity = 0.7;
	
	[self.view addSubview:self.registerContainerView];
	
	[self configureLoginButton];
	
	// Subscribe to keyboard visible notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [self setLoginContainerView:nil];
    [self setRegisterContainerView:nil];
	
	[self setLoginUsernameTextField:nil];
	[self setRegisterUsernameTextField:nil];
	[self setRegisterNameTextField:nil];
	[self setLoginButton:nil];
	[self setRegisterButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.viewModeSegmentedControl.selectedSegmentIndex = 0;
	self.loginContainerView.center = CGPointMake(roundf(CGRectGetMidX(self.view.bounds)), roundf(CGRectGetMidY(self.view.bounds)));
	self.registerContainerView.center = CGPointMake(roundf(CGRectGetMidX(self.view.bounds)), roundf(CGRectGetMidY(self.view.bounds)));
	[self changeViewMode:PersonViewModeLogin animated:NO];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [loginContainerView release];
    [registerContainerView release];
	[loginUsernameTextField release];
	[registerUsernameTextField release];
	[registerNameTextField release];
	[loginButton release];
	[registerButton release];
	[viewModeSegmentedControl release];
	
    [super dealloc];
}


@end
