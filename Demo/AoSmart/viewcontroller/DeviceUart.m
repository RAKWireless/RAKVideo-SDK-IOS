//
//  DeviceUart.m
//  AoSmart
//
//  Created by rakwireless on 16/8/25.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "DeviceUart.h"
#import "CommanParameter.h"
#import "CommonFunc.h"
#import "MBProgressHUD.h"


Byte keep_alive[] = {0x01,0x55,0x00};
Byte start[] = {0x01,0x55};

@interface DeviceUart ()
{
    NSString* deviceConnectingId;
    NSString* deviceConnectingIp;
    NSString* deviceConnectingpsk;
    NSString* deviceVersion;
    int deviceConnectingPort;
    GCDAsyncSocket* GCDUartSocket;//用于建立TCP socket
    GCDAsyncUdpSocket* GCDUdpSocket;//用于建立UDP socket
    bool _isExit;
    int sendLen;
    int recvLen;
    bool _isLX520;
}
@end

@implementation DeviceUart

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    CGFloat viewW=self.view.frame.size.width;
    CGFloat viewH=self.view.frame.size.height;
    
    _isExit=NO;
    _DeviceUartBack=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceUartBack.frame=CGRectMake(diff_x, diff_top, add_title_size, add_title_size);
    [_DeviceUartBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [_DeviceUartBack addTarget:nil action:@selector(_DeviceUartBackClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_DeviceUartBack];
    
    UILabel *line=[[UILabel alloc]init];
    line.frame=CGRectMake(0, _DeviceUartBack.frame.origin.y+_DeviceUartBack.frame.size.height+10, viewW, 1);
    line.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:line];
    
    _DeviceUartSendBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceUartSendBtn.frame=CGRectMake(viewW*0.1,viewH-diff_top-viewW*0.6*110/484, viewW*0.3, viewW*0.6*110/484);
    [_DeviceUartSendBtn setBackgroundImage:[UIImage imageNamed:@"add_next_normal.png"] forState:UIControlStateNormal];
    [_DeviceUartSendBtn setBackgroundImage:[UIImage imageNamed:@"add_next_pressed.png"] forState:UIControlStateHighlighted];
    _DeviceUartSendBtn.titleLabel.font=[UIFont fontWithName:@"Arial" size:add_title_size];
    [_DeviceUartSendBtn setTitle:NSLocalizedString(@"device_uart_send_btn", nil) forState: UIControlStateNormal];
    _DeviceUartSendBtn.titleLabel.textColor=[UIColor redColor];
    [_DeviceUartSendBtn addTarget:nil action:@selector(_DeviceUartSendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_DeviceUartSendBtn];
    
    _DeviceUartClearBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceUartClearBtn.frame=CGRectMake(viewW*0.6,viewH-diff_top-viewW*0.6*110/484, viewW*0.3, viewW*0.6*110/484);
    [_DeviceUartClearBtn setBackgroundImage:[UIImage imageNamed:@"add_next_normal.png"] forState:UIControlStateNormal];
    [_DeviceUartClearBtn setBackgroundImage:[UIImage imageNamed:@"add_next_pressed.png"] forState:UIControlStateHighlighted];
    _DeviceUartClearBtn.titleLabel.font=[UIFont fontWithName:@"Arial" size:add_title_size];
    [_DeviceUartClearBtn setTitle:NSLocalizedString(@"device_uart_clear_btn", nil) forState: UIControlStateNormal];
    _DeviceUartClearBtn.titleLabel.textColor=[UIColor redColor];
    [_DeviceUartClearBtn addTarget:nil action:@selector(_DeviceUartClearBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_DeviceUartClearBtn];
    
    _DeviceUartSendNum=[[UILabel alloc]init];
    _DeviceUartSendNum.font = [UIFont fontWithName:@"Arial" size:add_title_size];
    _DeviceUartSendNum.frame=CGRectMake(viewW*0.1,_DeviceUartSendBtn.frame.origin.y-diff_top-viewW*0.6*110/484, viewW*0.3, viewW*0.6*110/484);
    _DeviceUartSendNum.text=[NSString stringWithFormat:@"%@0",NSLocalizedString(@"device_uart_send_num", nil)];
    [self.view  addSubview:_DeviceUartSendNum];
    
    _DeviceUartRecvNum=[[UILabel alloc]init];
    _DeviceUartRecvNum.font = [UIFont fontWithName:@"Arial" size:add_title_size];
    _DeviceUartRecvNum.frame=CGRectMake(viewW*0.6,_DeviceUartSendBtn.frame.origin.y-diff_top-viewW*0.6*110/484, viewW*0.3, viewW*0.6*110/484);
    _DeviceUartRecvNum.text=[NSString stringWithFormat:@"%@0",NSLocalizedString(@"device_uart_recv_num", nil)];
    [self.view  addSubview:_DeviceUartRecvNum];
    
    UILabel *line1=[[UILabel alloc]init];
    line1.frame=CGRectMake(0, _DeviceUartRecvNum.frame.origin.y-10, viewW, 1);
    line1.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:line1];
    
    CGFloat height=line1.frame.origin.y-line.frame.origin.y-2;
    _DeviceUartRecvField =[[UITextView alloc] initWithFrame:CGRectMake(diff_x,line.frame.origin.y+1, viewW-2*diff_x, height/2)];
    _DeviceUartRecvField.scrollEnabled = YES;
    _DeviceUartRecvField.font = [UIFont fontWithName:@"Arial" size:add_title_size];
    _DeviceUartRecvField.textColor = [UIColor lightGrayColor];
    _DeviceUartRecvField.backgroundColor = [UIColor clearColor];
    _DeviceUartRecvField.secureTextEntry = NO;
    _DeviceUartRecvField.editable = NO;
    [self.view addSubview:_DeviceUartRecvField];
    
    UILabel *line2=[[UILabel alloc]init];
    line2.frame=CGRectMake(0, _DeviceUartRecvField.frame.origin.y+1+height/2, viewW, 1);
    line2.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:line2];
    
    _DeviceUartSendField =[[UITextView alloc] initWithFrame:CGRectMake(diff_x,line2.frame.origin.y+1, viewW-2*diff_x, height/2)];
    _DeviceUartSendField.font = [UIFont fontWithName:@"Arial" size:add_title_size];
    _DeviceUartSendField.textColor = [UIColor lightGrayColor];
    _DeviceUartSendField.backgroundColor = [UIColor clearColor];
    _DeviceUartSendField.secureTextEntry = NO;
    _DeviceUartSendField.scrollEnabled = YES;
    [self.view addSubview:_DeviceUartSendField];
    
    deviceConnectingId=[self Get_Parameter:@"play_device_id"];
    deviceConnectingIp=[self Get_Parameter:@"play_device_ip"];
    NSString *key=[NSString stringWithFormat:@"Password=%@",deviceConnectingId];
    deviceConnectingpsk=[self Get_Parameter:key];
    deviceVersion=[self Get_Parameter:@"version"];
    deviceVersion=deviceVersion.lowercaseString;
    if ([deviceVersion containsString:@"wifiv"]) {//HDMI模块
        _isLX520=NO;
    }
    else{//LX520模块
        _isLX520=YES;
    }
    
    if ([deviceConnectingIp compare:@"127.0.0.1"]==NSOrderedSame) {
        deviceConnectingPort=REMOTEPORTMAPPING;
    }
    else{
        if (_isLX520) {
            deviceConnectingPort=80;
        }
        else{
            deviceConnectingPort=1008;
        }
    }
    if (_isLX520){
        GCDUartSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];//建立与设备 TCP 80端口连接，用于串口透传数据发送与接收
        NSError *err;
        [GCDUartSocket connectToHost:deviceConnectingIp onPort:deviceConnectingPort error:&err];
        if (err != nil)
        {
            NSLog(@"error = %@",err);
            [self showAllTextDialog:NSLocalizedString(@"uart_connect_failed", nil)];
        }
        else{
            [self showAllTextDialog:NSLocalizedString(@"uart_connect_success", nil)];
        }
        [NSThread detachNewThreadSelector:@selector(sendPacket) toTarget:self withObject:nil];//保活
        [GCDUartSocket readDataWithTimeout:-1 tag:0];

    }
    else{
        GCDUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *err;
        [GCDUdpSocket bindToPort :25000 error:&err];
        if (err != nil)
        {
            NSLog(@"error = %@",err);
            [self showAllTextDialog:NSLocalizedString(@"uart_connect_failed", nil)];
        }
        else{
            [self showAllTextDialog:NSLocalizedString(@"uart_connect_success", nil)];
        }
        [GCDUdpSocket beginReceiving:&err];
    }
}

//保活
- (void)sendPacket
{
    while(!_isExit){
        NSData *data = [NSData dataWithBytes:keep_alive length:3];
        [GCDUartSocket writeData:data withTimeout:1.0 tag:100];
        [NSThread sleepForTimeInterval:10.0f];
    }
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if([sock isEqual:GCDUartSocket]){
        if(data.length > 2)
        {
            NSLog(@"data.length=%d",(int)data.length);
            NSData *sd =[data subdataWithRange:NSMakeRange(2, data.length-2)];
            NSString *result  =[[ NSString alloc] initWithData:sd encoding:NSUTF8StringEncoding];
            recvLen+=data.length-2;
            _DeviceUartRecvNum.text=[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"device_uart_recv_num", nil),recvLen];
            _DeviceUartRecvField.text=[NSString stringWithFormat:@"%@%@",_DeviceUartRecvField.text,result];
        }
        [GCDUartSocket readDataWithTimeout:-1 tag:0];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    if([sock isEqual:GCDUdpSocket]){
        if(data.length > 2)
        {
            NSLog(@"data.length=%d",(int)data.length);
            NSData *sd =[data subdataWithRange:NSMakeRange(2, data.length-2)];
            NSString *result  =[[ NSString alloc] initWithData:sd encoding:NSUTF8StringEncoding];
            recvLen+=data.length-2;
            _DeviceUartRecvNum.text=[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"device_uart_recv_num", nil),recvLen];
            _DeviceUartRecvField.text=[NSString stringWithFormat:@"%@%@",_DeviceUartRecvField.text,result];
        }
    }
}

- (void)_DeviceUartSendBtnClick{
    NSMutableData *mData = [[NSMutableData alloc] init];
    NSData *adata = [[NSData alloc] initWithBytes:start length:2];
    NSData *bdata = [_DeviceUartSendField.text dataUsingEncoding:NSUTF8StringEncoding];
    sendLen+=bdata.length;
    _DeviceUartSendNum.text=[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"device_uart_send_num", nil),sendLen];
    [mData appendData:adata];
    [mData appendData:bdata];
    NSData *subData =[mData subdataWithRange:NSMakeRange(0, mData.length)];
    if (_isLX520) {
        [GCDUartSocket writeData:subData withTimeout:1.0 tag:100];
    }
    else{
        [GCDUdpSocket sendData:subData toHost:deviceConnectingIp port:deviceConnectingPort withTimeout:1.0 tag:100];
    }
}

- (void)_DeviceUartClearBtnClick{
    sendLen=0;
    recvLen=0;
    _DeviceUartRecvNum.text=[NSString stringWithFormat:@"%@0",NSLocalizedString(@"device_uart_recv_num", nil)];
    _DeviceUartSendNum.text=[NSString stringWithFormat:@"%@0",NSLocalizedString(@"device_uart_send_num", nil)];
    _DeviceUartRecvField.text=@"";
    _DeviceUartSendField.text=@"";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Back
- (void)_DeviceUartBackClick{
    _isExit=YES;
    if (GCDUartSocket != nil) {
        [GCDUartSocket disconnect];//关闭建立的SOCKET
        GCDUartSocket = nil;
    }
    if (GCDUdpSocket != nil) {
        [GCDUdpSocket close];//关闭建立的SOCKET
        GCDUdpSocket = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

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
    if (textField == _DeviceUartSendField) {
        [_DeviceUartRecvField becomeFirstResponder];
    }
    else
        [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //隐藏键盘
    [_DeviceUartSendField resignFirstResponder];
    [_DeviceUartRecvField resignFirstResponder];
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
