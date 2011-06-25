//
//  AddDVDViewController.h
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

#import <UIKit/UIKit.h>

@class MODVD;
@class MOPerson;
@protocol AddEditDVDViewControllerDelegate;

@interface AddEditDVDViewController : UIViewController {
    
	UITextField *titleTextField;
	UIButton *addButton;
	UIDatePicker *purchaseDatePicker;
}

@property (nonatomic, assign)	id<AddEditDVDViewControllerDelegate>	delegate;

@property (nonatomic, retain)	MODVD			*dvd;
@property (nonatomic, retain)	MOPerson		*owner;

@property (nonatomic, retain) IBOutlet UIButton *addButton;
@property (nonatomic, retain) IBOutlet UIDatePicker *purchaseDatePicker;
@property (nonatomic, retain) IBOutlet UITextField *titleTextField;

- (IBAction)addButtonAction:(id)sender;
- (IBAction)titleTextFieldEditingChangedAction:(id)sender;

@end


@protocol AddEditDVDViewControllerDelegate <NSObject>
- (void)addDVDViewControllerDidFinish:(AddEditDVDViewController *)addDVDViewController;
@end
