//
//  CFileDragDestinationView.m
//  SimpleServer
//
//  Created by Jonathan Wight on 12/31/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CFileDragDestinationView.h"

#import <QuartzCore/QuartzCore.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation CFileDragDestinationView

- (void)awakeFromNib
	{
	[self registerForDraggedTypes:@[ (__bridge id)kUTTypeFileURL ]];
	}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
	{
    NSDragOperation theMask = [sender draggingSourceOperationMask];
    if ([sender.draggingPasteboard.types containsObject:(__bridge id)kUTTypeFileURL])
		{
		self.layer.borderColor = [NSColor keyboardFocusIndicatorColor].CGColor;
		self.layer.borderWidth = 5.0;

        if (theMask & NSDragOperationLink)
			{
            return(NSDragOperationLink);
			}
		else if (theMask & NSDragOperationCopy)
			{
            return(NSDragOperationCopy);
			}
		}
    return(NSDragOperationNone);
	}

- (void)draggingExited:(id <NSDraggingInfo>)sender
	{
	self.layer.borderColor = NULL;
	self.layer.borderWidth = 0.0;
	}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
	{
	self.layer.borderColor = NULL;
	self.layer.borderWidth = 0.0;
	if (self.dragHandler)
		{
		NSPasteboardItem *theItem = sender.draggingPasteboard.pasteboardItems[0];
		NSURL *theURL = [NSURL URLWithString:[theItem stringForType:(__bridge id)kUTTypeFileURL]];
		self.dragHandler(theURL);
		}
	return(YES);
	}

@end
