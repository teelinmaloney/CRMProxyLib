//
//  CRMOrgService.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/15/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "CRMOrgService.h"
#import "CRMRequestBuilder.h"
#import "CRMResponseParser.h"
#import "CRMSecurityToken.h"

@interface CRMOrgService() {
@private 
    CRMRequestBuilder *requestBuilder_;
    CRMResponseParser *parser_;
}

- (CRMSecurityToken *) authenticate;

@end

@implementation CRMOrgService

@synthesize organizationServiceUrl = _organizationServiceUrl;
@synthesize secureTokenServiceUrl = _secureTokenServiceUrl;
@synthesize org = _org;
@synthesize username = _username;
@synthesize password = _password;

#pragma mark Public methods

-(id)init
{
    return [self initWithOrganizationServiceUrl:nil andSecureTokenServiceUrl:nil];
}

-(id)initWithOrganizationServiceUrl:(NSString *)orgUrl andSecureTokenServiceUrl:(NSString *)stsUrl
{
    self = [super init];
    if (self) {
        
        _organizationServiceUrl = orgUrl;
        _secureTokenServiceUrl = stsUrl;
        
        requestBuilder_ = [[CRMRequestBuilder alloc]init];
        [requestBuilder_ setOrganizationServiceUrl:[self organizationServiceUrl]];
        [requestBuilder_ setSecureTokenServiceUrl:[self secureTokenServiceUrl]];
        
        parser_ = [[CRMResponseParser alloc]init];
        
    }
    return self;
}

-(CRMSecurityToken*)authenticate
{
    NSString *authRequestXml = [requestBuilder_ buildAuthRequestForUserName:_username andPassword:_password];
    
    ASIHTTPRequest *authRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString: [requestBuilder_ secureTokenServiceUrl]]];
    [authRequest setRequestMethod:@"POST"];
    [authRequest addRequestHeader:@"Content-Type" value:@"application/soap+xml; charset=utf-8"];
    [authRequest setPostBody:[[authRequestXml dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
    [authRequest setContentLength:[authRequestXml length]];
    [authRequest startSynchronous];
    
    if ([authRequest error] != nil) {
        NSLog(@"\n\nError authenticating: \n%@\n\n", [authRequest error]);
        return nil;
    }

    NSError *error;
    CRMSecurityToken *response = [parser_ parseAuthenticationResponse:[authRequest responseString] error:&error];
    if (error) {
        NSLog(@"\n\nError: %@", [error localizedDescription]);
    }
    return response;
}

-(id)execute:(NSString *)requestXml
{
    CRMSecurityToken *token = [self authenticate];
    
    NSString *soapRequestXml = [requestBuilder_ buildExecuteRequest:requestXml withSecurityToken:token];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self organizationServiceUrl]]];
    [request addRequestHeader:@"Content-Type" value:@"application/soap+xml; charset=utf-8"];
    [request setContentLength: [soapRequestXml length]];
    [request setPostBody:[[soapRequestXml dataUsingEncoding:NSUTF8StringEncoding]mutableCopy]];
    [request startSynchronous];
    
    if ([request error] != nil) {
        NSLog(@"%@", [request error]);
        return nil;
    }
    
    return [request responseString];
}

-(NSString*)create:(id<CRMEntity>)model
{
    CRMSecurityToken *token = [self authenticate];
    
    NSString *soapRequestXml = [requestBuilder_ buildCreateRequest:model withSecurityToken:token];
    NSLog(@"\nCreate Request: \n%@\n\n", soapRequestXml);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self organizationServiceUrl]]];
    [request addRequestHeader:@"Content-Type" value:@"application/soap+xml; charset=utf-8"];
    [request setContentLength: [soapRequestXml length]];
    [request setPostBody:[[soapRequestXml dataUsingEncoding:NSUTF8StringEncoding]mutableCopy]];
    [request startSynchronous];
    
    if ([request error] != nil) {
        NSLog(@"%@", [request error]);
        return nil;
    }
    
    NSError *error;
    NSString *result = [request responseString];
    NSLog(@"\nCreate Result: \n%@\n", result);
    if ([result rangeOfString:@"s:Fault"].location != NSNotFound) {
        id fault = [parser_ parseFault:result error:&error];
        NSLog(@"Error: %@", fault);
    }
    
    return [parser_ parseCreateResponse:result error:&error];
}

-(void)update:(id<CRMEntity>)model
{
    CRMSecurityToken *token = [self authenticate];
    
    NSString *soapRequestXml = [requestBuilder_ buildUpdateRequest:model withSecurityToken:token];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self organizationServiceUrl]]];
    [request addRequestHeader:@"Content-Type" value:@"application/soap+xml; charset=utf-8"];
    [request setContentLength: [soapRequestXml length]];
    [request setPostBody:[[soapRequestXml dataUsingEncoding:NSUTF8StringEncoding]mutableCopy]];
    [request startSynchronous];
    
    if ([request error] != nil) {
        NSLog(@"%@", [request error]);
        return;
    }
    // Not sure if update request returns a result?
    NSError *error;
    NSString *result = [request responseString];
    NSLog(@"\nUpdate Result: \n%@\n", result);
    if ([result rangeOfString:@"s:Fault"].location != NSNotFound) {
        id fault = [parser_ parseFault:result error:&error];
        NSLog(@"Error: %@", fault);
    }
}

-(void)delete:(NSString *)entityId
{
    
}

-(id)retrieve:(NSString *)modelName
   entityName:(NSString *)entityName 
     entityId:(NSString *)entityId 
   attributes:(NSArray *)attributes
{
    return nil;
}

-(NSArray *)retrieveMultiple:(NSString *)fetchXml ofClassName:(NSString *)className
{
    CRMSecurityToken *token = [self authenticate];
    
    NSString *soapRequestXml = [requestBuilder_ buildFetchRequest:fetchXml withSecurityToken:token];
    NSLog(@"%@", soapRequestXml);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self organizationServiceUrl]]];
    [request addRequestHeader:@"Content-Type" value:@"application/soap+xml; charset=utf-8"];
    [request setContentLength:[soapRequestXml length]];
    [request setPostBody:[[soapRequestXml dataUsingEncoding:NSUTF8StringEncoding]mutableCopy]];
    [request startSynchronous];
    
    if ([request error] != nil) {
        NSLog(@"%@", [request error]);
        return nil;
    }
    
    NSError *error;
    NSString *result = [request responseString];
    
    NSLog(@"\nResult: \n%@\n", result);
    if ([result rangeOfString:@"s:Fault"].location != NSNotFound) {
        id fault = [parser_ parseFault:result error:&error];
        NSLog(@"Error: %@", fault);
    }
    
    return [parser_ parseRetrieveMultipleResponse:result forClassName:className error:&error];
}

@end
