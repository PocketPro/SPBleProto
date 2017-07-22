//
//  SPPeripheralManager.m
//  SPBLEPROTO
//
//  Created by Gord Parke on 7/21/17.
//  Copyright © 2017 Gord Parke. All rights reserved.
//

#import "SPPeripheralManager.h"

// If you create a new characteristic, you must:
//   1) Define it below,
//   2) Add it to the service in the init method,
//   3) Pull its value from the swing object in dataForUUID:

// Full Swing Service
#define SP_UDID_FULL_SWING_SERVICE      @"c913b920-0351-4493-bc47-df1f5b4914dd"
#define SP_UDID_FULL_SWING_TIMESTAMP            @"eac79057-6afa-4214-9869-98d2467b6512"
#define SP_UDID_FULL_SWING_UUID_MS              @"23e8619c-4fcc-48d1-ab0c-be108f234751"
#define SP_UDID_FULL_SWING_UUID_LS              @"c4476c7f-0110-4f15-b302-972bbb027ab2"
#define SP_UDID_CLUBHEAD_SPEED                  @"79df503e-4d36-4b26-a70b-6cdf51b50816"
#define SP_UDID_HAND_SPEED                      @"218f9d45-0750-4fd4-84ad-1e0ab728f374"
#define SP_UDID_SWING_TEMPO                     @"e6fce1ae-6ef3-40e6-b397-0fb654a8e7ed"
#define SP_UDID_TIME_TO_IMPACT                  @"88942203-949e-41ea-be8b-483b1bf2ffe4"
#define SP_UDID_SHAFT_LEAN_ADDRESS              @"9d3a3ee1-5846-4f23-b659-bd641d9d23b0"
#define SP_UDID_SHAFT_LEAN_IMPACT               @"8d65c1b0-9fd1-4937-a606-f7b890293a75"
#define SP_UDID_SHAFT_ANGLE_ADDRESS             @"bb220e48-5cfe-476d-878e-e0b002ed69f2"
#define SP_UDID_SHAFT_ANGLE_IMPACT              @"229c6f32-e897-479a-8df4-52ef9b9f0ae9"
#define SP_UDID_BACKSWING_LENGTH                @"34a2d576-ad54-4afc-9d19-2d1b7592e6cb"
#define SP_UDID_FACE_ANGLE_TOP                  @"39e223af-f327-4bb8-91eb-a6c310f7aba0"
#define SP_UDID_SHAFT_DIRECTION_TOP             @"f29eb446-712b-4299-9a26-479ff44db948"
#define SP_UDID_FACE_ANGLE_HALF_BACK            @"c8647978-eec5-4947-ae43-5b6e1bfbfec0"
#define SP_UDID_FACE_ANGLE_HALF_DOWN            @"b2697ca0-8f8a-4320-a19e-03922e437b74"
#define SP_UDID_INSIDE_PLANE_ANGLE_HALF_BACK    @"5c3d96b2-30ee-4e71-b044-42465e7d63cd"
#define SP_UDID_INSIDE_PLANE_ANGLE_HALF_DOWN    @"dd7d76cc-ee59-413e-8a92-54e2aa21d206"
#define SP_UDID_FACE_ANGLE_IMPACT               @"019fead5-c5c7-45d6-bb1b-b6e009c3adc3"
#define SP_UDID_ATTACK_ANGLE_IMPACT             @"609a13a2-86bc-4f0d-8ed2-a152c2b73acb"
#define SP_UDID_PATH_DIRECTION_IMPACT           @"e1d428d1-7be4-4b8e-8733-a996c184b2d2"


// Putt Service
#define SP_UDID_PUTT_SERVICE           @"83dacba2-f440-44fd-9bde-8dd0173f2c1c"
#define SP_UDID_PUTT_TIMESTAMP                  @"747afc12-592c-4b2b-a9bd-eb48cba35544"
#define SP_UDID_PUTT_SWING_UUID_MS              @"B026FA13-6738-4C35-AA0F-AD904169B6FA"
#define SP_UDID_PUTT_SWING_UUID_LS              @"44E2C380-2ADD-4F57-B717-2525FCE9A2BE"
#define SP_UDID_PUTT_SWING_TEMPO                @"9756916f-c416-4592-9161-ea7fa5197efd"
#define SP_UDID_PUTT_HEAD_SPEED                 @"ec29686c-6350-49a8-bdb6-eb953fab28af"
#define SP_UDID_PUTT_LENGTH_TOP                 @"63a0343b-c195-4150-9827-d4e295095fc3"
#define SP_UDID_PUTT_RISE_ANGLE_IMPACT          @"489e3b5b-d6e8-4c4f-9fcc-c48986858c61"
#define SP_UDID_PUTT_SHAFT_DIRECTION_TOP        @"3c8df210-54ae-4ff3-9776-bf737f952592"
#define SP_UDID_PUTT_LIE_IMPACT                 @"56819d5a-5bbe-42d5-b53f-d45acf29fcd2"
#define SP_UDID_PUTT_LIE_ADDRESS                @"e254e365-5d9f-49f7-8394-feba45b1f5af"
#define SP_UDID_PUTT_SHAFT_ANGLE_IMPACT         @"62359214-c4d0-4b1f-82dd-d243846e30c1"
#define SP_UDID_PUTT_SHAFT_ANGLE_ADDRESS        @"724de838-43f6-44d6-8c02-c510c5948211"
#define SP_UDID_PUTT_LOFT_IMPACT                @"bb6fbdaa-2efe-4cd0-b152-251c4969b25a"
#define SP_UDID_PUTT_LOFT_ADDRESS               @"2b4d2a83-4920-42be-9470-72348fc58a7c"
#define SP_UDID_PUTT_SHAFT_LEAN_IMPACT          @"7bd9932e-ee90-4bf6-836b-fce148d585c9"
#define SP_UDID_PUTT_SHAFT_LEAN_ADDRESS         @"2918fd73-e7d1-405f-8e0c-467b01b15018"
#define SP_UDID_PUTT_FACE_ANGLE_IMPACT          @"19c14970-c2c6-41c3-bdcc-e72fb5564016"
#define SP_UDID_PUTT_PATH_DIRECTION_IMPACT      @"22f647d4-ce1c-4e2b-b326-c0bb63bac248"


@interface SPPeripheralManager () <CBPeripheralManagerDelegate>
@property (nonatomic) CBPeripheralManager *underlyingManager;
@property (nonatomic) NSDate *swingSetDate;
@property (nonatomic) NSDictionary *charateristics;
@end

@implementation SPPeripheralManager

+ (SPPeripheralManager *)sharedManager {
    static SPPeripheralManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]){
        self.underlyingManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)startAdvertising {
    if (!self.underlyingManager.isAdvertising && self.underlyingManager.state == CBManagerStatePoweredOn){
        [self.underlyingManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SP_UDID_FULL_SWING_SERVICE]] }];
    }
}

- (void)stopAdvertising {
    if (self.underlyingManager.isAdvertising) {
        [self.underlyingManager stopAdvertising];
    }
}

- (void)setSwing:(id<SP3DSwingProtocol>)swing{
    if (_swing != swing){
        _swing = swing;
        
        _swingSetDate = [NSDate date];
        
        // Update timestamp fields
        if (self.underlyingManager.isAdvertising){
            GSClub_t club = GSGetClub(swing.handle);
            if (club.type == GSClubTypePutter){
                [self.underlyingManager updateValue:[self dataForUUIDString:SP_UDID_PUTT_TIMESTAMP]
                                  forCharacteristic:[self.charateristics objectForKey:SP_UDID_PUTT_TIMESTAMP]
                               onSubscribedCentrals:nil];
            } else {
                [self.underlyingManager updateValue:[self dataForUUIDString:SP_UDID_FULL_SWING_TIMESTAMP]
                                  forCharacteristic:[self.charateristics objectForKey:SP_UDID_FULL_SWING_TIMESTAMP]
                               onSubscribedCentrals:nil];
            }
        }
    }
}

- (NSData *)dataForParameterKey:(GSParameterKey_t)key{
    GSParameter_t param = GSGetParameterForKey(self.swing.handle, key);
    return [NSData dataWithBytes:&(param.value) length:sizeof(param.value)];
}

- (NSData *)dataForUUIDString:(NSString *)uuid {
    if (!self.swing || !uuid) {
        return nil;
    }
    
    
    // Full Swing
    if ([uuid isEqualToString:SP_UDID_FULL_SWING_TIMESTAMP]){
        
        // Extract date from swing
        NSDate *swingDate = nil;
        GSUInt32 swingDateSeconds;
        if (GSGetSwingTimestampInSeconds(self.swing.handle, &swingDateSeconds) == GSSuccess){
            swingDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)swingDateSeconds];
            if ([swingDate timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:1312947367]] > 0){
                // Swing date is before Aug 9/2011.  This means that the time is relative to boot time
                // of the device (it didn't have an absolute date when the swing was taken)
                swingDate = self.swingSetDate;
            }
        }
        
        // Convert to unix time and update characteristic
        NSTimeInterval unixTime = [swingDate timeIntervalSince1970];
        return [NSData dataWithBytes:&unixTime length:sizeof(unixTime)];
        
    } else if ([uuid isEqualToString:SP_UDID_FULL_SWING_UUID_MS]){
        //TODO
        int tmp = 0;
        return [NSData dataWithBytes:&tmp length:sizeof(tmp)];
    } else if ([uuid isEqualToString:SP_UDID_FULL_SWING_UUID_LS]){
        //TODO
        int tmp = 0;
        return [NSData dataWithBytes:&tmp length:sizeof(tmp)];
    } else if ([uuid isEqualToString:SP_UDID_CLUBHEAD_SPEED]){
        return [self dataForParameterKey:GSParameterKeyHeadSpeedImpact];
    } else if ([uuid isEqualToString:SP_UDID_HAND_SPEED]){
        return [self dataForParameterKey:GSParameterKeyHandSpeedImpact];
    } else if ([uuid isEqualToString:SP_UDID_SWING_TEMPO]){
        return [self dataForParameterKey:GSParameterKeyTempo];
    } else if ([uuid isEqualToString:SP_UDID_TIME_TO_IMPACT]){
        return [self dataForParameterKey:GSParameterKeyTimeToImpact];
    } else if ([uuid isEqualToString:SP_UDID_SHAFT_LEAN_ADDRESS]){
        return [self dataForParameterKey:GSParameterKeyShaftLeanAddress];
    } else if ([uuid isEqualToString:SP_UDID_SHAFT_LEAN_IMPACT]){
        return [self dataForParameterKey:GSParameterKeyShaftAngleImpact];
    } else if ([uuid isEqualToString:SP_UDID_BACKSWING_LENGTH]){
        return [self dataForParameterKey:GSParameterKeyBackswingLength];
    } else if ([uuid isEqualToString:SP_UDID_FACE_ANGLE_TOP]){
        return [self dataForParameterKey:GSParameterKeyFaceAngleTop];
    } else if ([uuid isEqualToString:SP_UDID_SHAFT_DIRECTION_TOP]){
        return [self dataForParameterKey:GSParameterKeyShaftDirectionTop];
    } else if ([uuid isEqualToString:SP_UDID_FACE_ANGLE_HALF_BACK]){
        return [self dataForParameterKey:GSParameterKeyFaceAngleHalfBack];
    } else if ([uuid isEqualToString:SP_UDID_FACE_ANGLE_HALF_DOWN]){
        return [self dataForParameterKey:GSParameterKeyFaceAngleHalfDown];
    } else if ([uuid  isEqualToString:SP_UDID_INSIDE_PLANE_ANGLE_HALF_BACK]){
        return [self dataForParameterKey:GSParameterKeyTakeawayAngleHalfBack];
    } else if ([uuid isEqualToString:SP_UDID_INSIDE_PLANE_ANGLE_HALF_DOWN]){
        return [self dataForParameterKey:GSParameterKeyReturnAngleHalfDown];
    } else if ([uuid isEqualToString:SP_UDID_FACE_ANGLE_IMPACT]){
        return [self dataForParameterKey:GSParameterKeyFaceAngleImpact];
    } else if ([uuid isEqualToString:SP_UDID_ATTACK_ANGLE_IMPACT]){
        return [self dataForParameterKey:GSParameterKeyAttackAngleImpact];
    } else if ([uuid isEqualToString:SP_UDID_PATH_DIRECTION_IMPACT]){
        return [self dataForParameterKey:GSParameterKeyPathDirectionImpact];
    }
    
    return nil;
}

- (CBCharacteristic *)charWithTypeString:(NSString *)strType value:(float)value{
    CBMutableCharacteristic *characteristic= [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:strType] properties:CBCharacteristicPropertyRead value:[NSData dataWithBytes:&value length:sizeof(float)] permissions:CBAttributePermissionsReadable];
    return characteristic;
}

- (void)addCharacteristicWithTypeString:(NSString *)strType toDictionary:(NSMutableDictionary *)dict {
    // Passing in "nil" for value will cause the central manager to ask its delegate (this object) for the value.
    CBMutableCharacteristic *characteristic= [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:strType] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    
    [dict setObject:characteristic forKey:strType];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager {
    // Opt out from any other state
    if (peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        [peripheralManager stopAdvertising];
        return;
    }
    
    // We're in CBPeripheralMa0nagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    NSMutableDictionary *chars = [NSMutableDictionary dictionary];
    
    // Full swing
    [self addCharacteristicWithTypeString:SP_UDID_CLUBHEAD_SPEED toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_FULL_SWING_TIMESTAMP toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_HAND_SPEED toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_FULL_SWING_UUID_LS toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_FULL_SWING_UUID_LS toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_SWING_TEMPO toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_TIME_TO_IMPACT toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_SHAFT_LEAN_ADDRESS toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_SHAFT_LEAN_IMPACT toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_SHAFT_ANGLE_ADDRESS toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_SHAFT_ANGLE_IMPACT toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_BACKSWING_LENGTH toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_FACE_ANGLE_TOP toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_SHAFT_DIRECTION_TOP toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_FACE_ANGLE_HALF_BACK toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_FACE_ANGLE_HALF_DOWN toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_INSIDE_PLANE_ANGLE_HALF_BACK toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_INSIDE_PLANE_ANGLE_HALF_DOWN toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_FACE_ANGLE_IMPACT toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_ATTACK_ANGLE_IMPACT toDictionary:chars];
    [self addCharacteristicWithTypeString:SP_UDID_PATH_DIRECTION_IMPACT toDictionary:chars];

    self.charateristics = [NSDictionary dictionaryWithDictionary:chars];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SP_UDID_FULL_SWING_SERVICE]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = [NSArray arrayWithArray:self.charateristics.allValues];
    
    // And add it to the peripheral manager
    [peripheralManager addService:transferService];
    if (self.underlyingManager.isAdvertising) {
        [self startAdvertising];
    } else {
        [self stopAdvertising];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    NSData *value = [self dataForUUIDString:request.characteristic.UUID.UUIDString];
    if (value) {
        request.value = value;
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    } else {
        [peripheral respondToRequest:request withResult:CBATTErrorReadNotPermitted];
    }
    
}


@end
