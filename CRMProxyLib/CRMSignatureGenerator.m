//
//  CRMSignatureGenerator.m
//  SignatureGenerationPrototype
//
//  Created by Steven Oxley on 4/18/12.
//  Copyright (c) 2012 Sonoma Partners, LLC. All rights reserved.
//

#import "CRMSignatureGenerator.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+Base64.h"
#import "GDataXmlNode.h"

@implementation CRMSignatureGenerator

- (NSString *)hashTimestampXml:(NSData *)xmlBytes
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSString *hash = nil;
    unsigned char *computedData = CC_SHA1([xmlBytes bytes], [xmlBytes length], digest);
    if (computedData) {
        NSData *digestData = [NSData dataWithBytes:computedData length:CC_SHA1_DIGEST_LENGTH];
        hash = [digestData base64EncodedString];
    }
    return hash;
}

- (GDataXMLElement *)createTimestampNodeWithId:(NSString *)id atTime:(NSDate *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSError *error;
    GDataXMLElement *timestampElement = [[GDataXMLElement alloc]
                                         initWithXMLString:[NSString stringWithFormat:@"<u:Timestamp xmlns:u=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" u:Id=\"%@\"><u:Created>%@</u:Created><u:Expires>%@</u:Expires></u:Timestamp>",
                                                            id, 
                                                            [formatter stringFromDate:time],
                                                            [formatter stringFromDate:[time dateByAddingTimeInterval:300.0]]]
                                         error:&error];
    return timestampElement;
}

- (GDataXMLElement *)createSignatureNodeWithId:(NSString *)id andReferenceData:(NSData *)referenceData andKeyData:(NSData *)keyData andKeyInfoReference:(NSString *)keyInfoReference
{
    GDataXMLElement *signature = [[GDataXMLElement alloc] initWithXMLString:@"<Signature xmlns=\"http://www.w3.org/2000/09/xmldsig#\"/>" error:nil];
    
    NSString *firstElementString = [NSString stringWithFormat:@"<SignedInfo xmlns=\"http://www.w3.org/2000/09/xmldsig#\"><CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"></CanonicalizationMethod><SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#hmac-sha1\"></SignatureMethod><Reference URI=\"#_0\"><Transforms><Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"></Transform></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"></DigestMethod><DigestValue>%@</DigestValue></Reference></SignedInfo>", [self hashTimestampXml:referenceData]];
    
    GDataXMLElement *firstElement = [[GDataXMLElement alloc] initWithXMLString:firstElementString error:nil];
    //NSLog(@"%@", firstElementString);
    
    NSData *xmlData = [firstElementString dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char macOut[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, keyData.bytes, keyData.length, xmlData.bytes, xmlData.length, macOut);
    NSData *signatureData = [NSData dataWithBytes:macOut length:CC_SHA1_DIGEST_LENGTH];
    GDataXMLElement *signatureValue = [[GDataXMLElement alloc] initWithXMLString:[NSString stringWithFormat:@"<SignatureValue>%@</SignatureValue>", [signatureData base64EncodedString]] error:nil];
    
    [signature addChild:firstElement];
    [signature addChild:signatureValue];
    GDataXMLElement *keyInfo = [GDataXMLElement elementWithName:@"KeyInfo"];
    [keyInfo addChild:[[GDataXMLElement alloc] initWithXMLString:keyInfoReference error:nil]];
    
    [signature addChild:keyInfo];
    
    return signature;
}

@end
