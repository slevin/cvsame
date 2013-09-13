//
//  CVBoardViewController.m
//  cvsame
//
//  Created by Sean Levin on 9/10/13.
//  Copyright (c) 2013 Sean Levin. All rights reserved.
//

#import "CVBoardViewController.h"
#import "CVDoodSet.h"
#import "CVBoardLayout.h"
#import "CVDood.h"

#define CELL_ID @"cellId"

@interface CVBoardViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *board;
@property (nonatomic, strong) CVDoodSet *doodSet;
@property (nonatomic, strong) CVBoardLayout *boardLayout;

@end

@implementation CVBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)resetDoodSet {
    
    CVDoodSet *doodSet = [[CVDoodSet alloc] initWithColumnCount:8];
    self.doodSet = doodSet;
    
    self.boardLayout = [[CVBoardLayout alloc] initWithItemSize:40 doodSet:self.doodSet];
    self.board.collectionViewLayout = self.boardLayout;
    self.board.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetDoodSet];
    [self.board reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"CVDoodCell" bundle:[NSBundle mainBundle]];
    [self.board registerNib:nib forCellWithReuseIdentifier:CELL_ID];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.doodSet.numberOfDoods;
    return count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.board dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:100];
    CVDood *dood = [self.doodSet doodForIndexPath:indexPath];
    label.text = dood.textForType;
    return cell;
}

@end
