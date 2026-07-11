/**
 * Handler for ContactTrigger. Validates that the Contact Name (FirstName/LastName)
 * is not changed once it has been set. Throws a validation error on the record
 * when a name change is detected during an update.
 */
public with sharing class ContactTriggerHandler {

    /**
     * Entry point called by ContactTrigger on before update.
     *
     * @param newContacts  List of Contact records with incoming field values. //updates
     * @param oldMap       Map of Contact Id to the prior state of each record.
     */
    public static void handle(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        validateNameNotChanged(newContacts, oldMap);
    }

    // ─── Private helpers ────────────────────────────────────────────────────────

    private static void validateNameNotChanged(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        for (Contact newContact : newContacts) {
            Contact oldContact = oldMap.get(newContact.Id);

            Boolean firstNameChanged = newContact.FirstName != oldContact.FirstName;
            Boolean lastNameChanged  = newContact.LastName  != oldContact.LastName;

            if (firstNameChanged || lastNameChanged) {
                newContact.addError(Label.Contact_Name_Change_Not_Allowed);
            }
        }
    }
}