//
//  StreetViewVC.m
//  GM01_AddingMarkersToMap
//
//  Created by Aleksandr Pronin on 10/10/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import "StreetViewVC.h"

@interface StreetViewVC ()

@end

@implementation StreetViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    GMSPanoramaService *service = [[GMSPanoramaService alloc] init];
    [service requestPanoramaNearCoordinate:self.coordinate callback:^(GMSPanorama * _Nullable panorama, NSError * _Nullable error) {
        if (panorama) {
            GMSPanoramaCamera *camera = [GMSPanoramaCamera cameraWithHeading:180
                                                                       pitch:0
                                                                        zoom:1
                                                                         FOV:90];
            GMSPanoramaView *panView = [[GMSPanoramaView alloc] init];
            panView.camera = camera;
            panView.panorama = panorama;
            self.view = panView;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
