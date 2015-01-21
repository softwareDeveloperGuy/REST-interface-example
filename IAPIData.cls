///////////////////////////////////////////////////////////
//// The API Interface for Data classes that
//// need to be imported.
//////////////////////////////////////////////////////////
public interface IAPIData {
	IAPIData Parse(String json);
	IAPIData getDataStructure(String jSON);
	void batchAccumulator(IAPIData accumulateFrom);
	void Persistdata();
	sObject MapDataToObject();
	String GetPartialURI();
	integer getNextURLValue();
	boolean keyExistsInMap(string mapKey);
	id getSFID(string mapKey);
	void SetCurrentImportBatchID(ID batchID);
	ID GetCurrentImportBatchID();
	integer getNewRecordCount();
	integer getUpdatedRecordCount();
	integer getErrorRecordCount();
	string addParameters();
	string completeCalloutURI(string batchPartialURL, string batchParameters, string nextPage);
	integer getMaxCallouts();
	boolean RequiresUpdate(string mapKey, string externalValue);
}