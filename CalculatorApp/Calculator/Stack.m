//
//  Stack.m
//  iOSPractice
//
//  Created by Nadav Pozmantir on 27/09/2018.
//  Copyright © 2018 Nadav Pozmantir. All rights reserved.
//

#import "Stack.h"

@interface Stack()
@property (nonatomic) NSMutableArray *objects;
@end

@implementation Stack

- (instancetype)init {
    if ((self = [super init])) {
        _objects = [NSMutableArray new];
    }
    return self;
}

- (NSUInteger)count {
    return _objects.count;
}

- (void)push:(id)object {
    if (object) {
        [_objects addObject:object];
    }
}

- (id)pop {
    id lastObject = [_objects lastObject];
    if (lastObject) {
        [_objects removeLastObject];
    }
    return lastObject;
}

- (id)peek {
    return [_objects lastObject];
}

- (void)clear {
    [_objects removeAllObjects];
}

@end
