public with sharing class JSON2Apex {
    
    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || 
                curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT ||
                curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    public String ContactId {get;set;} 
    public String AccountId {get;set;} 
    public String CaseId {get;set;} // in json: Case
    public String AgentInfo {get;set;}
    public String AgentID {get;set;}
    
    public JSON2Apex(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                //System.debug('*******text -- '+Text);
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'ContactId') {
                        ContactId = parser.getText();
                    }  
                    else if (text == 'AccountId') {
                        AccountId = parser.getText();
                    }
                    else if (text == 'CaseNumber') {
                        CaseId = parser.getText();
                    }
                    else if (text == 'agent') {
                        AgentInfo = parser.getText();
                    }
                    else if (text == 'userId') {
                        AgentID = parser.getText();
                    } 
                    else {
                        System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }


    public static JSON2Apex parse(String json) {
        return new JSON2Apex(System.JSON.createParser(json));
    }
    
}