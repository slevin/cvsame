//
//  CVDood.m
//  cvsame
//
//  Created by Sean Levin on 9/10/13.
//  Copyright (c) 2013 Sean Levin. All rights reserved.
//

#import "CVDood.h"

@implementation CVDood


- (void)randomizeType {
    NSInteger typeNumber = arc4random_uniform(4);
    self.doodType = (CVDoodType)typeNumber;
}

- (UIImage*)imageForType {
    switch (self.doodType) {
        case kCVDoodTypeBike:
            return  [UIImage imageNamed:@"motorcycle.png"];
            break;
        case kCVDoodTypeCastle:
            return [UIImage imageNamed:@"castle.png"];
            break;
        case kCVDoodTypeCrowd:
            return [UIImage imageNamed:@"group.png"];
            break;
        case kCVDoodTypeToilet:
            return [UIImage imageNamed:@"toilet.png"];
            break;
        default:
            NSAssert(NO, @"Undefined type");
            return nil;
    }
}

- (NSString*)textForType {
    switch (self.doodType) {
        case kCVDoodTypeBike:
            return @"Bike";
            break;
        case kCVDoodTypeCastle:
            return @"Castle";
            break;
        case kCVDoodTypeCrowd:
            return @"Crowd";
            break;
        case kCVDoodTypeToilet:
            return @"Toilet";
            break;
        default:
            NSAssert(NO, @"Undefined type");
            return nil;
    }
}

@end
