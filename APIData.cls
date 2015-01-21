public abstract class APIData implements IAPIData {

	private final Boolean INCLUDE_DELTAS_IN_IMPORT = Environment.IncludeDeltasInImport;
	Public Database.UpsertResult[] upsertListResults;

	// Batch ID to track progress.
	private ID currentImportBatchID;
	public void SetCurrentImportBatchID(ID batchID) { currentImportBatchID = batchId;}
	public ID GetCurrentImportBatchID() { return currentImportBatchID; }

	// # imported
	private integer newRecordCount = 0;
	public integer getNewRecordCount() { return newRecordCount;}

	// # updated
	private integer updatedRecordCount = 0;
	public integer getUpdatedRecordCount(){ return updatedRecordCount;}

	// # errors
	private integer errorRecordCount = 0;
	public integer getErrorRecordCount() { return errorRecordCount;}

	public List<Import_Detail__c> errorRecords;
	public List<Import_Detail__c> updatedRecords;

	// Tag Identifying Class.
	private string tag = '';
	public string getTag() {return ' [* ' + tag + ' *]';}
	public void setTag(string value) {tag = value;}

	///////////////////////////////////////////////////////
	//// General API Data Definitions
	///////////////////////////////////////////////////////

	public Meta meta;
	public class Meta {
		public String first_url;
		public String last_url;
		public String next_url;
		public String previous_url;
		public Integer total;
		public Integer per_page;
		public Integer current_page;
		public Integer last_page;
	}


	// MAP of key value pairs <fkID, SFIds>
	public Map<String, ID> existingIDsMap ;
	public Set<String> setOfExternalIDs ;
	public Map<String, String> existingDatesMap;


	////////////////////////////////////////////////////
	///// IAPIDATA interface required method. Generic.
	///// ///////////////////////////////////////////////
	public virtual integer getNextURLValue(){
		string lastValue = meta.next_url.substringAfterLast('=');
		integer returnValue = 0;
		if ( (lastValue != null) && (lastValue.isNumeric() == true)  && lastValue != '0' ){
			returnValue = Integer.valueOf(lastValue);
		} else {
			returnValue = 1;
		}
		return returnValue;
	}


	/////////////////////////////////////////////////////////////////////
	/// Upsert Logic. Better to update.
	////////////////////////////////////////////////// ///////////////////
	public virtual void upsertRecords(List<sObject> recordSet){
		// code overwritten
		processUpsertResponse();
	}


   	public void processUpsertResponse(){
   		DiagnosticsInstrumentation.push('processUpsertResponse' + getTag());
   		errorRecordCount = 0;
   		updatedRecordCount = 0;
   		newRecordCount = 0;
		errorRecords = new List<Import_Detail__c>();
		updatedRecords = new List<Import_Detail__c>();
		Import_Detail__c currentRecord;
		// Iterate through each returned result
		if (upsertListResults != null){
			for(Integer idx = 0; idx < upsertListResults.size(); idx++)
			{
				if (upsertListResults[idx].isSuccess() == false) {
					errorRecordCount++;
					currentRecord = processErrorRecord(upsertListResults[idx].getErrors(), idx);
					if(currentRecord != null) errorRecords.Add(currentRecord);
				}

				if (upsertListResults[idx].isSuccess() && upsertListResults[idx].isCreated()) {
					newRecordCount++;
				}

				if (upsertListResults[idx].isSuccess() && upsertListResults[idx].isCreated() == false) {
					updatedRecordCount++;
					if (Environment.trackUpdatedRecords == true){
						currentRecord = processUpdatedRecord(upsertListResults[idx], idx);
						if(currentRecord != null) updatedRecords.Add(currentRecord);
					}
				}
			}
		}
		if (errorRecords!= null && errorRecords.size() > 0) {
			try {
				insert errorRecords;
				} catch (DMLException de) {
					system.debug('A DML Exception Occurred');
				}
		}
		if (Environment.trackUpdatedRecords == true && updatedRecords != null && updatedRecords.size() > 0) insert updatedRecords;
		DiagnosticsInstrumentation.pop();
	}

	public virtual Import_Detail__c processErrorRecord(Database.Error[] errList, integer idx){
    	Import_Detail__c returnDetail = new Import_Detail__c();
		returnDetail.Detail_Type__c = 'Error';
		returnDetail.Import_Batch__c = currentImportBatchID;
		for(Database.Error err : errList) {
			returnDetail.Message__c = returnDetail.Message__c + 'Error: ' + err.getStatusCode() + ': ' + err.getMessage() + '.  Affected Fields: ' + err.getFields() + '\n';
		}
    	return returnDetail;
    }

    public virtual Import_Detail__c processUpdatedRecord(Database.UpsertResult sr, integer idx){
    	Import_Detail__c returnDetail = new Import_Detail__c();
    	returnDetail.Detail_Type__c = 'Updated';
    	returnDetail.Import_Batch__c = currentImportBatchID;
    	returnDetail.Message__c 	=  'Salesforce ID: ' + sr.getId();
    	return returnDetail;
    }

	///////////////////////////////////////////////////
	////// General Helper Methods
	//////////////////////////////////////////////////

    public virtual void updateLookup(){
    	// overwritten in the sub-class
    }

    public virtual void populatesetOfExternalIDs(){
    }

    public boolean keyExistsInMap(string mapKey){
		updateLookup();
		boolean returnValue = false;
		if (mapKey != null  && existingIDsMap != null){
			returnValue = existingIDsMap.containsKey(mapKey);
		}
		return (returnValue);
    }

    public id getSFID(string mapKey)  {
		ID sfID = null;
		updateLookup();
		if (keyExistsInMap(mapKey)){
			sfID = existingIDsMap.get(mapKey);
		}
		DiagnosticsInstrumentation.debug(getTag() + ' getSFID - Key: ' + mapkey + ' -sfid: ' + sfid );
		return sfID;
	}


	public virtual string completeCalloutURI(string partialURI, string extraParameters, string next) {
		return (partialURI + next + extraParameters);
	}

	public virtual integer getMaxCallouts() {
		//default to minCallOuts
		return Integer.Valueof(Environment.MinCallouts);
	}

	public virtual boolean RequiresUpdate(string mapKey, string externalValue) {
		boolean returnVal = true;
		string currentValue;
		if (keyExistsInMap(mapKey) == true){
			returnVal = false;
		}
		if (INCLUDE_DELTAS_IN_IMPORT && returnVal == false ){
			//need to add key to new map
			currentValue = existingDatesMap.get(mapKey);
			if (currentValue != null) {
				returnVal = !(currentValue.equals(externalValue));
			} else {
				returnVal = true;
			}
		}
		return returnVal;
	}

	// This method is called whenever the List Of RAW data (from API), that needs to be inserted
	// for any API data type.  the OutputDataStream is defined in Each Class.
	public void displayData(){
		DiagnosticsInstrumentation.debug('--------------- DATA RECEIVED ---' + getTag());
		outputDataStream();
	}

	public virtual void outputDataStream(){
	}

	public void displayToInsert(){
		DiagnosticsInstrumentation.debug('--------------- DATA TO BE INSERTED ---' + getTag());
		outputToInsertStream();
	}

	public virtual void outputToInsertStream(){
	}

	public virtual void displaySetOfExternalIDs(){
		DiagnosticsInstrumentation.push('------- DisplaySetOfExternalIDs ---' + getTag());
		integer iCounter = 0	;
		for (string st : setOfExternalIDs){
			DiagnosticsInstrumentation.debug('['+iCounter+'] ID in set : ' + st);
			iCounter++;
		}
		DiagnosticsInstrumentation.pop();
	}

	public virtual void displayMapOfExistingIDs(){
		DiagnosticsInstrumentation.push('-------- DisplayMapOfExistingIDs ---' + getTag());
		integer iCounter = 0;
		string stvalue = '';
		for (string st : existingIDsMap.KeySet() )	{
			stvalue = existingIDsMap.get(st);
			DiagnosticsInstrumentation.debug('['+iCounter + '] Key: ' + st + '******  Value: ' + String.Valueof(stvalue));
			iCounter ++;
		}
		DiagnosticsInstrumentation.pop();
	}

	public virtual void displayMapOfExistingDates(){
		DiagnosticsInstrumentation.push('-------- DisplayMapOfExistingDates ---' + getTag());
		integer iCounter = 0;
		string stvalue = '';
		for (string st : existingDatesMap.KeySet() )	{
			stvalue = existingDatesMap.get(st);
			DiagnosticsInstrumentation.debug('['+iCounter + '] Key: ' + st + '******  Value: ' + String.Valueof(stvalue));
			iCounter ++;
		}
		DiagnosticsInstrumentation.pop();
	}


	public void displayResults(){
		DiagnosticsInstrumentation.push('--------------- RESULTS OF UPSERT ---' + getTag() + '-------------------------------------');
		DiagnosticsInstrumentation.debug('============================================================================================');
		displayResultsStream();
		DiagnosticsInstrumentation.pop();
	}

	public virtual void displayResultsStream(){

	}

}