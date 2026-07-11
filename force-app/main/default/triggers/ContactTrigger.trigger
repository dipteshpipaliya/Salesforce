/**
 * Trigger on the Contact object.
 * Delegates all logic to ContactTriggerHandler to keep the trigger thin.
 */
trigger ContactTrigger on Contact (before update) {
    ContactTriggerHandler.handle(Trigger.new, Trigger.oldMap);
}