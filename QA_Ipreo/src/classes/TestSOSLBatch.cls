public class TestSOSLBatch implements Database.Batchable<Object> {

    public Iterable<Object> start(Database.BatchableContext bc) {
        return (Iterable<Object>)[FIND '.com' IN EMAIL FIELDS RETURNING Account (Id, Name), Contact(Id, Name), Lead(Id, Name)];
    }

    public void execute(Database.BatchableContext bc, List<Object> scope) {
        System.debug(JSON.serializePretty(scope));
    }

    public void finish(Database.BatchableContext bc) {

    }
}