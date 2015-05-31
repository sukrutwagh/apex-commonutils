@isTest(SeeAllData=false)
global class COM_BatchQueueTest {
	
	private static final String BATCH_CLASSNAME = 'COM_BatchExample';
	private static final String BATCH_QUERY = 'Select Id From User Limit 1';
	
    static testMethod void shouldAddBatchToQueueAndStartExecution() {
        // given
        
        // when
        test.startTest();
        String paramsJSONString = Json.serialize(new List<String>{BATCH_QUERY});
        String jobId = COM_BatchQueue.addJob(BATCH_CLASSNAME, paramsJSONString, null);
        test.stopTest();
        
        // then
        system.assertNotEquals(null, jobId);
        COM_Batch_Queue__c bQueue = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c
                                    from COM_Batch_Queue__c where id = :jobId];
        system.assertEquals(COM_BatchQueue.STATUS_STARTED, bQueue.Status__c);
        system.assertNotEquals(null, bQueue.Apex_JobId__c);  
    }
    
     static testMethod void shouldAddBatchWithScopeToQueueAndStartExecution() {
        // given
        
        // when
        test.startTest();
        String paramsJSONString = Json.serialize(new List<String>{BATCH_QUERY});
        String jobId = COM_BatchQueue.addJob(BATCH_CLASSNAME, paramsJSONString, null,COM_BatchQueue.DEFAULT_JOB_PRIORITY,5);
        test.stopTest();
        
        // then
        system.assertNotEquals(null, jobId);
        COM_Batch_Queue__c bQueue = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c, Scope__c
                                    from COM_Batch_Queue__c where id = :jobId];
        system.assertEquals(COM_BatchQueue.STATUS_STARTED, bQueue.Status__c);
        system.assertEquals(5, bQueue.Scope__c);
        system.assertNotEquals(null, bQueue.Apex_JobId__c);
        
    }
    
    static testMethod void shouldNotStartNewBatchBeforePreviousIsDone() {
        // given
        
        // when
        test.startTest();
        String paramsJSONString = Json.serialize(new List<String>{BATCH_QUERY});
        String jobId = COM_BatchQueue.addJob(BATCH_CLASSNAME, paramsJSONString, null);
        String dependentJobId = COM_BatchQueue.addJob(BATCH_CLASSNAME, paramsJSONString, jobId);
        test.stopTest();
        
        // then
        system.assertNotEquals(null, jobId);
        system.assertNotEquals(null, dependentJobId);
        COM_Batch_Queue__c bQueue = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c
                                    from COM_Batch_Queue__c where id = :dependentJobId];
        system.assertEquals(COM_BatchQueue.STATUS_INITIAL, bQueue.Status__c);
        system.assertEquals(null, bQueue.Apex_JobId__c);
        
        COM_BatchQueue bq = new COM_BatchQueue();
        bq.execute(null);
        bQueue = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c from COM_Batch_Queue__c where id = :dependentJobId];
        system.assertEquals(COM_BatchQueue.STATUS_STARTED, bQueue.Status__c);
        system.assertNotEquals(null, bQueue.Apex_JobId__c);
    }
    
    static testMethod void shouldExecuteBatchesInOrder() {
        // given
        List<COM_Batch_Queue__c> jobsStarted = new List<COM_Batch_Queue__c>();
        List<COM_Batch_Queue__c> jobsQueued = new List<COM_Batch_Queue__c>();
        String paramsJSONString = Json.serialize(new List<String>{BATCH_QUERY});
        for (Integer i=0; i< COM_BatchQueue.MAX_NUMBER_OF_CONCURRENT_BATCH_PROCESSES; i++){
            jobsStarted.add(new COM_Batch_Queue__c(Batch_Class_Name__c = BATCH_CLASSNAME,Parameters_JSON__c = paramsJSONString,Priority__c = COM_BatchQueue.DEFAULT_JOB_PRIORITY,
                                             Status__c = COM_BatchQueue.STATUS_INITIAL));
            jobsQueued.add(new COM_Batch_Queue__c(Batch_Class_Name__c = BATCH_CLASSNAME,Parameters_JSON__c = paramsJSONString,Priority__c = COM_BatchQueue.DEFAULT_JOB_PRIORITY,
                                             Status__c = COM_BatchQueue.STATUS_INITIAL));
        }
        insert jobsStarted;
        // when
        test.startTest();
        insert jobsQueued;
        paramsJSONString = Json.serialize(new List<String>{'Unit_Effort__c', 'Month_Applies_To__c', 'Forecast_Unit__c'});
        String jobId = COM_BatchQueue.addJob(BATCH_CLASSNAME, paramsJSONString, null,COM_BatchQueue.DEFAULT_JOB_PRIORITY,5);
        //String jobId = COM_BatchQueue.addJob('PRA_WorkedEffortBatch', null, null);
        test.stopTest();
        
        // then
        jobsStarted = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c
                                    from COM_Batch_Queue__c where id in :jobsStarted];
        jobsQueued = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c
                                    from COM_Batch_Queue__c where id in :jobsQueued];
                                    
        for (Integer i=0; i< COM_BatchQueue.MAX_NUMBER_OF_CONCURRENT_BATCH_PROCESSES; i++){
            system.assertEquals(COM_BatchQueue.STATUS_STARTED, jobsStarted.get(i).Status__c);
            system.assertEquals(COM_BatchQueue.STATUS_INITIAL, jobsQueued.get(i).Status__c);
        }
    }
    // * Test error handling: when wrong class name is provided
       // * Test error handling: when parent job finished with error
    
    static testMethod void shouldGetErrorOnWrongClass() {
        // given
        
        // when
        test.startTest();
        String paramsJSONString = Json.serialize(new List<String>{BATCH_QUERY});
        String jobId            = COM_BatchQueue.addJob('WrongClassName', paramsJSONString, null);        
        String dependentJobId   = COM_BatchQueue.addJob(BATCH_CLASSNAME, paramsJSONString, jobId);
        test.stopTest();
        
        // then
        system.assertNotEquals(null, jobId);
        system.assertNotEquals(null, dependentJobId);
        List<COM_Batch_Queue__c> bQueue = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c
                                    from COM_Batch_Queue__c where id in (:dependentJobId, :jobId)];
        for(COM_Batch_Queue__c job : bQueue){
            if (job.id == jobId){
                system.assertEquals(COM_BatchQueue.STATUS_ERROR, job.Status__c);
                system.debug('--Error msg: ' + job.Exception__c);
            }
            else {
                system.assertEquals(COM_BatchQueue.STATUS_ERROR, job.Status__c);
                system.debug('--Error msg: ' + job.Exception__c);
                system.assertEquals(COM_BatchQueue.ERROR_PARENT_JOB_FINISHED_WITH_ERROR, job.Exception__c);
            }
        }
    }
    
    //Test behaviour when apex job (batch) ends with error (or it's aborded)
    
     static testMethod void shouldGetApexJobError() {
        // given
        String jobId;
        try {
            // when
            test.startTest();
            // add job with wrong parametest
            String paramsJSONString = Json.serialize(new List<String>{null});
            jobId = COM_BatchQueue.addJob(BATCH_CLASSNAME, paramsJSONString, null);
            
            // on stopTest we will get exception from execeution of batch process (from other thread)
            test.stopTest();
            
            // then
            
        }
        catch (Exception ex){
            system.debug('--Caught exception: ' + ex);
        }
        
        system.assertNotEquals(null, jobId);
        COM_Batch_Queue__c bQueue = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c
                                    from COM_Batch_Queue__c where id = :jobId];
        system.assertEquals(COM_BatchQueue.STATUS_STARTED, bQueue.Status__c);
        system.assertNotEquals(null, bQueue.Apex_JobId__c);
        
        // Although there was exception on execution of apex job it still is in preparation status
        // that's why You have to manuly abort him
        system.abortJob(bQueue.Apex_JobId__c);
        
        // update status as job finshed with error
        COM_BatchQueue bq = new COM_BatchQueue();
        bq.execute(null);
        bQueue = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c
                                    from COM_Batch_Queue__c where id = :jobId];
        AsyncApexJob aaj = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,ExtendedStatus,TotalJobItems
                                    FROM AsyncApexJob WHERE id = :bQueue.Apex_JobId__c];
        system.debug('-- AAJ: ' + aaj);
        system.assertEquals('Aborted', aaj.Status);
        system.assertEquals(COM_BatchQueue.STATUS_ERROR, bQueue.Status__c);
        system.debug('--Apex Job error msg: ' + bQueue.Exception__c);
        system.assertNotEquals(null, bQueue.Apex_JobId__c);
    }
    
    //Test error handling: add job with not existing parent 
    
     static testMethod void shouldFailOnParentJobNotFound() {
        // given
        
        // when
        test.startTest();
        String paramsJSONString = Json.serialize(new List<String>{BATCH_QUERY});
        String delJobId = COM_BatchQueue.addJob(BATCH_CLASSNAME, paramsJSONString, null);
        delete [select id from COM_Batch_Queue__c where id = :delJobId];
        String jobId = COM_BatchQueue.addJob(BATCH_CLASSNAME, paramsJSONString, delJobId);
        test.stopTest();
        
        // then
        system.assertNotEquals(null, jobId);
        COM_BatchQueue bq = new COM_BatchQueue();
        bq.execute(null);
        
        COM_Batch_Queue__c bQueue = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, LastModifiedDate, 
                                        Parameters_JSON__c, Priority__c, Status__c
                                    from COM_Batch_Queue__c where id = :jobId];
        system.debug('--job: ' + bQueue);
        system.assertEquals(COM_BatchQueue.STATUS_ERROR, bQueue.Status__c);
        
        // check static function
        String inStr = '1234567890';
        system.assertEquals(9,COM_BatchQueue.cutStringToMaxSize(inStr, 9).length());
    }
    
     //TODO:
     static testMethod void shouldExecutionOnCOM_BatchQueueable() {
        // given
        
        // when
        test.startTest();
      
        String paramsJSONString = Json.serialize(new List<String>{BATCH_QUERY});
        COM_Batch_Queue__c batchQueue = new COM_Batch_Queue__c(Batch_Class_Name__c = BATCH_CLASSNAME,Parameters_JSON__c = paramsJSONString,
                                      Status__c ='Waiting',Priority__c = 5 );
        insert batchQueue;
        
        COM_BatchQueueable batch=new COM_BatchQueueable();
        batch.query = BATCH_QUERY;
        batch.setBatchParameters(batchQueue.Parameters_JSON__c);           
        
        String apexJobId;
        apexJobId = database.executebatch(batch);            
        test.stopTest();
        
    }
}