//
//  CAppDelegate.m
//  SimpleServer
//
//  Created by Jonathan Wight on 12/17/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CAppDelegate.h"

#import "CFileDragDestinationView.h"

@interface CAppDelegate ()
@property (readwrite, nonatomic, assign) IBOutlet CFileDragDestinationView *fileDragDestinationView;
@property (readwrite, nonatomic, copy) NSString *bonjourName;
@property (readwrite, nonatomic, strong) NSURL *directoryURL;
@property (readwrite, nonatomic, copy) NSString *indexName;
@property (readwrite, nonatomic, assign) BOOL serving;
@property (readwrite, nonatomic, strong) NSTask *task;
@end

#pragma mark -

@implementation CAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
	{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"directoryURL"])
		{
		self.directoryURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"directoryURL"]];
		}

	self.bonjourName = [[NSUserDefaults standardUserDefaults] objectForKey:@"bonjourName"];
	self.indexName = [[NSUserDefaults standardUserDefaults] objectForKey:@"indexName"];
	}

- (void)applicationWillTerminate:(NSNotification *)notification;
	{
	NSLog(@"WILL TERMINATE");

	if (self.task)
		{
		[self.task terminate];
		self.task = NULL;
		}

	[[NSUserDefaults standardUserDefaults] setObject:[self.directoryURL absoluteString] forKey:@"directoryURL"];
	[[NSUserDefaults standardUserDefaults] setObject:self.bonjourName forKey:@"bonjourName"];
	[[NSUserDefaults standardUserDefaults] setObject:self.indexName forKey:@"indexName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	}

- (void)awakeFromNib
	{
	self.fileDragDestinationView.dragHandler = ^(NSURL *inURL) {

		id theValue = NULL;
		[inURL getResourceValue:&theValue forKey:NSURLIsDirectoryKey error:NULL];
		if ([theValue boolValue] == YES)
			{
			self.directoryURL = inURL;
			self.bonjourName = [[[NSFileManager defaultManager] displayNameAtPath:inURL.path] stringByDeletingPathExtension];
			self.indexName = NULL;
			}
		else
			{
			self.directoryURL = [inURL URLByDeletingLastPathComponent];
			self.bonjourName = [[[NSFileManager defaultManager] displayNameAtPath:inURL.path] stringByDeletingPathExtension];
			self.indexName = [inURL lastPathComponent];
			}

		};
	}

- (IBAction)choose:(id)inSender
	{
	NSOpenPanel *thePanel = [[NSOpenPanel alloc] init];
	thePanel.canChooseDirectories = YES;
	thePanel.canChooseFiles = NO;
	[thePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result == NSOKButton)
			{
			self.directoryURL = thePanel.URL;
			}
		}];
	}

- (IBAction)toggleServing:(id)inSender
	{
	if (self.serving == NO)
		{
		NSString *thePath = [[[[NSBundle mainBundle] sharedSupportURL] URLByAppendingPathComponent:@"quick_serve.py"] path];

		NSTask *theTask = [[NSTask alloc] init];
		theTask.launchPath = @"/usr/bin/python";
		theTask.arguments = @[
			thePath,
			[self.directoryURL path],
			self.bonjourName,
			@"path",
			self.indexName,
			];
		[theTask launch];

		self.task = theTask;
		//
		self.serving = YES;
		}
	else
		{
		if (self.task)
			{
			[self.task terminate];
			self.task = NULL;
			}

		self.serving = NO;
		}
	}


@end
