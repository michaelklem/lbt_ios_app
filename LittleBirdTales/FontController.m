//
//  FontController.m
//  LittleBirdTales
//
//  Created by Mac on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FontController.h"

@implementation FontController
@synthesize fontSize, fontName, delegate;

#pragma mark - View lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(IBAction)back:(id)sender {
    if (!IsIdiomPad && self.delegate) {
        [self.delegate fontDidSelected:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    return [fonts count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView 
             titleForRow:(NSInteger)row 
            forComponent:(NSInteger)component {
    return [fonts objectAtIndex:row];
}

- (CGSize) contentSizeForViewInPopover
{
	return CGSizeMake(320, 416);
}
-(IBAction)fontSizeChanged:(id)sender {
    self.fontSize = roundf(fontSizeSlider.value);
    fontLabel.font = [UIFont fontWithName:self.fontName size:self.fontSize];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.fontName = [fonts objectAtIndex:row];
    fontLabel.font = [UIFont fontWithName:self.fontName size:self.fontSize];
}

-(BOOL)prefersStatusBarHidden { return YES; }


- (void)viewDidLoad {
    [super viewDidLoad];
    fonts = [[NSMutableArray alloc] init];
    for (NSString* family in [UIFont familyNames]) {
        [fonts addObjectsFromArray:[UIFont fontNamesForFamilyName:family]];
    }
    int selectedIndex = 0;
    for (int i = 0; i < fonts.count; i ++) {
        if ([[fonts objectAtIndex:i] isEqualToString:self.fontName]) {
            selectedIndex = i;
            break;
        }
    }
    [fontPicker selectRow:selectedIndex inComponent:0 animated:NO];
    fontSizeSlider.value = self.fontSize;
    fontLabel.font = [UIFont fontWithName:self.fontName size:self.fontSize];
    if (IsIdiomPad) {
        backBtn.hidden = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
