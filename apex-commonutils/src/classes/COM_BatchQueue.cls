/*
This class will be scheduled to run every 5 minutes

System.schedule('BatchQueue-0', '0 5 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-1', '0 10 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-2', '0 15 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-3', '0 20 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-4', '0 25 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-5', '0 30 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-6', '0 35 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-7', '0 40 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-8', '0 45 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-9', '0 50 * * * ?', new COM_BatchQueue());
System.schedule('BatchQueue-10', '0 55 * * * ?', new COM_BatchQueue());

*/
global without sharing class COM_BatchQueue implements Schedulable{
    
    public static Integer MAX_NUMBER_OF_CONCURRENT_BATCH_PROCESSES = 5;
    public static String STATUS_INITIAL     = 'Waiting';
    public static String STATUS_ERROR       = 'Error';
    public static String STATUS_STARTED     = 'Execution';
    public static String STATUS_COMPLETED   = 'Completed';
    public static String STATUS_COMPLETED_WITH_ERRORS   = 'Completed with Errors';
    
    // error messages
    public static String ERROR_PARENT_JOB_NOT_FOUND = 'Dependent job has not been found';
    public static String ERROR_PARENT_JOB_FINISHED_WITH_ERROR = 'Dependent job had finished with error';
    public static String ERROR_APEX_JOB_NOT_FOUND = 'Batch process, not found';
    
    
    public static Integer DEFAULT_JOB_PRIORITY = 5;
    
    public static String addJob (String className, String  listOfParameters, String listOfDependedJobIds){
        return addJob(className, listOfParameters, listOfDependedJobIds, DEFAULT_JOB_PRIORITY);
    }
    public static String addJob (String className, String  listOfParameters, String listOfDependedJobIds, Integer priority){
        return addJob ( className, listOfParameters, listOfDependedJobIds, priority, null);
    }
    public static String addJob (String className, String  listOfParameters, String listOfDependedJobIds, Integer priority, Integer scope){
        COM_Batch_Queue__c batchQueue = new COM_Batch_Queue__c(Batch_Class_Name__c = className,Parameters_JSON__c = listOfParameters,
                                        Dependent_Job_List__c = listOfDependedJobIds, Priority__c = priority, Status__c = STATUS_INITIAL,
                                        scope__c = scope);
        insert batchQueue;
        executeQueuedJobs();
        
        return batchQueue.id;
    }
    
    global void execute(SchedulableContext sc) {
        executeQueuedJobs();
    }
    public static void executeQueuedJobs(){
        Integer noOfSlots = getNumberOfJobsSlots();
        
        try {
            updateStatusOfJobs ();
        }
        catch (Exception ex){
            system.debug(ex);
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, 'Error occured during updating status of queued jobs: ' + ex));
        }
        
        if (noOfSlots > 0){
            List<COM_Batch_Queue__c> jobsList = getListOfQueuedJobs(noOfSlots);
            for (COM_Batch_Queue__c job : jobsList){
                executeJob(job);
            }
        }
    }
    private static List<COM_Batch_Queue__c> getListOfQueuedJobs (Integer noOfJobs){
        List<COM_Batch_Queue__c> retVal = new List<COM_Batch_Queue__c> ();
        
        // get list of all waiting jobs
        List<COM_Batch_Queue__c> waitingJobs = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, CreatedDate, Dependent_Job_List__c, Exception__c, 
                                                    LastModifiedDate,Parameters_JSON__c, Priority__c, Status__c, scope__c
                                                from COM_Batch_Queue__c where Status__c = 'Waiting'
                                                order by Priority__c , LastModifiedDate, CreatedDate];
        Integer noJobsFound = 0;
        Map <Id, List<String>> dependentJobs = new Map <Id, List<String>> (); // map for checking if dependent jobs had finished
        
        // find the jobs which should be executed
        // jobs will be added to list only if there are no dependent jobs
        // if there will be found sufficient number of no dependent jobs - this will be return
        // otherewise check will be done to see if dependent job can be started
        
        for (Integer i=0; i<waitingJobs.size() &&  noJobsFound < noOfJobs ; i++){
            COM_Batch_Queue__c job = waitingJobs.get(i);
            
            if(job.Dependent_Job_List__c == null || job.Dependent_Job_List__c == ''){
                if (dependentJobs.size() == 0){ // add jobs only if there so far was no one which is dependent
                    retVal.add(job);
                    noJobsFound++;
                }
            }
            else{
                List<String> dependentList = job.Dependent_Job_List__c.split(',');
                dependentJobs.put(job.id, dependentList);
            }
        }
        
        // if there where queued dependent jobs, check to gain queued jobs. Results jobs list have to be done once more
        if (dependentJobs.size() > 0){
            retVal = new List<COM_Batch_Queue__c> (); 
            noJobsFound = 0;
            
            Map <Id, Boolean> dependentJobFinished = checkIfJobCanBeStarted (dependentJobs);
            
            for (Integer i=0; i<waitingJobs.size() &&  noJobsFound < noOfJobs ; i++){
                COM_Batch_Queue__c job = waitingJobs.get(i);
            
                if(job.Dependent_Job_List__c == null || job.Dependent_Job_List__c == ''){
                    retVal.add(job);
                    noJobsFound++;
                }
                else{
                    if (dependentJobFinished.get(job.id)){
                        retVal.add(job);
                        noJobsFound++;
                    }
                }
            }
        }
        
        return retVal;
    }
    private static Map <Id, Boolean> checkIfJobCanBeStarted(Map <Id, List<String>> checkedJobs){
        Map <Id, Boolean> retVal = new Map <Id, Boolean> ();
        Set<String> dependentIds = new Set<String>();
        
        for (String key : checkedJobs.keySet()){
            for(String jobId : checkedJobs.get(key)){
                dependentIds.add(jobId);
            }
        }
        Map<Id, COM_Batch_Queue__c> depedentJobs = new Map<Id, COM_Batch_Queue__c> ([select Id, Status__c from COM_Batch_Queue__c where id in :dependentIds]);
        
        // list of jobs which depedent (parent jobs) had finshed with error, their status has to be aslo updated
        Map <Id, String> dependentJobHadFinishedWithError = new Map <Id, String>(); 
        
        // check if all dependent jobs have finished
        for (String key : checkedJobs.keySet()){
            Boolean allJobsCompleted = true;
            for(String dependentJobId : checkedJobs.get(key)){
                if (depedentJobs.containsKey(dependentJobId)){
                    if (depedentJobs.get(dependentJobId).Status__c != 'Completed'){
                        // job has diffrent type than completed - can not start this ("child") job
                        allJobsCompleted = false;
                        if (depedentJobs.get(dependentJobId).Status__c == STATUS_ERROR){
                            dependentJobHadFinishedWithError.put (key, ERROR_PARENT_JOB_FINISHED_WITH_ERROR);
                        }
                    }
                }
                else {
                    allJobsCompleted = false;
                    // exception dependent job was not found
                    dependentJobHadFinishedWithError.put (key, ERROR_PARENT_JOB_NOT_FOUND);
                }
            }
            retVal.put(key, allJobsCompleted);
        }
        // update status of jobs if error were found
        if (dependentJobHadFinishedWithError.size() > 0 ){
            setErrorStatusForJobs(dependentJobHadFinishedWithError);
        }
        // debug
        for (Id key : retVal.keySet()){
            system.debug('checkIfJobCanBeStarted -' + key + ':' + retVal.get(key));
        }
        return retVal;
    }
    private static void setErrorStatusForJobs (Map <Id, String> dependentJobHadFinishedWithError){
        List<COM_Batch_Queue__c> updateJobs = [select Id, Status__c from COM_Batch_Queue__c where id in :dependentJobHadFinishedWithError.keySet()];
        for (COM_Batch_Queue__c job : updateJobs){
            job.Status__c = STATUS_ERROR;
            job.Exception__c = dependentJobHadFinishedWithError.get(job.id);
        }
        update updateJobs;
    }
    private static Integer getNumberOfJobsSlots(){
        Integer noOfRunningJobs = [select count() FROM AsyncApexJob WHERE Status in ('Queued','Processing', 'Preparing') and JobType = 'BatchApex'];
        
        return MAX_NUMBER_OF_CONCURRENT_BATCH_PROCESSES - noOfRunningJobs;
    }
    private static void updateStatusOfJobs (){
        List<COM_Batch_Queue__c> jobsInProgress = [select Id, Name, Apex_JobId__c, Batch_Class_Name__c, Exception__c, Status__c, scope__c
                                from COM_Batch_Queue__c where Status__c = 'Execution'];
        Set<String> apexJobsIds = new Set<String>();
        for (COM_Batch_Queue__c job : jobsInProgress){
            apexJobsIds.add(job.Apex_JobId__c);
        }
        Map<Id, AsyncApexJob> apexJobs = new Map<Id, AsyncApexJob>([SELECT Id, Status, NumberOfErrors, JobItemsProcessed,ExtendedStatus,TotalJobItems
                                        FROM AsyncApexJob WHERE id in :apexJobsIds]);
        List<COM_Batch_Queue__c> updatedStatusJobs = new List<COM_Batch_Queue__c> ();
        
        for (COM_Batch_Queue__c job : jobsInProgress){
            if (apexJobs.containsKey(job.Apex_JobId__c)){
                if (apexJobs.get(job.Apex_JobId__c).Status == 'Completed'){
                    if (apexJobs.get(job.Apex_JobId__c).NumberOfErrors == 0){
                        job.Status__c = STATUS_COMPLETED;
                    }
                    else{
                        job.Status__c = STATUS_COMPLETED_WITH_ERRORS;
                        job.Exception__c = cutStringToMaxSize(apexJobs.get(job.Apex_JobId__c).ExtendedStatus, 255);
                    }
                    
                    updatedStatusJobs.add(job);
                }
                if (apexJobs.get(job.Apex_JobId__c).Status == 'Failed' || apexJobs.get(job.Apex_JobId__c).Status == 'Aborted'){
                    job.Status__c = STATUS_ERROR;
                    if (apexJobs.get(job.Apex_JobId__c).ExtendedStatus != null){
                        job.Exception__c = cutStringToMaxSize(apexJobs.get(job.Apex_JobId__c).ExtendedStatus, 255);
                    }                   
                    updatedStatusJobs.add(job);
                }
            }
            else {
                job.Status__c = STATUS_ERROR;
                job.Exception__c = ERROR_APEX_JOB_NOT_FOUND;
                updatedStatusJobs.add(job);
            }
        }
        update updatedStatusJobs;
    }
    private static String executeJob (COM_Batch_Queue__c job ){
        String retVal;
        try{
            COM_BatchQueueable batch;
            system.debug('----------------'+batch);
            system.debug('------job.Batch_Class_Name__c----------'+job.Batch_Class_Name__c);
            Type t = Type.forName(job.Batch_Class_Name__c);
            system.debug('----------------'+t);
            batch  = (COM_BatchQueueable)t.newInstance();
            system.debug('----------------'+batch);
            batch.setBatchParameters(job.Parameters_JSON__c);
            
            String apexJobId;
            
            if (job.scope__c != null && job.scope__c != 0){
                apexJobId = database.executebatch(batch, (Integer)job.scope__c);
            }
            else{
                apexJobId = database.executebatch(batch);
            }
            
            job.Apex_JobId__c = apexJobId;
            job.Status__c = STATUS_STARTED;
            update job;
        }
        catch (Exception ex){
            COM_Batch_Queue__c errorBatch = new COM_Batch_Queue__c(id = job.id, Status__c = 'Error');
            errorBatch.Exception__c = cutStringToMaxSize(ex.getMessage(),255);
            update errorBatch;
        }
        
        return retVal;
    }
    /* UTILS */
    public static String cutStringToMaxSize (String inStr, Integer maxSize){
        String retVal = inStr;
        if (inStr.length() > maxSize){
            retVal = inStr.substring(0, maxSize);
        }
        
        return retVal;
    }
    
    
}