public with sharing class ContactService {
    
    /**
     * Updates the standard Description field on a list of Contacts if it's currently empty.
     * @param contactList List of Contacts to evaluate and update
     */
    public static void updateContactDescription(List<Contact> contactList) {
        // Safe guard against null lists
        if (contactList == null || contactList.isEmpty()) {
            return;
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Contact con : contactList) {
            // Check if the standard Description field is blank
            if (String.isBlank(con.Description)) {
                con.Description = 'Default description populated via Apex ContactService.';
                contactsToUpdate.add(con);
            }
        }
        
        // Only perform DML if there are records to update
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}