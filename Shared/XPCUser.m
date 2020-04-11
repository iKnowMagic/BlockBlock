//
//  file: XPCUser.m
//  project: BlockBlock (login item)
//  description: user XPC methods
//
//  created by Patrick Wardle
//  copyright (c) 2018 Objective-See. All rights reserved.
//

#import "consts.h"
#import "logging.h"
#import "XPCUser.h"
#import "utilities.h"
#import "AppDelegate.h"
#import "AlertWindowController.h"

/* GLOBALS */

//alert (windows)
extern NSMutableDictionary* alerts;

@implementation XPCUser

//show an alert window
-(void)alertShow:(NSDictionary*)alert
{
    //dbg msg
    logMsg(LOG_DEBUG, [NSString stringWithFormat:@"daemon invoked user XPC method, '%s'", __PRETTY_FUNCTION__]);
    
    //on main (ui) thread
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        //alert window
        AlertWindowController* alertWindow = nil;
        
        //alloc/init alert window
        alertWindow = [[AlertWindowController alloc] initWithWindowNibName:@"AlertWindow"];
        
        //sync to save alert
        // ensures there is a (memory) reference to the window
        @synchronized(alerts)
        {
            //save
            alerts[alert[ALERT_UUID]] = alertWindow;
        }
        
        //set alert
        alertWindow.alert = alert;
        
        //show in all spaces
        alertWindow.window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces;
        
        //show alert window
        [alertWindow showWindow:self];
            
        //'request' user attenion
        // bounces icon on the dock
        [NSApp requestUserAttention:NSInformationalRequest];
        
        //make alert window key
        [alertWindow.window makeKeyAndOrderFront:self];
        
        //set app's background/foreground state
        [((AppDelegate*)[[NSApplication sharedApplication] delegate]) setActivationPolicy];
        
    });
    
    return;
}


//TODO: add if we want to get fancy

/*

//main app's xpc methods
#ifndef LOGIN_ITEM

//rule changed
// broadcast new rules, so any (relevant) windows can be updated
-(void)rulesChanged:(NSDictionary*)rules
{
    //dbg msg
    logMsg(LOG_DEBUG, [NSString stringWithFormat:@"daemon invoked user XPC method, '%s'", __PRETTY_FUNCTION__]);
    
    //broadcast
    [[NSNotificationCenter defaultCenter] postNotificationName:RULES_CHANGED object:nil userInfo:@{RULES_CHANGED:rules}];
    
    return;
}

#endif
*/

@end
