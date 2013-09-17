//
//  CVBoardLayout.m
//  cvsame
//
//  Created by Sean Levin on 9/10/13.
//  Copyright (c) 2013 Sean Levin. All rights reserved.
//

#import "CVBoardLayout.h"
#import "CVDood.h"
#import "CVDoodSet.h"

@interface CVBoardLayout ()

@property (nonatomic, assign) CGFloat itemSize;
@property (nonatomic, strong) CVDoodSet *doodSet;
@property (nonatomic, strong) NSValue *lastContentSize;

@end

@implementation CVBoardLayout

- (instancetype)initWithItemSize:(CGFloat)aSize doodSet:(CVDoodSet*)aDoodSet {
    if ((self = [super init])) {
        _itemSize = aSize;
        _doodSet = aDoodSet;
    }
    return self;
}

- (CGSize)collectionViewContentSize {
    if (self.lastContentSize) {
        return [self.lastContentSize CGSizeValue];
    } else {
        CGFloat width = self.doodSet.numberOfColumns * self.itemSize;
        CGFloat height = [self.doodSet maxDoodHeight] * self.itemSize;
        CGSize contentSize = CGSizeMake(width, height);
        self.lastContentSize = [NSValue valueWithCGSize:contentSize];
        return contentSize;
    }
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray new];
    CGSize contentSize = [self collectionViewContentSize];
    
    [self.doodSet enumerateDoods:^(CVDood *dood, NSInteger column, NSInteger row) {
        CGFloat x = column * self.itemSize;
        CGFloat y = contentSize.height - ((row + 1) * self.itemSize);
        CGRect doodRect = CGRectMake(x, y, self.itemSize, self.itemSize);
        BOOL intersects = CGRectIntersectsRect(rect, doodRect);
        if (intersects) {
            NSIndexPath *indexPath = [self.doodSet indexPathForDoodAtColumn:column row:row];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [layoutAttributes addObject:attributes];
        }
    }];
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSInteger column, row;
    [self.doodSet columnRowForDoodAtIndexPath:indexPath outColumn:&column outRow:&row];
    CGSize contentSize = [self collectionViewContentSize];
    CGFloat x = column * self.itemSize;
    CGFloat y = contentSize.height - ((row + 1) * self.itemSize);
    CGRect doodRect = CGRectMake(x, y, self.itemSize, self.itemSize);
    attributes.frame = doodRect;
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

@end
