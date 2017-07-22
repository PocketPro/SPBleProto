//
//  ControlsViewController.m
//  SPBLEPROTO
//
//  Created by Gord Parke on 7/22/17.
//  Copyright © 2017 Gord Parke. All rights reserved.
//

#import "ControlsViewController.h"
#import "SPPeripheralManager.h"

@interface ControlsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *advertiseSwitch;

@end

@implementation ControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SPPeripheralManager *manager = [SPPeripheralManager sharedManager];
    if (self.advertiseSwitch.on){
        [manager startAdvertising];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:PPSatelliteManagerTransferDidCompleteWithSwings
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      NSArray *transferredSwings = note.object;
                                                      manager.swing = transferredSwings.lastObject;
                                                  }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAdvertiseSwitchToggle:(id)sender {
    if (self.advertiseSwitch.on) {
        [[SPPeripheralManager sharedManager] startAdvertising];
    } else {
        [[SPPeripheralManager sharedManager] stopAdvertising];
    }
}

@end
