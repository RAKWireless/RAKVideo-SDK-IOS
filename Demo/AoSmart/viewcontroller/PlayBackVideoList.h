//
//  PlayBackVideoList.h
//  AoSmart
//
//  Created by rakwireless on 16/8/26.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParametersConfig.h"

@interface PlayBackVideoList : UIViewController<ParametersConfigDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIButton* btnVideoListBack;
    UITableView* ShowVideoListTableview;
}
@property (retain, nonatomic) ParametersConfig* parametersConfigVideoList;
@end
