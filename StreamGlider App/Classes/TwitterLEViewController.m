//
//  TwitterLEViewController.m
//  StreamGlider
//
//  Created by Dmitry Shingarev on 11/11/2011.
//  Copyright (c) 2011 StreamGlider, Inc. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "TwitterLEViewController.h"
#import "TwitterFrame.h"
#import "CacheController.h"
#import "MagModeViewController.h"

@interface TwitterLEViewController ()

@property (retain, nonatomic) IBOutlet UIImageView *userImage;

@end

@implementation TwitterLEViewController

@synthesize userImage;
@synthesize userNameLabel;
@synthesize statusLabel;
@synthesize dateLabel;
@synthesize magModeVC;

#pragma mark Touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [magModeVC displayPreviewForFrame:frame];
}

- (void)displayFrameData {
    TwitterFrame *tf = (TwitterFrame*)frame;
    statusLabel.text = tf.text;
    
    userNameLabel.text = tf.userName;
    dateLabel.text = [Frame formatDate:tf.createdAt];
    
    // display profile image
    userImage.image = [[CacheController sharedInstance] getImage:tf.imageURL];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setUserImage:nil];
    [self setUserNameLabel:nil];
    [self setStatusLabel:nil];
    [self setDateLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc {
    [userImage release];
    [userNameLabel release];
    [statusLabel release];
    [dateLabel release];
    [super dealloc];
}
@end
