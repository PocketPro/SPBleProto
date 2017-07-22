//
//  Swing.m
//  SkyProKit
//
//  Created by Gord Parke on 8/14/13.
//  Copyright (c) 2013 Gord Parke. All rights reserved.
//

#import "Swing.h"
#import "Club.h"
#import "Satellite.h"
#import "SkyProKit.h"

@interface Swing ()
@property (nonatomic, readwrite) void *handle;
@property (nonatomic, readwrite, getter = isValid) BOOL valid;
@property (nonatomic, strong, readwrite) NSError *error;
@end


@implementation Swing

- (NSString *)descriptionStringForError:(GSErr)err
{
    // This method provides a description for a given error code.  The returned string is suitable for
    // displaying as the title in an alert panel.  Where we can, we use the GolfSwingKit error strings,
    // although they are not suitable for all users since some contain esoteric language and none are localized.
    
    switch (err) {
        // Invalid device version
        case GSInvalidDeviceVersion :
            return @"Unrecognized Version";
            
        // Invalid club measurement
        case GSInvalidClubLength:
        case GSInvalidClubLoft:
        case GSInvalidClubLie:
        case GSInvalidClubCenterFaceOffsetX:
        case GSInvalidClubCenterFaceOffsetZ:
        case GSInvalidClubLeadingEdgeOffsetY:
            return [NSString stringWithCString:gsErrorCodeStrings[err] encoding:NSUTF8StringEncoding];
            
        // Invalid club calibration
        case GSClubParametersMismatch:
        case GSInvalidMClipToBodyMatrix:
        case GSNoMClipToBodyMatrix:
            return @"Calibration Not Found";
            
        // Swing data not reconstructable
        case GSSwingNotDetected:
            return @"Reconstruction Unsuccessful";
            
        default:
            return @"Error";
    }
}

- (NSString *)recoverySuggestionStringForError:(GSErr)err handle:(GSSwing_t *)handle;
{
    // This method provides a recovery suggestion for a given error code.  The returned string is suitable for
    // displaying as the secondary message in an alert panel.  
    
    switch (err) {
        // Invalid device version
        case GSInvalidDeviceVersion:
            return [NSString stringWithFormat:@"Please update your %@ app", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
            
        // Invalid club measurement
        case GSInvalidClubLength:
        case GSInvalidClubLoft:
        case GSInvalidClubLie:
        case GSInvalidClubCenterFaceOffsetX:
        case GSInvalidClubCenterFaceOffsetZ:
        case GSInvalidClubLeadingEdgeOffsetY:
            return @"Please calibrate your club and then edit its measurements.";
            
        // Invalid club calibration
        case GSClubParametersMismatch:
        case GSInvalidMClipToBodyMatrix:
        case GSNoMClipToBodyMatrix:
            return @"Please calibrate your club before taking any more swings.";
            
        // Swing data not reconstructable
        case GSSwingNotDetected:
        {
            // This is a special case in which we can query the swing handle for more information
            GSErr validationErr = GSSwingValidationError(handle);
            switch (validationErr) {
                case GSNotStillEnoughAfterInitialWaggle:
                    return @"Please hold your club still for an instant just before swinging.  We detected too much waggle before this shot.";
               
                case GSInitialRotationRateUnacceptable:
                    return @"Please hold your club still for an instant just before swinging.";
                    
                case GSNoImpactDetectedInSwing:
                    return @"We didn't detect a ball impact.  If you're indoors, please hit a limited-distance ball or brush a hitting "
                            "surface (mat, ground, etc.)  If you're putting, please make sure a putter is calibrated.";
                    
                default:
                    return @"No swing detected.  Please try again.";
            }
        }
            
        default:
            return [NSString stringWithFormat: @"There was an unexpected error (%d).  Please try again.", err];

    }
}

- (BOOL)processSwingData
{
    GSErr err;
    
    // Assert we have a club
    if (!self.club) [NSException raise:NSInternalInconsistencyException format:@"No club in %@", NSStringFromSelector(_cmd)];
    if (!self.satellite) [NSException raise:NSInternalInconsistencyException format: @"No satellite in %@", NSStringFromSelector(_cmd)];
    
    // Create a new swing
    GSSwing_t *newHandle = GSCreateSwing();
    
    // Enter our club measurements into the swing
    GSClub_t club;
    club.type = [self.club.type intValue];
    club.loftNumber = [self.club.loftNumber intValue];
    club.measurements.length = [self.club.length floatValue];
    club.measurements.manufacturedLie = [self.club.manufacturedLieAngle floatValue];
    club.measurements.manufacturedLoft = [self.club.manufacturedLoftAngle floatValue];
    club.measurements.centerFaceOffsetX = [self.club.centerFaceOffsetX floatValue];
    club.measurements.centerFaceOffsetZ = [self.club.centerFaceOffsetZ floatValue];
    club.measurements.leadingEdgeOffsetY = [self.club.leadingEdgeOffsetY floatValue];
    if ((err = GSSetClub(newHandle, club)) == GSSuccess){
        
        // Enter our satellite's parameters into the swing
        GSInt16 hardwareVersionMajor = [[self.satellite versionMajor] integerValue];
        GSInt16 hardwareVersionMinor = [[self.satellite versionMinor] integerValue];
        if ((err = GSSetDeviceParameters(newHandle, hardwareVersionMajor, hardwareVersionMinor, NULL, NULL)) == GSSuccess){
         
            // Actually process the data and calculate the swing
            err = GSCalculateSwingFromIMUData(newHandle, [self.rawSwingData bytes] , (GSInt)[self.rawSwingData length]);
        }
    }
    
    // Handle any error that resulted and update our validity properties
    if (err != GSSuccess){
        self.valid = NO;
        self.error = [NSError errorWithDomain:@"GolfSwingKitErrorDomain" code:err userInfo:@{
                    NSLocalizedDescriptionKey: [self descriptionStringForError:err],
        NSLocalizedRecoverySuggestionErrorKey: [self recoverySuggestionStringForError:err handle:newHandle]
                      }];
        
        // Release new handle 
        GSFreeSwing(&newHandle);
        newHandle = nil; // Redundant, but here to make the nulling explicit.
    } else {
        self.valid = YES;
        self.error = nil;
        NSAssert(newHandle != nil, @"No error returned but swing handle is nil");
    }
    
    // Update the handle
    GSFreeSwing((GSSwing_t **)&_handle);   // Release old handle
    self.handle = newHandle;
    
    return (err == GSSuccess);
}


@end
