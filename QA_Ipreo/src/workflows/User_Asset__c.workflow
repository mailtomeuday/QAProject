<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Is_Sponsored_User</fullName>
        <field>Is_Sponsored_User__c</field>
        <literalValue>1</literalValue>
        <name>Update Is Sponsored User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Denote Sponsored User</fullName>
        <actions>
            <name>Update_Is_Sponsored_User</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate value when a value is placed in the Sponsored User Account field</description>
        <formula>!ISBLANK(Sponsored_Users_Account__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
