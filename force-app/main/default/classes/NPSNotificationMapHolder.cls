public class NPSNotificationMapHolder {
    public String acctOwnerEmail;
	public String acctCSMEmail;
	public String acctOwnerFirstName;
    public List<String> acctContactList = new List<String>();
    
    public NPSNotificationMapHolder() {}
    
    public NPSNotificationMapHolder(String acctOwnerEmail, String acctOwnerFirstName, String acctCSMEmail, List<String> acctContactList) {
		this.acctOwnerEmail = acctOwnerEmail;
		this.acctOwnerFirstName = acctOwnerFirstName;
		this.acctCSMEmail = acctCSMEmail;
        this.acctContactList = acctContactList;
    }
}