public without sharing class COM_ByPassPermission {

   /**
	* @author  Sandip Atkari
	* @date    01/12/2015
	* @description Change contact ownership changes automatically upon updating the Account Owner.
	*              Jira#SFDC-332
	*/
	public static void updateContactOwner(Map<Id, Account> mapAccsToOwnerChg){

System.Debug('After Update - Account Map Size : ' + mapAccsToOwnerChg.size());
        if(mapAccsToOwnerChg.size() > 0){
System.Debug('After Update - Enter into Logic : ' + mapAccsToOwnerChg.size());
            list<Contact> listConsOwnerChgToUpdate = new list<Contact>();
            list<Contact> listContacts = [SELECT Id,OwnerId, AccountId FROM Contact WHERE AccountId IN :mapAccsToOwnerChg.keySet()];
System.Debug('After Update - List Contact size : ' + listContacts.size());                                    
            for(Contact cons : listContacts){
                Account objAcc = mapAccsToOwnerChg.get(cons.AccountId);
                cons.OwnerId = objAcc.OwnerId;
                listConsOwnerChgToUpdate.add(cons);
            }
System.Debug('After Update - List Owner update Contact size : ' + listConsOwnerChgToUpdate.size());                                                          
            if (listConsOwnerChgToUpdate.size()>0) update listConsOwnerChgToUpdate;
        }
	}
}