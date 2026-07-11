@isTest
private class ContactServiceTest {

    @isTest
    static void testUpdateContactDescription() {
        // 1. Create Test Data (Salesforce tests cannot see real org data by default)
        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com',
            Description = '' // Leaving it blank to trigger our class logic
        );
        insert testContact;
        
        // 2. Execute the code to be tested
        Test.startTest();
        ContactService.updateContactDescription(new List<Contact>{ testContact });
        Test.stopTest();
        
        // 3. Verify the results using Asserts
        // Re-query the record from the database to see the updated changes
        Contact updatedContact = [SELECT Id, Description FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        
        // Assert that the standard Description field is no longer blank and matches our expected text
        Assert.areEqual(
            'Default description populated via Apex ContactService.', 
            updatedContact.Description, 
            'The Contact description should have been updated by the service class.'
        );
    }
}