//
//  CFileDragDestinationView.h
//  SimpleServer
//
//  Created by Jonathan Wight on 12/31/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CFileDragDestinationView : NSView

@property (readwrite, nonatomic, copy) void (^dragHandler)(NSURL *URL);

@end
