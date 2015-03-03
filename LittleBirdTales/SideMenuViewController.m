//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "UserTalesController.h"
#import "UserLessonsController.h"
#import "UserLoginViewController.h"
#import "DownloadAssignmentsController.h"
#import "StudentDownloadTalesController.h"
#import "Lesson.h"
#import "Lib.h"

@implementation SideMenuViewController

NSArray *tableData;

#pragma mark -
#pragma mark - UITableViewDataSource

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize table data
    tableData = [NSArray arrayWithObjects:@"Tales", @"Download Tale", @"Lessons", @"Download Lesson", @"Logout", nil];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@%@", @"Logged in as ", [Lib getValueOfKey:@"user_name"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController* controller;
    switch(indexPath.row) {
        case 0:
            controller = [[UserTalesController alloc] initWithNibName:@"UserTalesController-iPad" bundle:nil];
            break;
        case 1:
            controller = [[StudentDownloadTalesController alloc] initWithNibName:@"StudentDownloadTalesController-iPad" bundle:nil];
            break;
        case 2:
            controller = [[UserLessonsController alloc] initWithNibName:@"UserLessonsController-iPad" bundle:nil];
            break;
        case 3:
            controller = [[DownloadAssignmentsController alloc] initWithNibName:@"DownloadAssignmentsController-iPad" bundle:nil];
            break;
        case 4:
            [Lib setValue:@"" forKey:@"logged_in"];
            [Lib setValue:@"" forKey:@"user_id"];
            [Lib setValue:@"" forKey:@"bucket_path"];
            [Lib setValue:@"" forKey:@"is_teacher"];
            [Lib setValue:@"" forKey:@"is_student"];
            [Lib setValue:@"" forKey:@"encrypted_user_id"];
            [Lib setValue:@"" forKey:@"user_name"];            
            [Lesson removeAll];
            controller = [[UserLoginViewController alloc] initWithNibName:@"UserLoginViewController-iPad" bundle:nil];
            break;
    }
    
    [self.menuContainerViewController.centerViewController pushViewController:controller animated:NO];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
