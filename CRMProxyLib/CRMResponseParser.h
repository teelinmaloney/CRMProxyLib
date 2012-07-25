//
//  CRMResponseParser.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/25/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMEntity.h"
#import "CRMFault.h"
#import "CRMSecurityToken.h"

@interface CRMResponseParser : NSObject

-(CRMSecurityToken *)parseAuthenticationResponse:(NSString *)responseXml 
                                           error:(NSError **)error;

-(CRMFault *)parseFault:(NSString *)responseXml 
                  error:(NSError **)error;

-(NSString *)parseCreateResponse:(NSString *)responseXml 
                           error:(NSError **)error;

-(id<CRMEntity>)parseRetrieveResponse:(NSString *)responseXml 
                                  error:(NSError **)error;

-(NSArray *)parseRetrieveMultipleResponse:(NSString *)responseXml 
                                    error:(NSError **)error;

-(NSArray *)parseFetchResponse:(NSString *)responseXml
                  forClassName:(NSString *)className
                         error:(NSError **)error;
@end
