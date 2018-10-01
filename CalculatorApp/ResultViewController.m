//
//  ResultViewController.m
//  CalculatorApp
//
//  Created by Nadav Pozmantir on 30/09/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (nonatomic) NSNumberFormatter *doubleValueWithMaxFiveDecimalPlaces;
@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumberFormatter *doubleValueWithMaxFiveDecimalPlaces = [[NSNumberFormatter alloc] init];
    [doubleValueWithMaxFiveDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [doubleValueWithMaxFiveDecimalPlaces setMaximumFractionDigits:5];
    
    [self.resultLabel setText:[doubleValueWithMaxFiveDecimalPlaces stringFromNumber:self.result]];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
