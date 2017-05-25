<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Send_Closed_Notification_to_Team_Member</fullName>
        <description>[Account] Send Closed Notification to Team Member</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Primary Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Primary Analyst</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Primary Corporate Director</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Primary GMI Analyst</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Primary Product Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Primary Sales Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Primary Sales Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Primary Sales Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Secondary Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Secondary Analyst</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Secondary Corporate Director</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Secondary GMI Analyst</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Secondary Product Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Secondary Sales Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Secondary Sales Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Secondary Sales Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Team Lead GMI Analyst</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Work_Orders/Work_Order_Closed_Notification_To_Account_Team_Member</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Issuer_Name_Diff_Date_to_Today</fullName>
        <field>Issuer_Name_Diff_Date__c</field>
        <formula>IF( Issuer_Name__c &lt;&gt; Name, Now(), null)</formula>
        <name>Update Issuer Name Diff Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%5BAccount%5D Send Notification To Team Member</fullName>
        <actions>
            <name>Account_Send_Closed_Notification_to_Team_Member</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send notification when work order status was changed to closed</description>
        <formula>ISCHANGED(Tracking_Number__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Issuer Name Diff Date</fullName>
        <actions>
            <name>Update_Issuer_Name_Diff_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISCHANGED( Issuer_Name__c ) ||  $Setup.Account__c.Dataupdate_with_Issuer_File__c ) &amp;&amp; IF(Issuer_Name__c = Name, 	TRUE, 	IF(PRIORVALUE(Issuer_Name__c ) &lt;&gt; Name,   		IF(ISBLANK(PRIORVALUE(Issuer_Name__c )), 			TRUE, 			IF(Issuer_Name__c &lt;&gt; Name &amp;&amp; ISBLANK(Issuer_Name_Diff_Date__c), 				TRUE, 				FALSE) 		), 	TRUE 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
