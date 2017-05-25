trigger GS_EmailMessageTrigger on EmailMessage (before insert, after insert, before update, after update) {
    new GS_Triggers()
    
    // after insert
    .bind(GS_Triggers.Evt.afterinsert,new GS_EmailMessageUpdateSLATHandler())
    
    
    .manage();
}