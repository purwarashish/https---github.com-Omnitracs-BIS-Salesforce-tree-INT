declare module "@salesforce/apex/ActivationScheduleController.getQLSchedules" {
  export default function getQLSchedules(): Promise<any>;
}
declare module "@salesforce/apex/ActivationScheduleController.getworkingSchedulesMap" {
  export default function getworkingSchedulesMap(param: {inputQuoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/ActivationScheduleController.addRow" {
  export default function addRow(param: {quoteId: any, quoteLineId: any, workingRevScheduleId: any}): Promise<any>;
}
declare module "@salesforce/apex/ActivationScheduleController.submitForApproval" {
  export default function submitForApproval(param: {quoteId: any, workingRevisionSchedID: any}): Promise<any>;
}
declare module "@salesforce/apex/ActivationScheduleController.updateQLS" {
  export default function updateQLS(param: {quoteScheduleID: any, reason: any, quantity: any, scheduledDate: any}): Promise<any>;
}
declare module "@salesforce/apex/ActivationScheduleController.addRevision" {
  export default function addRevision(param: {quoteId: any, workingRevScheduleId: any}): Promise<any>;
}
