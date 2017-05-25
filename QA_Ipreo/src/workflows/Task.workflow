<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Activity_Type</fullName>
        <field>Activity_Type__c</field>
        <formula>TEXT( Type )</formula>
        <name>Set Activity Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%5BTask%5D Set Activity Type</fullName>
        <actions>
            <name>Set_Activity_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISNEW() ||  ISCHANGED( Type )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
