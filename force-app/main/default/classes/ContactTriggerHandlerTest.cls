/**
 * Tests for ContactTriggerHandler — verifies that a validation error is thrown
 * when a Contact's name is changed, and that non-name updates are allowed.
 */
@IsTest
private class ContactTriggerHandlerTest {

    @TestSetup
    static void setupTestData() {
        TestDataFactory.createContacts(251, true);
    }

    // ─── Positive: name change blocked ──────────────────────────────────────────

    @IsTest
    static void shouldAddError_WhenFirstNameChanged() {
        // Given
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
        Contact contact = contacts[0];
        contact.FirstName = 'UpdatedFirst';

        // When
        Test.startTest();
        Database.SaveResult result = Database.update(contact, false);
        Test.stopTest();

        // Then
        Assert.isFalse(result.isSuccess(), 'Update should have failed when FirstName is changed');
        Assert.isTrue(
            result.getErrors()[0].getMessage().length() > 0,
            'A validation error message should be present'
        );
    }

    @IsTest
    static void shouldAddError_WhenLastNameChanged() {
        // Given
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
        Contact contact = contacts[0];
        contact.LastName = 'UpdatedLast';

        // When
        Test.startTest();
        Database.SaveResult result = Database.update(contact, false);
        Test.stopTest();

        // Then
        Assert.isFalse(result.isSuccess(), 'Update should have failed when LastName is changed');
        Assert.isTrue(
            result.getErrors()[0].getMessage().length() > 0,
            'A validation error message should be present'
        );
    }

    @IsTest
    static void shouldAddError_WhenBothNamesChanged() {
        // Given
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
        Contact contact = contacts[0];
        contact.FirstName = 'NewFirst';
        contact.LastName  = 'NewLast';

        // When
        Test.startTest();
        Database.SaveResult result = Database.update(contact, false);
        Test.stopTest();

        // Then
        Assert.isFalse(result.isSuccess(), 'Update should fail when both names are changed');
    }

    // ─── Negative: non-name update allowed ──────────────────────────────────────

    @IsTest
    static void shouldAllowUpdate_WhenNameNotChanged() {
        // Given
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
        Contact contact = contacts[0];
        contact.Title = 'Engineer';

        // When
        Test.startTest();
        Database.SaveResult result = Database.update(contact, false);
        Test.stopTest();

        // Then
        Assert.isTrue(result.isSuccess(), 'Update should succeed when name is not changed');
    }

    // ─── Bulk: 251+ records ──────────────────────────────────────────────────────

    @IsTest
    static void shouldAddError_WhenNameChangedBulk() {
        // Given
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact];
        for (Contact c : contacts) {
            c.LastName = 'BulkChangedLast';
        }

        // When
        Test.startTest();
        List<Database.SaveResult> results = Database.update(contacts, false);
        Test.stopTest();

        // Then
        Integer errorCount = 0;
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                errorCount++;
            }
        }
        Assert.areEqual(
            contacts.size(),
            errorCount,
            'Every record with a name change should produce a validation error'
        );
    }

    @IsTest
    static void shouldAllowUpdate_WhenNameNotChangedBulk() {
        // Given
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact];
        for (Contact c : contacts) {
            c.Title = 'BulkTitle';
        }

        // When
        Test.startTest();
        List<Database.SaveResult> results = Database.update(contacts, false);
        Test.stopTest();

        // Then
        for (Database.SaveResult result : results) {
            Assert.isTrue(result.isSuccess(), 'All bulk updates with no name change should succeed');
        }
    }
}