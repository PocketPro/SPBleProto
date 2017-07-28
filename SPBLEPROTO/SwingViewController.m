//
//  SwingViewController.m
//  SkyProKit
//
//  Created by Gord Parke on 11/27/13.
//  Copyright (c) 2013 Gord Parke. All rights reserved.
//

#import "SwingViewController.h"
#import <SP3D/Scene/SP3DSceneController_private.h>
#import "Swing.h"
#import "Club.h"
#import "Satellite.h"
#import "PPSerializedSwing.h"

@interface SwingViewController () <SatelliteManagerTransferDelegate, UIActionSheetDelegate>
@property (nonatomic) NSUInteger swingCount;
@property (nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) IBOutlet UIActivityIndicatorView *transferringIndicator;
@end

@implementation SwingViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register ourselves as a transfer delegate of the Satellite Manager so we
    // receive notifications when transfers are complete...
    [[PPSatelliteManager sharedManager] setTransferDelegate:self];
}

#pragma mark - Satellite Manager Transfer Delegate
- (void)satelliteManagerSwingTransferringWillBeginWithCount:(NSUInteger)count
{
    // Update the status label
    self.statusLabel.text = @"Transferring...";
    [self.transferringIndicator startAnimating];
}

-(void)satelliteManagerSwingTransferringDidCompleteWithSwings:(NSArray *)swings
{
    // Return early if all the swings in the transfer failed
    if (swings.count == 0)
        return;
    
    // Stop transfer indicator and increment our internal swing count (used for display purposes)
    [self.transferringIndicator stopAnimating];
    self.swingCount++;
    
    // Update the swing label text
    Swing *swing = [swings lastObject];
    if (swing.handle) { // Check that the swing is valid...
        // Update the outlets
        self.statusLabel.text = [NSString stringWithFormat:@"Swing %lu", (unsigned long)self.swingCount];
    } else {
        // Swing is invalid.  Update the outlets accordingly.
        self.statusLabel.text = @"Invalid Swing";
    }
    
    // Set this last swing as our primary swing. This will cause the superclass to
    // render this swing in 3D if it is valid.
    self.primarySwing = swing;
}




#pragma mark -  Swing Serialization
/** Only look at these methods if you're interested in serializing / deserializing a swing */
- (IBAction)moreButtonPressed:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"Save Swing?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Swing", @"Restore Saved Swing", nil] showFromTabBar:self.tabBarController.tabBar];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // File Location
    NSURL *docs = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
    NSString *filepath = [[docs URLByAppendingPathComponent:@"savedSwing"] path];
    
    if (buttonIndex == 0) {
        // Save Swing Pressed
        if (self.primarySwing){
            // Cast primarySwing (self.primarySwing is a property of our superclass with type id <SP3DSwingProtocol>)
            Swing *primarySwing = (Swing *)self.primarySwing;
            
            // Create a PPSerializedSwing object using the rawSwingData and club data in primary swing.  This object implements NSCoding
            PPSerializedSwing *swingForSerialization = [[PPSerializedSwing alloc] initWithRawSwingData:primarySwing.rawSwingData satellite:primarySwing.satellite club:primarySwing.club];
            
            // Use NSKeyedArchiver to serialize this swing.
            [NSKeyedArchiver archiveRootObject:swingForSerialization toFile:filepath];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Couldn't Save" message:@"No swing to save" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    } else if (buttonIndex == 1){
        // Restore saved swing selected
        NSData *swingData = [NSData dataWithContentsOfFile:filepath];
        if (swingData){
            // Use NSKeyedUnarchiver to deserialize this swing
            PPSerializedSwing *serializedSwing = [NSKeyedUnarchiver unarchiveObjectWithData:swingData];
            
            // Create a new Swing object and copy data into it
            Swing *swing = [[Swing alloc] init];
            swing.rawSwingData = serializedSwing.rawSwingData;
            
            swing.club = [[Club alloc] init];
            [serializedSwing copyToClub:swing.club];
            
            swing.satellite = [[Satellite alloc] init];
            [serializedSwing copyToSatellite:swing.satellite];
            
            // Calculate the swing
            [swing processSwingData];
            
            // Re-purpose our satelliteManagerSwingTransferringDidCompleteWithSwings method above.
            // Reusing this delegate method, intead of abstracting out its functionality is a hack - but I wanted to keep the non-serialization part of the class as simple as possible.
            [self satelliteManagerSwingTransferringDidCompleteWithSwings:@[swing]];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Couldn't Restore" message:@"No previously saved swing" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

        }
        
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Unknown button index"];
    }
}

@end
