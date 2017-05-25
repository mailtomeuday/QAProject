<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_to_Active_When_Created</fullName>
        <description>Update Status to true if 
Start_Date__c &lt; DATEVALUE(NOW() and End_Date__c &gt; DATEVALUE(NOW()</description>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set to Active When Created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_to_Inactive_When_Created</fullName>
        <field>Status__c</field>
        <literalValue>Inactive</literalValue>
        <name>Set to Inactive When Created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%5BLicense%5D Update Status to Active When Created</fullName>
        <actions>
            <name>Set_to_Active_When_Created</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset_License__c.Auto_Populated_Active_Status__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Initialize license status when it&apos;s created. Set to Active.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%5BLicense%5D Update Status to Inactive When Created</fullName>
        <actions>
            <name>Set_to_Inactive_When_Created</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset_License__c.Auto_Populated_Active_Status__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Initialize license status when it&apos;s created. Set to Inactive.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
