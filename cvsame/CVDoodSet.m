//
//  CVDoodSet.m
//  cvsame
//
//  Created by Sean Levin on 9/10/13.
//  Copyright (c) 2013 Sean Levin. All rights reserved.
//

#import "CVDoodSet.h"
#import "CVDood.h"

@interface CVDoodSet ()

@property (nonatomic, strong) NSArray *columns;

@end

@implementation CVDoodSet

- (instancetype)initWithColumnCount:(NSInteger)aColumnCount {
    if ((self = [super init])) {
        [self loadWithRandomDoods:aColumnCount];
    }
    return self;
}

- (void)loadWithRandomDoods:(NSInteger)aColumnCount {
    NSMutableArray *columns = [NSMutableArray new];
    for (int i = 0; i < aColumnCount; i++) {
        NSMutableArray *newColumn = [NSMutableArray new];
        NSInteger randomHeight = arc4random_uniform(10) + 10;
        for (int j = 0; j < randomHeight; j++) {
            CVDood *dood = [[CVDood alloc] init];
            [dood randomizeType];
            [newColumn addObject:dood];
        }
        [columns addObject:newColumn];
    }
    self.columns = columns;
}

- (NSInteger)maxDoodHeight {
    NSInteger maxHeight = 0;
    for (NSArray *col in self.columns) {
        if (col.count > maxHeight) {
            maxHeight = col.count;
        }
    }
    return maxHeight;
}

- (NSInteger)numberOfColumns {
    return self.columns.count;
}

- (NSInteger)numberOfDoods {
    NSInteger count = 0;
    for (NSArray *col in self.columns) {
        count += col.count;
    }
    return count;
}

- (void)enumerateDoods:(void(^)(CVDood *dood, NSInteger column, NSInteger row))anEnumerationBlock {
    [self.columns enumerateObjectsUsingBlock:^(NSArray *col, NSUInteger colIdx, BOOL *stop) {
        [col enumerateObjectsUsingBlock:^(CVDood *dood, NSUInteger rowIdx, BOOL *stop) {
            anEnumerationBlock(dood, colIdx, rowIdx);
        }];
    }];
}

- (CVDood*)doodForIndexPath:(NSIndexPath*)anIndexPath {
    NSInteger row;
    NSInteger column;
    [self columnRowForDoodAtIndexPath:anIndexPath outColumn:&column outRow:&row];
    if (column > (self.columns.count - 1)) {
        return nil;
    } else {
        NSArray *col = self.columns[column];
        if (row > (col.count - 1)) {
            return nil;
        } else {
            CVDood *foundDood = col[row];
            return foundDood;
        }
    }
}

- (NSIndexPath*)indexPathForDoodAtColumn:(NSInteger)aColumn row:(NSInteger)aRow {
    __block NSInteger count = 0;
    [self.columns enumerateObjectsUsingBlock:^(NSArray *col, NSUInteger idx, BOOL *stop) {
        if (aColumn == idx) {
            count += aRow;
            *stop = YES;
        } else {
            count += col.count;
        }
    }];
    NSIndexPath *path = [NSIndexPath indexPathForItem:count inSection:0];
    return path;
}

- (void)columnRowForDoodAtIndexPath:(NSIndexPath*)anIndexPath outColumn:(NSInteger*)aColumn outRow:(NSInteger*)aRow {
    __block NSInteger count = anIndexPath.item;
    [self.columns enumerateObjectsUsingBlock:^(NSArray *col, NSUInteger idx, BOOL *stop) {
        if (count < col.count) {
            *aColumn = idx;
            *aRow = count;
            *stop = YES;
        } else {
            count -= col.count;
        }
    }];
}


@end
