global class COM_BatchExample extends COM_BatchQueueable {
		 global override void setBatchParameters(String parametersJSON){
		 	List<String> params = (List<String>) Json.deserialize(parametersJSON, List<String>.class);
        	query = params.get(0);
		 }
		 global override Database.QueryLocator start(Database.BatchableContext BC) {
       	 	return Database.getQueryLocator(query);
		 }
		 global override void execute(Database.BatchableContext BC, List<sObject> scope) {
		 	
		 }
		 global override void finish(Database.BatchableContext BC) {
		 	
		 }
	}