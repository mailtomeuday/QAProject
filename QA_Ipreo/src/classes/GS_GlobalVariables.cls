public class GS_GlobalVariables {
    public static Boolean EXECUTED = false;

    // Opportunity Stage Sales Meeting
    public static String OPPSALESMEETING = 'Sales Meeting';

    // Opportunity Stage Quote/Proposal Sent
    public static String OPPPROPOSALSENT = 'Quote/Proposal Sent';

    // Opportunity Stage Contract Pending
    public static String OPPCONTRACTPENDING = 'Contract Pending';

    // Opportunity Stage Closed Won Sales
    public static String OPPCLOSEWONSALES = 'Closed Won Sales';

    // Opportunity Stage Closed Won Verified
    public static String OPPCLOSEDWONVERIFIED = 'Closed Won Verified';

    // Opportunity Stage Closed Lost
    public static String OPPCLOSEDLOST = 'Closed Lost';

    // Opportunity Stage Closed Cancelled
    public static String OPPCLOSEDCANCELLED = 'Closed Cancelled';

    // Opportunity Stage Closed Cancelled Verified
    public static String OPPCLOSEDCANCELLEDVERIFIED = 'Closed Cancelled Verified';

    // Account Status
    // Prospect
    public static String ACCSTATUSPROSPECT = 'Prospect';
    
    // Former Client
    public static String ACCSTATUSFORMERCLIENT = 'Former Client';

    // Customer
    public static String ACCSTATUSCLIENT = 'Client';

    // Standard Entitlement Process
    public static String STANDARDOLA = 'SLA';

    // Case milestone names  --  First Response
    public static String MSFIRSTRESPONSE = 'First Response';

    // Case milestone names  --  Case Ownership
    public static String MSCASEOWNERSHIP = 'Case Ownership';

    // Case milestone names  --  Case First Response Required
    public static String MSCASEFIRSTREQUIRED = 'Case First Response Required';

    // Case milestone names  --  Case First Response Required
    public static String MSCASEFIRSTCOMPLETED = 'Case First Response Completed';

    // NYSE Program Tier = Tier A
    public static String NYSEPROGRAMTIERA = 'Tier A';

    // Opportunity record type develop name----- New Business
    public static String OPPRTNEWBUSINESS = 'New_Business';

    // Opportunity record type Name ----- Renewal
    public static String OPPRTRENEWAL = 'Renewal';

    // Opportunity record type Name ----- Budget
    public static String OPPRTBUDGET = 'Budget';

    // Work order record type name ------ Cancellation
    public static String WOCANCELLATION = 'Cancellation';

    // Opportunity Line Item status picklist value: Lost
    public static String OPPLINEITEMSTATUSLOST = 'Lost';

    // Opportunity Line Item status picklist value:  Cancelled
    public static String OPPLINEITEMSTATUSCANCELLED = 'Cancelled';

    // Case sub type ------ Trial Access Request
    public static String CASESUBTYPETRIALACCESSREQUEST = 'Trial Access Request';

    // Case Origin ------ Email2Case (SalesRequests-IR)
    public static String CASEORIGINSALESREQUESTSIR = 'Email2Case (SalesRequests-IR)';

    // Case Origin ------ Email2Case (Trial Users GMG)
    public static String CASEORIGINTRIALUSERSGMG = 'Email2Case (Trial Users GMG)';

    // Alert custom permission to inhibit the pre-population of the Description field
    public static String INHIBITALERTINGDESCRIPTION = 'Inhibit Alerting Description';

    // Alert Pre-Defaulting Description
    public static String ALERTPREDEFDESCRIPTION = 
                        '1. Current Product(s):  \n\n' +
                        '2. Opportunity $:  \n\n' +
                        '3. Opportunity Product List:  \n\n' +
                        '4. Expiration Date:  \n\n' +
                        '5. Risk:  \n\n' +
                        '6. External Attendee(s):  \n\n' +
                        '7. Executive Summary (limit to 4 sentences):  \n\n' +
                        '8. Next Steps:  \n\n' +
                        '9. Detailed Notes:  \n';

    // Contact object prefix, since this is a standard field, so the prefix can be hard code.
    public static String CONTACTPREFIX = '003';

    // User Asset Status, Active or Inactvie.
    public static String USERASSETACTIVE = 'Active';
    public static String USERASSETINACTIVE = 'Inactive';

    //Profile Name
    public static String SYSTEMADMIN = 'System Administrator';
    public static String OPERATIONSUER = 'Operations User';

}