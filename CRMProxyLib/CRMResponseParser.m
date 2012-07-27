//
//  CRMResponseParser.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/25/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import "CRMResponseParser.h"
#import "CRMEntityMapper.h"
#import "GDataXMLNode.h"

@interface CRMResponseParser() {}
@property (nonatomic, strong) NSDictionary *namespaces;

- (id<CRMEntity>)parseEntity:(NSString *)entityXml error:(NSError **)error;
- (id)parseValue:(NSString *)valueXml;
- (NSString *)decodeXml:(NSString *)value;
- (NSString *)formatResultSetXml:(NSString *)xml;
- (NSDictionary *)getAttributesFromXmlNode:(GDataXMLNode *)node;
@end

@implementation CRMResponseParser

@synthesize namespaces = _namespaces;

-(id)init
{
    self = [super init];
    if (self) {
        [self setNamespaces: [NSDictionary dictionaryWithObjectsAndKeys:
            @"http://schemas.microsoft.com/xrm/2011/Contracts", @"Contracts", 
            @"http://schemas.microsoft.com/xrm/2011/Contracts/Services", @"Services",
            @"http://docs.oasis-open.org/ws-sx/ws-trust/200512", @"trust",
            @"http://www.w3.org/2001/04/xmlenc#", @"xenc",
            @"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd", @"wsu",
            @"http://schemas.microsoft.com/crm/2007/WebServices", @"ws",
            nil]];
    }
    return self;
}

-(CRMSecurityToken *)parseAuthenticationResponse:(NSString *)responseXml error:(NSError **)error
{
    CRMSecurityToken *token = [[CRMSecurityToken alloc]init];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithXMLString:responseXml options:0 error:&*error];
    if (*error) {
        NSLog(@"Error parsing XML response. %@", [*error localizedDescription]);
        return nil;
    }
    if (doc) {
        
        NSArray *securityTokens = [doc nodesForXPath:@"//trust:RequestedSecurityToken/xenc:EncryptedData" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"\n\nError parsing encrypted data: %@", [*error localizedDescription]);
            return nil;
        }
        if ([securityTokens count] == 1) {
            token.tokenXml = [[securityTokens objectAtIndex:0] XMLString];
        }
        
        NSArray *secrets = [doc nodesForXPath:@"//trust:RequestedProofToken/trust:BinarySecret" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"\n\nError parsing binary secret: %@", [*error localizedDescription]);
            return nil;
        }
        if ([secrets count] == 1) {
            token.binarySecret = [[secrets objectAtIndex:0] stringValue];   
        }
        
        NSArray *rars = [doc nodesForXPath:@"//trust:RequestedAttachedReference" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"\nError parsing Requested Attached Reference");
            return nil;
        }
        if ([rars count] == 1) {
#pragma TODO parse using xpath
            GDataXMLElement *reference = [rars objectAtIndex:0];
            [reference addNamespace:[GDataXMLNode namespaceWithName:@"o" 
                                                        stringValue:@"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"]];
            [reference addNamespace:[GDataXMLNode namespaceWithName:@"trust" 
                                                        stringValue:@"http://docs.oasis-open.org/ws-sx/ws-trust/200512"]];
            
            GDataXMLElement *tokenReference = [[reference elementsForName:@"o:SecurityTokenReference"] objectAtIndex:0];
            [tokenReference addNamespace:[GDataXMLNode namespaceWithName:@"o" 
                                                             stringValue:@"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"]];
            token.requestedAttachedReference = [reference XMLString];
            token.securityTokenReference = [tokenReference XMLString];
        }
        
        NSArray *created = [doc nodesForXPath:@"//trust:Lifetime/wsu:Created" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"\nError parsing Lifetime - CreatedAt: %@", [*error localizedDescription]);
            return nil;
        }
        if ([created count] == 1) {
            token.createdAt = [[created objectAtIndex:0] stringValue];
        }
        
        NSArray *expires = [doc nodesForXPath:@"//trust:Lifetime/wsu:Expires" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"\nError parsing Lifetime - Expires: %@", [*error localizedDescription]);
            return nil;
        }
        if ([expires count] == 1) {
            token.expiresAt = [[expires objectAtIndex:0] stringValue];
        }
        
    }
    
    return token;
}

-(CRMFault *)parseFault:(NSString *)responseXml error:(NSError **)error
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithXMLString:responseXml options:0 error:&*error];
    if (*error) {
        NSLog(@"\nError creating XML document from response XML: \n%@\n", [*error localizedDescription]);
        return nil;
    }
    
    if (doc) {
        NSArray *faults = [doc nodesForXPath:@"s:Envelope/s:Body/s:Fault/s:Detail" error:&*error];
        if ([faults count] > 0) {
            CRMFault *fault = [[CRMFault alloc]init];
            
            GDataXMLNode *detail = [faults objectAtIndex:0];
            
            NSArray *errorCodes = [detail nodesForXPath:@"(//Contracts:ErrorCode)[last()]" namespaces:[self namespaces] error:&*error];
            if ([errorCodes count] > 0) {
                [fault setErrorCode:[[errorCodes objectAtIndex:0]stringValue]];
            }
            
            NSArray *errorDetails = [detail nodesForXPath:@"(//Contracts:ErrorDetails)[last()]" namespaces:[self namespaces] error:&*error];
            if ([errorDetails count] > 0) {
#pragma TODO - Verify correct parsing of ErrorDetails
                NSArray *details = [[errorDetails objectAtIndex:0]nodesForXPath:@"./child::text()" error:&*error];
                if ([details count] > 0) {
                    [fault setErrorDetails:[details copy]];
                }
            }
            
            NSArray *messages = [detail nodesForXPath:@"(//Contracts:Message)[last()]" namespaces:[self namespaces] error:&*error];
            if ([messages count] > 0) {
                [fault setMessage:[[messages objectAtIndex:0]stringValue]];
            }
            
            return fault;    
        }
    }
    return nil;
}

// Returns the GUID of the created record or NIL
-(NSString *)parseCreateResponse:(NSString *)responseXml error:(NSError **)error
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithXMLString:responseXml options:0 error:&*error];
    
    if (*error) {
        NSLog(@"\nError creating XML document from response XML: \n%@\n", [*error localizedDescription]);
        return nil;
    }
    
    if (doc) {
        NSArray *responses = [doc nodesForXPath:@"//Services:CreateResponse/Services:CreateResult" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"\nError parsing CreateResult element: \n%@\n", [*error localizedDescription]);
            return nil;
        }
        
        if ([responses count] == 1) {
            return [[responses objectAtIndex:0]stringValue];
        }
    }
    return nil;
}

-(id<CRMEntity>)parseRetrieveResponse:(NSString *)responseXml error:(NSError **)error
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:responseXml options:0 error:&*error];
    if (*error) {
        NSLog(@"\nError parsing response XML: %@", [*error localizedDescription]);
        return nil;
    }
    
    if (doc) {
        NSArray *entities = [doc nodesForXPath:@"s:Envelope/s:Body/RetrieveResponse/RetrieveResult" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"%@", [*error localizedDescription]);
            return nil;
        }
        if ([entities count] == 1) {
            return [self parseEntity:[[entities objectAtIndex:0]stringValue] error:&*error];
        }
    }
    
    return nil;
}

-(NSArray *)parseRetrieveMultipleResponse:(NSString *)responseXml forClassName:(NSString *)className error:(NSError **)error
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithXMLString:responseXml options:0 error:&*error];
    if (*error) {
        NSLog(@"%@", [*error localizedDescription]);
        return nil;
    }
    if (doc) {
        NSArray *results = [doc nodesForXPath:@"//Services:RetrieveMultipleResponse/Services:RetrieveMultipleResult" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"%@", [*error localizedDescription]);
            return nil;
        }
        if ([results count] == 1) {
            NSArray *entities = [[results objectAtIndex:0] nodesForXPath:@"Contracts:Entities/Contracts:Entity" namespaces:[self namespaces] error:&*error];
            if (*error) {
                NSLog(@"%@", [*error localizedDescription]);
                return nil;
            }
            if ([entities count] > 0) {
                CRMEntityMapper *entityMapper = [[CRMEntityMapper alloc]initWithEntityName:className];
                NSMutableArray *ents = [[NSMutableArray alloc]init];
                for (GDataXMLNode *node in entities) {
                    id<CRMEntity> entity = [entityMapper fromEntityXml:node];
                    [ents addObject:entity];
                }
                return ents;
            }
        }
    }
    return nil;
}

-(NSArray *)parseFetchResponse:(NSString *)responseXml forClassName:(NSString *)className error:(NSError **)error
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithXMLString:responseXml options:0 error:&*error];
    if (*error) {
        NSLog(@"%@", [*error localizedDescription]);
        return nil;
    }
    if (doc) {
        NSArray *results = [doc nodesForXPath:@"//ws:FetchResponse/ws:FetchResult" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"%@", [*error localizedDescription]);
            return nil;
        }
        if ([results count] == 1) {
            NSString *result = [self formatResultSetXml:[[results objectAtIndex:0]stringValue]];
            GDataXMLDocument *resultDoc = [[GDataXMLDocument alloc]initWithXMLString:result options:0 error:&*error];
            if (*error) {
                NSLog(@"%@", [*error localizedDescription]);
                return nil;
            }
            if (resultDoc) {
                NSArray *entities = [resultDoc nodesForXPath:@"resultset/result" error:&*error];
                if ([entities count] > 0) {
                    CRMEntityMapper *entityMapper = [[CRMEntityMapper alloc]initWithEntityName:className];
                    NSMutableArray *ents = [[NSMutableArray alloc]init];
                    for (GDataXMLNode *node in entities) {
                        id<CRMEntity> entity = [entityMapper fromFetchResultXml:node];
                        [ents addObject:entity];
                    }
                    return ents;
                }
            }
        }
    }
    return nil;
}

-(NSString *)formatResultSetXml:(NSString *)xml
{
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:@"((?<==)')|('(?=\\s+))|('(?=>))" options:0 error:NULL];
    return [regex stringByReplacingMatchesInString:xml options:0 range:NSMakeRange(0, [xml length]) withTemplate:@"\""];
}

-(id<CRMEntity>)parseEntity:(NSString *)entityXml error:(NSError **)error
{
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithXMLString:entityXml options:0 error:&*error];
    if (*error) {
        NSLog(@"%@", [*error localizedDescription]);
        return nil;
    }
    
    if (doc) {
        NSString *entityName;
        NSMutableDictionary *attributeValues = [[NSMutableDictionary alloc]init];
        
        NSArray *entityNames = [doc nodesForXPath:@"//a:EntityName::text()" error:&*error];
        if (*error) {
            NSLog(@"%@", [*error localizedDescription]);
            return nil;
        }
        
        if ([entityNames count] > 0) {
            entityName = [entityNames objectAtIndex:0];
        }
        
        id<CRMEntity> model = [[NSClassFromString(entityName) alloc]init];
        if (model == nil) {
            NSLog(@"Error: unable to create class for entity: %@", entityName);
            return nil;
        }
        
        NSArray *attributes = [doc nodesForXPath:@"//a:Attributes" namespaces:[self namespaces] error:&*error];
        if (*error) {
            NSLog(@"%@", [*error localizedDescription]);
            return nil;
        }
        
        if ([attributes count] > 0) {
            for (id attrNode in [[attributes objectAtIndex:0]children]) {
                
                NSString *key;
                NSString *type;
                
                NSArray *keys = [attrNode nodesForXPath:@"b:key" error:&*error];
                if ([keys count] == 1) {
                    key = [[keys objectAtIndex:0]stringValue];
                }
                
                NSArray *values = [attrNode nodesForXPath:@"b:value" error:&*error];
                if ([values count] == 1) {
                    //type = [[[values objectAtIndex:0]attributeForName:@"i:type"]stringValue];
                    NSString *valueXml = [[values objectAtIndex:0]XMLString];
                    [attributeValues setValue:[self parseValue:valueXml] forKey:key];
                }
                
            }
        }
        
        
        
        return model;
    }
    return nil;
}

-(id)parseValue:(NSString *)valueXml
{
    return nil;
}

-(NSString *)decodeXml:(NSString *)xml
{
    return [[xml stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"] stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
}

-(NSDictionary *)getAttributesFromXmlNode:(GDataXMLNode *)node
{
    if (node == nil || [[node children]count] == 0) {
        return nil;
    }
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
    for (GDataXMLNode *attr in [node children]) {
        NSString *key = [attr name];
        NSString *value = [attr stringValue];
        [attributes setValue:value forKey:key];
    }
    return attributes;
}

@end
