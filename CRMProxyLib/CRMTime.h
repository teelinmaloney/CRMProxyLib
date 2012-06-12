
#import <Foundation/Foundation.h>
#import "CRMEntity.h"
#import "CRMEntityReference.h"

@interface CRMTime : NSObject <CRMEntity>
@property (nonatomic, strong) CRMEntityReference* createdby;
@property (nonatomic, strong) NSDate* createdon;
@property (nonatomic, strong) CRMEntityReference* createdonbehalfby;
@property (nonatomic, strong) NSNumber* importsequencenumber;
@property (nonatomic, strong) CRMEntityReference* modifiedby;
@property (nonatomic, strong) NSDate* modifiedon;
@property (nonatomic, strong) CRMEntityReference* modifiedonbehalfby;
@property (nonatomic, strong) NSDate* overriddencreatedon;
@property (nonatomic, strong) NSObject* ownerid;
@property (nonatomic, strong) CRMEntityReference* owningbusinessunit;
@property (nonatomic, strong) CRMEntityReference* owningteam;
@property (nonatomic, strong) CRMEntityReference* owninguser;
@property (nonatomic, strong) NSString* sonoma_approvalreason;
@property (nonatomic, strong) NSDate* sonoma_approveddate;
@property (nonatomic, strong) NSNumber* sonoma_billable;
@property (nonatomic, strong) CRMEntityReference* sonoma_caseid;
@property (nonatomic, strong) NSString* sonoma_description;
@property (nonatomic, strong) NSNumber* sonoma_hours;
@property (nonatomic, strong) NSString* sonoma_invoicenumber;
@property (nonatomic, strong) NSNumber* sonoma_invoicetype;
@property (nonatomic, strong) CRMEntityReference* sonoma_itemid;
@property (nonatomic, strong) NSNumber* sonoma_location;
@property (nonatomic, strong) NSString* sonoma_name;
@property (nonatomic, strong) NSNumber* sonoma_onsite;
@property (nonatomic, strong) NSDate* sonoma_pmapproveddate;
@property (nonatomic, strong) CRMEntityReference* sonoma_projectid;
@property (nonatomic, strong) CRMEntityReference* sonoma_projecttaskid;
@property (nonatomic, strong) CRMEntityReference* sonoma_sonomainvoiceid;
@property (nonatomic, strong) NSNumber* sonoma_source;
@property (nonatomic, strong) CRMEntityReference* sonoma_timecategoryid;
@property (nonatomic, strong) NSDate* sonoma_timedate;
@property (nonatomic, strong) Guid* sonoma_timeid;
@property (nonatomic, strong) CRMEntityReference* sonoma_timeoffid;
@property (nonatomic, strong) CRMEntityReference* sonoma_timerecurrenceid;
@property (nonatomic, strong) NSObject* statecode;
@property (nonatomic, strong) NSNumber* statuscode;
@property (nonatomic, strong) NSNumber* versionnumber;
@end
