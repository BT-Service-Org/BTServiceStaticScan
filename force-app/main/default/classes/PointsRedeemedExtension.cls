public class PointsRedeemedExtension { 

	//public Product__c prod {get;set;}
	public List<Product__c> prods {get;set;}
	public List<Product_Redeemed__c> prls = new List<Product_Redeemed__c>();
	
	//public Id prId;
	
	Decimal pointsRedeemed = 0;
	Community_Contributor__c c = null;
	public Boolean hideButtons {get;set;} 

	public Decimal pointsAvailable {get;set;}
	
	public ShipTo shipTo {get;set;}
	
			
	public class ShipTo {
		public String street {get;set;}
		public String city {get;set;}
		public String state {get;set;}
		public String country {get;set;}
		public String zip {get;set;}
		
	}
	
	public PointsRedeemedExtension(ApexPages.StandardSetController controller) {
		System.debug('controller' + controller);
		//prod = new Product__c();
		prods = new List<Product__c>();

		prods = [select Id, Name, Points_Needed__c, Active__c, Product_Image__c,Unit_Price__c from Product__c where Id =: controller.getSelected()];
		//prods.add(prod);

		c = [select Id, Name, Total_Points_Earned__c,Points_Redeemed__c, Points_Available__c from Community_Contributor__c 
				where User__c =: UserInfo.getUserId() and Community_Rewards_Program__c =: Util.getValue('CURRENT_REWARDS_PROGRAM')];

		pointsAvailable = c.Points_Available__c;
		
		shipTo = new ShipTo();
	}

	public Boolean getHideButtons() {
		return hideButtons;
	}
	
	public void setHideButtons() {
		hideButtons = true;
	}

	public PageReference submit() {

		if (shipTo == null || shipTo.street == null || shipTo.city == null || shipTo.country == null || shipTo.zip == null) {
			
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a Shipping Address. Street, City , Country and Zipcode are required fields.');
        	ApexPages.addMessage(myMsg); 
        	return null;
		} else {
			for (Product_Redeemed__c pr : prls) {
				pr.Shipping_Street__c = shipTo.street;
				pr.Shipping_City__c = shipTo.city;
				pr.Shipping_State__c = shipTo.state;
				pr.Shipping_Country__c = shipTo.country;
				pr.Shipping_Zip_Code__c = shipTo.zip;
			}

			//create a record in products redeemed object		
			insert prls;
		}

		//subtract from points earned
		if (c.Points_Redeemed__c == null) {
			c.Points_Redeemed__c = 0;
		}
		c.Points_Redeemed__c += pointsRedeemed;
		update c;
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Congratulations! Your request was submitted successfully. You will receive a confirmation email shortly.');
        ApexPages.addMessage(myMsg); 
        setHideButtons();
 		return null;
	}
	
	public Boolean validate() {
		if (prods == null || prods.size() == 0) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one prize. ');
            ApexPages.addMessage(myMsg);
            setHideButtons();
            return false;
		} else {
			if (c.Points_Available__c <= 0) {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have any points to redeem. Please submit new contributions to earn points. ');
	            ApexPages.addMessage(myMsg);
	            setHideButtons();
	            return false;
			} else {
				System.debug('prod selected ' + prods);
				for (Product__c prod : prods) {
					Product_Redeemed__c pr = new Product_Redeemed__c(Product__c=prod.Id, Status__c='Submitted', Type__c='Product Purchase',
							Date_Purchased__c=System.Today(), Community_Contributor__c=c.Id, Purchase_Price__c=prod.Unit_Price__c);
					prls.add(pr);
					pointsRedeemed += prod.Points_Needed__c;
				}
							
			}

			System.debug('points redeemed ' + pointsRedeemed);
			if (pointsRedeemed > c.Points_Available__c) {
				System.debug('points avail ' + c.Points_Available__c);
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have sufficient points to purchase the selected prize.');
	            ApexPages.addMessage(myMsg);
	            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'You can only redeem '+c.Points_Available__c + ' .');
	            ApexPages.addMessage(myMsg1);
	            setHideButtons();
	            return false;
			} else {
				return true;
			}

		}
	}
	
	public PageReference confirm() {	
		if (validate()) { 	
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Please confirm your selection. You will not be able to make changes once you hit submit!');
	        ApexPages.addMessage(myMsg);
	        return null;
		} 
		return null;
	}
	
	public PageReference step2() {
		confirm();
		PageReference nextpage = Page.ProductRedeemedConfirmationPage;
		nextPage.setRedirect(false);
		return nextPage; 
	}
	
	

}