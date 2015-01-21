# REST-interface-example
This example code implements an Interface to a REST Service from which a number of Objects will be updated from.
This implementation uses Object Oriented principles in order to define a reusable implementation with any object.
The idea is that in order to add a new object to the interface, one would just need to create a new concrete class that implements the IAPIData interface.

## Main Classes
* IAPIData.cls - Defines the Interface  Class for all of the Concrete Data Classes to use.
* APIData.cls  - Implements IAPIData from which all Object Data Classes are derived from.
* API.cls - Main Class that Controls the Interface Import

## Concrete Classes
* ObjectA.cls - Example of one concrete class.
* Object[N] - New concrete classes need to be added to process new objects.

## Helper Classes
* DiagnosticsInstrumentation.cls  -- this class aids in debugging.
* Environment.cls and EnvironmentVariable.cls -- Class used throughout the project to configure the solution.

## Object Models
* Import_Batch__c.ojbect - Data that dries the API.cls class to perform imports from the REST service.
* Import_Detail__c.object - results from import such as errors / warnings.





