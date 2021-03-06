// Class taken out of AppleMan's book  used to store
// value pairs in an object for initializing purposes
global class EnvironmentVariable {

    global static String get(String name){
        String returnValue = null;
        final Map<String,EnvironmentVariable__c> all = EnvironmentVariable__c.getAll();
        if( name != null
            && name.trim() != null
            && name.trim().length() > 0
            && all != null
            && all.get(name) != null
        ){
            returnValue = all.get(name).value__c;
        }
        return returnValue;
    }

    global static String put(String name, String value){
        String returnValue = null; //the previous value
        if( name != null
            && name.trim() != null
            && name.trim().length() != 0
        ){
            EnvironmentVariable__c record = null;
            try{
                record = [
                    select id,value__c
                    from EnvironmentVariable__c
                    where name = :name
                ];
            }catch(QueryException e){}
            if(record == null){
                record = new EnvironmentVariable__c(
                     name = name
                    ,value__c = value
                );
            } else {
                returnValue = record.value__c;
            }
            record.value__c = value;
            if(record.id != null){
                update record;
            } else {
                insert record;
            }
        }
        return returnValue;
    }


}