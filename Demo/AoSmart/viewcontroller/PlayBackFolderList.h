//
//  PlayBackFolderList.h
//  AoSmart
//
//  Created by rakwireless on 16/8/25.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParametersConfig.h"

@interface PlayBackFolderList : UIViewController<ParametersConfigDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIButton* btnFolderListBack;
    UITableView* ShowFolderListTableview;
}
@property (retain, nonatomic) ParametersConfig* parametersConfigFolderList;
@end
