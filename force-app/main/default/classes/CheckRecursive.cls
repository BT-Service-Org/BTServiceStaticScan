public class CheckRecursive {
    private static boolean run = true;
    public static boolean isRun(){
        if(run){
         run=false;
         return true;
        }else{
            return run;
        }
    }
}