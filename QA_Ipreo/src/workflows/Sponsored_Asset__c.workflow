<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Active_Flag_To_True</fullName>
        <field>Active__c</field>
        <literalValue>1</literalValue>
        <name>Set Active Flag to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Active_Flag_to_False</fullName>
        <field>Active__c</field>
        <literalValue>0</literalValue>
        <name>Set Active Flag to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%5BSponsored Asset%5D Set Active Flag to False</fullName>
        <actions>
            <name>Set_Active_Flag_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.Status</field>
            <operation>equals</operation>
            <value>Inactive</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>%5BSponsored Asset%5D Set Active flag to True</fullName>
        <actions>
            <name>Set_Active_Flag_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.Status</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
