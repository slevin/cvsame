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
