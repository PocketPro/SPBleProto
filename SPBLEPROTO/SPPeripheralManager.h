//
//  SPPeripheralManager.h
//  SPBLEPROTO
//
//  Created by Gord Parke on 7/21/17.
//  Copyright © 2017 Gord Parke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/Corebluetooth.h>
#import "SkyProKit.h"

@class SPPeripheralManager;

@interface SPPeripheralManager : NSObject

+ (SPPeripheralManager *)sharedManager;

@property (nonatomic) id<SP3DSwingProtocol> swing;

- (void)startAdvertising;
- (void)stopAdvertising;

@end
