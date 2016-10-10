//
//  DirectionCell.h
//  GM01_AddingMarkersToMap
//
//  Created by Aleksandr Pronin on 10/10/16.
//  Copyright © 2016 Aleksandr Pronin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
