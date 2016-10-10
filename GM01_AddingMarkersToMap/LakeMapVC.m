//
//  LakeMapVC.m
//  AddingMarkersToMap
//
//  Created by Aleksandr Pronin on 10/3/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import "LakeMapVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "CSMarker.h"
#import "DirectionsListVC.h"
#import "StreetViewVC.h"

@interface LakeMapVC () <GMSMapViewDelegate>

@property(strong, nonatomic) NSSet *markers;
@property(strong, nonatomic) NSURLSession *markerSession;
@property(strong, nonatomic) CSMarker *userCreatedMarker;
@property(strong, nonatomic) NSArray *steps;
@property(strong, nonatomic) GMSPolyline *polyline;
@property(assign, nonatomic) CLLocationCoordinate2D activeMarkerCoordinate;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *directionsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *streetViewButton;


@end

@implementation LakeMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float minZoom = 13.9;
    float maxZoom = 16;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                    diskCapacity:10 * 1024 *1024
                                                        diskPath:@"MarkerData"];
    self.markerSession = [NSURLSession sessionWithConfiguration:config];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:48.6983
                                                            longitude:26.5757
                                                                 zoom:minZoom
                                                              bearing:0
                                                         viewingAngle:0];
    
    self.mapView.camera = camera;
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMinZoom:minZoom maxZoom:maxZoom];
    self.mapView.delegate = self;
    
    [self setupMarkerData];
    self.directionsButton.enabled = false;
    self.streetViewButton.enabled = false;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GMSMapViewDelegate

/*
// custom label example
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
*/


// finding directions example
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
//    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    self.activeMarkerCoordinate = marker.position;
    if (self.mapView.myLocation != nil) {
        self.polyline.map = nil;
        self.polyline = nil;
        NSString *urlString = [NSString stringWithFormat:
                               @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                               @"https://maps.googleapis.com/maps/api/directions/json",
                               mapView.myLocation.coordinate.latitude,
                               mapView.myLocation.coordinate.longitude,
                               marker.position.latitude,
                               marker.position.longitude,
                               @"AIzaSyBTBTHaSY0S0C3gRzcveCa-2SpVW10WfV0"];
        NSURL *directionsURL = [NSURL URLWithString:urlString];
        NSURLSessionDataTask *directionsTask = [self.markerSession dataTaskWithURL:directionsURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable err) {
            NSError *error = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (!error && json.count) {
                self.steps = json[@"routes"][0][@"legs"][0][@"steps"];
                
//                NSLog(@"steps: %@", self.steps);
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.directionsButton.enabled = true;
                    GMSPath *path = [GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
                    self.polyline = [GMSPolyline polylineWithPath:path];
                    self.polyline.strokeWidth = 7;
                    self.polyline.strokeColor = [UIColor greenColor];
                    self.polyline.map = self.mapView;
                }];
            }
        }];
        [directionsTask resume];
    }
    return YES;
}


- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self.directionsButton.enabled) {
        self.directionsButton.enabled = false;
    }
    if (self.streetViewButton.enabled) {
        self.streetViewButton.enabled = false;
    }
    if (self.polyline) {
        self.polyline.map = nil;
        self.polyline = nil;
    }
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    if (self.directionsButton.enabled) {
        self.directionsButton.enabled = false;
    }
    if (self.streetViewButton.enabled) {
        self.streetViewButton.enabled = false;
    }
    if (self.polyline) {
        self.polyline.map = nil;
        self.polyline = nil;
    }
    self.mapView.selectedMarker = nil;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    NSString *message = [NSString stringWithFormat:@"You tapped the info window for the %@ marker", marker.title];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self.streetViewButton.enabled) {
        self.streetViewButton.enabled = false;
    }
    if (self.userCreatedMarker != nil) {
        self.userCreatedMarker.map = nil;
        self.userCreatedMarker = nil;
    }
    if (self.polyline) {
        self.polyline.map = nil;
        self.polyline = nil;
    }
    
    GMSGeocoder *geocoder = [GMSGeocoder geocoder];
    
    [geocoder reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
        CSMarker *marker = [[CSMarker alloc] init];
        marker.position = coordinate;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = nil;
        marker.title = response.firstResult.thoroughfare;
        marker.snippet =  response.firstResult.locality;
        self.userCreatedMarker = marker;
        
//        NSLog(@"new marker: [latitude - %f] [longitude - %f] [title - %@] [snippet - %@]", coordinate.latitude, coordinate.longitude, marker.title, marker.snippet);
        
        [self drawMarkers];
    }];
}

#pragma mark - Actions

- (IBAction)downloadMarkerData:(id)sender {
    NSURL *lakesURL = [NSURL URLWithString:@"http://192.168.1.148:3000/markers"];
    NSURLSessionDataTask *task = [self.markerSession dataTaskWithURL:lakesURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                          error:nil];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self createMarkerObjectsWithJson:json];
        }];
    }];
    [task resume];
}

- (IBAction)directionsTapped:(id)sender {
    DirectionsListVC *directionsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectionsListVC"];
    directionsListVC.steps = self.steps;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:directionsListVC];
    [self presentViewController:nc animated:YES completion:^{
        self.steps = nil;
        self.mapView.selectedMarker = nil;
        self.directionsButton.enabled = false;
    }];
}

- (IBAction)streetViewTapped:(id)sender {
    StreetViewVC *streetViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StreetViewVC"];
    streetViewVC.coordinate = self.activeMarkerCoordinate;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:streetViewVC];
    [self presentViewController:nc animated:YES completion:^{
        self.mapView.selectedMarker = nil;
        self.streetViewButton.enabled = false;
    }];
}

#pragma mark - Private

- (void)drawMarkers {
    for (CSMarker *marker in self.markers) {
        if (marker.map == nil) {
            marker.map = self.mapView;
        }
    }
    if (self.userCreatedMarker != nil && self.userCreatedMarker.map == nil) {
        self.userCreatedMarker.map = self.mapView;
        self.mapView.selectedMarker = self.userCreatedMarker;
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate setTarget:self.userCreatedMarker.position];
        [self.mapView animateWithCameraUpdate:cameraUpdate];
    }
}

- (void)setupMarkerData {
    //    GMSMarker *marker1 = [[GMSMarker alloc] init];
    //    marker1.position = CLLocationCoordinate2DMake(28.5441, -81.37301);
    //    marker1.title = @"Lake Eola";
    //    marker1.snippet = @"Come see the swans";
    //    marker1.appearAnimation = kGMSMarkerAnimationPop;
    //    marker1.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    //    marker1.map = nil;
    //
    //    GMSMarker *marker2 = [[GMSMarker alloc] init];
    //    marker2.position = CLLocationCoordinate2DMake(28.53137, -81.36675);
    //    marker2.map = nil;
    //
    //    self.markers = [NSSet setWithObjects:marker1, marker2, nil];
    
    [self drawMarkers];
}

- (void)createMarkerObjectsWithJson:(NSArray *)json {
    self.streetViewButton.enabled = true;
    NSMutableSet *mutableSet = [[NSMutableSet alloc] initWithSet:self.markers];
    for (NSDictionary *markerData in json) {
        
        CSMarker *newMarker = [[CSMarker alloc] init];
        newMarker.objectID = [markerData[@"id"] stringValue];
        newMarker.appearAnimation = (GMSMarkerAnimation)[markerData[@"appearAnimation"] integerValue];
        newMarker.position = CLLocationCoordinate2DMake([markerData[@"lat"] doubleValue],
                                                        [markerData[@"lng"] doubleValue]);
        newMarker.title = markerData[@"title"];
        newMarker.snippet = markerData[@"snippet"];
        newMarker.map = nil;
        [mutableSet addObject:newMarker];
    }
    self.markers = [mutableSet copy];
    [self drawMarkers];
}

@end
