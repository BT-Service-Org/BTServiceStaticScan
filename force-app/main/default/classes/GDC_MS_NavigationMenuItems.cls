/**
 * Controller for fetching NavigationMenuItems from GDC Community.
 */
global with sharing class GDC_MS_NavigationMenuItems extends VisualEditor.DynamicPickList{

    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Home', 'Home');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();        
        List<NavigationLinkSet> linkSets = [SELECT Id FROM NavigationLinkSet WHERE DeveloperName = 'GDC_MS_Navigation1'];
        Id linkSetId = linkSets[0].Id;
        for(NavigationMenuItem nmt: [SELECT Label,Position,Status FROM NavigationMenuItem WHERE NavigationLinkSetId = :linkSetId ORDER BY Position]){
            VisualEditor.DataRow rowValue = new VisualEditor.DataRow(nmt.Label, nmt.Label);
            myValues.addRow(rowValue);
        }
        return myValues;
    }
    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItem> getNavigationMenuItems() {
        String networkId = Network.getNetworkId();   
        system.debug(' --NID -- '+ networkId);
        List<NavigationLinkSet> linkSets = [SELECT Id FROM NavigationLinkSet WHERE NetworkId = :networkId AND DeveloperName = 'GDC_MS_Navigation1'];
        system.debug(' -- Lnks -- ' + linkSets);
        Id linkSetId = linkSets[0].Id;
        return [SELECT Label,Target,Type,Position,Status FROM NavigationMenuItem WHERE NavigationLinkSetId = :linkSetId AND Status='Live'  ORDER BY Position];
    }
}