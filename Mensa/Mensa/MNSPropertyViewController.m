//
//  MNSPropertyViewController.m
//  Mensa
//
//  Created by Jordan Kay on 12/15/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSProperty.h"
#import "MNSPropertyView.h"
#import "MNSPropertyViewController.h"

@implementation MNSPropertyViewController

- (void)updateView:(MNSPropertyView *)view withObject:(MNSProperty *)property
{
    UITextField *inputField = view.inputField;
    if (property.allowsUserInput) {
        inputField.placeholder = property.name;
        inputField.text = property.value;
        inputField.hidden = NO;
        inputField.delegate = self;
        self.inputProperty = property;
    } else {
        inputField.hidden = YES;
        inputField.delegate = nil;
        self.inputProperty = nil;
    }
}

#pragma mark - NSObject

- (void)dealloc
{
    MNSPropertyView *view = (MNSPropertyView *)self.view;
    view.inputField.delegate = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.inputProperty.value = [textField.text length] ? textField.text : textField.placeholder;
}

@end
