//
//  RNBlueToothManager.h
//  LazyBBQ
//
//  Created by King on 2019/6/17.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "BlueToothManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNBlueToothManager : RCTEventEmitter <RCTBridgeModule>

@property(nonatomic, strong) BlueToothManager *btManager;

@end

NS_ASSUME_NONNULL_END
