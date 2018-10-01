//
//  Stack.h
//  iOSPractice
//
//  Created by Nadav Pozmantir on 27/09/2018.
//  Copyright © 2018 Nadav Pozmantir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;

- (instancetype)init;
- (void)push:(id)object;
- (id)pop;
- (id)peek;
- (void)clear;

@end
