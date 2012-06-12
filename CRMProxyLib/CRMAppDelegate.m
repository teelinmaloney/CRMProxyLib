//
//  CRMAppDelegate.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CRMAppDelegate.h"
#import "CRMTime.h"
#import "CRMPost.h"
#import "CRMOrgService.h"
#import "CRMQueryBuilder.h"
#import "CRMResponseParser.h"

@interface CRMAppDelegate() {
 @private
    NSString *authResponseXml;
    NSString *createResponseXml;
    NSString *faultResponseXml;
}

-(void)initResponses;
-(void)whoAmI;
-(void)testCreate;
-(void)testFetch;
-(void)testParse;
@end

@implementation CRMAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self initResponses];

    //[self whoAmI];
    //[self testCreate];
    [self testParse];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)whoAmI
{
    NSString *request = @"<Execute xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
    "<request i:type='c:WhoAmIRequest' xmlns:b='http://schemas.microsoft.com/xrm/2011/Contracts'"
    " xmlns:i='http://www.w3.org/2001/XMLSchema-instance'"
    " xmlns:c='http://schemas.microsoft.com/crm/2011/Contracts'>"
    "<b:Parameters xmlns:d='http://schemas.datacontract.org/2004/07/System.Collections.Generic'/>"
    "<b:RequestId i:nil='true'/>"
    "<b:RequestName>WhoAmI</b:RequestName>"
    "</request></Execute>";
    
    CRMOrgService *service = [[CRMOrgService alloc]initWithUrl:@"https://grapevine.sonomapartners.com/XRMServices/2011/Organization.svc" 
                                                  organization:@"grapevine"];
    
    NSString *response = [service execute:request];
    NSLog(@"\n\nWhoAmI Response: \n%@", response);
;}

-(void)testCreate
{
    CRMPost *post = [[CRMPost alloc]init];
    post.text = @"Test from OrgService";
    post.regardingobjectid = [[CRMEntityReference alloc]initWithEntityName:@"systemuser" andId:@"FC6A0980-A1FF-DE11-A75B-00101826F7F4"];
    post.source = [NSNumber numberWithInt:2];
    
    CRMOrgService *service = [[CRMOrgService alloc]initWithUrl:@"https://grapevine.sonomapartners.com/XRMServices/2011/Organization.svc" 
                                                 organization:@"grapevine"];
    
    NSString *response = [service create:post];
    NSLog(@"\n\nCreate Response: \n%@", response);
}

-(void)testFetch
{
    CRMOrgService *service= [[CRMOrgService alloc]initWithUrl:@"https://grapevine.sonomapartners.com/XRMServices/2011/Organization.svc" 
                                                 organization:@"grapevine"];
    
    CRMQueryBuilder *builder = [[CRMQueryBuilder alloc]initWithEntityName:@"post"];
    [builder setAllAttributes:YES];
    [builder setConditions:[NSArray arrayWithObjects: 
                            [[CRMCondition alloc]initWithAttribute:@"createdon" andConditionOperator:Equal andValue:[NSDate date]], 
                            nil]];

    [service execute:[builder toFetchXml]];
}

-(void)testParse
{
    CRMResponseParser *parser = [[CRMResponseParser alloc]init];
    
    NSError *error;
    
    [parser parseAuthenticationResponse:authResponseXml error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    
    id fault = [parser parseFault:faultResponseXml error:&error];
    NSLog(@"%@", fault);
    
    NSString *guid = [parser parseCreateResponse:createResponseXml error:&error];
    NSLog(@"\n\nCreate Response: \n%@", guid);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(void)initResponses
{
    authResponseXml = [NSString stringWithString:@"<?xml version='1.0'?><s:Envelope xmlns:s='http://www.w3.org/2003/05/soap-envelope' xmlns:a='http://www.w3.org/2005/08/addressing' xmlns:u='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'><s:Header><a:Action s:mustUnderstand='1'>http://docs.oasis-open.org/ws-sx/ws-trust/200512/RSTRC/IssueFinal</a:Action><a:RelatesTo>urn:uuid:449CA228-7730-4164-9BB2-6A31903DB896</a:RelatesTo><o:Security xmlns:o='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd' s:mustUnderstand='1'><u:Timestamp u:Id='_0'>        <u:Created>2012-06-05T02:19:11.295Z</u:Created><u:Expires>2012-06-05T02:24:11.295Z</u:Expires></u:Timestamp></o:Security></s:Header><s:Body><trust:RequestSecurityTokenResponseCollection xmlns:trust='http://docs.oasis-open.org/ws-sx/ws-trust/200512'><trust:RequestSecurityTokenResponse><trust:Lifetime><wsu:Created xmlns:wsu='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'>2012-06-05T02:19:11.295Z</wsu:Created>          <wsu:Expires xmlns:wsu='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'>2012-06-05T03:19:11.295Z</wsu:Expires>        </trust:Lifetime><wsp:AppliesTo xmlns:wsp='http://schemas.xmlsoap.org/ws/2004/09/policy'><wsa:EndpointReference xmlns:wsa='http://www.w3.org/2005/08/addressing'><wsa:Address>https://grapevine.sonomapartners.com/</wsa:Address></wsa:EndpointReference></wsp:AppliesTo><trust:RequestedSecurityToken>          <xenc:EncryptedData xmlns:xenc='http://www.w3.org/2001/04/xmlenc#' Type='http://www.w3.org/2001/04/xmlenc#Element'><xenc:EncryptionMethod Algorithm='http://www.w3.org/2001/04/xmlenc#aes256-cbc'/><KeyInfo xmlns='http://www.w3.org/2000/09/xmldsig#'><e:EncryptedKey xmlns:e='http://www.w3.org/2001/04/xmlenc#'><e:EncryptionMethod Algorithm='http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p'><DigestMethod Algorithm='http://www.w3.org/2000/09/xmldsig#sha1'/></e:EncryptionMethod><KeyInfo><o:SecurityTokenReference xmlns:o='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>                    <X509Data><X509IssuerSerial><X509IssuerName>SERIALNUMBER=07969287, CN=Go Daddy Secure Certification Authority, OU=http://certificates.godaddy.com/repository, O='GoDaddy.com, Inc.', L=Scottsdale, S=Arizona, C=US</X509IssuerName><X509SerialNumber>2197130310013940</X509SerialNumber></X509IssuerSerial></X509Data></o:SecurityTokenReference></KeyInfo><e:CipherData><e:CipherValue>RyuePM8OfBApv1isTNiyET6UgqgHWnAh5CW+lBIhzn1lNiIZTP9mlRoAKY21uABl2URPAYo/EaPt6C5pK46zKUAkM56Mu2w8KPp8VWTMN3xCx4AZykuVUxHavupGt43fvoGIxhwksRisg6JnqgJlO9ZoESY+ztpUQrHpQP193ktaBDKpfZXB/W5EhRHqGwZxkYmj5n3H0ZZ7NFH3GTDJlnkudN7gXcYevtHVwz6sBhCx2YMXDx+AwraC2klri274rZxJVAPxESvyeeXqHyITX37xMbefJ8HkapllcH6juE9a+incIpNEMXylpAkhLOFrCO/aQGecie4CoieZnNYyLg==</e:CipherValue></e:CipherData></e:EncryptedKey></KeyInfo><xenc:CipherData><xenc:CipherValue>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</xenc:CipherValue></xenc:CipherData></xenc:EncryptedData></trust:RequestedSecurityToken><trust:RequestedProofToken><trust:BinarySecret>ftF2XskxYDO5S4k8L5yMNBxo8WvEZHWcplJ698mdhuw=</trust:BinarySecret></trust:RequestedProofToken><trust:RequestedAttachedReference><o:SecurityTokenReference xmlns:o='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'><o:KeyIdentifier ValueType='http://docs.oasis-open.org/wss/oasis-wss-saml-token-profile-1.0#SAMLAssertionID'>_1585bca6-3a5e-4018-b189-fd5b745972cb</o:KeyIdentifier></o:SecurityTokenReference></trust:RequestedAttachedReference><trust:RequestedUnattachedReference><o:SecurityTokenReference xmlns:o='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'><o:KeyIdentifier ValueType='http://docs.oasis-open.org/wss/oasis-wss-saml-token-profile-1.0#SAMLAssertionID'>_1585bca6-3a5e-4018-b189-fd5b745972cb</o:KeyIdentifier></o:SecurityTokenReference></trust:RequestedUnattachedReference><trust:TokenType>urn:oasis:names:tc:SAML:1.0:assertion</trust:TokenType><trust:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</trust:RequestType><trust:KeyType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/SymmetricKey</trust:KeyType></trust:RequestSecurityTokenResponse></trust:RequestSecurityTokenResponseCollection></s:Body></s:Envelope>"];
    
    createResponseXml = [NSString stringWithString:@"<s:Envelope xmlns:s='http://www.w3.org/2003/05/soap-envelope' xmlns:a='http://www.w3.org/2005/08/addressing' xmlns:u='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'><s:Header><a:Action s:mustUnderstand='1'>http://schemas.microsoft.com/xrm/2011/Contracts/Services/IOrganizationService/CreateResponse</a:Action><a:RelatesTo>urn:uuid:97EC91DA-6DA7-4163-B320-B62332451CB8</a:RelatesTo><ActivityId CorrelationId='47c54199-8af3-4fd9-9899-ad85cf964b19' xmlns='http://schemas.microsoft.com/2004/09/ServiceModel/Diagnostics'>00000000-0000-0000-0000-000000000000</ActivityId><o:Security s:mustUnderstand='1' xmlns:o='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'><u:Timestamp u:Id='_0'><u:Created>2012-05-26T02:39:52.224Z</u:Created><u:Expires>2012-05-26T02:44:52.224Z</u:Expires></u:Timestamp></o:Security></s:Header><s:Body><CreateResponse xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'><CreateResult>935e5711-dca6-e111-b5e5-0026b9f9e50c</CreateResult></CreateResponse></s:Body></s:Envelope>"];
    
    faultResponseXml = [NSString stringWithString:@"<s:Envelope xmlns:s='http://www.w3.org/2003/05/soap-envelope' xmlns:a='http://www.w3.org/2005/08/addressing'  xmlns:u='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'><s:Header><a:Action s:mustUnderstand='1'>http://schemas.microsoft.com/xrm/2011/Contracts/Services/IOrganizationService/CreateOrganizationServiceFaultFault</a:Action><a:RelatesTo>urn:uuid:481A8C03-972D-4137-8261-BC8F2EBFE593</a:RelatesTo><ActivityId xmlns='http://schemas.microsoft.com/2004/09/ServiceModel/Diagnostics' CorrelationId='8a5718aa-1d35-46fd-9a7d-c329bad25f70'>00000000-0000-0000-0000-000000000000</ActivityId><o:Security xmlns:o='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd' s:mustUnderstand='1'><u:Timestamp u:Id='_0'><u:Created>2012-05-26T00:14:32.777Z</u:Created><u:Expires>2012-05-26T00:19:32.777Z</u:Expires></u:Timestamp></o:Security></s:Header><s:Body><s:Fault><s:Code><s:Value>s:Sender</s:Value></s:Code><s:Reason><s:Text xml:lang='en-US'>regardingobjectid</s:Text></s:Reason><s:Detail><OrganizationServiceFault xmlns='http://schemas.microsoft.com/xrm/2011/Contracts' xmlns:i='http://www.w3.org/2001/XMLSchema-instance'><ErrorCode>-2147220989</ErrorCode><ErrorDetails xmlns:b='http://schemas.datacontract.org/2004/07/System.Collections.Generic'/><Message>regardingobjectid</Message><Timestamp>2012-05-26T00:14:32.7776714Z</Timestamp><InnerFault><ErrorCode>-2147220989</ErrorCode><ErrorDetails xmlns:b='http://schemas.datacontract.org/2004/07/System.Collections.Generic'/><Message>regardingobjectid</Message><Timestamp>2012-05-26T00:14:32.7776714Z</Timestamp><InnerFault><ErrorCode>-2147220970</ErrorCode><ErrorDetails xmlns:b='http://schemas.datacontract.org/2004/07/System.Collections.Generic'/><Message>System.ArgumentException: regardingobjectid</Message><Timestamp>2012-05-26T00:14:32.7776714Z</Timestamp><InnerFault i:nil='true'/><TraceText i:nil='true'/></InnerFault><TraceText i:nil='true'/></InnerFault><TraceText i:nil='true'/></OrganizationServiceFault></s:Detail></s:Fault></s:Body></s:Envelope>"];
}

@end
