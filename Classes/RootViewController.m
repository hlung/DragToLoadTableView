/*
 * This file is part of the DragToLoadTableView package.
 * (c) Thongchai Kolyutsakul <thongchaikol@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Created on 26/1/2011.
 */

#import "RootViewController.h"

@implementation RootViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	tableView.dragDelegate = self;
	tableView.tableDelegate = self;
	dataArray = [[NSMutableArray alloc] init];
	[dataArray addObjectsFromArray:[NSArray arrayWithObjects:@"start",nil]];
	[tableView enableLoadBottom];
}

#pragma mark -
#pragma mark DragToLoadTableViewDelegate

// *** Do load top / load bottom
-(void)startLoadTop {
	[self performSelector:@selector(finishedLoadingTop) withObject:nil afterDelay:1];
}

-(void)startLoadBottom {
	[self performSelector:@selector(finishedLoadingBottom) withObject:nil afterDelay:1];
}

#pragma mark etc
-(void)finishedLoadingTop {
    /*
    // Insert top
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"top",nil];
	[a addObjectsFromArray:dataArray];
	dataArray = [a mutableCopy];*/
    
    // Clear all
    [dataArray removeAllObjects];
    [dataArray addObjectsFromArray:[NSArray arrayWithObjects:@"start",nil]];
    
	[tableView reloadData];
	[tableView stopAllLoadingAnimation];
}
-(void)finishedLoadingBottom {
	[dataArray addObjectsFromArray:[NSArray arrayWithObjects:@"new",nil]];
	[tableView reloadData];
	[tableView stopAllLoadingAnimation];
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[dataArray release];
    [super dealloc];
}

#pragma mark -
#pragma mark DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)itableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *reuseIden = @"cell"; // don't use @"cellMore" because it is used by loadTop and bottom cells
	UITableViewCell *cell = [itableView dequeueReusableCellWithIdentifier:reuseIden];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIden] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = [dataArray objectAtIndex:indexPath.row];
	return cell;
}


@end
