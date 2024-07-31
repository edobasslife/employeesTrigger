/*
Write a code (Apex Trigger) that searches for records in the Account object where Name = “Acme Inc” 
and updates the NumberOfEmployees field with the number of contacts linked to the account.
The trigger is when a Contact record is linked/unlinked to the ”Acme Inc” Account records.
*/

trigger updateEmployees on Contact (after insert, after update, after delete,after undelete) {

    Set<Id> accIds = new Set<Id>();

    if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)) {
        if(!trigger.new.isEmpty()) {
            for(Contact con : trigger.new) {
                if(con.AccountId != null) {
                    accIds.add(con.AccountId);
                }
            }
        }
    }

    if(trigger.isAfter && trigger.isUpdate) {
        if(!trigger.new.isEmpty()) {
            for(Contact con : trigger.new) {
                if(con.AccountId != trigger.oldMap.get(con.Id).AccountId) {
                    if(trigger.oldMap.get(con.Id).AccountId != null) {
                        accIds.add(trigger.oldMap.get(con.Id).AccountId);
                    }
                    if(con.AccountId != null) {
                        accIds.add(con.AccountId);
                    }
                }
            }
        }
    }

    if(trigger.isAfter && trigger.isDelete) {
        if(!trigger.old.isEmpty()) {
            for(Contact con : trigger.old) {
                if(con.AccountId != null) {
                    accIds.add(con.AccountId);
                }
            }
        }
    }

    if(!accIds.isEmpty()) {
        List<Account> acctList = [SELECT Id, NumberOfEmployees__c, Name, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accIds AND Name = 'Acme Inc'];
        List<Account> accountToUpdate = new List<Account>();

        if(!acctList.isEmpty()) {
            for(Account acc : acctList) {
                acc.NumberOfEmployees__c = acc.Contacts.size();
                accountToUpdate.add(acc);
            }
        }

        if (!accountToUpdate.isEmpty()) {
            try {
                update accountToUpdate;
            } catch (DmlException e) {
                System.debug('An error has occurred: ' + e.getMessage());
            }
        }
    }
}
