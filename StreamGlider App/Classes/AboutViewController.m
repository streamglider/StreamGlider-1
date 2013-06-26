//
//  AboutViewController.m
//  StreamCast
//
//  Created by Dmitry Shingarev on 18/03/2011.
//  Copyright 2011 StreamGlider, Inc. All rights reserved.
//
//  This program is free software if used non-commercially: you can redistribute it and/or modify
//  it under the terms of the BSD 4 Clause License as published by
//  the Free Software Foundation.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  BSD 4 Clause License for more details.
//
//  You should have received a copy of the BSD 4 Clause License
//  along with this program.  If not, see the README.md file with this program.

#import "AboutViewController.h"
#import "TutorialViewController.h"
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "Core.h"

@interface AboutViewController ()

@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UILabel *releasedLabel;
@property (nonatomic, retain) IBOutlet UILabel *installedLabel;

- (IBAction)handleCloseTapped;
- (IBAction)handleSiteTapped;
- (IBAction)handleTutorialTapped;
- (IBAction)handleSettingsTapped;
- (IBAction)handleUserInfoTapped:(id)sender;

@end

@implementation AboutViewController

@synthesize releasedLabel, versionLabel, installedLabel, navController, shouldKillTimers;

#pragma mark Handlers

- (IBAction)handleCloseTapped {
    if (shouldKillTimers)
        [[Core sharedInstance] installTimers];
    
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)handleSiteTapped {	
    if (shouldKillTimers)
        [[Core sharedInstance] installTimers];
    
	[self dismissModalViewControllerAnimated:YES];	
        
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:SITE_URL]];
}

- (IBAction)handleTutorialTapped {
	TutorialViewController *tvc = [[TutorialViewController alloc] 
								   initWithNibName:@"TutorialViewController" 
								   bundle:nil];
	
	[navController pushViewController:tvc animated:YES];
	[tvc release];

	[self dismissModalViewControllerAnimated:NO];	
}

- (IBAction)handleSettingsTapped {
	SettingsViewController *svc = [[SettingsViewController alloc] 
								   initWithNibName:@"SettingsViewController" 
								   bundle:nil];
	svc.modalPresentationStyle = UIModalPresentationFormSheet;
	
	[self presentModalViewController:svc animated:YES];
	[svc release];
}

- (IBAction)handleUserInfoTapped:(id)sender {
    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" 
                                                                    bundle:nil];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.panelType = LoginPanelTypeSwitchIdentity;
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

#pragma mark UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (shouldKillTimers)
        [[Core sharedInstance] killTimers];
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	versionLabel.text = [defaults objectForKey:@"version_pref"];	
	
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:RELEASE_DATE];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	
	releasedLabel.text = [formatter stringFromDate:date];
	
	int installedSeconds = [[defaults objectForKey:@"installed_date"] intValue];							
	installedLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:installedSeconds]];
    
	[formatter release];	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Overriden to allow any orientation.
//    return YES;
//}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {    
    [self setVersionLabel:nil];
    [self setReleasedLabel:nil];
    [self setInstalledLabel:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Lifecycle

- (void)dealloc {
	self.releasedLabel = nil;
	self.installedLabel = nil;
	self.versionLabel = nil;
		
    [super dealloc];
}


@end
