public with sharing class CheckRecursiveAfter
{
    private static boolean run = true;
    
    public static boolean runOnce()
    {
        util.debug('runOnce method called. value of private static variable run = ' + run);
        if(run)
        {
            run = false;
            return true;
        }
        else
        {
            return run;
        }
    }
    
    public static void resetRunOnceFlag() {
        run = true;
    }
}