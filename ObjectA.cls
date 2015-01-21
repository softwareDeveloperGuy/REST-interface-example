public class ObjectA extends APIData {


	///////////////////////////////////////////
	//// DATA definition for ObjectA from API.
	//// /////////////////////////////////////
	public class Data {
		public String id;
		public String name;
		public String created_at;
		public String updated_at;
	}
	/////////////////////////////////////////
	//  Members needed that represent API Data
	/////////////////////////////////////////
	public Data API_CurrentObject;
	public List<Data> data;				// populated by parse()
	public List<Data> batchObjectA;		// populated by batchAccumulator


	/////////////////////////////////////////////
	// SalesForce members.
	/////////////////////////////////////////////
	public ObjectA__c ObjectA;
	public Map<string, ObjectA__c> mapOfObjectA;

	/////////////////////////////////////////////
	// Constructor(s)
	/////////////////////////////////////////////
	public ObjectA() {
		batchObjectA = new List<Data>();
		setTag('ObjectA');
	}

	public ObjectA(string tagLine) {
		batchObjectA = new List<Data>();
		if (tagLine != null) setTag(tagLine);
	}

	/////////////////////////////////////////////////////////////////
	///IAPIDATA interface implementation
	/////////////////////////////////////////////////////////////////
	public static ObjectA parse(String json) {
		return (ObjectA) System.JSON.deserialize(json, ObjectA.class);
	}

	public ObjectA getDataStructure(String jSON){
		return ObjectA.parse(jSON);
	}


	public void batchAccumulator(IAPIData accumulateFrom) {
		List<Data> apiData = ((ObjectA)accumulateFrom).data;
		if (TMBEnvironment.ImportLatestDataOnly == true){
			filterData(apiData) ;
		} else {
			if (apiData != null) {
				batchObjectA.AddAll(apiData);
			}
		}
	}

	public void filterData(List<Data> apiData){
		Date cutOffDate = Date.Today().AddDays(Integer.valueOf(TMBEnvironment.ImportLatestDays) * -1);
		for (Data d : apiData){
			if ((Date.ValueOf(d.updated_at)  >= cutOffDate ) || (Date.ValueOf(d.created_at) >= cutOffDate)){
			//if (Date.ValueOf(d.created_at)  >= cutOffDate ) {
				batchObjectA.Add(d);
			}
		}
	}

	public void persistData() {
        DiagnosticsInstrumentation.push('persistData ' + getTag());
        displayData();
		mapOfObjectA = new Map<String, ObjectA__c>();
		for (Data dt : batchObjectA){
			if (RequiresUpdate(dt.id, dt.updated_at)){
				API_CurrentObject = dt;
				ObjectA = mapDataToObject();
				if (ObjectA != null) {
					mapOfObjectA.put(dt.id, ObjectA);
				}
			}
		}
		if (mapOfObjectA.Size() > 0){
			displayToInsert();
			upsertRecords(mapOfObjectA.values());
			displayResults();
		}
        DiagnosticsInstrumentation.pop();
	}

	public ObjectA__c mapDataToObject(){
		ObjectA__c ObjectA 			= new ObjectA__c();
		ObjectA.User_ID__c    		= API_CurrentObject.id;
		ObjectA.Name 		 		= API_CurrentObject.name;
		ObjectA.ext_created_at__c 	= API_CurrentObject.created_at;
		ObjectA.ext_updated_at__c 	= API_CurrentObject.updated_at;

		return ObjectA;
	}

	public string GetPartialURI(){
		Return TMBEnvironment.ObjectAURI;
	}

	/////////////////////////////////////////////////////////////////////
	////Helper Methods
	/////////////////////////////////////////////////////////////////////

	public override void upsertRecords(List<sObject> recordSet){
		DiagnosticsInstrumentation.push('upsertRecords' + getTag());
		upsertListResults = Database.Upsert(mapofObjectA.values(), ObjectA__c.Fields.user_id__c, false);
		processUpsertResponse();
		DiagnosticsInstrumentation.pop();
	}


    public void AddDataToBatchList( string id){
    	// All data should be here, since this object isupdated thru the Songs which have it already.
		Data initData = new Data();
		initData.id = id;
		batchObjectA.Add(initData);
    }

    public override void updateLookup(){
    	if (existingIDsMap == null) {
    		setOfExternalIDs = null;
    		populatesetOfExternalIDs();
			existingIDsMap = new Map<String, ID>();
			existingDatesMap = new Map<String, String>();
			for(ObjectA__c ac : [SELECT a.id, a.User_id__c, a.ext_updated_at__c FROM ObjectA__c a WHERE a.User_id__c IN :setOfExternalIDs] ) {
				existingIDsMap.put(ac.user_id__c, ac.id);
				existingDatesMap.put(ac.user_id__c, ac.ext_updated_at__c);
			}
			displayMapOfExistingIDs();
			displayMapOfExistingDates();
		}
    }

    public override void populatesetOfExternalIDs(){
		setOfExternalIDs = new Set<String>();
		for (Data d : batchObjectA){
			setOfExternalIDs.Add(d.id);
		}
		displaySetOfExternalIDs();

    }

    public string addParameters(){
		string returnValue='';
		if (TMBEnvironment.IncludeInactiveSongsObjectA == true) {
			returnValue = '&with_inactive=true';
		}
		return returnValue;
	}

	public Override integer getMaxCallouts() {
		return Integer.ValueOf(TMBEnvironment.MaxCallouts);
	}

	public override Import_Detail__c processErrorRecord(Database.Error[] errList, integer idx){
    	Import_Detail__c returnDetail = new Import_Detail__c();
		returnDetail.Detail_Type__c = 'Error';
		returnDetail.Import_Batch__c = GetCurrentImportBatchID();
		for(Database.Error err : errList) {
			returnDetail.Message__c = returnDetail.Message__c + 'Error: ' + err.getStatusCode() + ': ' + err.getMessage() + '.  Affected Fields: ' + err.getFields() + '\n';
		}
		returnDetail.Message__c = returnDetail.Message__c + getObjectAInformation(mapOfObjectA.values()[idx]);
    	return returnDetail  ;
    }


	public override void outputDataStream(){
		if (batchObjectA != null) {
			integer iCounter = 0;
			for(Data dt : batchObjectA) {
				DiagnosticsInstrumentation.debug('['+iCounter+'] ObjectA ID: ' + dt.id + '--- Name: ' + dt.Name );
				iCounter ++;
			}
		} else {
			DiagnosticsInstrumentation.debug('NO DATA RECEIVED.');
		}
	}

	public override void outputToInsertStream(){
		integer iCounter = 0;
		for (ObjectA__c ar : mapOfObjectA.values()) {
			DiagnosticsInstrumentation.debug(' ('+iCounter + ') ' + getObjectAInformation(ar) );
			iCounter ++;
		}
	}

	public override void displayResultsStream(){
		integer iCounter = 0;
		string objectInfo = '';
		for (Database.UpsertResult sr : upsertListResults) {
			objectInfo	=  getObjectAInformation(mapOfObjectA.Values()[iCounter]);
			objectInfo = '(' + iCounter + ') ' + objectInfo;
		    if (sr.isSuccess() == false) {
		        for(Database.Error err : sr.getErrors()) {
					DiagnosticsInstrumentation.debug(objectInfo + ' ***  ERROR Has Occurred:');
		         	DiagnosticsInstrumentation.debug('     ' + err.getStatusCode() + ': ' + err.getMessage());
		           	DiagnosticsInstrumentation.debug('      Fields that affected this error: ' + err.getFields());
		        }
		    }
			if (sr.isSuccess() && sr.isCreated()) {
				DiagnosticsInstrumentation.debug(objectInfo + ' ****** ObjectA CREATED.  SFID: ' + sr.getId() );
			}
		    if (sr.isSuccess() && sr.isCreated() == false) {
				DiagnosticsInstrumentation.debug(objectInfo + ' ****** ObjectA UPDATED.  SFID: ' + sr.getId() );
		    }
		    iCounter ++;
		}
	}

	private string getObjectAInformation(ObjectA__c art){
		return(	'ObjectA ID: ' 	+ art.user_id__c + '\t' +
							'Name: ' 	+ art.name);
	}

}