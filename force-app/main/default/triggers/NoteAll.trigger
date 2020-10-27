trigger NoteAll on Note (
    after delete, after insert, after undelete, after update, before delete, before insert, before update
) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        LeadActivityUtils.updatePartnerDrivenActivity(Trigger.new);
        OpportunityActivityUtils.updatePartnerDrivenActivity(Trigger.new);
    }
}