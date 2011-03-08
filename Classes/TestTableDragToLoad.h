//
//  TestTableDragRefresh.h
//  Memoli
//
//  Created by Hlung on 26/1/2554.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragToLoadTableViewCustom.h"

@interface TestTableDragToLoad : UIViewController <DragToLoadTableViewCustomListener,DragTableDelegate> {
	IBOutlet DragToLoadTableViewCustom *tableView;
	NSMutableArray *dataArray;
	int page;
}
@end
