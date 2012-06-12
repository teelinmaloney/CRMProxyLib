#import "CRMTime.h"

@implementation CRMTime
@synthesize createdby = _createdby;
@synthesize createdon = _createdon;
@synthesize createdonbehalfby = _createdonbehalfby;
@synthesize importsequencenumber = _importsequencenumber;
@synthesize modifiedby = _modifiedby;
@synthesize modifiedon = _modifiedon;
@synthesize modifiedonbehalfby = _modifiedonbehalfby;
@synthesize overriddencreatedon = _overriddencreatedon;
@synthesize ownerid = _ownerid;
@synthesize owningbusinessunit = _owningbusinessunit;
@synthesize owningteam = _owningteam;
@synthesize owninguser = _owninguser;
@synthesize sonoma_approvalreason = _sonoma_approvalreason;
@synthesize sonoma_approveddate = _sonoma_approveddate;
@synthesize sonoma_billable = _sonoma_billable;
@synthesize sonoma_caseid = _sonoma_caseid;
@synthesize sonoma_description = _sonoma_description;
@synthesize sonoma_hours = _sonoma_hours;
@synthesize sonoma_invoicenumber = _sonoma_invoicenumber;
@synthesize sonoma_invoicetype = _sonoma_invoicetype;
@synthesize sonoma_itemid = _sonoma_itemid;
@synthesize sonoma_location = _sonoma_location;
@synthesize sonoma_name = _sonoma_name;
@synthesize sonoma_onsite = _sonoma_onsite;
@synthesize sonoma_pmapproveddate = _sonoma_pmapproveddate;
@synthesize sonoma_projectid = _sonoma_projectid;
@synthesize sonoma_projecttaskid = _sonoma_projecttaskid;
@synthesize sonoma_sonomainvoiceid = _sonoma_sonomainvoiceid;
@synthesize sonoma_source = _sonoma_source;
@synthesize sonoma_timecategoryid = _sonoma_timecategoryid;
@synthesize sonoma_timedate = _sonoma_timedate;
@synthesize sonoma_timeid = _sonoma_timeid;
@synthesize sonoma_timeoffid = _sonoma_timeoffid;
@synthesize sonoma_timerecurrenceid = _sonoma_timerecurrenceid;
@synthesize statecode = _statecode;
@synthesize statuscode = _statuscode;
@synthesize versionnumber = _versionnumber;

-(NSString *)entityName
{
    return @"sonoma_time";
}

-(NSString *)id
{
    return _sonoma_timeid;
}
@end
