//
//  CVDood.h
//  cvsame
//
//  Created by Sean Levin on 9/10/13.
//  Copyright (c) 2013 Sean Levin. All rights reserved.
//

#import "MTLModel.h"

typedef NS_ENUM(NSUInteger, CVDoodType) {
    kCVDoodTypeCastle,
    kCVDoodTypeToilet,
    kCVDoodTypeCrowd,
    kCVDoodTypeBike
};

typedef NS_ENUM(NSUInteger, CVDoodState) {
    kCVDoodNormal,
    kCVDoodDelete
};

@interface CVDood : MTLModel

@property (nonatomic, assign) CVDoodType doodType;
@property (nonatomic, assign) CVDoodState doodState;
@property (nonatomic, assign) BOOL deleting;
@property (nonatomic, readonly) NSString *textForType;


- (void)randomizeType;



@end
