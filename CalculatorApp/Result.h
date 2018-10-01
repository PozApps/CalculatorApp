//
//  Result.h
//  CalculatorApp
//
//  Created by Nadav Pozmantir on 30/09/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Result : NSObject <NSCoding>

@property (nonatomic) NSString *expression;
@property (nonatomic) NSNumber *result;

- (instancetype)initWithExpression:(NSString *)e result:(NSNumber *)r;


@end
