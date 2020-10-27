@isTest
public class TestUnityFeedbackFormController
{
    static testMethod void myUnitTest()
    {
        case c = new case();
        ApexPages.StandardController cnt = new ApexPages.StandardController(c);
        UnityFeedbackFormController ufc = new UnityFeedbackFormController(cnt);
        UnityFeedbackFormController ufc1 = new UnityFeedbackFormController();      
        ufc.getUseRatingValues();
        ufc.getActionRatingValues();
        ufc.getHelpratingValues();
        ufc.getLabelRatingValues();
        ufc.phoneField= '(715) 848-1365';
        ufc.getChooseContactValues();
        ufc.submitCase();
    }
    static testMethod void myUnitTest1()
    {
        ApexPages.currentPage().getParameters().put('pn','test');
        case c1 = new case();
        ApexPages.StandardController cnt1 = new ApexPages.StandardController(c1);
        UnityFeedbackFormController ufc2 = new UnityFeedbackFormController(cnt1);
        ufc2.chooseContact='test@c.com';
        ufc2.ratingForLabel='1';
        ufc2.RatingIsHelpful='1';
        ufc2.ratingAction='1';
        ufc2.ratingUse='1';
        ufc2.comments='test';
        ufc2.suggestions='test';
        ufc2.submitCase();
        ufc2.chooseContact='(715) 848-1365';
        ufc2.submitCase();   
    }
}