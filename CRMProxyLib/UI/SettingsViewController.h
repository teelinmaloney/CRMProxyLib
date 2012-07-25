//
//  SettingsViewController.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
{
    IBOutlet UITextField *domain;
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UILabel *error;
}

- (IBAction)test:(id)sender;

@end
