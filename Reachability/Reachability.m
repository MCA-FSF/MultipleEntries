/*
 
 File: Reachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 
 Version: 2.0.4ddg
 */

/*
 Significant additions made by Andrew W. Donoho, August 11, 2009.
 This is a derived work of Apple's Reachability v2.0 class.
 
 The below license is the new BSD license with the OSI recommended personalizations.
 <http://www.opensource.org/licenses/bsd-license.php>

 Extensions Copyright (C) 2009 Donoho Design Group, LLC. All Rights Reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Andrew W. Donoho nor Donoho Design Group, L.L.C.
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY DONOHO DESIGN GROUP, L.L.C. "AS IS" AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */


/*
 
 Apple's Original License on Reachability v2.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.

 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
*/

/*
 Each reachability object now has a copy of the key used to store it in a dictionary.
 This allows each observer to quickly determine if the event is important to them.
*/

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>

#import "Reachability.h"

NSString *const kInternetConnection  = @"InternetConnection";
NSString *const kReachabilityChangedNotification = @"NetworkReachabilityChangedNotification";
NSString *const kkReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";

#define CLASS_DEBUG 1 // Turn on logReachabilityFlags. Must also have a project wide defined DEBUG.

#if (defined DEBUG && defined CLASS_DEBUG)
#define logReachabilityFlags(flags) (logReachabilityFlags_(__PRETTY_FUNCTION__, __LINE__, flags))


static NSString *reachabilityFlags_(SCNetworkReachabilityFlags flags) {
	
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 30000) // Apple advises you to use the magic number instead of a symbol.
    return [NSString stringWithFormat:@"Reachability Flags: %c%c %c%c%c%c%c%c%c",
			(flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
			(flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
			
			(flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
			(flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
			(flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
			(flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
			(flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
			(flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
#else
	// Compile out the v3.0 features for v2.2.1 deployment.
    return [NSString stringWithFormat:@"Reachability Flags: %c%c %c%c%c%c%c%c",
			(flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
			(flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
			
			(flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
			(flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
			(flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
			// v3 kSCNetworkReachabilityFlagsConnectionOnTraffic == v2 kSCNetworkReachabilityFlagsConnectionAutomatic
			(flags & kSCNetworkReachabilityFlagsConnectionAutomatic)  ? 'C' : '-',
			// (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-', // No v2 equivalent.
			(flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
			(flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
#endif
	
} // reachabilityFlags_()

static void logReachabilityFlags_(const char *name, int line, SCNetworkReachabilityFlags flags) {
#ifdef COMPONENT_REMOVE
    BDLoggerDebug(LOG_REACHABILITY_TAG, @"%s (%d) \n\t%@", name, line, reachabilityFlags_(flags));
#endif
} // logReachabilityFlags_()

#define logNetworkStatus(status) (logNetworkStatus_(__PRETTY_FUNCTION__, __LINE__, status))

#ifdef COMPONENT_REMOVE
static void logNetworkStatus_(const char *name, int line, NetworkStatus status) {

	NSString *statusString = nil;
	
	switch (status) {
		case kNotReachable:
			statusString = @"Not Reachable";
			break;
		case kReachableViaWWAN:
			statusString = @"Reachable via WWAN";
			break;
		case kReachableViaWiFi:
			statusString = @"Reachable via WiFi";
			break;
	}

	BDLoggerDebug(LOG_REACHABILITY_TAG , @"%s (%d) \n\tNetwork Status: %@", name, line, statusString);

} // logNetworkStatus_()
#endif
#else
#define logReachabilityFlags(flags)
#define logNetworkStatus(status)
#endif

@interface Reachability (private)

- (NetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags;

@end

@implementation Reachability
{
    SCNetworkReachabilityRef _reachabilityRef;
}

// Preclude direct access to ivars.
+ (BOOL) accessInstanceVariablesDirectly {
	
	return NO;

} // accessInstanceVariablesDirectly


- (void) dealloc
{
    [self stopNotifier];
    if (_reachabilityRef != NULL)
    {
        CFRelease(_reachabilityRef);
    }
} // dealloc

#if (defined DEBUG && defined CLASS_DEBUG)
- (NSString *) description {
	
	NSAssert(_reachabilityRef, @"-description called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags = 0;
	
	SCNetworkReachabilityGetFlags(_reachabilityRef, &flags);
	
	return [NSString stringWithFormat: @"\n\t%@", reachabilityFlags_(flags)];
	
} // description
#endif


#pragma mark -
#pragma mark Notification Management Methods


//Start listening for reachability notifications on the current run loop
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {

    #pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [Reachability class]], @"info was wrong class in ReachabilityCallback");
	// Post a notification to notify the client that the network reachability changed.、
    Reachability* noteObject = (__bridge Reachability *)info;
	[[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification 
														object: noteObject];
    
#warning  6.3 临发版前，配合lbs发现修改，发现频道无法获取网络状态变化，原因是他们监听的是 @"kReachabilityChangedNotification" 值，为了不影响现有功能保险起见，再发送一个通知，下一版统一 =_=!!
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kkReachabilityChangedNotification
                                                        object: noteObject];


} // ReachabilityCallback()


- (BOOL) startNotifier
{
    BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	if(SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
    {
		if(SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
		}
	}
	return returnValue;

} // startNotifier


- (void) stopNotifier
{

    if(_reachabilityRef) {
		
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

	}

} // stopNotifier


#pragma mark -
#pragma mark Reachability Allocation Methods


+ (Reachability *) reachabilityWithHostName: (NSString *) hostName {
	
    
    Reachability* returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL)
    {
        returnValue= [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else
        {
            CFRelease(reachability);
        }
    }
    return returnValue;
	
} // reachabilityWithHostName


+ (NSString *) makeAddressKey: (in_addr_t) addr {
	// addr is assumed to be in network byte order.
	
	static const int       highShift    = 24;
	static const int       highMidShift = 16;
	static const int       lowMidShift  =  8;
	static const in_addr_t mask         = 0x000000ff;
	
	addr = ntohl(addr);
	
	return [NSString stringWithFormat: @"%d.%d.%d.%d", 
			(addr >> highShift)    & mask, 
			(addr >> highMidShift) & mask, 
			(addr >> lowMidShift)  & mask, 
			 addr                  & mask];
	
} // makeAddressKey:


+ (Reachability *) reachabilityWithAddress:(const struct sockaddr *)hostAddress
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    
    Reachability* returnValue = NULL;
    
    if (reachability != NULL)
    {
        returnValue = [[self alloc] init];
        if (returnValue != NULL)
        {
            returnValue->_reachabilityRef = reachability;
        }
        else
        {
            CFRelease(reachability);
        }
    }
    return returnValue;

} // reachabilityWithAddress


+ (Reachability *) reachabilityForInternetConnection
{
	//ipv6 checked
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];

} // reachabilityForInternetConnection


#pragma mark -
#pragma mark Network Flag Handling Methods


#if USE_DDG_EXTENSIONS
//
// iPhone condition codes as reported by a 3GS running iPhone OS v3.0.
// Airplane Mode turned on:  Reachability Flag Status: -- -------
// WWAN Active:              Reachability Flag Status: WR -t-----
// WWAN Connection required: Reachability Flag Status: WR ct-----
//         WiFi turned on:   Reachability Flag Status: -R ------- Reachable.
// Local   WiFi turned on:   Reachability Flag Status: -R xxxxxxd Reachable.
//         WiFi turned on:   Reachability Flag Status: -R ct----- Connection down. (Non-intuitive, empirically determined answer.)
const SCNetworkReachabilityFlags kConnectionDown =  kSCNetworkReachabilityFlagsConnectionRequired | 
												    kSCNetworkReachabilityFlagsTransientConnection;
//         WiFi turned on:   Reachability Flag Status: -R ct-i--- Reachable but it will require user intervention (e.g. enter a WiFi password).
//         WiFi turned on:   Reachability Flag Status: -R -t----- Reachable via VPN.
//
// In the below method, an 'x' in the flag status means I don't care about its value.
//
// This method differs from Apple's by testing explicitly for empirically observed values.
// This gives me more confidence in it's correct behavior. Apple's code covers more cases 
// than mine. My code covers the cases that occur.
//
- (NetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags {
	
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return NotReachable;
    }
    
    NetworkStatus returnValue = NotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = ReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = ReachableViaWWAN;
    }
    
    return returnValue;
} // networkStatusForFlags:


- (NetworkStatus) currentReachabilityStatus {
	
	NSAssert(_reachabilityRef, @"currentReachabilityStatus called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags = 0;
	NetworkStatus status = kNotReachable;
	
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		
//		logReachabilityFlags(flags);
		
		status = [self networkStatusForFlags: flags];
		
		return status;
		
	}
	
	return kNotReachable;
	
} // currentReachabilityStatus


- (BOOL) isReachable {
	
	NSAssert(_reachabilityRef, @"isReachable called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags = 0;
	NetworkStatus status = kNotReachable;
	
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		
//		logReachabilityFlags(flags);

		status = [self networkStatusForFlags: flags];

//		logNetworkStatus(status);
		
		return (kNotReachable != status);
		
	}
	
	return NO;
	
} // isReachable


- (BOOL) isConnectionRequired {
	//ipv6 checked
	NSAssert(_reachabilityRef, @"isConnectionRequired called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags;
	
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		
		logReachabilityFlags(flags);
		
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);

	}
	
	return NO;
	
} // isConnectionRequired


- (BOOL) connectionRequired {
	
	return [self isConnectionRequired];
	
} // connectionRequired
#endif


#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 30000)
static const SCNetworkReachabilityFlags kOnDemandConnection = kSCNetworkReachabilityFlagsConnectionOnTraffic | 
                                                              kSCNetworkReachabilityFlagsConnectionOnDemand;
#else
static const SCNetworkReachabilityFlags kOnDemandConnection = kSCNetworkReachabilityFlagsConnectionAutomatic;
#endif

- (BOOL) isConnectionOnDemand {
	
	NSAssert(_reachabilityRef, @"isConnectionIsOnDemand called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags;
	
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		
		logReachabilityFlags(flags);
		
		return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
				(flags & kOnDemandConnection));
		
	}
	
	return NO;
	
} // isConnectionOnDemand


- (BOOL) isInterventionRequired {
	
	NSAssert(_reachabilityRef, @"isInterventionRequired called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags;
	
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		
		logReachabilityFlags(flags);
		
		return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
				(flags & kSCNetworkReachabilityFlagsInterventionRequired));
		
	}
	
	return NO;
	
} // isInterventionRequired


- (BOOL) isReachableViaWWAN {
	
	NSAssert(_reachabilityRef, @"isReachableViaWWAN called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags = 0;
	NetworkStatus status = kNotReachable;
	
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		
		logReachabilityFlags(flags);
		
		status = [self networkStatusForFlags: flags];
		
		return  (kReachableViaWWAN == status);
			
	}
	
	return NO;
	
} // isReachableViaWWAN


- (BOOL) isReachableViaWiFi {
	
	NSAssert(_reachabilityRef, @"isReachableViaWiFi called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags = 0;
	NetworkStatus status = kNotReachable;
	
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		
		logReachabilityFlags(flags);
		
		status = [self networkStatusForFlags: flags];
		
		return  (kReachableViaWiFi == status);
		
	}
	
	return NO;
	
} // isReachableViaWiFi


- (SCNetworkReachabilityFlags) reachabilityFlags {
	
	NSAssert(_reachabilityRef, @"reachabilityFlags called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags = 0;
	
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		
		logReachabilityFlags(flags);
		
		return flags;
		
	}
	
	return 0;
	
} // reachabilityFlags

@end
