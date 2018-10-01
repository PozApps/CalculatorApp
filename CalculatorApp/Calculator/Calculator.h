//
//  Calculator.h
//  iOSPractice
//
//  Created by Nadav Pozmantir on 27/09/2018.
//  Copyright © 2018 Nadav Pozmantir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Calculator : NSObject

+ (instancetype)sharedInstace;
- (NSNumber *)calc:(NSString *)expression error:(NSError **)error;

@end
