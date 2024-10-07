public Class checkRecursive {
    private static boolean run = true;
	private static boolean run1 = true;
	private static boolean latLongAddressFlag = true;
	private static boolean ConvertMileage = true;
    public static boolean ConvertedFlag() {
		System.debug('Class checkRecursive::'+ConvertMileage);
	if(ConvertMileage) {
		ConvertMileage = false;
		return true;
	} else {
		return ConvertMileage;
	}
}
	public static boolean runOnce() {
            System.debug('Class checkRecursive::'+run);
	    if(run) {
			run = false;
			return true;
	    } else {
	        return run;
	    }
    }
    public static boolean runSecondFlag() {
	    if(run1) {
			run1 = false;
			return true;
	    } else {
	        return run1;
	    }
    }
	public static boolean getting_SetLatLondAddressFlag() {
	    
	       return latLongAddressFlag;
	    
    }
	public static void setting_SetLatLondAddressFlag(Boolean flag) {
	    if(flag !=null){
			latLongAddressFlag=flag;
		}else{
			latLongAddressFlag=true;
		}
 	}
	 public static void setting_run(Boolean flag) {
	    if(flag !=null){
			run=flag;
		}else{
			run=true;
		}
 	}
}