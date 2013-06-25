//
//  YTPreviewViewController.h
//  StreamCast
//
//  Created by Dmitry Shingarev on 27/10/2010.
//  Copyright 2010 SemantiStar, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewViewController.h"

@class LocalLinksWebView;

@interface YTPreviewViewController : PreviewViewController <UIWebViewDelegate> {
	LocalLinksWebView *webView;
	UILabel *titleLabel;
	UILabel *publishedLabel;
}

@property (nonatomic, retain) IBOutlet LocalLinksWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *publishedLabel;

@end
