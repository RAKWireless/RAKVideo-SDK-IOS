//
//  ViewController.m
//  AoSmart
//
//  Created by rakwireless on 16/1/20.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "AddDeviceStep0.h"
#import "CommanParameter.h"
#import "ModifyDeviceName.h"
#import "VideoMedia.h"
#import "VideoHelp.h"
#import "DeviceConnect.h"
#import "DeviceData.h"
#import "DeviceInfo.h"
#import "Scanner.h"

Scanner *_device_Scan;
DeviceData *_device_Data;
NSMutableArray *_collection_Items;
NSMutableArray *_local_Items;
UIAlertView *waitAlertView;

@interface ViewController ()
{
    bool _isExit;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    _isExit=NO;
    CGFloat viewH=self.view.frame.size.height;
    CGFloat viewW=self.view.frame.size.width;
    
    _videoHelp=[UIButton buttonWithType:UIButtonTypeCustom];
    _videoHelp.frame = CGRectMake(diff_x, diff_top, title_size*3, title_size);
    [_videoHelp setTitle: NSLocalizedString(@"main_help", nil) forState: UIControlStateNormal];
    _videoHelp.titleLabel.font = [UIFont systemFontOfSize: main_help_size];
    [_videoHelp setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_videoHelp setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _videoHelp.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_videoHelp addTarget:nil action:@selector(_videoHelpClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_videoHelp];

    _videoRefresh=[UIButton buttonWithType:UIButtonTypeCustom];
    _videoRefresh.frame=CGRectMake(viewW-diff_x-title_size, diff_top, title_size, title_size);
    [_videoRefresh setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
    [_videoRefresh addTarget:nil action:@selector(_videoRefreshClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_videoRefresh];
    
    _videoMedia=[UIButton buttonWithType:UIButtonTypeCustom];
    _videoMedia.frame=CGRectMake(0, 0, viewH*614/6/260, viewH/6);
    _videoMedia.center=CGPointMake(viewW/2, viewH-viewH/12-diff_bottom);
    [_videoMedia setImage:[UIImage imageNamed:@"main_logo.png"] forState:UIControlStateNormal];
    [_videoMedia addTarget:nil action:@selector(_videoMediaClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_videoMedia];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.headerReferenceSize = CGSizeMake(viewW, diff_top);//头部
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(diff_x, _videoRefresh.frame.size.height+_videoRefresh.frame.origin.y+diff_top, viewW-2*diff_x, _videoMedia.frame.origin.y-(_videoRefresh.frame.size.height+_videoRefresh.frame.origin.y+diff_top*2)) collectionViewLayout:flowLayout];
    
    //设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //注册cell
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    //创建长按手势监听
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(myHandleTableviewCellLongPressed:)];
    longPress.minimumPressDuration = 1.0;
    //将长按手势添加到需要实现长按操作的视图里
    [self.collectionView addGestureRecognizer:longPress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    _isExit=NO;
    _device_Scan = [[Scanner alloc] init];
    [self scanDevice];
    
    _collection_Items=[[NSMutableArray alloc]init];
    _local_Items=[[NSMutableArray alloc]init];
    _device_Data=[[DeviceData alloc]init];
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void) viewDidDisappear:(BOOL)animated
{
    _isExit=YES;
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

//VideoMedia Click
- (void)_videoMediaClick{
    VideoMedia *v = [[VideoMedia alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

//VideoHelp Click
- (void)_videoHelpClick{
    VideoHelp *v = [[VideoHelp alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

//VideoRefresh Click
- (void)_videoRefreshClick{
    [self scanDevice];
}

//Save Parameter
- (void)Save_Parameter:(NSString *)devices :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:devices forKey:key];
    [defaults synchronize];
}

#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ([_collection_Items count]+1);
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    [cell sizeToFit];
    
    if (([_collection_Items count]==0)||(indexPath.row==[_collection_Items count])) {
        cell.imgView.image=[UIImage imageNamed:@"main_device_add.png"];
        cell.text.text = NSLocalizedString(@"add_device_list_name", nil);
    }
    else{
        DeviceInfo *_device=_collection_Items[indexPath.row];
        if ([_device.deviceStatus compare:_deviceOnline]==NSOrderedSame) {
            cell.imgView.image=[UIImage imageNamed:@"main_device_local.png"];
        }
        else{
            cell.imgView.image=[UIImage imageNamed:@"main_device_remote.png"];
        }
        cell.text.text =[_device_Data getDeviceNameById: _device.deviceID];
    }
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //边距占5*4=20 ，2个
    //图片为正方形，边长：(fDeviceWidth-20)/2-5-5 所以总高(fDeviceWidth-20)/2-5-5 +20+30+5+5 label高20 btn高30 边
    return CGSizeMake((self.collectionView.frame.size.width-20)/3, (self.collectionView.frame.size.width-20)/3+50);
}
//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:()section
{
    return UIEdgeInsetsMake(0, 5, 5, 5);
}
//定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==[_collection_Items count]) {
        AddDeviceStep0 *v = [[AddDeviceStep0 alloc] init];
        [self.navigationController pushViewController: v animated:true];
    }else{
        DeviceInfo *_device= _collection_Items[indexPath.row];
        NSString *deviceName=[_device_Data getDeviceNameById:_device.deviceID];
        [self Save_Parameter:_device.deviceID :@"play_device_id"];
        [self Save_Parameter:_device.deviceIp :@"play_device_ip"];
        [self Save_Parameter:deviceName :@"play_device_name"];
        DeviceConnect *v = [[DeviceConnect alloc] init];
        [self.navigationController pushViewController: v animated:true];
    }
    NSLog(@"选择%ld",indexPath.row);
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void) myHandleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint pointTouch = [gestureRecognizer locationInView:self.collectionView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
        
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pointTouch];
        if ((indexPath == nil)||(indexPath.row==[_collection_Items count])) {
            NSLog(@"nil");
        }else{
            NSLog(@"Section = %ld,Row = %ld",(long)indexPath.section,(long)indexPath.row);
            ModifyDeviceName *v = [[ModifyDeviceName alloc] init];
            DeviceInfo *_device= _collection_Items[indexPath.row];
            v.deviceId=_device.deviceID;
            [self.navigationController pushViewController: v animated:true];
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"UIGestureRecognizerStateChanged");
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
    }
}

#pragma mark -- scanDevice
- (void)scanDevice
{
    if (_isExit) {
        return;
    }
    waitAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"main_scan_indicator_title", nil)
                                               message:NSLocalizedString(@"main_scan_indicator", nil)
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil, nil];
    [waitAlertView show];
    [_local_Items removeAllObjects];
    [_collection_Items removeAllObjects];
    [self.collectionView reloadData];
    [NSThread detachNewThreadSelector:@selector(scanDeviceTask) toTarget:self withObject:nil];
}

- (void)scanDeviceTask
{
    Scanner *result = [_device_Scan ScanDeviceWithTime:1.5f];
    [self performSelectorOnMainThread:@selector(scanDeviceOver:) withObject:result waitUntilDone:NO];
}

- (void)scanDeviceOver:(Scanner *)result;
{
    NSMutableArray *_deviceInfos=[_device_Data getDeviceIds];
    if (result.Device_ID_Arr.count > 0) {
        NSLog(@"Scan Over...");
        [result.Device_ID_Arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *deviceIp = [result.Device_IP_Arr objectAtIndex:idx];
            NSString *deviceId = [result.Device_ID_Arr objectAtIndex:idx];
            bool tempsame=NO;
            for (int i=0;i<[_local_Items count]; i++) {
                DeviceInfo *temp=_local_Items[i];
                if ([deviceId compare:temp.deviceID]==NSOrderedSame){
                    tempsame=YES;
                    break;
                }
            }
            if (!tempsame) {
                DeviceInfo *localDevice=[[DeviceInfo alloc]init];
                localDevice.deviceID=deviceId;
                localDevice.deviceName=[_device_Data getDeviceNameById:deviceId];
                localDevice.deviceIp=deviceIp;
                localDevice.deviceStatus=_deviceOnline;
                NSLog(@"Scan nothing1...");
                [_local_Items addObject:localDevice];//本地设备
                [_collection_Items addObject:localDevice];//添加已经扫描到的本地设备
                NSLog(@"Scan nothing2...");
            }
        }];
    }
    else
    {
        NSLog(@"Scan nothing...");
    }
    [_deviceInfos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //保存的所有设备都为offline
        DeviceInfo *_saveInfo=_deviceInfos[idx];
        NSString *_saveId=_saveInfo.deviceID;
        
        DeviceInfo *_localInfo;
        int index=0;
        bool same=NO;
        for(int i=0;i<[_local_Items count];i++)
        {
            _localInfo=_local_Items[i];
            NSString *_localId=_localInfo.deviceID;
            //相同，表示已经保存过，则更新设备名称和设备状态为online
            NSLog(@"%@",_saveId);
            NSLog(@"%@",_localId);
            if([_saveId compare:_localId]==NSOrderedSame ){
                index=i;
                NSLog(@"%d",i);
                same=YES;
                break;
            }
        }
        //不相同则直接添加
        if (!same) {
            NSLog(@"Scan nothing3...");
            [_collection_Items addObject:_saveInfo];
            NSLog(@"Scan nothing4...");
        }
        else{
            NSLog(@"Scan nothing5...");
            //_collection_Items和_local_Items是相同的
            DeviceInfo *newInfo=_localInfo;//ip id为扫描到的值
            newInfo.deviceName=_saveInfo.deviceName;//name 为保存值
            newInfo.deviceStatus=_deviceOnline;//status 为在线
            [_collection_Items replaceObjectAtIndex:index withObject:newInfo];//更新这个设备信息
            same=YES;
        }
    }];
    [self.collectionView reloadData];
    [waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
}


//Set StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden//for iOS7.0
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
