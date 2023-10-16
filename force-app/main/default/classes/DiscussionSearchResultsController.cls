public class DiscussionSearchResultsController {
	
	public String paramKey = System.currentPageReference().getParameters().get('key');
	
	public void setParamkey (String paramKey) {
		this.paramKey = paramKey;
	}
	
	public Boolean isTestController = false;
	public void setIsTestController (Boolean isTestController) {
		this.isTestController = isTestController;
	}
	
	public Boolean getIsTestController () {
		return isTestController;
	}
	
	public DiscussionSearchResultsController () {
		contructorFunction();
	}
	
	public void contructorFunction () {
		if (paramKey != null) {
			criteria = paramKey;
			search();
		}	
	}
	
	/* ************************ */
	/*			Search			*/
	/* ************************ */
	
	public String criteria;
	
	public String getCriteria () {
		return criteria;
	}
	
	public void setCriteria (String criteria) {
		this.criteria = criteria;
	}
	
	public class searchResult {
		String title;
		String matches;
		String url;
		
		public void setTitle (String title, String criteria) {
			String highlight = '';
			if (title != null) {
				String titleLow = title.toLowerCase();
				String criteriaLow = criteria.toLowerCase();
				
				if (criteria != null && criteria != '' && titleLow.indexOf(criteriaLow) != -1) {
					highlight = title.replaceAll('(?i)' + criteria, '<span class="highlight">$0</span>');
				}
				else {
					highlight = title;
				}
			}
			this.title = highlight;	
		}
		
		public void setMatches (String matches, String criteria) {
			String highlight = '';
			Integer maxLength = 50;
			if (matches != null) {
				String matchesLow = matches.toLowerCase();
				String criteriaLow = criteria.toLowerCase();
				matches = matches.replaceAll('(?i)<[^>]*>', '');
				if (criteria != null && criteria != '' && matchesLow.indexOf(criteriaLow) != -1) {
					Integer msjLength = matches.length();
					Integer iniHighLight = matchesLow.indexOf(criteriaLow) - 50;
					Integer criteriaLength = criteria.length();
					Integer endHighLight = matchesLow.indexOf(criteriaLow) + criteriaLength + 50;
					if (iniHighLight < 0) {
						if (endHighLight > msjLength) {
							highlight = matches.substring(0,msjLength);	
						}
						else {
							highlight = matches.substring(0,endHighLight) + '...';	
						}
					}
					else {
						System.debug('\n\n//////////////end \n\n'+endHighLight+'\n\n//////////////');	
							System.debug('\n\n////////////// ini \n\n'+iniHighLight+'\n\n//////////////');
							System.debug('\n\n////////////// matches n\n'+matches.length()+'\n\n//////////////');
						if (endHighLight > msjLength) {
							if(matches.length() >= iniHighLight) {
								highlight = '...' + matches.substring(iniHighLight,msjLength);
							}

						}
						else {
							highlight = '...' + matches.substring(iniHighLight,endHighLight) + '...';	
						}		
					}
					
					highlight = highlight.replaceAll('(?i)' + criteria, '<span class="highlight">$0</span>');
				}
				else {
					if(matches.length() <= maxLength*2) {
						highlight = matches;	
					}
					else {
						//highlight = matches;
						highlight = matches.substring(0,maxLength*2) + '...';	
					}	
				}
			}
			this.matches = highlight;
		}
		
		public void setUrl (List<DiscussionMessage__c> messageList, String topicId , Datetime msjDate) {
			
			Boolean find = false;
			Integer posDown;
			Integer posTop;
			Decimal posD;
			Decimal posDecimal;
			Decimal posDR;
			Integer posMiddle;
			
			if (messageList.size() != 0) {
				posDown = 0;
				posTop = messageList.size() - 1;
				
				posD = Decimal.valueOf(posTop + posDown);
				posDecimal = posD.divide(2,1);
				posDR = posDecimal.round(RoundingMode.DOWN);
				posMiddle = posDR.intValue();
							
				for(Integer i = 0; i < messageList.size(); i++){
					if (messageList.get(posMiddle).PostedDate__c == msjDate) {
						find = true;
					}
					else {
						if (msjDate < messageList.get(posMiddle).PostedDate__c) {
							posTop = posMiddle;	
							posD = Decimal.valueOf(posTop + posDown);
							posDecimal = posD.divide(2,1);
							posDR = posDecimal.round(RoundingMode.DOWN);
							posMiddle = posDR.intValue();
						}
						else {
							posDown = posMiddle;
							posD = Decimal.valueOf(posTop + posDown);
							posDecimal = posD.divide(2,1);
							posDR = posDecimal.round(RoundingMode.UP);
							posMiddle = posDR.intValue();
						}
						
					}
				
				
				}
				
			}
			else {
				posTop = 0;
				posDown = 0;
				posMiddle = 0;	
			}
			
			Integer numItemPerPage = 10;
			Integer numPage;
			if (posMiddle != 0) {	
				numPage = (posMiddle - (Math.mod(posMiddle, numItemPerPage)))/ numItemPerPage;
				if (Math.mod(posMiddle, numItemPerPage) != 0 ) {
		   			numPage++;
		   		} 
				
				if (numPage <= 1) {
					this.url = 'https://na1.salesforce.com/apex/DiscussionDetail?id='+ topicId;
				}
				else {
					this.url = 'https://na1.salesforce.com/apex/DiscussionDetail?id='+ topicId +'&p=' + numPage;	
				}
			}
			else {
				numPage = 1;
				this.url = 'https://na1.salesforce.com/apex/DiscussionDetail?id='+ topicId;
			}
		}
		
		
		public String getTitle () {
			return title;
		}
		
		public String getMatches () {
			return matches;
		}
		
		public String getUrl () {
			return url;
		}
	}	
	
	public List<searchResult> results = new List<searchResult>();
	
	public List<searchResult> getResults () {
		return results;
	}
	
	public Integer totalItemsNumber= 0;
	
	public Integer getTotalItemsNumber () {
		return totalItemsNumber;
	}
	
	public Boolean noMatches;
	
	public Boolean getNoMatches () {
		return noMatches;	
	}
	
	
	
	public void search () { 
		List<searchResult> resultList = new List<searchResult>();
		criteria = criteria.trim();
		List<DiscussionTopic__c> listTopicsMsj = new List<DiscussionTopic__c>();
		
		if(getIsTestController()){
			listTopicsMsj = [Select d.Id, (Select PostedDate__c, Id, Subject__c From DiscussionTopic__r order by PostedDate__c limit 10) from DiscussionTopic__c d limit 10];
		}
		else{
			listTopicsMsj = [Select d.Id, (Select PostedDate__c, Id, Subject__c From DiscussionTopic__r order by PostedDate__c) from DiscussionTopic__c d];
		}
			 
		if (criteria == null || criteria == '') {
			for(DiscussionMessage__c item: [select PostedDate__c, DiscussionTopic__c, Subject__c, Message__c from DiscussionMessage__c order by Subject__c ]) {
				searchResult resultItem = new searchResult();
				
				resultItem.setTitle(item.Subject__c, criteria);
				resultItem.setMatches(item.Message__c, criteria);
				
				Boolean find = false;
				List<DiscussionMessage__c> topicMsj = new List<DiscussionMessage__c>();
				Integer posListTopicsMsj = 0;
				
				for(Integer it = 0; it < listTopicsMsj.size(); it++) {
					if (listTopicsMsj.get(it).Id == item.DiscussionTopic__c) {
						topicMsj = listTopicsMsj.get(it).DiscussionTopic__r;
					}
				}
				
				resultItem.setUrl(topicMsj, item.DiscussionTopic__c, item.PostedDate__c); 
				resultList.add(resultItem);
			}
			System.debug('\n \n ////////////////////////////////// \n SAVE THIS resultList: ' + resultList.size() + '\n //////////////////////////// \n \n');
		}
		else {
			results = null;
			//System.debug('\n /////////////////////////// \n SAVE THIS RESULTS FOR: \n \t CRITERIA: ' + criteria + '\n \t RESULTS: ' + (List<DiscussionMessage__c>)[FIND :(criteria + '*') IN ALL FIELDS RETURNING DiscussionMessage__c (Subject__c, Message__c, Id ORDER BY Subject__c)][0] + '\n ///////////////////// \n');
			for(DiscussionMessage__c item: (List<DiscussionMessage__c>)[FIND :(criteria + '*') IN ALL FIELDS RETURNING DiscussionMessage__c (PostedDate__c , Subject__c, Message__c, DiscussionTopic__c, Id ORDER BY Subject__c)][0]) {
				searchResult resultItem = new searchResult();
				resultItem.setTitle(item.Subject__c, criteria);
				resultItem.setMatches(item.Message__c, criteria);
				
				List<DiscussionMessage__c> topicMsj = new List<DiscussionMessage__c>();
				for(Integer it = 0; it < listTopicsMsj.size(); it ++ ){
					if (listTopicsMsj.get(it).Id == item.DiscussionTopic__c) {
						topicMsj = listTopicsMsj.get(it).DiscussionTopic__r;
					}
				}
				
				
				resultItem.setUrl(topicMsj, item.DiscussionTopic__c, item.PostedDate__c); 
				resultList.add(resultItem);
			}
			System.debug('\n \n ////////////////////////////////// \n SAVE THIS resultList: ' + resultList.size() + '\n //////////////////////////// \n \n');
		}
		totalItemsNumber = resultList.size();
		if (totalItemsNumber == 0 ) {
			noMatches = true;
			cntPagination = 0;	
			firstRow = 0;
			currentPagination = 1;
			jumpPage = 1;
		}
		else {
			noMatches = false;
			firstRow = 0;
			currentPagination = 1;
			jumpPage = 1;
			genCntPagination();	
		}
		results = resultList;
		resultList = null;
		listTopicsMsj = null;
	}
	
	
	
	/* ************************ */
	/*		  Pagination		*/
	/* ************************ */
   	
    /**
   	* Set of Integers to control pagination
   	*/
   	public Integer numberOfItemsToShow = 10;
   	public Integer cntPagination;
   	public Integer currentPagination = 1;
   	public Integer firstRow = 0;
   	
   	/**
   	* Set of Booleans to show or not prev / next links
   	*/
   	public boolean prevPageLinkShow = false;
   	public boolean prevPageShow  = false;
   	public boolean nextPageLinkShow  = false;
   	public boolean nextPageShow  = false;
   	   	
   	public void genCntPagination () {
   		
   		cntPagination = (totalItemsNumber - (Math.mod(totalItemsNumber, numberOfItemsToShow)))/ numberOfItemsToShow;	
   		if (Math.mod(totalItemsNumber, numberOfItemsToShow) != 0 ) {
   			cntPagination++;
   		} 	
   		
   	}
   	
   	public void nextPage () {
   		currentPagination++;
   		jumpPage = currentPagination;
   		firstRow = firstRow + numberOfItemsToShow;   		
   	}
   	
   	public void prevPage () {
   		currentPagination--;
   		jumpPage = currentPagination;
   		firstRow = firstRow - numberOfItemsToShow;	
   	}

	/* Last Page */
   	public void lastPage () {
   		currentPagination = cntPagination;
		jumpPage = cntPagination;
		firstRow = (jumpPage - 1)* numberOfItemsToShow;		
   	}
   	
   	/* First Page */
   	public void firstPage () {
   		currentPagination = 1;
   		jumpPage = 1;
   		firstRow = (jumpPage - 1)* numberOfItemsToShow;	
   	}

   	public void refreshPages () {
   		
   	}
   	/**
   	* Pagination Integer Getters
   	*/
   	public Integer getFirstItem () {
		return (firstRow + 1);
	}
	
	public Integer getLastItem () {
		Integer lastItem;
		if ((currentPagination == cntPagination) || (currentPagination == 1 && (totalItemsNumber < numberOfItemsToShow))) {
			lastItem = firstRow + Math.mod(totalItemsNumber, numberOfItemsToShow);
		}
		else {
			lastItem = firstRow + 10;
		}
		return lastItem;
	}
   	
   	public Integer getCurrentPagination () {
   		return currentPagination;
   	}
   	
   	public Integer getCntPagination () {
   		return cntPagination;
   	}
   	
   	public Integer getNumberOfItemsToShow () {
   		return numberOfItemsToShow;
   	}
   	
   	public Integer getFirstRow () {
   		return firstRow;
   	}
   	
   	/**
   	* Pagination Boolean Getters
   	*/
   	
	public boolean getPrevPageLinkShow () {
		
		if(currentPagination == 1){ prevPageLinkShow = false;		
		} else {prevPageLinkShow = true;}
		
   		return prevPageLinkShow;
   	}
   	
   	public boolean getPrevPageShow () {
   		
   		if(currentPagination == 1){	prevPageShow = true; 
   		} else {prevPageShow = false;}
   		
   		return prevPageShow;
   	}
   	
   	public boolean getNextPageLinkShow () {
   		
   		if((currentPagination == cntPagination) || (cntPagination == 0)){	nextPageLinkShow = false; 
		} else { nextPageLinkShow = true;}   		
   		
   		return nextPageLinkShow;
   	}
   	
   	public boolean getNextPageShow () {
   		
   		if((currentPagination == cntPagination) || (cntPagination == 0)){ nextPageShow = true; 
		} else { nextPageShow = false;} 
   		
   		return nextPageShow;
   	}	
   	
	/* ************************ */
	/*		  Jump to Page		*/
	/* ************************ */
	
	public Integer jumpPage = 1;
	
	public Integer getJumpPage () {
		return jumpPage;
	}
	
	public void setJumpPage (Integer jumpPage) {
		this.jumpPage = jumpPage;
	}
	
	public void JumpToPage () {
		if (jumpPage > cntPagination) {
			currentPagination = cntPagination;
			jumpPage = cntPagination;
		}
		else {
			if (jumpPage < 1) {
				currentPagination = 1;
				jumpPage = 1;
			}
			else {	
				currentPagination = jumpPage;
			}
		}
		firstRow = (jumpPage - 1)* numberOfItemsToShow;
	}
	

}