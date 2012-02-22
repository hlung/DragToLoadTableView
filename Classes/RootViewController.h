/*
 * This file is part of the DragToLoadTableView package.
 * (c) Thongchai Kolyutsakul <thongchaikol@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Created on 26/1/2011.
 */

#import <UIKit/UIKit.h>
#import "DragToLoadTableView.h"

@interface RootViewController : UIViewController <DragToLoadTableViewDelegate,DragTableDelegate> {
	IBOutlet DragToLoadTableView *tableView;
	NSMutableArray *dataArray;
	int page;
}
@end
