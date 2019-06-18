//
//  BlueToothManager.m
//  BBQ
//
//  Created by Richard on 14/12/10.
//  Copyright (c) 2014年 Chutong. All rights reserved.
//

#import "BlueToothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <ExternalAccessory/ExternalAccessory.h>

static NSString *TRANSFER_SERVICE_UUID = @"FE551580-4180-8A02-EF2C-1B42A0AC3F83";
static NSString *TRANSFER_CHARACTERISTIC_UUID = @"FE551582-4180-8A02-EF2C-1B42A0AC3F83";
static NSString *TRANSFER_CHARACTERISTIC_WRITE_UUID = @"FE551581-4180-8A02-EF2C-1B42A0AC3F83";

@implementation BBQInfo


- (id)initWithData:(NSData *)data
{
    self = [super init];
    if(self){

        NSLog(@"data:%@",data);
        
        int16_t i=0,j=0,m=0,n=0;
        [data getBytes:&i range:NSMakeRange(0, 2)];
        [data getBytes:&j range:NSMakeRange(2, 2)];
        [data getBytes:&m range:NSMakeRange(4, 2)];
        [data getBytes:&n range:NSMakeRange(6, 2)];
        
        self.channelThree = 300;
        self.channelFour = 300;
        
#ifdef BBQ4
        int16_t v3,v4,s3,s4=0;
        [data getBytes:&v3 range:NSMakeRange(8, 2)];
        [data getBytes:&v4 range:NSMakeRange(10, 2)];
        [data getBytes:&s3 range:NSMakeRange(12, 2)];
        [data getBytes:&s4 range:NSMakeRange(14, 2)];
        self.channelThree = v3;
        self.channelFour = v4;
        self.setThree = s3;
        self.setFour = s4;
#endif
        self.channelOne = i;
        self.channelTwo = j;
        self.setOne = m;
        self.setTwo = n;
        
        self.date = [NSDate date];
        NSLog(@"p1:%d set:%d",i,m);
        NSLog(@"p2:%d set:%d",j,n);
    }
    return self;
}
@end


@implementation ChannelInfo

- (NSString *)getDateKey
{
    NSString *key = @"date";
    switch (self.type) {
        case ChannelOne:
            key = @"dateChannelOne";
            break;
        case ChannelTwo:
            key = @"dateChannelTwo";
            break;
        case ChannelThree:
            key = @"dateChannelThree";
            break;
        case ChannelFour:
            key = @"dateChannelFour";
            break;
            
        default:
            break;
    }
    return key;
}

- (NSString *)getMeatKey
{
    NSString *key = @"meat";
    switch (self.type) {
        case ChannelOne:
            key = @"meatChannelOne";
            break;
        case ChannelTwo:
            key = @"meatChannelTwo";
            break;
        case ChannelThree:
            key = @"meatChannelThree";
            break;
        case ChannelFour:
            key = @"meatChannelFour";
            break;
            
        default:
            break;
    }
    return key;
}

- (id)initWithType:(ChannelType)type
{
    self = [super init];
    if(self){
        self.calculateArray = [NSMutableArray array];
        self.type = type;
        
        self.meat = [[NSUserDefaults standardUserDefaults] objectForKey:[self getMeatKey]];
        self.alarmDate = [[NSUserDefaults standardUserDefaults] objectForKey:[self getDateKey]];
    }
    return self;
}

- (NSInteger)restTime
{
    //当前只有一个温度，需要更多温度才能计算
    if(self.calculateArray.count <= 1)
        return -1;
    
    NSInteger value = [[self.calculateArray firstObject] integerValue];
    NSInteger lastValue = [[self.calculateArray lastObject] integerValue];
    NSInteger diffTemperature = lastValue - value;
    //温度没有变化时，无法计算剩余时间
    if(diffTemperature == 0)
        return -1;
    NSInteger rest = (self.alarmValue - lastValue) * (self.calculateArray.count/diffTemperature);
    return rest;
}

- (void)setAlarmValue:(NSInteger)alarmValue
{
    _alarmValue = alarmValue;
    [[BlueToothManager shareManager] setChannel:self.type value:(int)alarmValue];
    
    _alarmDate = [NSDate date];
    
    [[NSUserDefaults standardUserDefaults] setObject:_alarmDate forKey:[self getDateKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDeviceSetValue:(NSInteger)deviceSetValue
{
    _alarmValue = deviceSetValue;
    _deviceSetValue = deviceSetValue;
}

- (NSInteger)alarmFsValue
{
    return _alarmValue *1.8 +32;
}

- (void)setMeat:(NSString *)meat
{
    _meat = meat;
    
    NSString *key = [self getMeatKey];
    if(_meat){
        [[NSUserDefaults standardUserDefaults] setObject:_meat forKey:key];
    }
    else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addCalculateValue:(NSInteger)value
{
    self.value = value;
    
    if(value > self.maxValue){
        self.maxValue = value;
    }
    
    NSDate *date = [NSDate date];
    if(!self.startDate){
        self.startDate = date;
    }
    self.endDate = date;
    
    if(value < [[self.calculateArray firstObject] integerValue])
    {
        [self.calculateArray removeAllObjects];
    }
    [self.calculateArray addObject:[NSNumber numberWithInteger:value]];
}

- (NSInteger)durtaion
{
    CGFloat durtaion = [self.endDate timeIntervalSinceDate:self.startDate];
    return durtaion;
}

@end

@interface BlueToothManager()<EAAccessoryDelegate, NSStreamDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@end

@implementation BlueToothManager

+ (BlueToothManager *)shareManager
{
    static BlueToothManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BlueToothManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if(self){
        self.listChannelOne = [NSMutableArray array];
        self.listChannelTwo = [NSMutableArray array];
        
        self.channelOne = [[ChannelInfo alloc] initWithType:ChannelOne];
        self.channelTwo = [[ChannelInfo alloc] initWithType:ChannelTwo];
        self.channelThree = [[ChannelInfo alloc] initWithType:ChannelThree];
        self.channelFour = [[ChannelInfo alloc] initWithType:ChannelFour];
        
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (NSInteger)durtaionChannelOne
{
    BBQInfo *firstInfo = [self.listChannelOne firstObject];
    BBQInfo *lastInfo = [self.listChannelOne lastObject];
    
    CGFloat durtaion = [lastInfo.date timeIntervalSinceDate:firstInfo.date];
    
    NSLog(@"%f",durtaion);
    
    return durtaion;
}

- (NSInteger)durtaionChannelTwo
{
    BBQInfo *firstInfo = [self.listChannelTwo firstObject];
    BBQInfo *lastInfo = [self.listChannelTwo lastObject];
    
    return [lastInfo.date timeIntervalSinceDate:firstInfo.date];
}

#pragma mark - Central Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    [self scan];
}

#pragma mark - 数据设置
- (void)setChannel:(ChannelType)type value:(int)value
{
    for (CBService *service in self.discoveredPeripheral.services)
    {
        if (service.characteristics != nil)
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                NSLog(@"characteristic.UUID:%@",characteristic.UUID);
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]])
                {
                    //注：由于操作不可能两路一起设定，所有两个设定值只有1个有效。无效的填250（0xFA）。第6个字节是有效的设定值减去6。
                    NSMutableData *data = [NSMutableData data];
                    int channelOne = ((type == ChannelOne)?value:250);
                    int channelTwo = ((type == ChannelTwo)?value:250);
                    
                    int zero = 0;
                    int last = value - 6;
                    
                    [data appendBytes:&channelOne length:2];
//                    [data appendBytes:&zero length:1];
                    [data appendBytes:&channelTwo length:2];
//                    [data appendBytes:&zero length:1];
                    
                    #ifdef BBQ4
                    int channelThree = ((type == ChannelThree)?value:250);
                    int channelFour = ((type == ChannelFour)?value:250);
                    [data appendBytes:&channelThree length:2];
//                    [data appendBytes:&zero length:1];
                    [data appendBytes:&channelFour length:2];
//                    [data appendBytes:&zero length:1];
                    #endif
                    
                    [data appendBytes:&zero length:1];
                    [data appendBytes:&last length:1];
                    
                    [self.discoveredPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                }
            }
        }
    }
}

 - (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didWriteValueForCharacteristic:%@",error);
}

- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
    
    NSLog(@"Scanning started");
}

/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    // Reject any where the value is above reasonable range
//    if (RSSI.integerValue > -15) {
//        return;
//    }
//    
//    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
//    if (RSSI.integerValue < -35) {
//        return;
//    }
    
    // Ok, it's in range - have we already seen it?
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    self.connect = YES;
    
    self.channelOne.enable = YES;
    self.channelTwo.enable = YES;
    self.channelThree.enable = YES;
    self.channelFour.enable = YES;
    
    // Stop scanning
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
//    [self.readData setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID],[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_WRITE_UUID]] forService:service];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}

#pragma mark - 数据读取
/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
//    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//    NSLog(@"stringFromData:%@",stringFromData);
//    // Have we got everything we need?
//    if ([stringFromData isEqualToString:@"EOM"]) {
//        
//        // Cancel our subscription to the characteristic
//        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
//        
//        // and disconnect from the peripehral
//        [self.centralManager cancelPeripheralConnection:peripheral];
//    }
    
    
    BBQInfo *info = [[BBQInfo alloc] initWithData:characteristic.value];
    // Otherwise, just add the data on to what we already have
    self.channelOne.enable = (info.channelOne != 300);
    self.channelTwo.enable = (info.channelTwo != 300);
    self.channelThree.enable = (info.channelThree != 300);
    self.channelFour.enable = (info.channelFour != 300);
    
    if(self.channelOne.enable){
        [self.channelOne addCalculateValue:info.channelOne];
        self.channelOne.deviceSetValue = info.setOne;
    }
    if(self.channelTwo.enable){
        [self.channelTwo addCalculateValue:info.channelTwo];
        self.channelTwo.deviceSetValue = info.setTwo;
    }
    if(self.channelThree.enable){
        [self.channelThree addCalculateValue:info.channelThree];
        self.channelThree.deviceSetValue = info.setThree;
    }
    if(self.channelOne.enable){
        [self.channelFour addCalculateValue:info.channelFour];
        self.channelFour.deviceSetValue = info.setFour;
    }
    
    NSDate *date = [NSDate date];
    NSInteger diff = [date timeIntervalSinceDate:self.lastDate];
    if(!self.lastDate || diff > 5)
    {
        if(self.channelOne.enable){
            [self.listChannelOne addObject:[NSNumber numberWithInteger:info.channelOne]];
        }
        if(self.channelTwo.enable){
            [self.listChannelTwo addObject:[NSNumber numberWithInteger:info.channelTwo]];
        }
        if(self.channelThree.enable){
            [self.listChannelThree addObject:[NSNumber numberWithInteger:info.channelThree]];
        }
        if(self.channelFour.enable){
            [self.listChannelTwo addObject:[NSNumber numberWithInteger:info.channelFour]];
        }
        
        self.lastDate = date;
    }
    self.info = info;
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.discoveredPeripheral = nil;
    self.connect = NO;
    
    self.channelOne.enable = NO;
    self.channelTwo.enable = NO;
    self.channelThree.enable = NO;
    self.channelFour.enable = NO;
    
    // We're disconnected, so start scanning again
    [self scan];
}



/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (self.discoveredPeripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    self.connect = NO;
    self.channelOne.enable = NO;
    self.channelTwo.enable = NO;
    self.channelThree.enable = NO;
    self.channelFour.enable = NO;
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}
@end
