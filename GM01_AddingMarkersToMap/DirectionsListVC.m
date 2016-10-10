//
//  DirectionsListVC.m
//  GM01_AddingMarkersToMap
//
//  Created by Aleksandr Pronin on 10/9/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import "DirectionsListVC.h"
#import "DirectionCell.h"

@interface DirectionsListVC ()

@end

@implementation DirectionsListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.steps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"html: %@", self.steps[indexPath.row][@"html_instructions"]);
    
    DirectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DirectionCell" forIndexPath:indexPath];
    NSString *directionHtml = [NSString stringWithFormat:@"<p style='font-family:verdana;font-size:80\%%'>%@</p>", self.steps[indexPath.row][@"html_instructions"]];
    NSString *distanceHtml = [NSString stringWithFormat:@"<p style='font-family:verdana;font-size:80\%%'>%@</p>", self.steps[indexPath.row][@"distance"][@"text"]];
    NSString *htmlString = [NSString stringWithFormat:@"<html><body>%@%@</bodu></html>", directionHtml, distanceHtml];
    [cell.webView loadHTMLString:htmlString baseURL:nil];
    return cell;
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
