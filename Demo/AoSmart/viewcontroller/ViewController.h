//
//  ViewController.h
//  AoSmart
//
//  Created by rakwireless on 16/1/20.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIButton *_videoHelp;
    UIButton *_videoRefresh;
    UIButton *_videoMedia;
}
@property (nonatomic,strong)UICollectionView *collectionView;

@end

