//
//  CVDoodSet.h
//  cvsame
//
//  Created by Sean Levin on 9/10/13.
//  Copyright (c) 2013 Sean Levin. All rights reserved.
//

#import "MTLModel.h"

extern NSString* const DoodSetAllRemovedNotification;
extern NSString* const DoodSetStuckNotification;

@interface CVColumnRow : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong, readonly) NSArray *columns;

+ (instancetype)columnRowWithColumn:(NSInteger)aColumn row:(NSInteger)aRow;

@end

@class CVDood;

@interface CVDoodSet : MTLModel

@property (nonatomic, readonly, assign) NSInteger numberOfColumns;
@property (nonatomic, readonly, assign) NSInteger numberOfDoods;

- (instancetype)initWithColumnCount:(NSInteger)aColumnCount;

- (NSInteger)maxDoodHeight;

- (void)enumerateDoods:(void(^)(CVDood *dood, NSInteger column, NSInteger row))anEnumerationBlock;

- (NSIndexPath*)indexPathForDoodAtColumn:(NSInteger)aColumn row:(NSInteger)aRow;
- (void)columnRowForDoodAtIndexPath:(NSIndexPath*)anIndexPath outColumn:(NSInteger*)aColumn outRow:(NSInteger*)aRow;
- (CVDood*)doodForIndexPath:(NSIndexPath*)anIndexPath;

/// deleting actions
- (NSInteger)tryRemoveAtIndexPath:(NSIndexPath*)anIndexPath;
- (NSArray*)indexPathsOfDeletedDoods;
- (void)removeDeletedDoods;

/// test if we can remove any more
- (void)testRemoveableDoodsRemaining;

@end
