//
//  Result.m
//  CalculatorApp
//
//  Created by Nadav Pozmantir on 30/09/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import "Result.h"

@implementation Result

- (instancetype)initWithExpression:(NSString *)e result:(NSNumber *)r {
    if (self = [super init]) {
        _expression = e;
        _result = r;
    }
    
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _expression = [aDecoder decodeObjectForKey:@"expression"];
        _result = [aDecoder decodeObjectForKey:@"result"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_expression forKey:@"expression"];
    [aCoder encodeObject:_result forKey:@"result"];
}

@end
