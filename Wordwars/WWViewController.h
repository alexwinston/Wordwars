//
//  WWViewController.h
//  Wordwars
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GCTurnBasedMatchHelper.h"

#import "WWGame.h"
#import "WWGameViewConstraints.h"
#import "WWTileView.h"

@interface WWViewController : UIViewController <GCTurnBasedMatchHelperDelegate, UITableViewDataSource, UITableViewDelegate>
{
    @private
    NSArray *_dictionary;
    NSMutableArray *_matches;
    NSMutableDictionary *_matchGames;
    IBOutlet UITableView *_matchesTableView;
}
- (IBAction)newGameButtonTouched:(id)sender;
@end
