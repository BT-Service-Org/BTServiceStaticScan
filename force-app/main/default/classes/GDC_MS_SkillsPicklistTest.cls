/****************************
 * Created By - Kushagra, Sehrab and Vibhor
 * Purpose - This is a test class for GDC_MS_SkillsPicklist class.
 ****************************/

@isTest
public class GDC_MS_SkillsPicklistTest {
    
	static testMethod void testGetDefaultValue() {
        test.startTest();
        GDC_MS_SkillsPicklist sp = new GDC_MS_SkillsPicklist();
        VisualEditor.DataRow defaultValue = sp.getDefaultValue();
        test.stopTest();
    }
    
    
	static testMethod void testGetValues() {
        test.startTest();
        GDC_MS_SkillsPicklist sp = new GDC_MS_SkillsPicklist();
        VisualEditor.DynamicPickListRows myValues = sp.getValues();
        test.stopTest();
    }
}