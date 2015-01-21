global class Environment {

    global static final String BASEURI_KEY = 'BaseURI';
    global static String BaseURI {
        set{ EnvironmentVariable.put(BASEURI_KEY,value); }
        get{ return EnvironmentVariable.get(BASEURI_KEY); }
    }

    global static final String TOKEN_KEY = 'Token';
    global static String Token {
        set{ EnvironmentVariable.put(TOKEN_KEY,value); }
        get{ return EnvironmentVariable.get(TOKEN_KEY); }
    }

    global static final String MAX_CALLOUTS_KEY = 'Max_Callouts';
    global static String MaxCallouts {
        set{ EnvironmentVariable.put(MAX_CALLOUTS_KEY,value); }
        get{ return EnvironmentVariable.get(MAX_CALLOUTS_KEY); }
    }

    global static final String MIN_CALLOUTS_KEY = 'Min_Callouts';
    global static String MinCallouts {
        set{ EnvironmentVariable.put(MIN_CALLOUTS_KEY,value); }
        get{ return EnvironmentVariable.get(MIN_CALLOUTS_KEY); }
    }

    // default
    global static final String MAX_BATCH_RECORDS_KEY = 'Max_batch_records';
    global static String MaxBatchRecords {
        set{ EnvironmentVariable.put(MAX_BATCH_RECORDS_KEY,value); }
        get{ return EnvironmentVariable.get(MAX_BATCH_RECORDS_KEY); }
    }

    global static final string INCLUDE_DELTAS_IN_IMPORT_KEY = 'Include_deltas_in_Import';
    global static Boolean IncludeDeltasInImport {
        set{ EnvironmentVariable.put(INCLUDE_DELTAS_IN_IMPORT_KEY, CommonFunctions.convertBooleanToString(value));}
        get{ return CommonFunctions.convertStringToBoolean(EnvironmentVariable.get(INCLUDE_DELTAS_IN_IMPORT_KEY));}
    }

    global static final String TRACK_UPDATED_RECORDS_KEY = 'Track_Updated_records';
    global static Boolean trackUpdatedRecords {
        set{ EnvironmentVariable.put(TRACK_UPDATED_RECORDS_KEY, CommonFunctions.convertBooleanToString(value));}
        get{ return CommonFunctions.convertStringToBoolean(EnvironmentVariable.get(TRACK_UPDATED_RECORDS_KEY));}
    }

    global static final String DIAGNOSTICS_ENABLED_KEY = 'DiagnosticsEnabled';
    global static Boolean DiagnosticsEnabled {
        set{ EnvironmentVariable.put(DIAGNOSTICS_ENABLED_KEY, CommonFunctions.convertBooleanToString(value));}
        get{ return CommonFunctions.convertStringToBoolean(EnvironmentVariable.get(DIAGNOSTICS_ENABLED_KEY));}
    }

    global static final String BATCHMODE_ENABLED_KEY = 'Batch_Mode_Enabled';
    global static Boolean BatchModeEnabled {
        set{ EnvironmentVariable.put(BATCHMODE_ENABLED_KEY, CommonFunctions.convertBooleanToString(value));}
        get{ return CommonFunctions.convertStringToBoolean(EnvironmentVariable.get(BATCHMODE_ENABLED_KEY));}
    }

    global static final String IMPORT_LATEST_ONLY_KEY = 'Import_Latest_Data_only';
    global static Boolean ImportLatestDataOnly {
        set{ EnvironmentVariable.put(IMPORT_LATEST_ONLY_KEY, CommonFunctions.convertBooleanToString(value));}
        get{ return CommonFunctions.convertStringToBoolean(EnvironmentVariable.get(IMPORT_LATEST_ONLY_KEY));}
    }

    global static final String IMPORT_LATEST_DAYS_KEY = 'Import_Latest_Days';
    global static String ImportLatestDays {
        set{ EnvironmentVariable.put(IMPORT_LATEST_DAYS_KEY,value); }
        get{ return EnvironmentVariable.get(IMPORT_LATEST_DAYS_KEY); }
    }

    global static final String ABORT_ALL_JOBS = 'ABORT_ALL_JOBS';
    global static Boolean AbortAllJobs {
        set{ EnvironmentVariable.put(ABORT_ALL_JOBS, CommonFunctions.convertBooleanToString(value));}
        get{ return CommonFunctions.convertStringToBoolean(EnvironmentVariable.get(ABORT_ALL_JOBS));}
    }
    public static void SetDefaultEnvironment(String type) {

        Environment.BaseURI              = 'https://ADD_API_URL_HERE';
        Environment.Token                = 'ADD_TOKEN_TO_THE_SERVICE_HERE';
        Environment.MaxCallouts          = '10';
        Environment.MinCallouts          = '1';
        Environment.MaxBatchRecords      = '100';
        Environment.trackUpdatedRecords  = false;
        Environment.DiagnosticsEnabled   = false;
        Environment.BatchModeEnabled       = true;
        Environment.ImportLatestDays       = '7' ;
        Environment.MaxBatchRecords      = '100';
    }
}