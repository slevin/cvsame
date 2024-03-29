//
//  CVDoodSet.m
//  cvsame
//
//  Created by Sean Levin on 9/10/13.
//  Copyright (c) 2013 Sean Levin. All rights reserved.
//

#import "CVDoodSet.h"
#import "CVDood.h"

NSString* const DoodSetAllRemovedNotification = @"allRemoved";
NSString* const DoodSetStuckNotification = @"stuck";

@implementation CVColumnRow

+ (instancetype)columnRowWithColumn:(NSInteger)aColumn row:(NSInteger)aRow {
    CVColumnRow *cr = [CVColumnRow new];
    cr.column = aColumn;
    cr.row = aRow;
    return cr;
}

@end

@interface CVDoodSet ()

@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, assign) NSInteger deleteCount;

@end

@implementation CVDoodSet

- (instancetype)initWithDoodSet:(CVDoodSet*)aDoodSet {
    if ((self = [super init])) {
        NSMutableArray *newColumns = [NSMutableArray new];
        for (NSArray *oldCol in aDoodSet.columns) {
            NSMutableArray *newCol = [NSMutableArray new];
            for (CVDood *oldDood in oldCol) {
                [newCol addObject:[oldDood copy]];
            }
            [newColumns addObject:newCol];
        }
        self.columns = [newColumns copy];
    }
    return self;
}

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
        NSInteger randomHeight = arc4random_uniform(10) + 5;
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

- (void)clearAllDoodStates {
    [self enumerateDoods:^(CVDood *dood, NSInteger column, NSInteger row) {
        dood.doodState = kCVDoodNormal;
    }];
    self.deleteCount = 0;
}

- (void)testRemoveableDoodsRemaining {
    BOOL anyLeft = [self removeableDoodsRemaining];
    if (anyLeft == NO) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DoodSetStuckNotification object:self];
    }
}

- (BOOL)removeableDoodsRemaining {
    NSInteger item = 0;
    BOOL outerFoundRemovable = NO;
    for (NSArray *col in self.columns) {
        BOOL foundRemovable = NO;
        for (CVDood *dood in col) {
            CVDoodSet *doodSetCopy = [self copy];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
            NSInteger deleteCount = [doodSetCopy tryRemoveAtIndexPath:indexPath];
            if (deleteCount > 1) {
                foundRemovable = YES;
                break;
            } else {
                item++;
            }
        }
        if (foundRemovable) {
            outerFoundRemovable = YES;
            break;
        }
    }
    return outerFoundRemovable;
}

- (NSInteger)tryRemoveAtIndexPath:(NSIndexPath*)anIndexPath {
    NSInteger column, row;
    [self columnRowForDoodAtIndexPath:anIndexPath outColumn:&column outRow:&row];
    CVColumnRow *colRow = [CVColumnRow columnRowWithColumn:column row:row];
    [self clearAllDoodStates];
    [self tryRemoveAtColumnRow:colRow];
    return self.deleteCount;
}

- (void)tryRemoveAtColumnRow:(CVColumnRow*)aColumnRow {
    CVDood *thisDood = self.columns[aColumnRow.column][aColumnRow.row];
    thisDood.doodState = kCVDoodDelete;
    self.deleteCount += 1;
    NSArray *neighbors = [self neighborsOfColumnRow:aColumnRow];
    for (CVColumnRow *colRow in neighbors) {
        CVDood *thatDood = self.columns[colRow.column][colRow.row];
        if (thatDood.doodState == kCVDoodNormal && thatDood.doodType == thisDood.doodType) {
            [self tryRemoveAtColumnRow:colRow];
        }
    }
}

- (NSArray*)indexPathsOfDeletedDoods {
    NSMutableArray *array = [NSMutableArray new];
    __block NSInteger item = 0;
    [self.columns enumerateObjectsUsingBlock:^(NSArray *col, NSUInteger colIdx, BOOL *stop) {
        [col enumerateObjectsUsingBlock:^(CVDood *dood, NSUInteger rowIdx, BOOL *stop) {
            if (dood.doodState == kCVDoodDelete) {
                [array addObject:[NSIndexPath indexPathForItem:item inSection:0]];
            }
            item++;
        }];
    }];
    return [array copy];
}

- (void)removeDeletedDoods {
    // objects collapse down
    // and over to the left (if the column is empty)
    
    NSMutableArray *newColumns = [NSMutableArray new];
    NSMutableIndexSet *emptyColumns = [NSMutableIndexSet new];
    [self.columns enumerateObjectsUsingBlock:^(NSArray *col, NSUInteger colIdx, BOOL *stop) {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
        [col enumerateObjectsUsingBlock:^(CVDood *dood, NSUInteger rowIdx, BOOL *stop) {
            if (dood.doodState == kCVDoodDelete) {
                [indexSet addIndex:rowIdx];
            }
        }];
        NSMutableArray *newCol = [col mutableCopy];
        [newCol removeObjectsAtIndexes:indexSet];
        [newColumns addObject:newCol];
        if (newCol.count == 0) {
            [emptyColumns addIndex:colIdx];
        }
    }];

    [newColumns removeObjectsAtIndexes:emptyColumns];
    self.columns = newColumns;
    
    if (self.columns.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DoodSetAllRemovedNotification object:self];
    }
    
}

- (NSArray*)neighborsOfColumnRow:(CVColumnRow*)aColumnRow {
    NSMutableArray *array = [NSMutableArray new];
    NSArray *col = self.columns[aColumnRow.column];
    
    // up
    if (aColumnRow.row + 1 < col.count) {
        [array addObject:[CVColumnRow columnRowWithColumn:aColumnRow.column row:aColumnRow.row + 1]];
    }
    // right
    if (aColumnRow.column + 1 < self.columns.count && ((NSArray*)self.columns[aColumnRow.column + 1]).count > aColumnRow.row) {
        [array addObject:[CVColumnRow columnRowWithColumn:aColumnRow.column + 1 row:aColumnRow.row]];
    }
    // down
    if (aColumnRow.row > 0) {
        [array addObject:[CVColumnRow columnRowWithColumn:aColumnRow.column row:aColumnRow.row - 1]];
    }
    // left
    if (aColumnRow.column > 0 && ((NSArray*)self.columns[aColumnRow.column - 1]).count > aColumnRow.row) {
        [array addObject:[CVColumnRow columnRowWithColumn:aColumnRow.column - 1 row:aColumnRow.row]];
    }
    return array;
}


@end
