global virtual with sharing class COM_BatchQueueable implements Database.Batchable <sObject>{
    
    global String query;
    global virtual void  setBatchParameters(String parametersJSON){}
    global virtual Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global virtual void execute(Database.BatchableContext BC, List<sObject> scope){}
    global virtual void finish(Database.BatchableContext BC){}

}