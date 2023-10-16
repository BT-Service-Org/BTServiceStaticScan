public class PlaybookWrapper {
    public String playbookId;
    public String playbookName;
    public String playbookDescription;
    public String playbookContractType;
    public List<Stage> stages;
    public class Stage {
        public String indexNumber;
        public String label;
        public String index;
        public OutcomeVsStageMethodOutcomeIds[] outcomeVsStageMethodOutcomeIds;
        public String Duration;
        public String KeyQuestions;
        public String Objectives;
        public String StageTitle;
        public String Description;
        public String DaysWeeks;
        public String Activities;
        public Decimal StageNumber;
        public boolean MandatoryStage;
        public String recordId;
    }
    public class OutcomeVsStageMethodOutcomeIds{
        public String outcomeId;
        public String outcomeName;
        public String outcomeOrder;
        public String stageOutcomeId;
        public StageMethodOutcome[] stageMethodOutcomes;
    }
    public class StageMethodOutcome{
        public String indexNumber;
        public Integer index;

        public Decimal orderNumber;
        //storing method outcome method
        public String methodId;
        public String methodName;
        //storing method outcome outcome
        public String outcomeId;
        public String outcomeName;

        public String methodOutcomeId;
        public String stageOutcomeId;

        public String stageMethodOutcomeId;
    }
    public class StageOutcome{
        public String outcomeId;
        public String order;
        public String stageId;
    }
    public static PlaybookWrapper parse(String json) {
        return (PlaybookWrapper) System.JSON.deserialize(json, PlaybookWrapper.class);
    }

    public static List<PlaybookWrapper> parseArray(String json) {
        return (List<PlaybookWrapper>) System.JSON.deserialize(json, List<PlaybookWrapper>.class);
    }
}