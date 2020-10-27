global class SpringCMRestHelper {
	public static void StartWorkflow (List <SObject> listofsobjects, String sfType, String workflowname, String sId) {
        if (String.isBlank(workflowname)) return;
        if (String.isBlank(sfType)) return;
        if (listofsobjects.isEmpty()) return;

            System.debug(UserInfo.getSessionId());
        SpringCMEos__EOS_Type__c eos = getEOSObject(sfType);
        String selectclause = eos.SpringCMEos__Variables__c + (eos.SpringCMEos__Variables__c.containsNone('Id')
        		? (eos.SpringCMEos__Variables__c.containsNone('Name')
        			? ', Id, Name'
        			: ', Id')
        		: (eos.SpringCMEos__Variables__c.containsNone('Name')
        			? ', Name'
        			: ''));

        String xml = buildWorkflowXML(listofsobjects, eos);

		startWorkflow(workflowname, xml, sId);
	}

	webservice static void StartWorkflow(String sfId, String sfType, String workflowname, String sId) {
        if (String.isBlank(workflowname)) return;
        if (String.isBlank(sfType)) return;
        if (String.isBlank(sfId)) return;

        SpringCMEos__EOS_Type__c eos = getEOSObject(sfType);
        String selectclause = eos.SpringCMEos__Variables__c + (eos.SpringCMEos__Variables__c.containsNone('Id')
        		? (eos.SpringCMEos__Variables__c.containsNone('Name')
        			? ', Id, Name'
        			: ', Id')
        		: (eos.SpringCMEos__Variables__c.containsNone('Name')
        			? ', Name'
        			: ''));

        List<SObject> ls = Database.query('SELECT ' + selectclause + ' FROM ' + sfType + ' WHERE Id =: sfId');

        String xml = buildWorkflowXML(ls, eos);

		startWorkflow(workflowname, xml, sId);
	}

	private static String buildWorkflowXML(List<SObject> listofsobjects, SpringCMEos__EOS_Type__c eosobject) {
        String xml = '';
        for (SObject obj : listofsobjects) {
            xml += buildWorkflowXML(eosobject.Name, getPath(obj, eosobject));
        }
        return String.isEmpty(xml) ? xml : '<salesforce>' + xml + '</salesforce>';
	}

	private static String buildWorkflowXML(String objecttype, List<String> eosdetails) {
		if (objecttype == null || objecttype == '') return null;
		System.debug('Type: '+objecttype);

		System.debug('SCM object path and name: ' + eosdetails);
		if (null == eosdetails.get(0)) return null;

		string xml = '';
		xml += '<object>';
		xml += '<id>' + eosdetails.get(0) + '</id>';
		xml += '<type>Salesforce.' + objecttype + '</type>';
		xml += '<foldername>' + eosdetails.get(2).escapeXml() + '</foldername>';
		xml += '<path>' + eosdetails.get(1).escapeXml() + '</path>';
		xml += '</object>';
		return xml;
	}

	private static List<String> getPath(SObject obj, SpringCMEos__EOS_Type__c eosObjectType) {
		String pathFormat = (String)eosObjectType.SpringCMEos__Path_Format__c;
		String nameFormat = (String)eosObjectType.SpringCMEos__Folder_Name_Format__c;
		String[] variables = ((String)eosObjectType.SpringCMEos__Variables__c).split(',');
		List<String> ret = new List<String>();

		ret.add((String)obj.get('Id'));
		List<string> substitutions = new List<String>();
		for (String var : variables) {
			System.debug('Variable found: ' + var);
			Object varSubstitution;
			if (var.contains('.')) {
				String [] parentSplit = var.split('\\.');
				SObject parent = obj;
				for (Integer i = 0; i < parentSplit.size(); i++) {
					if (i + 1 < parentSplit.size()) {
						if (String.valueOf(parent.getSObjectType()) != parentSplit[i])
							parent = parent.getSObject(parentSplit[i]);
						System.debug('Parent found: ' + parent);
					}
					else {
						if (parent != null) {
							varSubstitution =  parent.get(parentSplit[i]);
							System.debug('Found attribute value: ' + varSubstitution);
						}
						else varSubstitution = 'null';
					}
				}
			}
			else varSubstitution = obj.get(var);
			if (varSubstitution instanceof DateTime) {
				substitutions.add(String.valueOf(Date.valueOf(varSubstitution)));
			}
			else {
				String finalVar = String.valueOf(varSubstitution);
				if (finalVar.Contains('"') || finalVar.Contains('/')) {
					finalVar = finalVar.Replace('"', '_');
					finalVar = finalVar.Replace('/', '_');
				}
				substitutions.add(finalVar);
			}
		}
		ret.add(String.format(pathFormat, substitutions));
		ret.add(String.format(nameFormat, substitutions));
		return ret;
	}

	private static SpringCMEos__EOS_Type__c getEOSObject(String objecttype) {
		return [SELECT SpringCMEos__Folder_Name__c,
		SpringCMEos__Path__c, SpringCMEos__Variables__c, SpringCMEos__Folder_Name_Format__c,
		SpringCMEos__Path_Format__c, Name FROM SpringCMEos__EOS_Type__c WHERE Name =: objecttype ];
	}

	@future(callout=true)
	private static void startWorkflow(String workflowname, String xml, String session) {
            System.debug(session);
		SpringCMService springcm = new SpringCMService(String.isBlank(session) ? false : true, session);
		SpringCMWorkflow workflow = new SpringCMWorkflow(workflowname, xml);
        workflow = springcm.startWorkflow(workflow);		
	}
}