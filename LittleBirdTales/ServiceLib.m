//
//  ServiceLib.m
//  SOS
//
//  Created by Toan M. Ha on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServiceLib.h"
#import "Lib.h"

static ServiceLib* serviceLib;
@implementation ServiceLib
+(ServiceLib*)shareInstance {
	if (!serviceLib) {
		serviceLib = [[ServiceLib alloc] init];
	}
	return serviceLib;
}

+(NSString*)sendGetRequest:(NSString*)strURL {
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL]];
	[theRequest setHTTPMethod:@"GET"];
	NSData* responeData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];		
	NSString *string = [[NSString alloc] initWithData:responeData encoding:NSUTF8StringEncoding];	
	return string;	
}

+(NSString*)sendRequest:(NSMutableDictionary*)params andUrl:(NSString*)strURL {
    NSLog(@"Request to URL: %@",strURL);
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL]];
	
	[theRequest setHTTPMethod:@"POST"];
	
	NSString* paramStr = @"";
	
	if (params) {
		NSEnumerator *keys = [params keyEnumerator];
		
		for (int i = 0; i < [params count]; i++) {
			NSString *key = [keys nextObject];
			NSString *val = [params objectForKey:key];
			paramStr = [NSString stringWithFormat:@"%@&%@=%@",paramStr,key,val];
		}
	}
	
	if (paramStr.length > 0) {
		NSData* requestData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
		NSString* requestDataLengthString = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
		[theRequest setHTTPBody: requestData];
		[theRequest setValue:requestDataLengthString forHTTPHeaderField:@"Content-Length"];		
	}
	
	NSData* responeData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];	
	
	NSString *string = [[NSString alloc] initWithData:responeData encoding:NSUTF8StringEncoding];
	//NSLog(@"%@",string);
	return string;
	
}

+(NSData*)sendRequestForFile:(NSMutableDictionary*)params andUrl:(NSString*)strURL {
    NSLog(@"Request to URL: %@",strURL);
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL]];
	
	[theRequest setHTTPMethod:@"POST"];
	
	NSString* paramStr = @"";
	
	if (params) {
		NSEnumerator *keys = [params keyEnumerator];
		
		for (int i = 0; i < [params count]; i++) {
			NSString *key = [keys nextObject];
			NSString *val = [params objectForKey:key];
			paramStr = [NSString stringWithFormat:@"%@&%@=%@",paramStr,key,val];
		}
	}
	 
	if (paramStr.length > 0) {
		NSData* requestData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
		NSString* requestDataLengthString = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
		[theRequest setHTTPBody: requestData];
		[theRequest setValue:requestDataLengthString forHTTPHeaderField:@"Content-Length"];
	}
	
	NSData* responeData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
	
	return responeData;
	
}

@end
