@isTest
public with sharing class The_Station_ContentSearchValsTest {
    
    public static String cloudProductDefault = 'Sales Cloud';
    public static String communityDefault = 'The Station Hub';

    public The_Station_ContentSearchValsTest() {

    }


    @isTest static void test_DynamicPicklistValueClasses() {    
    
        The_Station_ContentSearchCloudProdVals cloud = new The_Station_ContentSearchCloudProdVals();
        VisualEditor.DataRow defaultCloud = cloud.getDefaultValue();
        String defaultCloudString = defaultCloud.getLabel();
        System.AssertEquals(cloudProductDefault, defaultCloudString);


        The_Station_ContentSearchCommunityVals community = new The_Station_ContentSearchCommunityVals();
        VisualEditor.DataRow defaultCommunity = community.getDefaultValue();
        String defaultCommunityString = defaultCommunity.getLabel();
        System.AssertEquals(communityDefault, defaultCommunityString);


        VisualEditor.DynamicPickListRows cloudValues = cloud.getValues();
        VisualEditor.DynamicPickListRows communityValues = community.getValues();

        if (cloudValues != null) {
            System.Assert(true, 'The_Station_ContentSearchCloudProdVals.getValues() returned ' + cloudValues);
        } else {
            System.Assert(false, 'The_Station_ContentSearchCloudProdVals.getValues() returned null');
        }

        if (communityValues != null) {
            System.Assert(true, 'The_Station_ContentSearchCommunityVals.getValues() returned ' + communityValues);
        } else {
            System.Assert(false, 'The_Station_ContentSearchCommunityVals.getValues() returned null');
        }

    }

}