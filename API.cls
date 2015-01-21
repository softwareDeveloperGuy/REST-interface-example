public class API {

		public Import_Batch__c CurrentBatch;
		public IAPIData batchData;
		public string batchStatus;
		public Boolean completeAfterOneIteration = false;

		//constructor
		public API() {
			LoadBatchFromQueue();
		}


		public static void runIt(){
			try {
				API at = new API();
				at.importCurrentBatch();
			}catch (exception ex) {
				DiagnosticsInstrumentation.DebugException(ex);
                DiagnosticsInstrumentation.PopAll();
			}
		}

		// Handler for the different types of Batch Imports.
		// Centralized function to import batches.
		public void importCurrentBatch() {
			DiagnosticsInstrumentation.push('importCurrentBatch API');
			If (CurrentBatch != null){
				CurrentBatch.Job_Status__c = 'Processing';
				if (CurrentBatch.Import_Type__c 	  == 'ObjectA') {
					batchData = new ObjectA();
				//} else if(CurrentBatch.Import_Type__c == 'ObjectB'){
				//	batchData = new ObjectB();
				//} else if(CurrentBatch.Import_Type__c == 'ObjectC'){
				//	batchData = new ObjectC();
				//} else if(CurrentBatch.Import_Type__c == 'ObjectD'){
				//	batchData = new ObjectD();
				//} else if(CurrentBatch.Import_Type__c == 'ObjectE'){
				//	batchData = new ObjectE();
				//} else if(CurrentBatch.Import_Type__c == 'ObjectF'){
				//	batchData = new ObjectF();
				//} else if(CurrentBatch.Import_Type__c == 'ObjectG'){
				//	batchData = new ObjectG();
				//} else if(CurrentBatch.Import_Type__c == 'ObjectH'){
				//	batchData = new ObjectH();
				}
				DiagnosticsInstrumentation.debug('WORKING ON BATCH:  ' + CurrentBatch.Import_Type__c);
				DiagnosticsInstrumentation.Debug('====================================================');
				if (batchData != null) {
					DiagnosticsInstrumentation.Debug('Starting BATCH: ' + currentBatch.import_type__c);
				}else{
					DiagnosticsInstrumentation.Debug('NO BATCH IN QUEUE');
				}
				DiagnosticsInstrumentation.Debug('====================================================');
                try{
                	batchData.SetCurrentImportBatchID(currentBatch.Id);
                    GetAllData();
                    saveBatchData();
                    update CurrentBatch;
                } catch(Exception ex){
                    DiagnosticsInstrumentation.DebugException(ex);
                    DiagnosticsInstrumentation.PopAll();
                }
            }
            DiagnosticsInstrumentation.pop();
        }


		//////////////////////////////////////////////////////////////////////////////////
		///// NOTE that the importing of batches is a Two Step Process
		//////////////////////////////////////////////////////////////////////////////////

		// STEP1: Generic GetAllData
		// Responsible for populating the batchData from API calls.
		public void GetAllData(){
			DiagnosticsInstrumentation.push('GetAllData API');
			Integer nextValue = 0;
			Integer callOutsCounter = 0;
			Boolean doneProcessing = false;
			String batchPartialURL = batchData.GetPartialURI();
			batchStatus = 'Processing';
			String batchParameters = batchData.addParameters();
			String callOutURI = '';
			do {
				callOutURI = batchData.completeCalloutURI(batchPartialURL, batchParameters, string.valueof(CurrentBatch.Next_Page__c));
				DiagnosticsInstrumentation.Debug('====================================================');
				DiagnosticsInstrumentation.debug('FULL URL FOR CALLOUT ' + callOutURI);
				DiagnosticsInstrumentation.Debug('====================================================');
				HttpResponse response = makeRequest(callOutURI);
				callOutsCounter++;
				if (response == null) {
					batchStatus = 'Error';
					doneProcessing = true;
				} else {
					IAPIData data = batchData.getDataStructure(response.getBody());
					batchData.batchAccumulator(data);
					nextValue = data.getNextURLValue();
					CurrentBatch.Last_Page__c = CurrentBatch.Next_Page__c;
					CurrentBatch.Next_Page__c = nextValue;
					if (nextValue == 1 ) {
						doneProcessing = true;
						batchStatus = 'Completed';
					}
					// NOTE: This will run faster because it only iterates thru one callout.  Use for testing only.
					if (completeAfterOneIteration == true ) {  To do Quick Runs and test scheduler
						doneProcessing = true;
						batchStatus = 'Completed';
					}
				}
			} while( (callOutsCounter <  batchData.getMaxCallouts()) && (doneProcessing == false));
			DiagnosticsInstrumentation.pop();
		}

		// STEP2: Generic SaveBatchData
		// Responsible for Saving the data to files.
		public void saveBatchData() {
			DiagnosticsInstrumentation.push('saveBatchData API');
			If ((CurrentBatch != null) && (batchData != null)) {
				// process the state.
				if (batchStatus != 'Error') {
					batchData.persistData();
				}
			}
			CurrentBatch.Job_Status__c = batchStatus;
			CurrentBatch.totals_imported__c = CurrentBatch.totals_imported__c + batchData.getNewRecordCount();
			CurrentBatch.totals_Errors__c = CurrentBatch.totals_Errors__c + batchData.getErrorRecordCount();
			CurrentBatch.totals_updated__c = CurrentBatch.totals_updated__c + batchData.getUpdatedRecordCount();
			DiagnosticsInstrumentation.pop();
		}

		public void LoadBatchFromQueue() {
			// Give precedence to Processing Jobs.  Before starting Queued ones.
			DiagnosticsInstrumentation.push('loadBatchFromQueue API');
			 try{
				CurrentBatch = [SELECT ID, Import_Type__c, Job_Status__c,  Last_Page__c, Next_Page__c, totals_imported__c, totals_Errors__c, totals_updated__c
				     FROM import_batch__c
				     WHERE job_status__c = 'Processing' LIMIT 1];
			 }
			 catch (Exception ex) {
			 	CurrentBatch = null;
			 }

			if (CurrentBatch == null){
				try{
					CurrentBatch = [SELECT ID, Import_Type__c, Job_Status__c,  Last_Page__c, Next_Page__c, totals_imported__c, totals_Errors__c, totals_updated__c
					     FROM import_batch__c
					     WHERE job_status__c = 'Queued' LIMIT 1];

				 }
				 catch (Exception ex) {
				 	CurrentBatch = null;
				 }
			}
			if (currentBatch != null){
				if ( CurrentBatch.totals_imported__c == null) CurrentBatch.totals_imported__c = 0;
				if ( CurrentBatch.totals_Errors__c == null) CurrentBatch.totals_Errors__c = 0;
				if ( CurrentBatch.totals_updated__c == null) CurrentBatch.totals_updated__c = 0;
			}
			DiagnosticsInstrumentation.pop();
		}


		public HttpResponse makeRequest(string method){
			HttpRequest  req  = new HttpRequest();
			Http 		 http = new Http();
			HttpResponse res  = null;
			req.setEndpoint(Environment.BaseURI + method);
			req.setMethod('GET');
			req.setHeader('X-Token', Environment.Token);
			try {
				res = http.send(req);
			} catch (CalloutException ca) {
				res = null;
			}
			return res;
		}

	}