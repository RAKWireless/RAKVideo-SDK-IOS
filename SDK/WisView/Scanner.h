#import <Foundation/Foundation.h>

@interface Scanner : NSObject
@property (nonatomic,retain) NSArray* Device_IP_Arr;
@property (nonatomic,retain) NSArray* Device_ID_Arr;
-(Scanner*)ScanDeviceWithTime:(NSTimeInterval)time;


@end
