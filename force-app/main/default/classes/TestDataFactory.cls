/**
 * Centralized factory for creating test SObject records.
 * All test setup should delegate record creation to this class.
 */
@IsTest
public class TestDataFactory {

    /**
     * Creates and optionally inserts a list of Contact records.
     *
     * @param count    Number of records to create.
     * @param doInsert Whether to insert records into the database.
     * @return         List of Contact records.
     */
    public static List<Contact> createContacts(Integer count, Boolean doInsert) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            contacts.add(new Contact(
                FirstName = 'First' + i,
                LastName  = 'Last' + i
            ));
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }
}