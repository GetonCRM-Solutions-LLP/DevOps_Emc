@istest
public with sharing class WrappperTax_Test {
	public static testmethod void testmethod1(){
		WrappperTax wrap = new WrappperTax();
		WrappperTax wrap1 = new WrappperTax(1,10,12,10,23);
	}
}