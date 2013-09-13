//
//  CVDoodSet.h
//  cvsame
//
//  Created by Sean Levin on 9/10/13.
//  Copyright (c) 2013 Sean Levin. All rights reserved.
//

#import "MTLModel.h"

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

@end
