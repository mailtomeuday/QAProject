<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_User_Status_to_Active</fullName>
        <field>User_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set User Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_User_Status_to_Inactive</fullName>
        <field>User_Status__c</field>
        <literalValue>Inactive</literalValue>
        <name>Set User Status to Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%5BContact%5D Update User Status to Active</fullName>
        <actions>
            <name>Set_User_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>No_of_Active_Assets__c &gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%5BContact%5D Update User Status to Inactive</fullName>
        <actions>
            <name>Set_User_Status_to_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>No_of_Active_Assets__c = 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
