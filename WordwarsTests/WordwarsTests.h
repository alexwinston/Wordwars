//
//  WordwarsTests.h
//  WordwarsTests
//
//  Created by Alex Winston on 11/26/12.
//  Copyright (c) 2012 Alex Winston. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "WWGame.h"

@interface WordwarsTests : SenTestCase <WWGameDelegate>
{
    BOOL _gameFinished;
}
@end
