//
//  Calculator.m
//  iOSPractice
//
//  Created by Nadav Pozmantir on 27/09/2018.
//  Copyright © 2018 Nadav Pozmantir. All rights reserved.
//

#import "Calculator.h"
#import "Stack.h"

NSString * const kExpressionError = @"com.pozapps.Calculator";

typedef enum {
    OPERATOR_EMPTY,
    OPERATOR_ADD,
    OPERATOR_SUBTRACT,
    OPERATOR_MULTIPLY,
    OPERATOR_DIVIDE,
    OPERATOR_POWER,
    OPERATOR_PARENTHESES_OPEN,
    OPERATOR_PARENTHESES_CLOSE
} Operator;

@interface Calculator ()
    @property (nonatomic) Stack *numbers;
    @property (nonatomic) Stack *operators;
@end

@implementation Calculator

+ (instancetype)sharedInstace {
    static Calculator *instance;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        instance = [[Calculator alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.numbers = [Stack new];
        self.operators = [Stack new];
    }
    return self;
}

- (NSNumber *)calc:(NSString *)expression error:(NSError **)error {
    
    @try {
        // Clean all spaces
        expression = [expression stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        // General validation checks for the expression
        if (![self generalValidationChecks:expression error:error]) {
            return nil;
        }

        // Clear the stacks in case their holding objects from last run
        [self clearStacks];
        
        // Iterate the expression, organise the values and operators in stacks and compute them
        for (int i = 0; i < expression.length; i++) {
            
            // Check for open parentheses
            int openParenthesesCount = [self openParentheses:expression offset:i operators:self.operators];
            i += openParenthesesCount;
            
            // Get next value
            NSNumber *value = [self nextNumber:expression offset:i error:error];
            if (!value) {
                return nil;
            }
            [self.numbers push:value];
            
            if ([value doubleValue] > 0) {
                int numberLength = log10([value doubleValue]) + 1;
                i += numberLength;
            } else {
                i += 1;
            }
            
            if (i >= expression.length) {
                break;
            }
            
            // Check for close parentheses
            NSNumber *closeParenthesesCount = [self closeParentheses:expression offset:i operators:self.operators numbers:self.numbers error:error];
            if (!closeParenthesesCount) {
                return nil;
            }
            i += [closeParenthesesCount intValue];

            if (i >= expression.length) {
                break;
            }
            
            // Get next operator and calculate if needed
            Operator currOperator = [self nextOperator:expression offset:i];
            [self calcByPriority:currOperator operators:self.operators onLastNumbers:self.numbers];
            [self.operators push:@(currOperator)];
        }
        
        // Calculate the rest of the stacks
        [self calcByPriority:OPERATOR_EMPTY operators:self.operators onLastNumbers:self.numbers];
        
        
        NSNumber *result;
        if ([self.numbers count] == 1 && [self.operators count] == 0) {
            // The final result should be found in the numbers stack as only one object
            result = [self.numbers pop];
        } else {
            if (error != NULL) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:@"Expression is invalid"
                             forKey:NSLocalizedDescriptionKey];
                
                *error = [[NSError alloc] initWithDomain:kExpressionError
                                                    code:4
                                                userInfo:userInfo];
            }
            return nil;
        }

        return result;
    }
    @catch (NSException *exception) {
        if (error != NULL) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:@"Undefined error has occured"
                         forKey:NSLocalizedDescriptionKey];
            
            *error = [[NSError alloc] initWithDomain:kExpressionError
                                                code:6
                                            userInfo:userInfo];
        }
        return nil;
    }
    
}

- (void)clearStacks {
    [self.numbers clear];
    [self.operators clear];
}

- (int)operatorPriority:(Operator)operator {
    switch (operator) {
        case OPERATOR_EMPTY:
            return 0;
        case OPERATOR_ADD:
        case OPERATOR_SUBTRACT:
            return 1;
        case OPERATOR_MULTIPLY:
        case OPERATOR_DIVIDE:
            return 2;
        case OPERATOR_POWER:
            return 3;
        default:
            return 0;
    }
}

- (void)calcByPriority:(Operator)operator operators:(Stack *)operators onLastNumbers:(Stack *)numbers {
    while ([numbers count] >= 2 && [operators count] >= 1) {
        if ([self operatorPriority:operator] <= [self operatorPriority:[[self.operators peek] intValue]]) {
            [self evaluateOneExpression:operators numbers:numbers];
        } else {
            break;
        }
    }
}

- (BOOL)calcParenteses:(Stack *)operators onLastNumbers:(Stack *)numbers {
    while ([self.operators count] > 0 && [[self.operators peek] intValue] != OPERATOR_PARENTHESES_OPEN) {
        [self evaluateOneExpression:operators numbers:numbers];
    }
    
    // If no operators left then the expression was invalid
    if ([self.operators count] > 0) {
        [self.operators pop];
        return YES;
    } else {
        return NO;
    }
}

- (void)evaluateOneExpression:(Stack *)operators numbers:(Stack *)numbers {
    double b = [[numbers pop] doubleValue];
    double a = [[numbers pop] doubleValue];
    Operator operator = [[operators pop] intValue];
    double result = [self calc:operator onNum:a andNum:b];
    [numbers push:@(result)];
}

- (double)calc:(Operator)operator onNum:(double)a andNum:(double)b {
    switch (operator) {
        case OPERATOR_ADD:
            return a + b;
        case OPERATOR_SUBTRACT:
            return a - b;
        case OPERATOR_MULTIPLY:
            return a * b;
        case OPERATOR_DIVIDE:
            return a / b;
        case OPERATOR_POWER:
            return pow(a,b);
        case OPERATOR_EMPTY:
        default:
            return b;
    }
}

- (int)openParentheses:(NSString *)expression offset:(int)offset operators:(Stack *)operators {
    int count = 0;
    
    Operator operator = [self nextOperator:expression offset:offset];
    while (operator == OPERATOR_PARENTHESES_OPEN) {
        [operators push: @(operator)];
        offset++;
        count++;
        operator = [self nextOperator:expression offset:offset];
    }
    return count;
}

- (NSNumber *)closeParentheses:(NSString *)expression offset:(int)offset operators:(Stack *)operators numbers:(Stack *)numbers error:(NSError **)error {
    int count = 0;
    Operator operator = [self nextOperator:expression offset:offset];
    while (operator == OPERATOR_PARENTHESES_CLOSE) {
        if (![self calcParenteses:operators onLastNumbers:numbers]) {
            if (error != NULL) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:@"There are more close parentheses then open parentheses"
                             forKey:NSLocalizedDescriptionKey];
                
                // Populate the error reference.
                *error = [[NSError alloc] initWithDomain:kExpressionError
                                                    code:5
                                                userInfo:userInfo];
            }
            return nil;
        }
        offset++;
        count++;
        if (offset < [expression length]) {
            operator = [self nextOperator:expression offset:offset];
        } else {
            break;
        }
        
    }
    return @(count);
}

- (NSNumber *)nextNumber:(NSString *)expression offset:(int)offset error:(NSError **)error {
    NSString *nextStr = [self getNextStr:expression offset:offset];
    
    if ([nextStr isEqualToString:@"e"]) {
        return @(M_E);
    } else {
        
        NSMutableString *numberStr = [NSMutableString new];
        NSCharacterSet *nonDigitsSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        
        BOOL isNumber = false;
        while (offset < [expression length] && [nextStr rangeOfCharacterFromSet:nonDigitsSet].location == NSNotFound) {
            isNumber = true;
            [numberStr appendString:nextStr];
            offset++;
            if (offset < [expression length]) {
                nextStr = [self getNextStr:expression offset:offset];
            } else {
                break;
            }
        }
        
        if (isNumber) {
            return @([numberStr intValue]);
        } else {
            if (error != NULL) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:[NSString stringWithFormat:@"Number was expected, but found operator instead: '%@'",nextStr]
                             forKey:NSLocalizedDescriptionKey];
                
                // Populate the error reference.
                *error = [[NSError alloc] initWithDomain:kExpressionError
                                                    code:3
                                                userInfo:userInfo];
            }
            return nil;
        }
    }
}


- (Operator)nextOperator:(NSString *)expression offset:(int)offset {
    NSString *nextStr = [self getNextStr:expression offset:offset];
    
    if ([nextStr isEqualToString:@"+"]) {
        return OPERATOR_ADD;
    } else if ([nextStr isEqualToString:@"-"]) {
        return OPERATOR_SUBTRACT;
    } else if ([nextStr isEqualToString:@"*"]) {
        return OPERATOR_MULTIPLY;
    } else if ([nextStr isEqualToString:@"/"]) {
        return OPERATOR_DIVIDE;
    } else if ([nextStr isEqualToString:@"^"]) {
        return OPERATOR_POWER;
    } else if ([nextStr isEqualToString:@"("]){
        return OPERATOR_PARENTHESES_OPEN;
    } else if ([nextStr isEqualToString:@")"]){
        return OPERATOR_PARENTHESES_CLOSE;
    } else {
        return OPERATOR_EMPTY;
    }
}

- (NSString *)getNextStr:(NSString *)expression offset:(int)offset {
    return [expression substringWithRange:NSMakeRange(offset, 1)];
}

- (BOOL)generalValidationChecks:(NSString *)expression error:(NSError **)error {
    if (!expression.length) {
        if (error != NULL) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:@"Expression can't be empty"
                         forKey:NSLocalizedDescriptionKey];
            
            *error = [[NSError alloc] initWithDomain:kExpressionError
                                                code:1
                                            userInfo:userInfo];
        }
        return NO;
    }
    
    // Check for invalid characters
    NSMutableCharacterSet *possibleChars = [NSMutableCharacterSet decimalDigitCharacterSet];
    [possibleChars addCharactersInString:@"+-/*^e()"];
    NSRange range = [expression rangeOfCharacterFromSet:[possibleChars invertedSet]];
    if (range.location != NSNotFound) {
        if (error != NULL) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:[NSString stringWithFormat:@"Input error near '%@'",[expression substringWithRange:range]]
                         forKey:NSLocalizedDescriptionKey];
            
            *error = [[NSError alloc] initWithDomain:kExpressionError
                                                code:2
                                            userInfo:userInfo];
        }
        return NO;
    }
    
    return YES;
}
 
@end
