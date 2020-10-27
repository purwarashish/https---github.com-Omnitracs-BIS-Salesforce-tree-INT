@isTest(SeeAllData = true)
private class TestSuggestedSolutionModeler{
    private static testMethod void testSuggSol(){
        SuggestedSolutionModeler ssm =new SuggestedSolutionModeler();
        ssm.getSuggestedSolutions('a*');
        ssm.getSuggestedSolutions('');
    }
}