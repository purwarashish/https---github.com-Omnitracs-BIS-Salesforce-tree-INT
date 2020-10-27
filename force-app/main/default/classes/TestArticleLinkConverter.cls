/**********************************************************************************************
 Date: 11/04/2012 
 Author: Subha, Tata Consultancy Services        
 
 Overview: 
  This Test class covers the QES Unity ArticleLinkConverter class 
       
 ***************************************************************************************/   

@isTest
public class TestArticleLinkConverter
{
    static testmethod void testMethodArticleLinkConverter()
    {
        Test.startTest();
        ArticleLinkConverter tst = new ArticleLinkConverter();
        tst.transformArticleHyperLinks('<a href="http://www.google.co.in">');
        tst.transformArticleHyperLinks('<a href="http://www.google.co.in#version?selectedDocumentId=">');
        Test.stopTest();
    }
}