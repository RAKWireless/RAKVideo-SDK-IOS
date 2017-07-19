//
//  DeviceConnect.m
//  AoSmart
//
//  Created by rakwireless on 16/1/26.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "DeviceConnect.h"
#import "CommanParameter.h"
#import "DevicePlay.h"
#import "MBProgressHUD.h"
#import "remote.h"
#import "CommonFunc.h"


NSString *deviceConnectId;
NSString *deviceConnectIp;
NSString *deviceConnectName;
int deviceConnectPort=80;
UIAlertView *waitCheckAlertView;

@interface DeviceConnect ()
{
    nabto_tunnel_state_t nabtoConnectStatus;
    nabto_tunnel_t tunnel_80;
    int nabto_remote_count;
}
@end

@implementation DeviceConnect

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    CGFloat viewW=self.view.frame.size.width;
    CGFloat viewH=self.view.frame.size.height;
    [self Save_Parameter:@"1" :@"screen"];
    
    _DeviceConnectBack=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceConnectBack.frame=CGRectMake(diff_x, diff_top, add_title_size, add_title_size);
    [_DeviceConnectBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [_DeviceConnectBack addTarget:nil action:@selector(_DeviceConnectBackClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_DeviceConnectBack];
    
    _DeviceConnectTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewW-_DeviceConnectBack.frame.size.width-diff_x, title_size)];
    _DeviceConnectTitle.center=CGPointMake(self.view.frame.size.width/2,_DeviceConnectBack.center.y);
    _DeviceConnectTitle.text = NSLocalizedString(@"device_connect_back_title", nil);;
    _DeviceConnectTitle.font = [UIFont systemFontOfSize: main_help_size];
    _DeviceConnectTitle.backgroundColor = [UIColor clearColor];
    _DeviceConnectTitle.textColor = [UIColor grayColor];
    _DeviceConnectTitle.textAlignment = UITextAlignmentCenter;
    _DeviceConnectTitle.lineBreakMode = UILineBreakModeWordWrap;
    _DeviceConnectTitle.numberOfLines = 0;
    [self.view addSubview:_DeviceConnectTitle];
    
    _DeviceConnectImage = [[UIImageView alloc]init];
    _DeviceConnectImage.frame=CGRectMake(0, 0, viewW*0.35, viewW*0.35);
    _DeviceConnectImage.center=CGPointMake(viewW/2, _DeviceConnectBack.frame.origin.y+diff_top*2+viewW*0.35/2);
    _DeviceConnectImage.image = [UIImage imageNamed:@"config_device.png"];
    [self.view  addSubview:_DeviceConnectImage];
    
    _DeviceConnectVideoType=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceConnectVideoType.frame = CGRectMake(diff_x,_DeviceConnectImage.frame.origin.y+_DeviceConnectImage.frame.size.height+diff_top, viewW-diff_x*2, title_size);
    [_DeviceConnectVideoType setTitle: NSLocalizedString(@"device_connect_video_h264", nil) forState: UIControlStateNormal];
    _DeviceConnectVideoType.titleLabel.font = [UIFont systemFontOfSize: add_title_size];
    [_DeviceConnectVideoType setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
    [_DeviceConnectVideoType setTitleColor:[UIColor darkGrayColor]forState:UIControlStateHighlighted];
    _DeviceConnectVideoType.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_DeviceConnectVideoType addTarget:nil action:@selector(_DeviceConnectVideoTypeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_DeviceConnectVideoType];
    
    UILabel *line1=[[UILabel alloc]init];
    line1.frame=CGRectMake(diff_x, _DeviceConnectVideoType.frame.origin.y+_DeviceConnectVideoType.frame.size.height+10, viewW-2*diff_x, 1);
    line1.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:line1];
    
    _DeviceConnectText = [[UILabel alloc] initWithFrame:CGRectMake(diff_x,line1.frame.origin.y+line1.frame.size.height+diff_top, (title_size*2), title_size)];
    _DeviceConnectText.text = NSLocalizedString(@"device_connect_psk", nil);
    _DeviceConnectText.font = [UIFont systemFontOfSize: add_title_size];
    _DeviceConnectText.backgroundColor = [UIColor clearColor];
    _DeviceConnectText.textColor = [UIColor grayColor];
    _DeviceConnectText.textAlignment = UITextAlignmentLeft;
    _DeviceConnectText.lineBreakMode = UILineBreakModeWordWrap;
    _DeviceConnectText.numberOfLines = 0;
    [self.view addSubview:_DeviceConnectText];
    
    _DeviceConnectField =[[UITextField alloc] initWithFrame:CGRectMake(_DeviceConnectText.frame.origin.x+_DeviceConnectText.frame.size.width,line1.frame.origin.y+line1.frame.size.height+diff_top, (viewW-_DeviceConnectText.frame.origin.x-_DeviceConnectText.frame.size.width-diff_x), title_size)];
    _DeviceConnectField.placeholder = NSLocalizedString(@"device_connect_psk_hint", nil);
    _DeviceConnectField.font = [UIFont fontWithName:@"Arial" size:add_title_size];
    _DeviceConnectField.textColor = [UIColor grayColor];
    _DeviceConnectField.backgroundColor = [UIColor clearColor];
    _DeviceConnectField.borderStyle = UITextBorderStyleNone;
    _DeviceConnectField.secureTextEntry = YES;
    _DeviceConnectField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_DeviceConnectField];
    
    UILabel *line=[[UILabel alloc]init];
    line.frame=CGRectMake(diff_x, _DeviceConnectField.frame.origin.y+_DeviceConnectField.frame.size.height+10, viewW-2*diff_x, 1);
    line.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:line];
    
    _DeviceScreenBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceScreenBtn.frame = CGRectMake(diff_x, line.frame.origin.y+line.frame.size.height, viewW*0.5, title_size);
    [_DeviceScreenBtn setTitle: NSLocalizedString(@"device_one_screen", nil) forState: UIControlStateNormal];
    _DeviceScreenBtn.titleLabel.font = [UIFont systemFontOfSize: add_text_size];
    [_DeviceScreenBtn setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_DeviceScreenBtn setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _DeviceScreenBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_DeviceScreenBtn addTarget:nil action:@selector(_DeviceScreenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_DeviceScreenBtn];
    
    _DeviceConnectForgetPsk=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceConnectForgetPsk.frame = CGRectMake(viewW*0.5-diff_x, line.frame.origin.y+line.frame.size.height, viewW*0.5, title_size);
    [_DeviceConnectForgetPsk setTitle: NSLocalizedString(@"device_connect_forget_psk", nil) forState: UIControlStateNormal];
    _DeviceConnectForgetPsk.titleLabel.font = [UIFont systemFontOfSize: add_text_size];
    [_DeviceConnectForgetPsk setTitleColor:[UIColor lightGrayColor]forState:UIControlStateNormal];
    [_DeviceConnectForgetPsk setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _DeviceConnectForgetPsk.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [_DeviceConnectForgetPsk addTarget:nil action:@selector(_DeviceConnectForgetPskClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_DeviceConnectForgetPsk];
    
    _DeviceConnectBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceConnectBtn.frame=CGRectMake(0,0, viewW*0.6, viewW*0.6*110/484);
    _DeviceConnectBtn.center=CGPointMake(viewW/2, _DeviceConnectForgetPsk.frame.origin.y+_DeviceConnectForgetPsk.frame.size.height+diff_top+viewW*0.6*110/484/2);
    [_DeviceConnectBtn setBackgroundImage:[UIImage imageNamed:@"add_next_normal.png"] forState:UIControlStateNormal];
    [_DeviceConnectBtn setBackgroundImage:[UIImage imageNamed:@"add_next_pressed.png"] forState:UIControlStateHighlighted];
    _DeviceConnectBtn.titleLabel.font=[UIFont fontWithName:@"Arial" size:add_title_size];
    [_DeviceConnectBtn setTitle:NSLocalizedString(@"device_connect_btn", nil) forState: UIControlStateNormal];
    _DeviceConnectBtn.titleLabel.textColor=[UIColor redColor];
    [_DeviceConnectBtn addTarget:nil action:@selector(_DeviceConnectBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_DeviceConnectBtn];
    
    deviceConnectId=[self Get_Parameter:@"play_device_id"];
    deviceConnectIp=[self Get_Parameter:@"play_device_ip"];
    deviceConnectName=[self Get_Parameter:@"play_device_name"];
    NSString *key=[NSString stringWithFormat:@"Password=%@",deviceConnectId];
    _DeviceConnectField.text = [self Get_Parameter:key];
    
    _chooseView=[[UIView alloc]init];
    _chooseView.frame=CGRectMake(0, 0, viewW, viewH);
    _chooseView.userInteractionEnabled=YES;
    _chooseView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    [self.view addSubview:_chooseView];
    
    UIView *_chooseBgView=[[UIView alloc]init];
    _chooseBgView.frame=CGRectMake(0, 0, viewW*0.8, title_size*2+diff_top*3);
    _chooseBgView.userInteractionEnabled=YES;
    _chooseBgView.center=self.view.center;
    _chooseBgView.backgroundColor=[UIColor whiteColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesChooseView)];
    [_chooseView addGestureRecognizer:singleTap];
    [_chooseView addSubview:_chooseBgView];
    
    _DeviceConnectVideoH264=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceConnectVideoH264.frame = CGRectMake(0,diff_top, viewW*0.8, title_size);
    [_DeviceConnectVideoH264 setTitle: NSLocalizedString(@"device_connect_video_h264", nil) forState: UIControlStateNormal];
    _DeviceConnectVideoH264.titleLabel.font = [UIFont systemFontOfSize: add_title_size];
    [_DeviceConnectVideoH264 setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
    [_DeviceConnectVideoH264 setTitleColor:[UIColor darkGrayColor]forState:UIControlStateHighlighted];
    _DeviceConnectVideoH264.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_DeviceConnectVideoH264 addTarget:nil action:@selector(_DeviceConnectVideoH264Click) forControlEvents:UIControlEventTouchUpInside];
    [_chooseBgView  addSubview:_DeviceConnectVideoH264];
    
    _DeviceConnectVideoMjpeg=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceConnectVideoMjpeg.frame = CGRectMake(0,_DeviceConnectVideoH264.frame.size.height+_DeviceConnectVideoH264.frame .origin.y +diff_top, viewW*0.8, title_size);
    [_DeviceConnectVideoMjpeg setTitle: NSLocalizedString(@"device_connect_video_mjpeg", nil) forState: UIControlStateNormal];
    _DeviceConnectVideoMjpeg.titleLabel.font = [UIFont systemFontOfSize: add_title_size];
    [_DeviceConnectVideoMjpeg setTitleColor:[UIColor grayColor]forState:UIControlStateNormal];
    [_DeviceConnectVideoMjpeg setTitleColor:[UIColor darkGrayColor]forState:UIControlStateHighlighted];
    _DeviceConnectVideoMjpeg.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [_DeviceConnectVideoMjpeg addTarget:nil action:@selector(_DeviceConnectVideoMjpegClick) forControlEvents:UIControlEventTouchUpInside];
    [_chooseBgView  addSubview:_DeviceConnectVideoMjpeg];
    _chooseView.hidden=YES;
    
    if ([[self Get_Parameter:@"videotype"] compare:@"mjpeg"]==NSOrderedSame ) {
        [_DeviceConnectVideoType setTitle: NSLocalizedString(@"device_connect_video_mjpeg", nil) forState: UIControlStateNormal];
    }else{
        [_DeviceConnectVideoType setTitle: NSLocalizedString(@"device_connect_video_h264", nil) forState: UIControlStateNormal];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    NSString *key=[NSString stringWithFormat:@"Password=%@",deviceConnectId];
    _DeviceConnectField.text = [self Get_Parameter:key];
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesChooseView{
    _chooseView.hidden=YES;
}

-(void)_DeviceConnectVideoH264Click{
    [_DeviceConnectVideoType setTitle: NSLocalizedString(@"device_connect_video_h264", nil) forState: UIControlStateNormal];
    [self Save_Parameter:@"h264" :@"videotype"];
    _chooseView.hidden=YES;
}

-(void)_DeviceConnectVideoMjpegClick{
    [_DeviceConnectVideoType setTitle: NSLocalizedString(@"device_connect_video_mjpeg", nil) forState: UIControlStateNormal];
    [self Save_Parameter:@"mjpeg" :@"videotype"];
    _chooseView.hidden=YES;
}

//Save Parameter
- (void)Save_Parameter:(NSString *)devices :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:devices forKey:key];
    [defaults synchronize];
}

//Get Parameter
- (NSString *)Get_Parameter:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}

//Remote Connect
- (void)checkRemoteConnectTimer:(NSTimer *)timer
{
    int status = CheckConnectStatus(&tunnel_80);
    if (status > 0) {
        [timer invalidate];
        deviceConnectIp=@"127.0.0.1";
        deviceConnectPort=REMOTEPORTMAPPING;
        //[self startCheckPassword];
    }
    nabto_remote_count++;
    if (nabto_remote_count>REMOTECONNECTTIMEOUT) {
        [timer invalidate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [waitCheckAlertView dismissWithClickedButtonIndex:0 animated:YES];
            [self showAllTextDialog:NSLocalizedString(@"device_connect_network_error", nil)];
            CloseTunnel(&tunnel_80);
            nabtoConnectStatus = NTCS_CLOSED;
        });
    }
    NSLog(@"%d",nabto_remote_count);
}

-(void) checkDevicePassword{
    if ([deviceConnectIp compare:@"127.0.0.1"]==NSOrderedSame) {
        nabto_remote_count=0;
        nabtoConnectStatus = NTCS_CLOSED;
        NabtoLibraryInit();
        nabtoConnectStatus = Async_ConnectDeviceWithTunnel(&tunnel_80 ,deviceConnectId ,80 ,REMOTEPORTMAPPING);
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkRemoteConnectTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }
    else{
        deviceConnectPort=80;
        [_parametersConfigDeviceConnect getUsernameAndPassword];
    }
}

- (void)setOnResultListener:(int)statusCode :(NSString*)body :(int)type{
    if (type==GET_VERSION) {
        if (statusCode==200) {
            body=[body stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *version=[self parseJsonString:body];
            if ([version compare:@""]==NSOrderedSame) {
                version=body;
            }
            NSLog(@"version=%@",version);
            [self Save_Parameter:version :@"version"];
        }
        [_parametersConfigDeviceConnect getFps:0];
    }
    else if (type==GET_USERNAME_PASSWORD) {
        if(statusCode==200){
            NSString *key=[NSString stringWithFormat:@"Password=%@",deviceConnectId];
            [self Save_Parameter:_DeviceConnectField.text :key];
            NSDate *date = [NSDate date];//设置源日期时区
            NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];//或UTC
            //设置转换后的目标日期时区
            NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
            NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];//得到源日期与世界标准时间的偏移量
            NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];//目标日期与本地时区的偏移量
            NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;//得到时间偏移量的差值
            NSString *timezone;
            int h=  fabs(interval)/3600;
            int m= (int)fabs(interval)%3600/60;
            if (interval>=0) {
                timezone=[NSString stringWithFormat:@"+%.2d%.2d",h,m];
            }
            else{
                timezone=[NSString stringWithFormat:@"+%.2d%.2d",h,m];
            }
            NSDateFormatter * formatter =   [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMdd"];
            NSString *nowDate = [formatter stringFromDate:date];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
            int hour = (int)[dateComponent hour];
            int minute = (int)[dateComponent minute];
            int second = (int)[dateComponent second];
            [_parametersConfigDeviceConnect setModuleRtcTime:nowDate :hour :minute :second :timezone];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [waitCheckAlertView dismissWithClickedButtonIndex:0 animated:YES];
                [self showAllTextDialog:NSLocalizedString(@"modify_device_success_psk_error", nil)];
                if ([deviceConnectIp compare:@"127.0.0.1"]==NSOrderedSame){
                    CloseTunnel(&tunnel_80);
                    nabtoConnectStatus = NTCS_CLOSED;
                }
            });

        }
    }
    else if (type==SET_MODULE_RTC_TIME) {
        if(statusCode==200){
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSThread sleepForTimeInterval:2.0f];
                [waitCheckAlertView dismissWithClickedButtonIndex:0 animated:YES];
                DevicePlay *v = [[DevicePlay alloc] init];
                [self.navigationController pushViewController: v animated:true];
                if ([deviceConnectIp compare:@"127.0.0.1"]==NSOrderedSame){
                    CloseTunnel(&tunnel_80);
                    nabtoConnectStatus = NTCS_CLOSED;
                }
            });
        }
        else{
            [_parametersConfigDeviceConnect getFps:0];
        }
    }
    else if (type==GET_FPS){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [NSThread sleepForTimeInterval:2.0f];
//            [waitCheckAlertView dismissWithClickedButtonIndex:0 animated:YES];
//            //[self showAllTextDialog:NSLocalizedString(@"video_set_sd_time_error", nil)];
//            if ([deviceConnectIp compare:@"127.0.0.1"]==NSOrderedSame){
//                CloseTunnel(&tunnel_80);
//                nabtoConnectStatus = NTCS_CLOSED;
//            }
//            DevicePlay *v = [[DevicePlay alloc] init];
//            [self.navigationController pushViewController: v animated:true];
//        });
        
        if(statusCode==200)
        {
            body=[body stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(@"====>%@",body);
            NSString *value=@"\"value\":\"";
            NSRange range=[body rangeOfString:value];
            if (range.location != NSNotFound) {
                NSString *fps=[body substringFromIndex:(range.location+value.length)];
                NSRange range1=[body rangeOfString:@"\""];
                if (range1.location != NSNotFound){
                    [self Save_Parameter:[fps substringToIndex:(range1.location+1)] :@"fps"];
                    NSLog(@"fps=%@",[fps substringToIndex:(range1.location+1)]);
                }
                else{
                    [self Save_Parameter:@"20" :@"fps"];
                }
            }
            else{
                [self Save_Parameter:@"20" :@"fps"];
            }
        }
        else{
            [self Save_Parameter:@"20" :@"fps"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            DevicePlay *v = [[DevicePlay alloc] init];
            [self.navigationController pushViewController: v animated:true];
        });
    }
}

//Back
- (void)_DeviceConnectBackClick{
    if ([deviceConnectIp compare:@"127.0.0.1"]==NSOrderedSame){
        CloseTunnel(&tunnel_80);
        nabtoConnectStatus = NTCS_CLOSED;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//Choose video formart
- (void)_DeviceConnectVideoTypeClick{
    NSLog(@"_DeviceConnectVideoTypeClick");
    _chooseView.hidden=NO;
}

//Choose display view number
- (void)_DeviceScreenBtnClick{
    if ([_DeviceScreenBtn.titleLabel.text compare:NSLocalizedString(@"device_one_screen", nil)]==NSOrderedSame)
    {
        [self Save_Parameter:@"2" :@"screen"];
        [_DeviceScreenBtn setTitle: NSLocalizedString(@"device_two_screen", nil) forState: UIControlStateNormal];
    }
    else{
        [self Save_Parameter:@"1" :@"screen"];
        [_DeviceScreenBtn setTitle: NSLocalizedString(@"device_one_screen", nil) forState: UIControlStateNormal];
    }
}

//ForgetPsk
- (void)_DeviceConnectForgetPskClick{
    [self showAllTextDialog:NSLocalizedString(@"device_connect_forget_psk_indicator", nil)];
}

//Connect
-(NSString*)parseJsonString:(NSString *)srcStr{
    NSString *Str=@"";
    NSString *keyStr=@"\"value\":\"";
    NSString *endStr=@"\"";
    NSRange range=[srcStr rangeOfString:keyStr];
    if (range.location != NSNotFound) {
        int i=(int)range.location;
        srcStr=[srcStr substringFromIndex:i+keyStr.length];
        NSRange range1=[srcStr rangeOfString:endStr];
        if (range1.location != NSNotFound) {
            int j=(int)range1.location;
            NSRange diffRange=NSMakeRange(0, j);
            Str=[srcStr substringWithRange:diffRange];
        }
    }
    return Str;
}

- (void)_DeviceConnectBtnClick{
    NSString *key=[NSString stringWithFormat:@"Password=%@",deviceConnectId];
    [self Save_Parameter:_DeviceConnectField.text :key];
    
    _parametersConfigDeviceConnect=[[ParametersConfig alloc]init:self ip:deviceConnectIp password:_DeviceConnectField.text];
    //get version
    [_parametersConfigDeviceConnect getVersion];
    
//    waitCheckAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"device_connect_psk_check_title", nil)
//                                               message:NSLocalizedString(@"device_connect_psk_check", nil)
//                                              delegate:nil
//                                     cancelButtonTitle:nil
//                                     otherButtonTitles:nil, nil];
//    [waitCheckAlertView show];
//    
//    NSThread* httpThread = [[NSThread alloc] initWithTarget:self
//                                                   selector:@selector(checkDevicePassword)
//                                                     object:nil];
//    [httpThread start];
}

#pragma mark-- Toast显示示例
-(void)showAllTextDialog:(NSString *)str{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = str;
    HUD.mode = MBProgressHUDModeText;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        //[HUD release];
        //HUD = nil;
    }];
}

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //隐藏键盘
    [_DeviceConnectField resignFirstResponder];
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
