<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Asset_External_Id</fullName>
        <field>AccountProductRegionKey__c</field>
        <formula>CASESAFEID(AccountId ) + &apos;_&apos; +   CASESAFEID(Product2Id) + &apos;_&apos; + TEXT(Product_Region__c)</formula>
        <name>Set Asset External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Active</fullName>
        <field>Status</field>
        <literalValue>Active</literalValue>
        <name>Set Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Inactive</fullName>
        <field>Status</field>
        <literalValue>Inactive</literalValue>
        <name>Set Status to Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%5BAsset%5D Update External Id</fullName>
        <actions>
            <name>Set_Asset_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Asset.AccountProductRegionKey__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>%5BAsset%5D Update Status to Active</fullName>
        <actions>
            <name>Set_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>No_of_Active_Licenses__c &gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%5BAsset%5D Update Status to Inactive</fullName>
        <actions>
            <name>Set_Status_to_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>No_of_Active_Licenses__c = 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
