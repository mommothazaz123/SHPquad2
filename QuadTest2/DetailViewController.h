//
//  DetailViewController.h
//  QuadTest2
//
//  Created by A on 6/30/15.
//  Copyright (c) 2015 SHPQuad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItem.h"
#import "WebItem.h"
#import "ImageDownloader.h"

@interface DetailViewController : UIViewController <UIScrollViewDelegate, ImageDownloaderProtocol>

//@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) id webItem;

@property (weak, nonatomic) IBOutlet UINavigationItem *detailTitle;
@property (weak, nonatomic) IBOutlet UIView *detailView; // DO NOT DELETE!!!
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIProgressView *imageProgress;

@end

