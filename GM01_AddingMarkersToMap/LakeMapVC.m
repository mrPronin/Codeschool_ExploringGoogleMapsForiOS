//
//  LakeMapVC.m
//  AddingMarkersToMap
//
//  Created by Aleksandr Pronin on 10/3/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import "LakeMapVC.h"
#import <GoogleMaps/GoogleMaps.h>

@interface LakeMapVC () <GMSMapViewDelegate>

@property(strong, nonatomic) GMSMapView *mapView;
@property(strong, nonatomic) NSSet *markers;

@end

@implementation LakeMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.5382
                                                            longitude:-81.3687
                                                                 zoom:15
                                                              bearing:0
                                                         viewingAngle:0];
    
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMinZoom:15 maxZoom:15];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    [self setupMarkerData];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMarkerData {
    GMSMarker *marker1 = [[GMSMarker alloc] init];
    marker1.position = CLLocationCoordinate2DMake(28.5441, -81.37301);
    marker1.title = @"Lake Eola";
    marker1.snippet = @"Come see the swans";
    marker1.appearAnimation = kGMSMarkerAnimationPop;
    marker1.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    marker1.map = nil;
    
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = CLLocationCoordinate2DMake(28.53137, -81.36675);
    marker2.map = nil;
    
    self.markers = [NSSet setWithObjects:marker1, marker2, nil];
    
    [self drawMarkers];
}

- (void)drawMarkers {
    for (GMSMarker *marker in self.markers) {
        if (marker.map == nil) {
            marker.map = self.mapView;
        }
    }
}

#pragma mark - GMSMapViewDelegate

- (UIView *GMS_NULLABLE_PTR)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    UIView *infoWindow = [[UIView alloc] init];
    infoWindow.frame = CGRectMake(0, 0, 200, 70);
    infoWindow.backgroundColor = [UIColor grayColor];
    
    // info window setup
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(14, 11, 175, 16);
    [infoWindow addSubview:titleLabel];
    titleLabel.text = marker.title;
    
    UILabel *snippetLabel = [[UILabel alloc] init];
    snippetLabel.frame = CGRectMake(14, 42, 175, 16);
    [infoWindow addSubview:snippetLabel];
    snippetLabel.text = marker.snippet;
    
    return infoWindow;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    NSString *message = [NSString stringWithFormat:@"You tapped the info window for the %@ marker", marker.title];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
