//
//  CVBoardLayout.h
//  cvsame
//
//  Created by Sean Levin on 9/10/13.
//  Copyright (c) 2013 Sean Levin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CVDoodSet;

@interface CVBoardLayout : UICollectionViewLayout

- (instancetype)initWithItemSize:(CGFloat)aSize doodSet:(CVDoodSet*)aDoodSet;

@end
