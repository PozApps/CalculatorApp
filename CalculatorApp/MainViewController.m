//
//  ViewController.m
//  Calculator
//
//  Created by Nadav Pozmantir on 30/09/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import "MainViewController.h"
#import "Calculator.h"
#import "ResultViewController.h"
#import "LogTableViewController.h"
#import "Result.h"

NSString * const kLogFile = @"/results.plist";

@interface MainViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *expressionTextField;
@property (weak, nonatomic) IBOutlet UITextView *errorTextView;

@property (nonatomic) NSMutableArray *logArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self loadResultsLog];
    });
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Handling Events
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(event.type == UIEventSubtypeMotionShake)
    {
        NSError *error;
        
        NSString *expression = self.expressionTextField.text;
        NSNumber *result = [[Calculator sharedInstace] calc:expression error:&error];
        
        if (!result) {
            [self.errorTextView setText:[error localizedDescription]];
        } else {
            [self.errorTextView setText:@""];
        
            Result *expressionResult = [[Result alloc] initWithExpression:expression result:result];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self logResult:expressionResult];
            });
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ResultViewController *resultViewController = [storyboard instantiateViewControllerWithIdentifier:@"ResultViewController"];
            [resultViewController setResult:result];
            [self presentViewController:resultViewController animated:YES completion:nil];
        }
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

 #pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([[segue identifier] isEqualToString:@"LogTableViewSegue"]) {
         LogTableViewController *logTableViewController = [segue destinationViewController];
         [logTableViewController setResultsArray:self.logArray];
     }
 }

#pragma mark - Log Results
- (void)loadResultsLog {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:kLogFile];
    NSData *logData = [NSData dataWithContentsOfFile:filePath];
    self.logArray = [NSKeyedUnarchiver unarchiveObjectWithData:logData];
    
    if (!self.logArray) {
        self.logArray = [NSMutableArray new];
    }
}


- (void)logResult:(Result *)result {
    
    [self.logArray insertObject:result atIndex:0];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.logArray];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:kLogFile];
    
    [data writeToFile:filePath atomically:YES];
}

#pragma mark - Release
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
