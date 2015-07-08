//
//  MasterViewController.m
//  QuadTest2
//
//  Created by A on 6/30/15.
//  Copyright (c) 2015 SHPQuad. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SimpleTableCell.h"

@interface MasterViewController (){
    HomeModel *_homeModel;
    NSArray *_feedItems;
    FeedItem *_selectedFeedItem;
}

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;*/
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _feedItems = [[NSArray alloc] init];
    _homeModel = [[HomeModel alloc] init];
    
    _homeModel.delegate = self;
    
    [_homeModel downloadItems];
    
    self.navigationController.navigationBar.translucent= NO;
    
    UIImage *image = [UIImage imageNamed:@"QuadLogoSlogan1_appv.png"];
    UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
    
    UIBarButtonItem *tabButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"QuadTabButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showTabView)];
    
    myImageView.contentMode = UIViewContentModeTop;
    
    self.navigationController.navigationItem.title = nil;
    self.navigationItem.titleView = myImageView;
    self.navigationItem.leftBarButtonItem = tabButton;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:0.3765 green:0 blue:0 alpha:1]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.6784 green:0.0588 blue:0.1137 alpha:1]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)itemsDownloaded:(NSArray *)items
{
    // This delegate method will get called when the items are finished downloading
    
    // Set the downloaded items to the array
    _feedItems = items;
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set selected feeditem to var
    _selectedFeedItem = _feedItems[indexPath.row];
    
    // Manually call segue to detail view controller
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

/*
- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}*/

#pragma mark - Tab View

- (void)showTabView
{
    [self performSegueWithIdentifier:@"showTabView" sender:self];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:_selectedFeedItem];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    
    if ([[segue identifier] isEqualToString:@"showTabView"]) {
        //do stuff
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of feed items (initially 0)
    return _feedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve cell
    NSString *cellIdentifier = @"SimpleTableCell";
    SimpleTableCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (myCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        myCell = [nib objectAtIndex:0];
    }
    
    // Get the listing to be shown
    FeedItem *item = _feedItems[indexPath.row];
    
    // Get references to labels of cell
    myCell.titleLabel.text = item.title;
    myCell.authorLabel.text = item.author;
    myCell.dateLabel.text = [item.date descriptionWithLocale:[NSLocale currentLocale]];
    // TODO: myCell.thumbnailImageView.image = item.
    
    return myCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}*/

@end
