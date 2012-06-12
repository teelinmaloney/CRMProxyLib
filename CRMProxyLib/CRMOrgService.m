//
//  CRMOrgService.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/15/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "CRMOrgService.h"
#import "CRMEntity.h"
#import "CRMRequestBuilder.h"
#import "CRMResponseParser.h"
#import "CRMSecurityToken.h"
#import "CRMSignatureGenerator.h"
#import "GDataXMLNode.h"
#import "NSData+Base64.h"

@interface CRMOrgService() {
@private 
    NSString *uuid_;
    CRMRequestBuilder *requestBuilder_;
    CRMResponseParser *parser_;
}

-(NSString *)buildSoapRequestXml:(NSString *)requestXml action:(NSString *)action securityToken:(CRMSecurityToken *)securityToken;

-(CRMSecurityToken*)authenticate;

@end

@implementation CRMOrgService

@synthesize url = _url;
@synthesize org = _org;
@synthesize username = _username;
@synthesize password = _password;

#pragma mark Public methods

-(id)init
{
    return [self initWithUrl:nil organization:nil];
}

-(id)initWithUrl:(NSString *)url organization:(NSString *)org
{
    self = [super init];
    if (self) {
        
        _url = url;
        _org = org;
        _username = @"domain\\username";
        _password = @"password";
        requestBuilder_ = [[CRMRequestBuilder alloc]init];
        parser_ = [[CRMResponseParser alloc]init];
        
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        uuid_ = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        CFRelease(uuidRef);
    }
    return self;
}

-(CRMSecurityToken*)authenticate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDate *now = [NSDate date];
    NSDate *fiveMinutes = [NSDate dateWithTimeInterval:300.0 sinceDate:now];
    NSString *sts_url = @"https://federation.sonomapartners.com/adfs/services/trust/13/usernamemixed";    
    NSString *requestBody = [NSString stringWithFormat:@""
                             "<s:Envelope xmlns:s='http://www.w3.org/2003/05/soap-envelope' xmlns:a='http://www.w3.org/2005/08/addressing' xmlns:u='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'><s:Header><a:Action s:mustUnderstand='1'>http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue</a:Action>"
                             "<a:MessageID>urn:uuid:%@</a:MessageID>"
                             "<a:ReplyTo><a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address></a:ReplyTo>"
                             "<a:To s:mustUnderstand='1'>%@</a:To>"
                             "<o:Security s:mustUnderstand='1' xmlns:o='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>"
                             "<u:Timestamp u:Id='_0'>"
                             "<u:Created>%@</u:Created>"
                             "<u:Expires>%@</u:Expires>"
                             "</u:Timestamp>"
                             "<o:UsernameToken u:Id='uuid-%@'>"
                             "<o:Username>%@</o:Username>"
                             "<o:Password Type='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'>%@</o:Password>"
                             "</o:UsernameToken>"
                             "</o:Security>"
                             "</s:Header>"
                             "<s:Body>"
                             "<trust:RequestSecurityToken xmlns:trust='http://docs.oasis-open.org/ws-sx/ws-trust/200512'>"
                             "<wsp:AppliesTo xmlns:wsp='http://schemas.xmlsoap.org/ws/2004/09/policy'>"
                             "<a:EndpointReference>"
                             "<a:Address>%@</a:Address>"
                             "</a:EndpointReference></wsp:AppliesTo><trust:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</trust:RequestType></trust:RequestSecurityToken></s:Body></s:Envelope>", 
                             uuid_, sts_url, 
                             [formatter stringFromDate:now], 
                             [formatter stringFromDate:fiveMinutes], 
                             uuid_, _username, _password, _url];

    
    ASIHTTPRequest *authRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString: sts_url]];
    [authRequest setRequestMethod:@"POST"];
    [authRequest addRequestHeader:@"Content-Type" value:@"application/soap+xml; charset=utf-8"];
    [authRequest setPostBody:[[requestBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
    [authRequest setContentLength:requestBody.length];
    [authRequest startSynchronous];
    
    if (authRequest.error != nil) {
        NSLog(@"\n\nError authenticating: \n%@\n\n", authRequest.error);
        return nil;
    }
    //NSLog(@"AUTH Response: \n%@\n\n", [authRequest responseString]);
    NSError *error;
    CRMSecurityToken *response = [parser_ parseAuthenticationResponse:[authRequest responseString] error:&error];
    if (error) {
        NSLog(@"\n\nError: %@", error.localizedDescription);
    }
    return response;
}

-(id)execute:(NSString *)requestXml
{
    CRMSecurityToken *token = [self authenticate];
    
    NSString *soapRequestXml = [self buildSoapRequestXml:requestXml action:@"Execute" securityToken:token];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:_url]];
    [request addRequestHeader:@"Content-Type" value:@"application/soap+xml; charset=utf-8"];
    [request setContentLength: soapRequestXml.length];
    [request setPostBody:[[soapRequestXml dataUsingEncoding:NSUTF8StringEncoding]mutableCopy]];
    [request startSynchronous];
    
    if (request.error != nil) {
        NSLog(@"%@", request.error);
        return nil;
    }
    
    return request.responseString;
}

-(NSString*)create:(id<CRMEntity>)model
{
    CRMSecurityToken *token = [self authenticate];
    
    NSString *soapRequestXml = [self buildSoapRequestXml:[requestBuilder_ buildCreateRequest:model] action:@"Create" securityToken:token];
    NSLog(@"\nCreate Request: \n%@\n\n", soapRequestXml);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:_url]];
    [request addRequestHeader:@"Content-Type" value:@"application/soap+xml; charset=utf-8"];
    [request setContentLength: soapRequestXml.length];
    [request setPostBody:[[soapRequestXml dataUsingEncoding:NSUTF8StringEncoding]mutableCopy]];
    [request startSynchronous];
    
    if (request.error != nil) {
        NSLog(@"%@", request.error);
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
    [self execute:[requestBuilder_ buildUpdateRequest:model]];
}

-(void)delete:(NSString *)entityId
{
    
}

-(id)retrieve:(NSString *)modelName
   entityName:(NSString *)entityName 
     entityId:(NSString *)entityId 
   attributes:(NSArray *)attributes
{
    //NSString *requestXml = [NSString stringWithFormat:@""];
    
//    NSString *response = [self execute:request];
//    return [self convertXml:response toModel:modelName];
    return nil;
}

-(NSArray *)retrieveMultiple:(NSString *)fetchXml
{
    NSMutableArray *items = [[NSMutableArray alloc]init];
    
    return [items copy];
}

#pragma mark - Request helpers

-(NSString *)buildSoapRequestXml:(NSString *)requestXml 
                          action:(NSString *)action 
                   securityToken:(CRMSecurityToken *)securityToken
{
    CRMSignatureGenerator *generator = [[CRMSignatureGenerator alloc] init];
    NSString *timestamp = [[generator createTimestampNodeWithId:@"_0" atTime:[NSDate date]] XMLString];
    
    GDataXMLElement *signatureElement = [generator createSignatureNodeWithId:@"_0" 
                                                            andReferenceData:[timestamp dataUsingEncoding:NSUTF8StringEncoding] 
                                                                  andKeyData:[NSData dataFromBase64String:securityToken.binarySecret] 
                                                         andKeyInfoReference:securityToken.securityTokenReference];
    
    NSString *signature = [signatureElement XMLString];
    
    return [NSString stringWithFormat:@""
            "<s:Envelope xmlns:s='http://www.w3.org/2003/05/soap-envelope'"
            " xmlns:a='http://www.w3.org/2005/08/addressing'"
            " xmlns:u='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'"
            " xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>"
            "<s:Header>"
            "<a:Action s:mustUnderstand='1'>http://schemas.microsoft.com/xrm/2011/Contracts/Services/IOrganizationService/%@</a:Action>"
            "<a:MessageID>urn:uuid:%@</a:MessageID>"
            "<a:ReplyTo><a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address></a:ReplyTo>"
            "<a:To s:mustUnderstand='1'>%@</a:To>"
            "<o:Security s:mustUnderstand='1' xmlns:o='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>"
            "%@"
            "%@"
            "%@"
            "</o:Security>"
            "</s:Header>"
            "<s:Body>"
            "%@"
            "</s:Body>"
            "</s:Envelope>", action, uuid_, _url, timestamp, securityToken.tokenXml, signature, requestXml];
}

@end
