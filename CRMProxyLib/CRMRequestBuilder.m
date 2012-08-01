//
//  CRMRequestBuilder.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/25/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import "CRMRequestBuilder.h"
#import "CRMEntityMapper.h"
#import "CRMSignatureGenerator.h"
#import "NSData+Base64.h"

@interface CRMRequestBuilder()
- (NSString *)buildSoapRequest:(NSString *)requestXml forAction:(NSString *)action withSecurityToken:(CRMSecurityToken *)token;
- (NSString *)encodeFetch:(NSString *)fetchXml;
@end

@implementation CRMRequestBuilder

@synthesize organizationServiceUrl = _organizationServiceUrl;
@synthesize secureTokenServiceUrl = _secureTokenServiceUrl;

- (NSString *) buildAuthRequestForUserName:(NSString *)userName andPassword:(NSString *)password
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDate *now = [NSDate date];
    NSDate *fiveMinutes = [NSDate dateWithTimeInterval:300.0 sinceDate:now];
    
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    
    return [NSString stringWithFormat:@""
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
         uuid, [self secureTokenServiceUrl], [formatter stringFromDate:now], [formatter stringFromDate:fiveMinutes], 
         uuid, userName, password, [self organizationServiceUrl]];
}

- (NSString *) buildCreateRequest:(id<CRMEntity>)model withSecurityToken:(CRMSecurityToken *)token
{
    NSString *requestXml = [NSString stringWithFormat:@""
        "<Create xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
        "%@"
        "</Create>", [CRMEntityMapper toXml:model]];
    
    return [self buildSoapRequest:requestXml forAction:@"Create" withSecurityToken:token];
}

- (NSString *) buildUpdateRequest:(id<CRMEntity>)model withSecurityToken:(CRMSecurityToken *)token
{
    NSString *requestXml = [NSString stringWithFormat: @""
        "<Update xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
        "%@"
        "</Update>", [CRMEntityMapper toXml:model]];
    
    return [self buildSoapRequest:requestXml forAction:@"Update" withSecurityToken:token];
}

- (NSString *) buildDeleteRequest:(id<CRMEntity>)model withSecurityToken:(CRMSecurityToken *)token
{
    NSString *requestXml = [NSString stringWithFormat: @""
        "<Delete xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
        "<entityName>%@</entityName>"
        "<id>%@</id>"
        "</Delete>", [model entityName], [model id]];
    
    return [self buildSoapRequest:requestXml forAction:@"Delete" withSecurityToken:token];
}

- (NSString *) buildFetchRequest:(NSString *)fetchXml withSecurityToken:(CRMSecurityToken *)token
{
    NSString *requestXml = [NSString stringWithFormat: @""
            "<RetrieveMultiple xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
            "<query i:type='a:FetchExpression'"
            " xmlns:i='http://www.w3.org/2001/XMLSchema-instance'"
            " xmlns:a='http://schemas.microsoft.com/xrm/2011/Contracts'>"
            "<a:Query>"
            "%@"
            "</a:Query>"
            "</query>"
            "</RetrieveMultiple>", [self encodeFetch:fetchXml]];
    
    return [self buildSoapRequest:requestXml forAction:@"RetrieveMultiple" withSecurityToken:token];
}

- (NSString *) buildExecuteRequest:(NSString *)requestXml withSecurityToken:(CRMSecurityToken *)token
{
    return [self buildSoapRequest:requestXml forAction:@"Execute" withSecurityToken:token];
}

- (NSString *) buildRetrieveRequest:(NSString *)entityName entityId:(NSString *)entityId withSecurityToken:(CRMSecurityToken *)token
{
    return [self buildRetrieveRequest:entityName entityId:entityId attributes:nil withSecurityToken:token];
}

- (NSString *) buildRetrieveRequest:(NSString *)entityName entityId:(NSString *)entityId attributes:(NSArray *)attributes 
                  withSecurityToken:(CRMSecurityToken *)token
{
    NSMutableString *columnSetXml = [[NSMutableString alloc]init];
    
    if ([attributes count] == 0) {
        [columnSetXml appendString:@"<a:AllColumns>true</a:AllColumns>"];
    } else {
        [columnSetXml appendString:@"<a:AllColumns>false</a:AllColumns>"];
        [columnSetXml appendString:@"<a:Columns xmlns:b='http://schemas.microsoft.com/2003/10/Serialization/Arrays'>"];
        for (NSString *attribute in attributes) {
            [columnSetXml appendFormat:@"<b:string>%@</b:string>", attribute];    
        }
        [columnSetXml appendString:@"</a:Columns>"];
    }
    
    NSString *requestXml = [NSString stringWithFormat:@""
        "<Retrieve xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
        "<entityName>"
        "%@"
        "</entityName>"
        "<id>"
        "%@"
        "</id>"
        "<columnSet xmlns:a='http://schemas.microsoft.com/xrm/2011/Contracts' xmlns:i='http://www.w3.org/2001/XMLSchema-instance'>"
        "%@"
        "</columnSet>"
        "</Retrieve>", entityName, entityId, columnSetXml];
    
    return [self buildSoapRequest:requestXml forAction:@"Retrieve" withSecurityToken:token];
}

- (NSString *) buildSoapRequest:(NSString *)requestXml forAction:(NSString *)action withSecurityToken:(CRMSecurityToken *)token
{
    CRMSignatureGenerator *generator = [[CRMSignatureGenerator alloc] init];
    
    NSString *timestamp = [[generator createTimestampNodeWithId:@"_0" atTime:[NSDate date]] XMLString];
    
    GDataXMLElement *signatureElement = [generator createSignatureNodeWithId:@"_0" 
                                                            andReferenceData:[timestamp dataUsingEncoding:NSUTF8StringEncoding] 
                                                                  andKeyData:[NSData dataFromBase64String:[token binarySecret]]
                                                         andKeyInfoReference:[token securityTokenReference]];
    
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    
    NSString *soapRequestXml = [NSString stringWithFormat:@""
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
        "</s:Envelope>", action, uuid, [self organizationServiceUrl], timestamp, [token tokenXml], [signatureElement XMLString], requestXml];
    
    return soapRequestXml;
}

- (NSString *) encodeFetch:(NSString *)fetchXml
{
    fetchXml = [fetchXml stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    fetchXml = [fetchXml stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    return fetchXml;
}

@end