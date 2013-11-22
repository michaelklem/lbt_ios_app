//
//  ServiceLib.h
//  SOS
//
//  Created by Toan M. Ha on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceLib : NSObject {
    
}
+(NSString*)sendRequest:(NSMutableDictionary*)params andUrl:(NSString*)strURL;
+(NSData*)sendRequestForFile:(NSMutableDictionary*)params andUrl:(NSString*)strURL;
+(NSString*)sendGetRequest:(NSString*)strURL;
+(ServiceLib*)shareInstance;
@end
