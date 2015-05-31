public class COM_EmailUtils {

/**
	* @author 	Aniruddha M
	* @date 	19/01/2015
	* @description Wrapper class for EmailMessage .
	* @param fromAddress, ToAddress, Subject, Subject Params, Body Params
	* @return EmailMessageWrapper 
	*/
	
	private static final COM_Logger LOGGER = new COM_Logger('COM_EmailUtils');
	
	public class EmailMessageWrapper {
	  	/**
		* Constructor for EmailMessageWrapper .
		* @param fromAddress, ToAddress, Subject, Subject Params, Body Params
		* @return EmailMessageWrapper 
		*/
		
		
		String FromAddress {get;set;}
		String ToAddressId {get;set;}
		String Subject{get;set;}
		Map<String,String> ParameterSubjectMap {get;set;}
		Map<String,String> ParameterBodyMap {get;set;}
		String ToAddress {get;set;}
		String BccAddress {get;set;}
		String Body {get;set;}
		/*public EmailMessageWrapper(String fromAddr, String toAddr, Id toAddrId, String sub, Map<String, String> mapSubjectParams, Map<String, String> mapBodyParams) {
       	 	this(fromAddr, toAddr, toAddrId, null, sub, mapSubjectParams, null, mapBodyParams );
       	 	
    	}*/
    	
    	
	    public EmailMessageWrapper(String fromAddr, String toAddr, Id toAddrId, String bccAddr, String sub, Map<String, String>  mapSubjectParams, String body, Map<String, String> mapBodyParams) {
	        this.FromAddress = fromAddr;
	        this.ToAddress = toAddr;
	        this.ToAddressId = toAddrId;
	        this.BccAddress = bccAddr;
	        this.Subject = sub;
	        this.ParameterSubjectMap = mapSubjectParams;
	        this.Body = body;
	        this.ParameterBodyMap = mapBodyParams;
	   }
	}
	
	
   
   /**
	* @author 	Aniruddha M
	* @date 	19/01/2015
	* @description Method to send and Email .
	* @param EmailMessageWrapper List, Email Template
	*  
	*/
   public static void sendEmail(List<EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateName){ 
   		String methodName = 'COM_EmailUtils:sendEmail';
   		LOGGER.entry(methodName);
        List<Messaging.SendEmailResult> listEmailResult = null;
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateName];
        for (EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSenderDisplayName(emailMessageWrapper.FromAddress);
            if(COM_Utils.isNotEmpty(emailMessageWrapper.FromAddress) && emailMessageWrapper.FromAddress.length() > 0)
                mail.setReplyTo(emailMessageWrapper.FromAddress);
            
            //To do : Check for Comma seperated (Contains) 
            if(COM_Utils.isNotEmpty(emailMessageWrapper.ToAddress) && emailMessageWrapper.ToAddress.length() > 0){
               mail.setToAddresses(new String[] { emailMessageWrapper.ToAddress });
               LOGGER.info(' TO ADDRESS from WRAPPER CLASS IF ----->>>> '+mail.getToAddresses());
            }
            else{
               mail.setTargetObjectId(emailMessageWrapper.ToAddressId);
               LOGGER.info(' TO ADDRESS from WRAPPER CLASS IF ----->>>> '+mail.getToAddresses());
            }
            //To do : Check for Comma seperated (Contains)    
            if(COM_Utils.isNotEmpty(emailMessageWrapper.BccAddress) && emailMessageWrapper.BccAddress.length() > 0)
               mail.setBccAddresses(new String[] {emailMessageWrapper.BccAddress });
            String subject = null;
            if(COM_Utils.isNotEmpty(emailMessageWrapper.Subject) && emailMessageWrapper.Subject.length() > 0) {
               mail.setSubject(emailMessageWrapper.Subject);
               subject = emailMessageWrapper.Subject;
                LOGGER.info(' SUBJECT from WRAPPER CLASS IF ----->>>> '+subject);
           }
           else{
                 subject = emailTemplate.Subject;
                 LOGGER.info(' SUBJECT from WRAPPER CLASS ELSE ----->>>> '+subject);
           }
           if(COM_Utils.isNotEmpty(emailMessageWrapper.ParameterSubjectMap)){
	           for(String key: emailMessageWrapper.ParameterSubjectMap.keySet()){
	               subject = subject.replace(key, (emailMessageWrapper.ParameterSubjectMap.get(key) == null ? '' : emailMessageWrapper.ParameterSubjectMap.get(key)));
	                 LOGGER.info(' SUBJECT from WRAPPER FOR LOOP ----->>>> '+subject);
	           }
           }
            mail.setSubject(subject);
            String htmlBody = emailTemplate.HtmlValue;
            String plainBody = emailTemplate.Body;
            if(COM_Utils.isNotEmpty(emailMessageWrapper.ParameterBodyMap)){
	            for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) {
	                 htmlBody = htmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
	                 plainBody = plainBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
	            }
            }
  			mail.setHtmlBody(htmlBody);
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(plainBody);
            
            LOGGER.info(' HTML BODY  ----->>>> '+htmlBody);
            LOGGER.info(' PLAIN BODY ----->>>> '+plainBody);
           
            listSingleEmailMessages.add(mail);
            LOGGER.info(' Mail Message Details ----->>>> '+listSingleEmailMessages);
        }
        if(!Test.isRunningTest()){
            listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
    	} 
    }
}