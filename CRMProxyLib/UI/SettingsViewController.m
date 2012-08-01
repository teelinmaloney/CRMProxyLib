//
//  SettingsViewController.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "CRMContact.h"
#import "CRMOrgService.h"
#import "CRMPost.h"
#import "CRMTime.h"

@interface SettingsViewController() {
@private
    CRMOrgService *service_;
}

- (void)runTests;
- (void)testCreate;
- (void)testDelete:(NSString *)entityId;
- (void)testEntityMetadata;
- (void)testRetrieve;
- (void)testRetrieveMultiple;
- (void)testUpdate:(NSString *)entityId;
- (void)testWhoAmI;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        service_ = [[CRMOrgService alloc]
            initWithOrganizationServiceUrl:@"https://int.crmqa.sonomapartners.com/arwqaclient/XRMServices/2011/Organization.svc" 
            andSecureTokenServiceUrl:@"https://federation.crmqa.sonomapartners.com/adfs/services/trust/13/usernamemixed"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)test:(id)sender
{
    [error setText:@""];
    
    [service_ setUsername:[NSString stringWithFormat:@"%@\\%@", [domain text], [username text]]];
    [service_ setPassword:[password text]];
    
    if ([[service_ username]length] != 0 && [[service_ password]length] != 0) {
        [self runTests];
    } else {
        [error setText:@"Please enter username and password."];
    }
}

#pragma mark - Test Methods

- (void)runTests
{
    [self testCreate];
    //[self testUpdate:@"c1603050-a5da-e111-8298-00101828c71a"];
    //[self testRetrieve];
    //[self testRetrieveMultiple];
    //[self testWhoAmI];
    //[self testEntityMetadata];
    //[self testSelector];
}

- (void)testCreate
{
//    CRMPost *post = [[CRMPost alloc]init];
//    post.text = @"Test from OrgService";
//    post.regardingobjectid = [[CRMEntityReference alloc]
//                              initWithEntityName:@"systemuser" andId:@"FC6A0980-A1FF-DE11-A75B-00101826F7F4"];
//    post.source = [NSNumber numberWithInt:2];
//    
//    NSString *response = [service_ create:post];
    CRMContact *contact = [[CRMContact alloc]init];
    [contact setFirstname:@"Joe"];
    [contact setLastname:@"Framework"];
    
    NSString *response = [service_ create:contact];
    NSLog(@"\n\nCreate Response: \n%@", response);
    
    [self testUpdate:response];
    [self testDelete:response];
}

- (void)testDelete:(NSString *)entityId
{
    CRMContact *contact = [[CRMContact alloc]init];
    [contact setContactid:(Guid *)entityId];
    
    [service_ delete:contact];
}

- (void)testRetrieve
{
    NSArray *attributes = [[NSArray alloc]initWithObjects:@"sonoma_name", nil];
    CRMTime *time = [service_ retrieve:@"sonoma_time" byId:@"AF11EF47-D2D4-E111-AA06-0026B9F9E50C" forClassName:@"CRMTime" withAttributes:attributes];
    NSLog(@"Id: %@, Detail: %@", [time id], [time sonoma_name]);
}

- (void)testRetrieveMultiple
{
    NSString *fetch = @"<fetch mapping=\"logical\" count=\"5\">"
	"<entity name=\"sonoma_time\">"
    "<all-attributes />"
    "<order attribute=\"createdon\" descending=\"true\" />"
    "<filter type='and'>"
    "<condition attribute='ownerid' operator='eq-userid' />"
    "</filter>"
	"</entity>"
    "</fetch>";
    
    NSArray *posts = [service_ retrieveMultiple:fetch forClassName:@"CRMTime"];
    NSLog(@"%d", [posts count]);
}

- (void)testUpdate:(NSString *)entityId
{
    CRMContact *contact = [[CRMContact alloc]init];
    [contact setContactid:(Guid *)entityId];
    [contact setMiddlename:@"Q"];
    
    [service_ update:contact];
}

- (void)testWhoAmI
{
    NSString *request = @"<Execute xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
    "<request i:type='c:WhoAmIRequest' xmlns:b='http://schemas.microsoft.com/xrm/2011/Contracts'"
    " xmlns:i='http://www.w3.org/2001/XMLSchema-instance'"
    " xmlns:c='http://schemas.microsoft.com/crm/2011/Contracts'>"
    "<b:Parameters xmlns:d='http://schemas.datacontract.org/2004/07/System.Collections.Generic'/>"
    "<b:RequestId i:nil='true'/>"
    "<b:RequestName>WhoAmI</b:RequestName>"
    "</request></Execute>";
    
    NSString *response = [service_ execute:request];
    NSLog(@"\n\nWhoAmI Response: \n%@", response);
}

- (void)testEntityMetadata
{
    NSString *request = @"<Execute xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
    "<request i:type='b:RetrieveEntityRequest' xmlns:b='http://schemas.microsoft.com/xrm/2011/Contracts'"
    " xmlns:i='http://www.w3.org/2001/XMLSchema-instance'>"
    "<b:Parameters xmlns:d='http://schemas.datacontract.org/2004/07/System.Collections.Generic'>"
    "  <b:KeyValuePairOfstringanyType>"
    "    <d:key>LogicalName</d:key>"
    "    <d:value xmlns:e='http://www.w3.org/2001/XMLSchema' i:type='e:string'>sonoma_time</d:value>"
    "  </b:KeyValuePairOfstringanyType>"
    "  <b:KeyValuePairOfstringanyType>"
    "    <d:key>RetrieveAsIfPublished</d:key>"
    "    <d:value xmlns:e='http://www.w3.org/2001/XMLSchema' i:type='e:boolean'>false</d:value>"
    "  </b:KeyValuePairOfstringanyType>"
    "  <b:KeyValuePairOfstringanyType>"
    "    <d:key>EntityFilters</d:key>"
    "    <d:value xmlns:m='http://schemas.microsoft.com/xrm/2011/Metadata' i:type='m:EntityFilters'>Entity Attributes</d:value>"
    "  </b:KeyValuePairOfstringanyType>"
    "  <b:KeyValuePairOfstringanyType>"
    "    <d:key>MetadataId</d:key>"
    "    <d:value xmlns:e='http://schemas.microsoft.com/2003/10/Serialization/' i:type='e:guid'>00000000-0000-0000-0000-000000000000</d:value>"
    "  </b:KeyValuePairOfstringanyType>"
    "</b:Parameters>"
    "<b:RequestId i:nil='true'/>"
    "<b:RequestName>RetrieveEntity</b:RequestName>"
    "</request></Execute>";
    
    NSString *response = [service_ execute:request];
    NSLog(@"\n\nRetrieve Entity Response: \n%@", response);    
}

@end
