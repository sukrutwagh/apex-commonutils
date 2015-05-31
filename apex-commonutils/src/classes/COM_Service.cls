public interface COM_Service {

	
	/** 
	* @author 	Sukrut Wagh
	* @date 	21/10/2014	
	* @description	Query to fetch the records to be processed. This will be used during the batch execution mode
	*/
	String getProcessingQuery();
	
	/** 
	* @author 	Sukrut Wagh
	* @date 	21/10/2014	
	* @description	Comma or semi-colon separated email addressess. Optional recipients to include for sending out emails to notify job completion
	*/
	String getEmailRecipients();
	
	/** 
	* @author 	Sukrut Wagh
	* @date 	21/10/2014	
	* @description	Optionally, service may choose to perform any pre-processing in this method
	*/
	void prepare();
	
	/** 
	* @author 	Sukrut Wagh
	* @date 	21/10/2014	
	* @description	Service processing/execution happens here. Processing could mean different things for different services.
	*				Some might execute business logic within sfdc context, some might execute callouts & so forth.
	* @param Records to be processed
	* @return Result
	*/
	COM_ServiceResult invoke(List<sObject> scope);
	
	/** 
	* @author 	Sukrut Wagh
	* @date 	21/10/2014	
	* @description	Optionally, service may perform any post processing on the results
	* @param results to be processed	
	*/
	Boolean processResult(List<COM_ServiceResult> results);
	
	/** 
	* @author 	Sukrut Wagh
	* @date 	21/10/2014	
	* @description	Optionally, service may perform any post processing on the results
	* @return Results
	*/
	List<COM_ServiceResult> getResults();
	
	void setProperties(Map<String,Object> props);
	
	Map<String,Object> getProperties();
	
}