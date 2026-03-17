import Toybox.Lang;
import Toybox.Application.Storage;

//! Simple storage helper for MoodFlow
class MoodFlowStorage {

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
}
