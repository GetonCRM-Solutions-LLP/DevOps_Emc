public with sharing class WrappperTax {
	public integer quarterno {get;set;}
      public Double Mileages {get;set;}
      public Double Reimbursements {get;set;}
      public Double MaxIRSrate {get;set;}
      public Double ImputedAmount {get;set;}
      public WrappperTax()
      {
        this.quarterno = null; 
        this.Mileages = null; 
        this.Reimbursements =null;
        this.MaxIRSrate = null;
        this.ImputedAmount =null;      
      }
      public WrappperTax(integer quarterno,Double Mileages,Double Reimbursements,Double MaxIRSrate,Double ImputedAmount)
      {
        this.quarterno = quarterno;
        this.Mileages = Mileages;
        this.Reimbursements =Reimbursements;
        this.MaxIRSrate = MaxIRSrate;
        this.ImputedAmount =ImputedAmount;
      }
}