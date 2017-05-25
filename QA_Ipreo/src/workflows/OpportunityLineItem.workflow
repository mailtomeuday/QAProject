<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Revenue_Delta_Type_to_Downtick</fullName>
        <field>Revenue_Delta_Type__c</field>
        <literalValue>Downtick</literalValue>
        <name>Set Revenue Delta Type to Downtick</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Revenue_Delta_Type_to_Flat</fullName>
        <field>Revenue_Delta_Type__c</field>
        <literalValue>Flat</literalValue>
        <name>Set Revenue Delta Type to Flat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Revenue_Delta_Type_to_Uptick</fullName>
        <field>Revenue_Delta_Type__c</field>
        <literalValue>Uptick</literalValue>
        <name>Set Revenue Delta Type to Uptick</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%5BOpportunity Product%5D Set Net New Business to Downtick</fullName>
        <actions>
            <name>Set_Revenue_Delta_Type_to_Downtick</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Opportunity Product:
IF Revenue Delta &lt; 0, THEN Revenue Delta Type = &quot;Downtick&quot;</description>
        <formula>Net_New_Business__c &lt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%5BOpportunity Product%5D Set Net New Business to Flat</fullName>
        <actions>
            <name>Set_Revenue_Delta_Type_to_Flat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Opportunity Product:
IF Revenue Delta = 0, THEN Revenue Delta Type = &quot;Flat&quot;</description>
        <formula>Net_New_Business__c = 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%5BOpportunity Product%5D Set Net New Business to Uptick</fullName>
        <actions>
            <name>Set_Revenue_Delta_Type_to_Uptick</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Opportunity Product:
IF Revenue Delta &gt; 0, THEN Revenue Delta Type = &quot;Uptick&quot;</description>
        <formula>Net_New_Business__c &gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
