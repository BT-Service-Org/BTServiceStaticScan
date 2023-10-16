public class lpForecastCategory
{
    public String monthYearDisplay {get;set;}
    public Integer baseCerts{get;set;}
    public Integer foundation{get;set;}
    public Integer certified{get;set;}
    public Integer projectRole{get;set;}
    public Integer roleReady{get;set;}
    public Id forecastCategoryId {get; set;}
   
    public lpForecastCategory()
    {
        monthYearDisplay = '';
        baseCerts = 0;
        foundation = 0;
        certified = 0;
        projectRole = 0;
        roleReady= 0;

    }
}