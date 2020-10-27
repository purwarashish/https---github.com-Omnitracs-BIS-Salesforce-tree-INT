public class VCG_CPQ_NeedsFieldsReviewController {
    Map<String,Map<String,List<sObject>>> needsFieldsSourceMap;
    
    public Map<String,Map<String,List<sObject>>> GetNeedsFieldsSourceMap()
    {
        if (needsFieldsSourceMap == null)
        {
            needsFieldsSourceMap = VCG_CPQ_NeedsFieldsUtility.getNeedsFieldsSources();
        }
        
        return needsFieldsSourceMap;
    }
}