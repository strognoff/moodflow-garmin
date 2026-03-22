import Toybox.Lang;
import Toybox.Application.Storage;

//! Persistent storage for MoodFlow data
class MoodFlowDataStore {

    function initialize() {
    }
    
    //! Get a value from storage
    function getValue(key as String) as Object? {
        return Storage.getValue(key);
    }
    
    //! Set a value in storage
    function setValue(key as String, value as Object) as Void {
        Storage.setValue(key, value);
    }
    
    //! Remove a value from storage
    function removeValue(key as String) as Void {
        Storage.deleteValue(key);
    }
}