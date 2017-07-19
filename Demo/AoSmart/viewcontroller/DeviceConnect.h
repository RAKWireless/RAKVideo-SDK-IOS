//
//  DeviceConnect.h
//  AoSmart
//
//  Created by rakwireless on 16/1/26.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParametersConfig.h"

@interface DeviceConnect : UIViewController<ParametersConfigDelegate>
{
    UIButton *_DeviceConnectBack;
    UILabel  *_DeviceConnectTitle;
    UIImageView *_DeviceConnectImage;
    UILabel *_DeviceConnectText;
    UITextField *_DeviceConnectField;
    UIButton *_DeviceConnectVideoType;
    UIButton *_DeviceConnectForgetPsk;
    UIButton *_DeviceScreenBtn;
    UIButton *_DeviceConnectBtn;
    UIView *_chooseView;
    UIButton *_DeviceConnectVideoH264;
    UIButton *_DeviceConnectVideoMjpeg;
}
@property (retain, nonatomic) ParametersConfig* parametersConfigDeviceConnect;
@end

