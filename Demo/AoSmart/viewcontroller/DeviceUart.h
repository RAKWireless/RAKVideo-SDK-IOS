//
//  DeviceUart.h
//  AoSmart
//
//  Created by rakwireless on 16/8/25.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

@interface DeviceUart : UIViewController
{
    UIButton *_DeviceUartBack;
    UITextView *_DeviceUartRecvField;
    UITextView *_DeviceUartSendField;
    UILabel *_DeviceUartRecvNum;
    UILabel *_DeviceUartSendNum;
    UIButton *_DeviceUartSendBtn;
    UIButton *_DeviceUartClearBtn;
}
@end
