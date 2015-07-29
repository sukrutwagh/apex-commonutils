/**
* @author 		Sukrut Wagh
* @date			07/18/2015
* @description	Utility class for Notification related helpers
*/

public class COM_NotificationUtils {

    private static final COM_Logger LOGGER = new COM_Logger('COM_NotificationUtils');
    
    /**
	* @description 			Compares two lists of same Schema.sObjectType for any data changes and sends email notification.
	*						Email definition, fields to compare, receipients, etc are derived from custom settings: NotificationControl__c
	* @param old			First list for comparison
	* @param newz			Second list for comparison
	*/
    public static void notifyChange(final List<SObject> old, final List<SObject> newz) {
    	try {
            if(COM_Utils.isEmpty(old) && COM_Utils.isEmpty(newz)) {
        		LOGGER.debug('Both lists are empty');
            } else {
                SObject sObj = null;
                if(COM_Utils.isNotEmpty(old)) {
                    sObj = old[0];
                }
                if(COM_Utils.isNotEmpty(newz)) {
                    sObj = newz[0];
                }
                NotificationControl__c config = COM_NotificationUtils.getConfig(sObj);			
                if(COM_Utils.isNotEmpty(config) && COM_Utils.isNotEmpty(config.Enable__c) && config.Enable__c) {
                    List<String> checkFields = null;
                    if(COM_Utils.isNotEmpty(config.NotifyOnFields__c)) {
                        checkFields = config.NotifyOnFields__c.split(COM_Constants.COMMA);
                    }
                    List<COM_Utils.SObjectFieldChanges> changes = COM_Utils.getChangedFields(old,newz,checkFields);
                    LOGGER.info('Changes:'+changes);
                    if(COM_Utils.isNotEmpty(changes)) {
                        LOGGER.info('Notifying changes - Send email');
                        List<String> recipients = null;
                        for(COM_Utils.SObjectFieldChanges change: changes) {
                            if(COM_Utils.isNotEmpty(change)) {
                               if(COM_Utils.isNotEmpty(change.newz)) {
                                    sObj = change.newz;
                               } else {
                                   sObj = change.old;
                               }
                               recipients = getRecipients(sObj,config);
                               al.EmailUtils.sendTextEmail(recipients,getSubject(sObj), getMsg(sObj,change));
                                LOGGER.info('Notifying changes - Email Sent successfully');
                            }
                        }
                    } else {
                        LOGGER.info('No changes found:'+changes);
                    }
                } else {
                    LOGGER.warn('No NotificationControl__c found for SObject:'+sObj+' and/or not enabled:'+config);
                }
            }
        } catch(Exception e) {
            LOGGER.error('An error occured during notifyChange',e);
        } finally {
            //TODO:
        }
    } 
    
    /**
	 * @author 		Sukrut Wagh
	 * @date		07/29/2015
	 * @description Returns the notification configuration custom setting defined for the object.
	 * @param obj	SObject
	 * @return NotificationControl__c custom setting
	 */
    public static NotificationControl__c getConfig(final SObject so) {
        NotificationControl__c config = null;
        String soAPIName = null;
        if(COM_Utils.isNotEmpty(so)) {
	        soAPIName = COM_Utils.getSObjectTypeName(so);
        	config = NotificationControl__c.getInstance(soAPIName);
        }
        LOGGER.info('Config for '+soAPIName+':'+config);
        return config;
    }
    
    private static String getSubject(final SObject so) {
        al.StringBuffer subject = new al.StringBuffer('Notification for:');
        if(COM_Utils.isNotEmpty(so)) {
            subject.append(COM_Utils.getSObjectTypeName(so)).append(':').append(getEventType()).append('\t').append(so.Id);
            
        }
        return subject.toStr();
    }
    
    
    
    private static String getEventType() {
        String eventType = '';
        if(Trigger.isExecuting) {
            if (Trigger.isInsert) {
                eventType = 'Created';
            } else if(Trigger.isUpdate) {
                eventType = 'Updated';
            } else if(Trigger.isDelete) {
                eventType = 'Deleted';
            }
        }
        return eventType;
    }
    
    private static String getMsg(final SObject so, COM_Utils.SObjectFieldChanges change) {
        LOGGER.debug('Generating email message');
        al.StringBuffer sb = new al.StringBuffer();
        if(COM_Utils.isNotEmpty(change) && COM_Utils.isNotEmpty(change.changedFieldNames) && change.changedFieldNames.size() > 0) {
            sb.append(COM_Utils.getObjUrl(so)).append('\n\n');
            for(String fieldName : change.changedFieldNames) {
                sb.append(fieldName).append(':');
                if(COM_Utils.isNotEmpty(change.old)) {
                    sb.append(String.valueOf(change.old.get(fieldName))).append('\t');
                }
                if(COM_Utils.isNotEmpty(change.newz)) {
                    sb.append(String.valueOf(change.newz.get(fieldName)));
                }
                sb.append('\n');
            }
        }
        return sb.toStr();
    }
    
    public static List<String> getRecipients(final SObject sObj, final NotificationControl__c config) {
        List<String> recipients = new List<String>();
        String emailFieldValue = null;
        if(COM_Utils.isNotEmpty(config) && COM_Utils.isNotEmpty(sObj)) {
            if(COM_Utils.isNotEmpty(config.AdditionalToAddress__c)) {
                List<String> addEmails = config.AdditionalToAddress__c.split(COM_Constants.COMMA);
                for(String addEmail : addEmails) {
                    if(al.EmailUtils.isValidEmailAddress(config.AdditionalToAddress__c)) {
                        recipients.add(config.AdditionalToAddress__c);
                    }
                }
            }
            if(COM_Utils.isNotEmpty(config.ToAddressFields__c))  {
                List<String> toAddrFields = config.ToAddressFields__c.split(COM_Constants.COMMA);
                for(String toAddrField : toAddrFields) {
                    emailFieldValue = (String)sObj.get(toAddrField);
                    if(al.EmailUtils.isValidEmailAddress(emailFieldValue)) {
                        recipients.add(emailFieldValue);
                    }
                }
            }
           if(COM_Utils.isNotEmpty(config.CcAddressFields__c))  {
                List<String> ccAddrFields = config.CcAddressFields__c.split(COM_Constants.COMMA);
                for(String ccAddrField : ccAddrFields) {
                    emailFieldValue = (String)sObj.get(ccAddrField);
                    if(al.EmailUtils.isValidEmailAddress(emailFieldValue)) {
                        recipients.add(emailFieldValue);
                    }
                }
            }
        }
        return recipients;
    }
    
}