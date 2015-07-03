//
//  DetailViewController.m
//  QuadTest2
//
//  Created by A on 6/30/15.
//  Copyright (c) 2015 SHPQuad. All rights reserved.
//

#import "DetailViewController.h"
#import "NSString+HTML.h"

@interface DetailViewController (){
    ImageDownloader *_imageDownloader;
    NSArray *_images;
}

@end

@implementation DetailViewController
@synthesize containerView = _containerView;


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        _webItem = nil;
        
        // Update the view.
        [self configureView];
    }
}

- (void)setWebItem:(id)newWebItem {
    if (_webItem != newWebItem) {
        _webItem = newWebItem;
        _detailItem = nil;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.

    
    if (self.detailItem) {
        self.detailTitle.title = [self.detailItem title];
        NSString *content = [self flattenHTML:[self.detailItem content]];
        content = [content stringByDecodingHTMLEntities];
        
        
        if ([[self.detailItem images]count]) { // if there is an image, init with an imageview
            // Set up the container view to hold your custom view hierarchy
            CGSize containerSize = self.view.frame.size;
            self.containerView = [[UIView alloc] initWithFrame:(CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=containerSize}];
            [self.view addSubview:self.containerView];
            
            // Set up your custom view hierarchy
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading.png"]];
            imageView.frame = CGRectMake(75.0f, 0.0f, 600.0f, 400.0f);
            [self.containerView addSubview:imageView];
            
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, imageView.frame.size.height, 750, self.view.frame.size.height - imageView.frame.size.height - 64)];
            [self.containerView addSubview:textView];
            
            [textView setEditable:NO];
            [textView setFont:[UIFont systemFontOfSize:18]];
            
            textView.text = content;
            
            NSLog(@"Blah");
            
            [_imageDownloader performSelectorInBackground:@selector(downloadImagesinArray:) withObject:[self.detailItem images]];
            
            //[_imageDownloader downloadImagesinArray:[self.detailItem images]];
            
            NSLog(@"Blah2");
            
        } else { // otherwise remove the imageview and init
            // Set up the container view to hold your custom view hierarchy
            CGSize containerSize = self.view.frame.size;
            self.containerView = [[UIView alloc] initWithFrame:(CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=containerSize}];
            [self.view addSubview:self.containerView];
            
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 750, self.view.frame.size.height - 64)];
            [self.containerView addSubview:textView];
            
            [textView setEditable:NO];
            [textView setFont:[UIFont systemFontOfSize:18]];
            
            textView.text = content;
        }
        
    } else if (self.webItem) { // load webview for selected item
        
    }
}

- (void)imagesDownloaded:(NSArray *)images
{
    if ([images count]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading.png"]];
        imageView.frame = CGRectMake(75.0f, 0.0f, 600.0f, 400.0f);
        [self.containerView addSubview:imageView];
        imageView.image = [images firstObject];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];

    _imageDownloader = [[ImageDownloader alloc] init];
    
    _imageDownloader.delegate = self;
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.6784 green:0.0588 blue:0.1137 alpha:1]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Orientation Handlers



#pragma mark HTML Flattener

- (NSString *)flattenHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    
    html = [html stringByReplacingOccurrencesOfString:@"</br>" withString:@"\n"];
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    html = [html stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n\n"];
    
    while ([theScanner isAtEnd] == NO) {
        
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //

    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}


#pragma mark Image Handlin'

-(void)imageDownloadStart
{
    [self performSelectorInBackground:@selector(downloadImage) withObject:nil];
}

- (UIImage *)downloadImage
{
    NSArray *imageArray = [self.detailItem images];
    NSLog(@"Image Array: %@", imageArray);
    NSURL *imageURL = imageArray.firstObject;
    UIImage *image = [[UIImage alloc]initWithData:[[NSData alloc]initWithContentsOfURL:imageURL]];
    //image = [self resizeImage:image withSize:CGSizeMake(600.0f, 400.0f)];
    return image;
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)newSize
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = newSize.width/newSize.height;
    
    if(imgRatio!=maxRatio)
    {
        if(imgRatio < maxRatio){
            imgRatio = newSize.width / actualHeight;
            actualWidth = round(imgRatio * actualWidth);
            actualHeight = newSize.width;
        }
        else{
            imgRatio = newSize.height / actualWidth;
            actualHeight = round(imgRatio * actualHeight);
            actualWidth = newSize.height;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //[resizedImage release];
    return resizedImage;
}
@end
