//
//  LogTableViewController.m
//  CalculatorApp
//
//  Created by Nadav Pozmantir on 30/09/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import "LogTableViewController.h"
#import "Result.h"

@interface LogTableViewController ()

@end

@implementation LogTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell" forIndexPath:indexPath];
    Result *expressionResult = [self.resultsArray objectAtIndex:indexPath.row];
    
    NSNumberFormatter *doubleValueWithMaxFiveDecimalPlaces = [[NSNumberFormatter alloc] init];
    [doubleValueWithMaxFiveDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [doubleValueWithMaxFiveDecimalPlaces setMaximumFractionDigits:5];
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@ = %@",expressionResult.expression,[doubleValueWithMaxFiveDecimalPlaces stringFromNumber:expressionResult.result]]];
    return cell;
}

@end
