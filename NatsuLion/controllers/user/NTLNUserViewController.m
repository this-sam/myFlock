#import "NTLNUserViewController.h"
#import "NTLNLinkTweetCell.h"
#import "NTLNRoundedIconView.h"
#import "NTLNColors.h"
#import "NTLNConfiguration.h"
#import "NTLNIconTextCell.h"
#import "NTLNUserTimelineViewController.h"
#import "NTLNFavoriteViewController.h"
#import "NTLNUserListViewController.h"
#import "NTLNHttpClientPool.h"

//#import "ViewFriendOnMapControllerView.h"

@interface NTLNUserViewController(Private)
- (void)getUserInfo;

@end


@implementation NTLNUserViewController

@synthesize message;

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)setupTableView {
	UITableView *tv = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
													style:UITableViewStylePlain] autorelease];	
	tv.delegate = self;
	tv.dataSource = self;
	tv.autoresizesSubviews = YES;
	tv.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.view = tv;
}

- (void)viewDidLoad {
	[self setupTableView];
	((UITableView*)self.view).autoresizesSubviews = YES;
	[self.navigationItem setTitle:@"User"];
}

- (void)viewWillAppear:(BOOL)animated {
	[self getUserInfo];
	
	NSIndexPath *tableSelection = [(UITableView*)self.view indexPathForSelectedRow];
	[(UITableView*)self.view deselectRowAtIndexPath:tableSelection animated:NO];
	
//	[(UITableView*)self.view reloadData];
	
	((UITableView*)self.view).backgroundColor = [[NTLNColors instance] scrollViewBackground];
	if ([[NTLNConfiguration instance] darkColorTheme]) {
		((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleWhite;
	} else {
		((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleBlack;
	}
}


- (void)dealloc {
	[userInfo release];
    [super dealloc];
}

- (UITableViewCell *)nameCell {	
	NTLNLinkNameCell *cell = [[[NTLNLinkNameCell alloc] initWithFrame:CGRectZero] autorelease];
	[cell createCellWithName:message.name screenName:message.screenName];
	
	NTLNRoundedIconView *iconview = [[[NTLNRoundedIconView alloc] 
									  initWithFrame:CGRectMake(6.5, 6.5, 56.0, 56.0) 
									  image:message.iconContainer.iconImage 
									  round:8.0] autorelease];
	iconview.backgroundColor = [[NTLNColors instance] oddBackground];
	[iconview addTarget:self action:@selector(replyButtonAction:)
	   forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:iconview];	
	
	/*
	int y = 70 ;
	int x = 90;
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(x, y, 148, 36)];
		[b setBackgroundImage:[UIImage imageNamed:@"normal_06.png"] forState:UIControlStateNormal];
		[b setBackgroundImage:[UIImage imageNamed:@"pushed_06.png"] forState:UIControlStateHighlighted];
		[b addTarget:self action:@selector(locationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(x+13, y, 90, 22)];
		[b setBackgroundImage:[UIImage imageNamed:@"normal_01.png"] forState:UIControlStateNormal];
		[b setBackgroundImage:[UIImage imageNamed:@"pushed_01.png"] forState:UIControlStateHighlighted];
//		[b addTarget:self action:@selector(replyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(x+13+90, y, 91, 22)];
		[b setBackgroundImage:[UIImage imageNamed:@"normal_02.png"] forState:UIControlStateNormal];
		[b setBackgroundImage:[UIImage imageNamed:@"pushed_02.png"] forState:UIControlStateHighlighted];
//		[b addTarget:self action:@selector(retweetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(x+13+90+90, y, 91, 22)];
		[b setBackgroundImage:[UIImage imageNamed:@"normal_02.png"] forState:UIControlStateNormal];
		[b setBackgroundImage:[UIImage imageNamed:@"pushed_02.png"] forState:UIControlStateHighlighted];
		[b addTarget:self action:@selector(locationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	*/
	
	cell.accessoryType = UITableViewCellAccessoryNone;

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (userInfo) {
		switch ([indexPath row]) {
			case 0:
				//return 120;
				return 70;
		}
	} else {
		if ([indexPath row] == 0) return 100;
	}
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (userInfo) {
		return 7;
	} else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	NTLNCell *cell = nil;
	if (userInfo) {
		switch(row)
		{
			case 0:
				cell = (NTLNCell*)[self nameCell];
				break;
			default:
				{
					cell = [[[NTLNIconTextCell alloc] initWithFrame:CGRectZero] autorelease];
					switch (row) {
						case 1:
							if (![userInfo.url isEqualToString:@""]) {
								
							
								[(NTLNIconTextCell*)cell createCellWithText:userInfo.url 
																	   icon:[UIImage imageNamed:@"icons_02.png"]
																	 isEven:NO];
								
							}
							cell.accessoryType = UITableViewCellAccessoryNone;
							cell.selectionStyle = UITableViewCellSelectionStyleNone;
							break;
						case 2:
							[(NTLNIconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d updates",userInfo.statuses_count] 
												icon:[UIImage imageNamed:@"icons_03.png"]
																 isEven:YES];
							break;
						case 3:
							[(NTLNIconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d favs",userInfo.favourites_count] 
												icon:[UIImage imageNamed:@"icons_05.png"]
																 isEven:NO];
							break;
						case 4:
							[(NTLNIconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d following",userInfo.friends_count]
												icon:[UIImage imageNamed:@"icons_01.png"]
																 isEven:YES];
							break;
						case 5:
							[(NTLNIconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"%d followers",userInfo.followers_count] 
												icon:[UIImage imageNamed:@"icons_01.png"]
																 isEven:NO];
							cell.accessoryType = UITableViewCellAccessoryNone;
							cell.selectionStyle = UITableViewCellSelectionStyleNone;
							break;
						case 6:
							[(NTLNIconTextCell*)cell createCellWithText:[NSString stringWithFormat:@"Location %@",userInfo.location] 
																   icon:[UIImage imageNamed:@"icons_02.png"]
																 isEven:YES];
							cell.accessoryType = UITableViewCellAccessoryNone;
							cell.selectionStyle = UITableViewCellSelectionStyleNone;
							break;
					}
				}
				break;
				
		}
	} else {
		cell = (NTLNCell*)[self nameCell];
	}
	return cell;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (userInfo) {
		switch (row){
			case 2:
			{
				NTLNUserTimelineViewController *vc = [[[NTLNUserTimelineViewController alloc] init] autorelease];
				vc.screenName = userInfo.screen_name;
				[[self navigationController] pushViewController:vc animated:YES];
			}
				break;
			case 3:
			{
				NTLNFavoriteViewController *vc = [[[NTLNFavoriteViewController alloc] initWithScreenName:userInfo.screen_name] autorelease];
				[[self navigationController] pushViewController:vc animated:YES];
			}
				break;
			case 4:
			{
				NTLNUserListViewController *vc = [[[NTLNUserListViewController alloc] init] autorelease];
				vc.screenName = userInfo.screen_name;
				[[self navigationController] pushViewController:vc animated:YES];
			}
				break;
			
			case 6:
			{	/*
				[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
				ViewFriendOnMapControllerView *vc = [[ViewFriendOnMapControllerView alloc] autorelease];
				vc.userInfo = userInfo;
				[[self navigationController] pushViewController:vc animated:YES];
				 */
			}
				break;
		}
	}
}

- (void)getUserInfo {
	NTLNTwitterUserClient *c = [[NTLNHttpClientPool sharedInstance] 
								idleClientWithType:NTLNHttpClientPoolClientType_TwitterUserClient];
	c.delegate = self;
	[c getUserInfoForScreenName:message.screenName];
}

- (void)twitterUserClientSucceeded:(NTLNTwitterUserClient*)sender {
	[userInfo release];
	userInfo = nil;
	
	if ([sender.users count] > 0) {
		userInfo = [[sender.users objectAtIndex:0] retain];
	}
	[self.tableView reloadData];
	
//	LOG(@"twitterUserClientSucceeded: %d", userInfo.statuses_count);
}

- (void)twitterUserClientFailed:(NTLNTwitterUserClient*)sender {
}

@end

