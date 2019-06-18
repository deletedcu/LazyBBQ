//
//  RNBlueToothManager.m
//  LazyBBQ
//
//  Created by King on 2019/6/17.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNBlueToothManager.h"

@implementation RNBlueToothManager

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup
{
  return YES;  // only do this if your module initialization relies on calling UIKit!
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"EventReminder"];
}

- (NSDictionary *)constantsToExport
{
  return @{ @"test": @"test" };
}

RCT_EXPORT_METHOD(initBlueToothManager:(RCTResponseSenderBlock)callback)
{
  self.btManager = [BlueToothManager shareManager];
  
  [RACObserve(self.btManager, connect) subscribeNext:^(NSNumber *value) {
    
    if (![value boolValue]) {
      // unconnected
      [self bluetoothEventReminderReceived:@"unconnected"];
    }
    else{
      // connected
      [self bluetoothEventReminderReceived:@"connected"];
    }
  }];
  NSDictionary *result = [self convertBTManagerToDictionary:self.btManager];
  callback(@[[NSNull null], result]);
}

- (void)bluetoothEventReminderReceived:(NSString *)eventName
{
  [self sendEventWithName:@"EventReminder" body:@{@"name": eventName, @"btManager": [self convertBTManagerToDictionary: self.btManager]}];
}

- (NSDictionary *)convertBTManagerToDictionary: (BlueToothManager* )manager
{
  return @{
           @"info": [self convertBBQInfoToDictionary:manager.info],
           @"connect": @(manager.connect),
           @"listChannelOne": manager.listChannelOne,
           @"listChannelTwo": manager.listChannelTwo,
//           @"listChannelThree": manager.listChannelThree,
//           @"listChannelFour": manager.listChannelFour,
           @"lastDate": @([self convertDateToTimeInterval:manager.lastDate]),
           @"channelOne": [self convertChannelInfoToDictionary:manager.channelOne],
           @"channelTwo": [self convertChannelInfoToDictionary:manager.channelTwo],
           @"channelThree": [self convertChannelInfoToDictionary:manager.channelThree],
           @"channelFour": [self convertChannelInfoToDictionary:manager.channelFour],
           };
}

- (NSDictionary *)convertChannelInfoToDictionary: (ChannelInfo *)info
{
  if (info == nil) {
    return @{};
  }
  return @{
           @"type": @([self getChannelType:info.type]),
           @"enable": @(info.enable),
           @"maxValue": @(info.maxValue),
           @"alarmValue": @(info.alarmValue),
           @"alarmFsValue": @(info.alarmFsValue),
           @"value": @(info.value),
           @"meat": [self getSafeString:info.meat],
           @"duration": @(info.durtaion),
           @"alarmDate": @([self convertDateToTimeInterval:info.alarmDate]),
           @"startDate": @([self convertDateToTimeInterval:info.startDate]),
           @"endDate": @([self convertDateToTimeInterval:info.endDate]),
           @"calculateArray": info.calculateArray,
           @"restTime": @(info.restTime),
           @"deviceSetValue": @(info.deviceSetValue)
           };
}

- (NSDictionary *)convertBBQInfoToDictionary: (BBQInfo *)info
{
  if (info == nil) {
    return @{};
  }
  return @{
           @"date": @([self convertDateToTimeInterval:info.date]),
           @"channelOne": @(info.channelOne),
           @"channelTwo": @(info.channelTwo),
           @"channelThree": @(info.channelThree),
           @"channelFour": @(info.channelFour),
           @"setOne": @(info.setOne),
           @"setTwo": @(info.setTwo),
           @"setThree": @(info.setThree),
           @"setFour": @(info.setFour)
           };
}

- (NSInteger)convertDateToTimeInterval: (NSDate *)date
{
  if (date == nil) {
    return -1;
  }
  return [date timeIntervalSince1970];
}

- (NSString *)getSafeString: (NSString *)str
{
  if (str == nil) {
    return @"";
  }
  return str;
}

- (NSInteger)getChannelType: (ChannelType)type {
  switch (type) {
    case ChannelOne:
      return 0;
    case ChannelTwo:
      return 1;
    case ChannelThree:
      return 2;
    case ChannelFour:
      return 3;
    default:
      return -1;
  }
}

@end
