//
//  NATViewController.m
//  iBeacon
//
//  Created by Hirohisa Kawasaki on 2014/03/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "NATViewController.h"

@import CoreLocation;
@import CoreBluetooth;

NSString *UUIDKey = @"9CB2AA11-09E2-47D2-AC78-147A35DE6D61";

@interface NATViewController () <CLLocationManagerDelegate, CBPeripheralManagerDelegate, CBCentralManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBCentralManager *centalManager;

@property (nonatomic, strong) NSUUID *proximityUUID;

@end

@implementation NATViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configure];
    [self renderButtons];
}

- (void)renderButtons
{
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setTitle:@"peripheral" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(peripheral) forControlEvents:UIControlEventTouchUpInside];
    [button1 sizeToFit];
    button1.center = (CGPoint) {
        .x = 240,
        .y = 80
    };
    [self.view addSubview:button1];

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 setTitle:@"central" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(central) forControlEvents:UIControlEventTouchUpInside];
    [button2 sizeToFit];
    button2.center = (CGPoint) {
        .x = 240,
        .y = 160
    };
    [self.view addSubview:button2];

    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button3 setTitle:@"location" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(location) forControlEvents:UIControlEventTouchUpInside];
    [button3 sizeToFit];
    button3.center = (CGPoint) {
        .x = 240,
        .y = 240
    };
    [self.view addSubview:button3];
}


- (void)configure
{

    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:UUIDKey];

    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"test"];
    self.region.notifyOnEntry = YES;
    self.region.notifyOnExit = YES;
    self.region.notifyEntryStateOnDisplay = YES;

}

- (void)central
{
    [self resetManagers];
    self.centalManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    [self.centalManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)peripheral
{
    [self resetManagers];
    self.peripheralManager = [[CBPeripheralManager alloc]
                              initWithDelegate:self
                              queue:nil options:nil];
}

- (void)location
{
    [self resetManagers];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringForRegion:self.region];
    [self.locationManager startRangingBeaconsInRegion:self.region];
}

- (void)resetManagers
{
    self.centalManager = nil;
    self.peripheralManager = nil;
    self.locationManager = nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [manager startMonitoringForRegion:region];
    [self showAlertView:[NSString stringWithFormat:@"%s", __func__]
                message:[region description]];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [beacons firstObject];
    [self showAlertView:[NSString stringWithFormat:@"%s", __func__]
                message:[beacon description]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self showAlertView:[NSString stringWithFormat:@"%s", __func__]
                message:[region description]];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self showAlertView:[NSString stringWithFormat:@"%s", __func__]
                    message:[NSString stringWithFormat:@"CBCentralManagerStatePoweredOn"]];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self showAlertView:[NSString stringWithFormat:@"%s", __func__]
                message:[NSString stringWithFormat:@"peripheral name is %@", peripheral.name]];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self showAlertView:[NSString stringWithFormat:@"%s", __func__]
                message:[NSString stringWithFormat:@"peripheral name is %@", peripheral.name]];
    [central connectPeripheral:peripheral options:nil];
}


#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self showAlertView:[NSString stringWithFormat:@"%s", __func__]
                    message:[NSString stringWithFormat:@"CBPeripheralManagerStatePoweredOn"]];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    switch (peripheralManager.state) {
        case CBPeripheralManagerStatePoweredOn: {
            NSDictionary *dictionary = [[self.region peripheralDataWithMeasuredPower:nil] copy];
            [self.peripheralManager startAdvertising:dictionary];
        }
            break;
        default:
            break;
    }
}

- (void)showAlertView:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end