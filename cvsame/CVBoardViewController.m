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

@interface CVBoardViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *board;
@property (nonatomic, strong) CVDoodSet *doodSet;
@property (nonatomic, strong) CVBoardLayout *boardLayout;
@property (nonatomic, strong) UIAlertView *allRemovedAlertView;
@property (nonatomic, strong) UIAlertView *stuckAlertView;
@property (nonatomic, assign) BOOL wonBoard;

@end

@implementation CVBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAllRemovedNotification:) name:DoodSetAllRemovedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStuckNotification:) name:DoodSetStuckNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resetDoodSet {
    self.wonBoard = NO;
    
    CVDoodSet *doodSet = [[CVDoodSet alloc] initWithColumnCount:8];
    self.doodSet = doodSet;
    [self.board reloadData];
    
    self.boardLayout = [[CVBoardLayout alloc] initWithItemSize:40 doodSet:self.doodSet];
    self.board.collectionViewLayout = self.boardLayout;
    self.board.dataSource = self;
    self.board.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetBoard];
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
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:100];
    CVDood *dood = [self.doodSet doodForIndexPath:indexPath];
    imageView.image = [dood imageForType];
    return cell; 
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger deleteCount = [self.doodSet tryRemoveAtIndexPath:indexPath];
    if (deleteCount > 1) {
        NSArray *deleteIndexes = [self.doodSet indexPathsOfDeletedDoods];
        [collectionView performBatchUpdates:^{
            [collectionView deleteItemsAtIndexPaths:deleteIndexes];
            [self.doodSet removeDeletedDoods];
        } completion:^(BOOL finished) {
            [self.doodSet testRemoveableDoodsRemaining];
        }];
    }
}

- (void)handleAllRemovedNotification:(NSNotification*)aNotification {
    self.wonBoard = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Hooray" message:@"You won. Masterful job. Go again?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    });
}

- (void)handleStuckNotification:(NSNotification*)aNotification {
    if (self.wonBoard == YES) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Ouch" message:@"Looks like you are stuck. Try again?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self resetBoard];
}

- (void)resetBoard {
    [self resetDoodSet];
    [self.board reloadData];
}

@end
