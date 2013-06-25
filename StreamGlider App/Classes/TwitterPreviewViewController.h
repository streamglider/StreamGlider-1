//
//  TwitterPreviewViewController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 26/10/2010.
//  Copyright 2010 SemantiStar, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewViewController.h"

@class LocalLinksWebView;

@interface TwitterPreviewViewController : PreviewViewController {
	LocalLinksWebView *webView;
	UIImageView *userImage;
	UILabel *userNameLabel;
	UILabel *createdAtLabel;
	UITextView *textView;	
}

@property (nonatomic, retain) IBOutlet LocalLinksWebView *webView;
@property (nonatomic, retain) IBOutlet UIImageView *userImage;
@property (nonatomic, retain) IBOutlet UILabel *userNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *createdAtLabel;
@property (nonatomic, retain) IBOutlet UITextView *textView;

@end
