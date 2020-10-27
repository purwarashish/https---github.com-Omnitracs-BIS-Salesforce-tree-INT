@isTest(SeeAllData=true)
private Class TestConnectionHelper{
    private static testMethod void testConnHelper(){
        ConnectionHelper connHelp = new ConnectionHelper();
        ConnectionHelper.getConnectionId('EDITED OUT');
        ConnectionHelper.getConnectionOwnerId('EDITED OUT');
    }

}