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
    NSMutableArray *_filteredItems;
    FeedItem *_selectedFeedItem;
    WebItem *_selectedWebItem;
    NSUserDefaults *_defaults;
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
    
    self.searchBar.delegate = self;
    
    _feedItems = [[NSArray alloc] init];
    _homeModel = [[HomeModel alloc] init];
    
    _homeModel.delegate = self;
    
    [_homeModel downloadItems];
    
    _defaults = [NSUserDefaults standardUserDefaults];
    if (![_defaults boolForKey:@"notFirstTime"]) {
        [_defaults setBool:YES forKey:@"notFirstTime"];
        [_defaults setBool:NO forKey:@"SpeedMode"];
        NSLog(@"Did first time setup");
    }
    
    
    self.navigationController.navigationBar.translucent= NO;
    
    UIImage *image = [UIImage imageNamed:@"QuadLogoSlogan1_appv.png"];
    UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
    
    image = [UIImage imageNamed:@"loading2.png"];
    UIImageView *tableBackgroundView = [[UIImageView alloc]initWithImage:image];
    tableBackgroundView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *tabButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"QuadTabButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showTabView)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settingsGear.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    
    myImageView.contentMode = UIViewContentModeTop;
    
    self.tableView.backgroundView = tableBackgroundView;
    
    self.navigationController.navigationItem.title = nil;
    self.navigationItem.titleView = myImageView;
    self.navigationItem.leftBarButtonItem = tabButton;
    self.navigationItem.rightBarButtonItem = settingsButton;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithRed:0.3765 green:0 blue:0 alpha:1]];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.6784 green:0.0588 blue:0.1137 alpha:1]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)itemsDownloaded:(NSArray *)items
{
    // This delegate method will get called when the items are finished downloading
    
    // Set the downloaded items to the array by resetting it and appending new data
    _feedItems = items;
    _filteredItems = [NSMutableArray arrayWithCapacity:[_feedItems count]];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
    });
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set selected feeditem to var
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        _selectedFeedItem = _filteredItems[indexPath.row];
    }
    else {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        _selectedFeedItem = _feedItems[indexPath.row];
    }
    
    // Set selected webitem to var
    _selectedWebItem = [WebItem webItemWithTitle:_selectedFeedItem.title andURL:[NSURL URLWithString:_selectedFeedItem.link]];
    
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


#pragma mark - Transitions

- (void)showTabView
{
    [self performSegueWithIdentifier:@"showTabView" sender:self];
}

- (void)showSettings
{
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        if ([_defaults boolForKey:@"SpeedMode"]) {
            [controller setDetailItem:_selectedFeedItem];
        } else {
            [controller setWebItem:_selectedWebItem];
        }
        
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
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return _filteredItems.count;
    } else {
        return _feedItems.count;
    }
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
    
    FeedItem *item;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = _filteredItems[indexPath.row];
    } else {
        item = _feedItems[indexPath.row];
    }
    
    
    // Get references to labels of cell
    myCell.titleLabel.text = item.title;
    myCell.authorLabel.text = item.author;
    myCell.dateLabel.text = item.date; //[item.date descriptionWithLocale:[NSLocale currentLocale]];
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

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [_filteredItems removeAllObjects];
    // Filter the array using NSPredicate
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    [tempArray removeAllObjects];
    // check if title contains search
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    _filteredItems = [NSMutableArray arrayWithArray:[_feedItems filteredArrayUsingPredicate:predicate]];
    // check for search in content
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF.content contains[c] %@",searchText];
    tempArray = [NSMutableArray arrayWithArray:[_feedItems filteredArrayUsingPredicate:predicate2]];
    [_filteredItems arrayByAddingObjectsFromArray:tempArray];
}

#pragma mark - UISearchDisplayController Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
