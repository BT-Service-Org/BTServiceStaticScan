public with sharing class WikiPageController {
	
	public String idWikiSite = '';
	
	public String idWikiPage = '';
	WikiPage__c	wikiPageBody;
	public List<WikiPage__c> results;
	public String theParent = '';
	public String parent = ''; 
	public Integer first = 0;
	public Integer maxView = 5;	 

   	public Info infoWP = new Info();
	
	/*
	public Boolean info = false;	 
	public Boolean go = false;
	*/
	
	public String linkpart1 = 'switchOverlay(true);;A4J.AJAX.Submit(\'_viewRoot\',\'WikiPage:auxForm\',event,{\'parameters\':{\'WikiPage:auxForm:auxLink\':\'WikiPage:auxForm:auxLink\',\'idWP2\':\'';
	public String linkpart2 = '\'} ,\'actionUrl\':\'/apex/WikiPage?javax.portlet.faces.DirectLink=true\',\'oncomplete\':function(request,event,data){switchOverlay(false);}} );return false;\" name=\"WikiPage:auxForm:auxLink\" id=\"WikiPage:auxForm:auxLink\" href=\"#\">';
	
	public WikiPageController () { 
		contructMethods();
	}
	
	public String paramIdWP = System.currentPageReference().getParameters().get('idWP');
	
	public void setParamIdWP (String paramIdWP){
		this.paramIdWP = paramIdWP;
	}
	
	public String wikiPageName = '';
	
	public String getWikiPageName () {
		String trunkName;
		if (wikiPageName.length() > 25) {
			trunkName = wikiPageName.substring(0,23) + '..';
		}
		else {
			trunkName = wikiPageName;
		}
		return trunkName;	
	}
	
	public List<WikiPage__c> wikiPageBodyList = new List<WikiPage__c>();
	
	public void contructMethods () {
		if(paramIdWP != null) {
			wikiPageBodyList = [SELECT Id, 
									   Name, 
									   ShortDescription__c, 
									   Body__c, 
									   Parent__c, 
									   LastModifiedDate,
									   PageCreatedBy__c,
									   Team__r.Id 
							    From WikiPage__c WHERE id =:paramIdWP];
			
			System.debug('\n\n//////////////////////\n SAVE THIS \nwikiPageBodyList : ' + wikiPageBodyList + '\n paramIdWP : ' + paramIdWP + '\n ///////////////////////////// \n\n');
			if (wikiPageBodyList.size() > 0) {
				wikiPageBody = wikiPageBodyList[0];
			}
			else {
				throw new CustomException('Insufficient Privileges');	
			}
			
			wikiPageName = wikiPageBody.Name;
			idWikiPage = paramIdWP; // no reason for this var...clean it up!
			
			idWikiSite = wikiPageBody.Team__r.Id;
			
			//theParent = [SELECT Id From WikiPage__c WHERE Name = 'Home' AND Team__c =:idWikiSite ].Id;
			//parent = [SELECT Id From WikiPage__c WHERE Name = 'Home' AND Team__c =:idWikiSite ].Id;
			parseHTML();
			infoGen();
			
			genPermissions(wikiPageBody.PageCreatedBy__c);
			
		}
	}
	
	
	/* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = new UserPermissions();
	
	public void genPermissions (Id OwnerId) {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(idWikiSite);
		userPermissions.setOwnerId(OwnerId);
		userPermissions.setObjectType('Wiki');
		userPermissions.setPermissions();		
	}
	
	public UserPermissions getUserPermissions () {
		System.debug('\n //////////////////////// \n USER PERMISSIONS: \n' + userPermissions + '\n //////////////////////////////// \n');
		return userPermissions;
	}
	/* ---------------------------- */		
		
	
	public String getWikiHome () {
		return [select Id from WikiPage__c where Name = 'Home' and Team__c =:idWikiSite limit 1].Id;
	}
	
	public String getWikiSiteName () {
		String teamName = '';
		if (idWikiSite != null) {
			Team__c teamNameResult = [select id, Name from Team__c where id=:idWikiSite];
			
			if (teamNameResult != null) {
				teamName = '<a href="/apex/TeamsRedirect?id=' + teamNameResult.Id + '">' + teamNameResult.name + '</a> > <a href="/apex/WikiTeamOverview?tid=' + teamNameResult.Id + '">Wiki</a> > ';	
			}
		}
		return teamName;
	}
	
	public String getidWikiPage () {
		return idWikiPage;
	}
	
	/*
	public Boolean getGo () {
		return this.go;
	}
	
	public Integer getcnt () {
		return this.cnt;
	}
	*/
	
   	/* ---------------------------- */
   	/*   	 SHOW WIKI PAGES		*/
   	/* ---------------------------- */	

	/*	
	public List<WikiPage__c> getPagesList () {
		return [ SELECT Id, Name, ShortDescription__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE Team__c =: idWikiSite ORDER BY Name ];
	}
	*/
	public WikiPage__c getWikiBody () {
		//infoGen();
		return wikiPageBody;	
	}

	
    public void getWiki() {
    	/*
    	go = false;
    	newPage = false;
    	edit = false;
    	*/
    	WikiPage__c wiki;
    	
    	//System.debug('\n \n /////////// \n GUARDE ESTA WIKI PARA MOSTRAR: / idWikiPage: ' + idWikiPage + '\n Parametro idWikiPage: ' + System.currentPageReference().getParameters().get('idWP2') + '\n Wiki: ' + wiki + '\n ///////////// \n');
    	
    	if (System.currentPageReference().getParameters().get('idWP2') == '' || System.currentPageReference().getParameters().get('idWP2') == null || System.currentPageReference().getParameters().get('idWP2') == '0') {
    		idWikiPage = getWikiHome();
    	}
    	else {
    		idWikiPage = System.currentPageReference().getParameters().get('idWP2');
    	}
    	  	
    	wiki = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];
		
		//System.debug('\n \n /////////// \n GUARDE ESTA WIKI PARA MOSTRAR: / idWikiPage: ' + idWikiPage + '\n Parametro idWikiPage: ' + System.currentPageReference().getParameters().get('idWP2') + '\n Wiki: ' + wiki + '\n ///////////// \n');
		
		Integer cntTempView = [select count() from WikiRecentlyViewed__c where User__c =:UserInfo.getUserId() AND WikiPage__c =:idWikiPage];
		if (cntTempView == 0 ) {
    		WikiRecentlyViewed__c wikiView = new WikiRecentlyViewed__c();
    		wikiView.User__c = UserInfo.getUserId();
    		wikiView.WikiPage__c = idWikiPage;
    		wikiView.Name = wiki.Name;
    		insert wikiView;
    		
    		Integer totalCnt = getCntViews(); 
			if ( totalCnt > maxView) {
				Integer delNum = totalCnt - maxView; 
				List<WikiRecentlyViewed__c> delView = [SELECT Id, Name FROM WikiRecentlyViewed__c WHERE User__c = :UserInfo.getUserId() ORDER BY LastModifiedDate limit :delNum];
				//System.debug('\n \n /////////// \n GUARDE ESTOS CONTADORES: / totalCnt: ' + totalCnt + ' / delNum: ' + delNum + ' \n REGISTROS A BORRAR : ' + delView + '\n /////////////');
				delete delView;	
			}
		}
		else {
			WikiRecentlyViewed__c tempView;
			tempView = [select User__c, WikiPage__c from WikiRecentlyViewed__c where User__c =:UserInfo.getUserId() AND WikiPage__c =:idWikiPage];
			update tempView;
		}
     	
     	//infoGen();
    	wikiPageBody = wiki;
    	//parseHTML();
    }
	
	
   	/* ---------------------------- */
   	/*   	  PARSE WIKI PAGE		*/
   	/* ---------------------------- */	 
 	public String html = null;
 	
 	public void parseHTML() {
		
		WikiPage__c wikiHTML;
    	String toc = '';
    	
    	if (idWikiPage == '0' || idWikiPage == null) {
    		wikiHTML = [SELECT Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate From WikiPage__c WHERE id =: getWikiHome()];	
    	}
    	else {
    		wikiHTML = [SELECT Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];
    	} 		
 		
  		html = wikiHTML.Body__c;
		if (html != null) {
	 		html = html.replaceAll('\n','<br>');
			html = html.replaceAll('&nbsp;',' ');
			html = html.replaceAll('&gt;','>');
			html = html.replaceAll('&lt;','<');
			
			
			/* ------------------------ */
	 		/* 		Code (No parsed) 	*/
	 		String noparsedOpen = '{{{';	
	 		String noparsedClose = '}}}';
	 		String splitOpen = '\\{\\{\\{';
	 		String splitClose = '\\}\\}\\}';
	 		String replacementCode = '%-%-%-%';
	 		List<String> noparsedText = new List<String>();
	 		while (html.lastIndexOf(noParsedOpen) != -1) {
		 		List<String> temp;
		 		temp = html.split(splitOpen ,2);
		 		List<String> temp2 = new List<String>();
		 		String code;
		 		if (temp[1].indexOf(noparsedClose) != -1) {
			 		temp2 = temp[1].split(splitClose ,2);
			 		code = temp2[0];
		 		}
		 		else {
		 			temp2.add(temp[1]);
				 	temp2.add('');
				 	code = temp[1];
		 		}
		 		
		 		html = temp[0] + replacementCode + temp2[1];
	 			noparsedText.add(code);
	 		}
 			
 			/* ------------------------ */
	 		/* 			Tables 		 	*/
			
			String tableStart = '{|';
	 		String tableStartExp = '\\{\\|';
	 		
	 		String tableEnd = '|}';
	 		String tableEndExp = '\\|\\}';
	 		
	 		String tableCaption = '|+';
	 		String tableCaptionExp = '\\|\\+';
	 		
	 		String tableRow = '|-';
	 		String tableRowExp = '\\|-';
	 		
	 		String tableHeader = '!';
	 		
	 		String tableData = '|';
	 		String tableDataExp = '\\|';
	 		
	 		while (html.lastIndexOf(tableStart) != -1) {
				List<String> htmlParts = new List<String>();
				htmlParts = html.split(tableStartExp,2);
				
				String bodyTable = '';
				String tableTag = '<table ';
				String tailHtml = '';
				
				if (htmlParts[1].indexOf(tableEnd) != -1) {
					List<String> tailParts = new List<String>();
					tailParts = htmlParts[1].split(tableEndExp,2);
					String tableContent = '';
					//System.debug('\n  //////////////( 10 )///////////////// \n SAVE THIS TABLE CONTENT: \n ' + tailParts + '\n ///////////////////////////////// \n');
					
					tableContent = tailParts[0];
					if (tailParts.size() < 2) {
						tailParts.add('');
					}
					
					tailHtml = tailParts[1];
					if (tableContent != '') {
						if (tableContent.toLowerCase().indexOf('<br>') != -1) {
							List<String> tableAttParts = new List<String>();
							tableAttParts = tableContent.split('<br>',2);
							List<String> tableAtts = new List<String>();
							bodyTable = tableAttParts[1].trim();
							
							// If the table have attributes
							if (tableAttParts[0].length() != 0) {
							
								/*
								tableAtts = tableAttParts[0].split('" ');
								
								for (String itemAtt : tableAtts) {
									List<String> attParts = new List<String>();
									if (itemAtt.indexOf('=') != -1) {
										attParts = itemAtt.split('=',2);
										String attName = attParts[0].trim();
										String attVal = attParts[1].trim();
										
										if (attName.toLowerCase() == 'border') {
											tableTag += ' border =' + attVal;
										}
										
										if (attName.toLowerCase() == 'align') {
											tableTag += ' align =' + attVal;
										}
										
										if (attName.toLowerCase() == 'cellpadding') {
											tableTag += ' cellpadding =' + attVal;
										}
										
										if (attName.toLowerCase() == 'cellspacing') {
											tableTag += ' cellspacing =' + attVal;
										}
										
										if (attName.toLowerCase() == 'width') {
											tableTag += ' width =' + attVal;
										}
										
										if (attName.toLowerCase() == 'style') {
											tableTag += ' style =' + attVal;
										}
									}
									if (itemAtt != tableAtts[tableAtts.size() - 1]) {
										tableTag += '"';
									}
								}
								*/
								tableTag += tableAttParts[0].trim(); //support all attributes
							}	
						}
						tableTag += '>';
						
						// If have caption Syntax
						//System.debug('\n  //////////////( 1 )///////////////// \n SAVE THIS BODY TABLE: \n ' + bodyTable + '\n ///////////////////////////////// \n');
						List<String> captionTextParts = new List<String>();
						
						if (bodyTable.toLowerCase().indexOf('<br>') != -1) {
							captionTextParts = bodyTable.substring(2).split('<br>',2);
							
							if (bodyTable.trim().indexOf(tableCaption) == 0 && bodyTable.toLowerCase().indexOf('<br>') != -1) {
								//System.debug('\n  //////////////( 2 )///////////////// \n SAVE THIS CAPTIONS PARTS: \n ' + captionTextParts + '\n ///////////////////////////////// \n');
								String captionText = captionTextParts[0].trim();
								if (captionText.indexOf(tableData) == -1) {
									//System.debug('\n  //////////////( 3 )///////////////// \n SAVE THIS CAPTIONS TEXT NO ATTRIBUTES : \n ' + captionText + '\n ///////////////////////////////// \n');
									tableTag += '<caption>' + captionText + '</caption>';
								}
								else {
									List<String> captionParts = new List<String>();
									captionParts = captionText.split(tableDataExp,2);
									//System.debug('\n  ///////////////( 4 )//////////////// \n SAVE THIS CAPTIONS TEXT ATTRIBUTES : \n ' + captionText + '\n' + captionParts + '\n ///////////////////////////////// \n');
									tableTag += '<caption ' + captionParts[0].trim() + '>' + captionParts[1] + '</caption>';	
								}
								bodyTable = captionTextParts[1];
							}
							else {
								if (bodyTable.trim().indexOf(tableRow) != 0) {
									bodyTable = '<br>' + bodyTable;
								}	
							}
							//System.debug('\n  ///////////////( 5 )//////////////// \n SAVE THIS BODY TABLE: \n ' + bodyTable + '\n ///////////////////////////////// \n');
							
							List<String> tableRows = new List<String>();
							if (bodyTable.indexOf(tableRow) != -1) {
								tableRows = bodyTable.split(tableRowExp);	
							}
							else {
								tableRows.add(bodyTable);
							}
							
							for (String itemRow : tableRows) {
								String iterRow = itemRow;
								List<String> rowAtt = new List<String>();
								rowAtt = iterRow.split('<br>',2);
								
								if (rowAtt.size() == 2) {
									tableTag += '<tr ';
									if (rowAtt[0] != '' && rowAtt[0] != null ) {
										tableTag += rowAtt[0].trim();
									}
									tableTag += '>';
									
									//System.debug('\n  //////////////( 6 )///////////////// \n SAVE THIS ITEM ROW: \n ' + itemRow + '\n ITER ROW: ' + iterRow + '\n ROW ATT: ' + rowAtt + '\n ///////////////////////////////// \n');
									iterRow = rowAtt[1].trim();
									
									for (String itemCell : iterRow.split('<br>')) {
										//System.debug('\n  ///////////////( 7 )//////////////// \n SAVE THIS ITEM CELL: \n ' + itemCell + '\n ///////////////////////////////// \n');
										if (itemCell.trim().indexOf(tableHeader) == 0) {
											tableTag += '<th ';
											String tdContent = '';
											if (itemCell.length() > 1) {
												itemCell = itemCell.substring(1);
												if (itemCell.indexOf(tableData) != -1) {
													List<String> tdAtts = new List<String>();
													tdAtts = itemCell.split(tableDataExp, 2);
													String tdAtt = '';
													if (tdAtts[0] != null) {
														tdAtt = tdAtts[0].trim();
													}
													if (tdAtts[1] != null) {
														tdContent = tdAtts[1].trim();
													}
													tableTag += tdAtt.trim();	 
												}	
												else {
													tdContent = itemCell.trim();	
												}
											}
											tableTag += '>';
											tableTag += tdContent;
										}
										
										else {
											if (itemCell.trim().indexOf(tableData) == 0) {
												tableTag += '<td ';
												String tdContent = '';
												if (itemCell.length() > 1) {
													itemCell = itemCell.substring(1);
													if (itemCell.indexOf(tableData) != -1) {
														List<String> tdAtts = new List<String>();
														tdAtts = itemCell.split(tableDataExp, 2);
														String tdAtt = '';
														if (tdAtts[0] != null) {
															tdAtt = tdAtts[0].trim();
														}
														if (tdAtts[1] != null) {
															tdContent = tdAtts[1].trim();
														}
														tableTag += tdAtt;	 
													}	
													else {
														tdContent = itemCell.trim();	
													}
												}
												tableTag += '>';
												tableTag += tdContent;
											}
											
											tableTag += '</td>';
										}
									}
									tableTag += '</tr>';	
								}
							}
						}
						tableTag += '</table>';
						html = htmlParts[0] + tableTag + tailHtml;
					}
					else {
						html = htmlParts[0] + '<table></table>' + tailHtml;	
					}
				}
				else {
					html = htmlParts[0] + '<table></table>' + htmlParts[1];
				}
				
				//System.debug('\n  //////////////( 8 )///////////////// \n SAVE THIS TABLE TAG: \n ' + tableTag + '\n ///////////////////////////////// \n');
	 		}				
			
			/* ------------------------ */
	 		/* 			Emoticons	 	*/
	 		String resourceId = '1211555009000';
			String surprised = ':\\|';
			html = html.replaceAll(surprised , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/whatchutalkingabout_smile.gif\'>');
			
	 		/* ------------------------ */
	 		/* 		Background color  	*/
	 		
	 		String bgcolorOpen = '[Bgcolor:';	
			while (html.IndexOf(bgcolorOpen) != -1) {
				List<String> temp = new List<String>();
				List<String> temp2 = new List<String>();
				temp = html.split('\\[Bgcolor:', 2);
				String tail = temp[1].trim();
				String endChar = '';
				
				if (tail.indexOf('rgb(') == 0) {
					temp2 = tail.split('\\)', 2);
					temp2[0] += ')';
					endChar = ' ';
				}
				else {
					if (tail.indexOf(' ') != -1 || tail.indexOf('<br>') != -1) {
						if((tail.indexOf(' ') < tail.indexOf('<br>')) || (tail.indexOf('<br>') == -1)) {
							temp2 = tail.split(' ', 2);
							endChar = ' ';
						}
						else {
							temp2 = tail.split('<br>', 2);	
							endChar = '<br>';
						}
					}
					else {
						temp2.add(tail);
						temp2.add(' ');	
					}
				}
				
				String bgcolorClose = 'Bgcolor\\]';
				String restHtml = temp2[1].replaceFirst(bgcolorClose,'</span>');
				html = temp[0] + '<span style="background-color:' + temp2[0] + ';">' + endChar + restHtml;	
			}
	
	 		/* ------------------------ */
	 		/* 		   Text Color	  	*/
	 		
	 		String colorOpen = '[Color:';	
			while (html.IndexOf(colorOpen) != -1) {
				List<String> temp = new List<String>();
				List<String> temp2 = new List<String>();
				temp = html.split('\\[Color:', 2);
				String tail = temp[1].trim();
				String endChar;
				if (tail.indexOf('rgb(') == 0) {
					temp2 = tail.split('\\)', 2);
					temp2[0] += ')';
					endChar = ' ';
				}
				else {
					if (tail.indexOf(' ') != -1 || tail.indexOf('<br>') != -1) {
						if((tail.indexOf(' ') < tail.indexOf('<br>')) || (tail.indexOf('<br>') == -1)) {
							temp2 = tail.split(' ', 2);
							endChar = ' ';
						}
						else {
							temp2 = tail.split('<br>', 2);	
							endChar = '<br>';    
						}
					}
					else {
						temp2.add(tail);
						temp2.add('');
					}
				}
				
				String colorClose = 'Color\\]';
				String restHtml = temp2[1].replaceFirst(colorClose,'</span>');
				html = temp[0] + '<span style="color:' + temp2[0] + ';">' + endChar + restHtml;	
			}
	
	 		/* ------------------------ */
	 		/* 			Text Ident 		*/
	 		
	 		String identOpen = '[[-';	
			while (html.IndexOf(identOpen) != -1) {
				List<String> temp = new List<String>();
				List<String> temp2 = new List<String>();
				temp = html.split('\\[\\[-', 2);
				String identClose;
				Integer identPx;
				if (temp[1].indexOf('>') != -1) {
					temp2 = temp[1].split('>', 2);
					identPx = (temp2[0].length() + 1) * 20;
					if (temp2[0].length() != 0 ) {
						identClose = temp2[0] + '->\\]\\]';
					}
					else {
						identClose = '->\\]\\]';
					}
				}
				else {
					identPx = 0;
					identClose = '';
					temp2.add(temp[1]);
					temp2.add('');	
				}
				
				String restHtml = temp2[1].replaceFirst(identClose,'</p>');
				html = temp[0] + '<p style="margin-left:' + identPx + 'px;">' + restHtml;	
			}
	
			
			/* ------------------------ */
	 		/* 			Text Align	 	*/
			
			String alignRightOpen = '\\[\\[>';
			String alignLeftOpen = '\\[\\[<';
			String alignCenterOpen = '\\[\\[=';
			String alignJustifyOpen = '\\[\\[<>';
			
			String alignRightClose = '>\\]\\]';
			String alignLeftClose = '<\\]\\]';
			String alignCenterClosen = '=\\]\\]';
			String alignJustifyClose = '<>\\]\\]';
			
			html = html.replaceAll('(?i)' + alignJustifyOpen ,'<p style="text-align: justify;">');
			html = html.replaceAll('(?i)' + alignRightOpen ,'<p style="text-align: right;">');
			html = html.replaceAll('(?i)' + alignLeftOpen ,'<p style="text-align: left;">');
			html = html.replaceAll('(?i)' + alignCenterOpen ,'<p style="text-align: center;">');
			
			
			html = html.replaceAll(alignJustifyClose ,'</p>');
			html = html.replaceAll(alignRightClose ,'</p>');
			html = html.replaceAll(alignLeftClose ,'</p>');
			html = html.replaceAll(alignCenterClosen ,'</p>');
			
	
		
	 		
	 		
	 		/* ------------------------ */
	 		/* 		Code (No parsed) 	*/
	 		String verbatimOpen = '<noParsed>';
	 		html = html.replace(verbatimOpen ,'<pre>');	
	 		String verbatimClose = '</noParsed>';
	 		html = html.replace(verbatimClose ,'</pre>');	
	
			/* ------------------------ */
	 		/* 		UnOrdered List	 	*/
	 		String listSyntax = '*';
	 		Boolean first = true;
	 		Boolean last = false;
	 		while (html.lastIndexOf(listSyntax) != -1) {	
		 		String listS = '\\*';
		 		List<String> temp;
		 		temp = html.split(listS,2);
		 		html = html.replaceFirst(listS , '<li>');
		 		
		 		if (temp[1].indexOf(listSyntax) >= temp[1].indexOf('<br>') || temp[1].indexOf(listSyntax)== -1 ) {
		 			if (temp[1].indexOf('<br>') == -1) {
		 				temp[1] = '>' + temp[1] + '</li></ul>';
		 				last = true;
		 			}
		 			else {	 
		 				List<String> temp2;	
		 				temp2 = temp[1].split('<br>',2);	
		 				if (temp2[1].indexOf(listSyntax) == 0) {	
		 					temp[1] = '>' + temp[1].replaceFirst('<br>', '</li>');
		 				}
		 				else {
		 					temp[1] = '>' + temp[1].replaceFirst('<br>', '</li></ul>');
		 					last = true;
		 				}
		 			}
		 		}
		 		else {
		 			temp[1] = temp[1].replaceFirst(listS,'');
		 			if (temp[1].indexOf('<br>') == -1) {
		 				temp[1] = ' style="padding-left:10px;">' + temp[1] + '</li></ul>';
		 				last = true;
		 			}
		 			else {	 		
		 				temp[1] = ' style="padding-left:10px;">' + temp[1].replaceFirst('<br>', '</li>');
		 			}
		 		}	
		 		if (first) {
		 			html = temp[0] + '<ul><li' + temp[1];
		 			first = false;
		 		}
		 		else {
		 			html = temp[0] + '<li' + temp[1];
		 		}
		 		if (last) {
		 			first = true;
		 			last = false;
		 		}
	 		}
	
	   		/* ------------------------ */
	 		/* 		Ordered List		*/
	 		String listSyntaxOL = '~';
	 		Boolean firstOL = true;
	 		Boolean lastOL = false;
	 		while (html.lastIndexOf(listSyntaxOL) != -1) {	
		 		String listS = '~';
		 		List<String> temp;
		 		temp = html.split(listS,2);
		 		html = html.replaceFirst(listS , '<li>');
		 		
		 		if (temp[1].indexOf(listSyntaxOL) >= temp[1].indexOf('<br>') || temp[1].indexOf(listSyntaxOL)== -1 ) {
		 			if (temp[1].indexOf('<br>') == -1) {
		 				temp[1] = '>' + temp[1] + '</li></ol>';
		 				lastOL = true;
		 			}
		 			else {	 
		 				List<String> temp2;	
		 				temp2 = temp[1].split('<br>',2);	
		 				if (temp2[1].indexOf(listSyntaxOL) == 0) {	
		 					temp[1] = '>' + temp[1].replaceFirst('<br>', '</li>');
		 				}
		 				else {
		 					temp[1] = '>' + temp[1].replaceFirst('<br>', '</li></ol>');
		 					lastOL = true;
		 				}
		 			}
		 		}
		 		else {
		 			temp[1] = temp[1].replaceFirst(listS,'');
		 			if (temp[1].indexOf('<br>') == -1) {
		 				temp[1] = ' style="padding-left:10px;">' + temp[1] + '</li></ol>';
		 				lastOL = true;
		 			}
		 			else {	 		
		 				temp[1] = ' style="padding-left:10px;">' + temp[1].replaceFirst('<br>', '</li>');
		 			}
		 		}	
		 		if (firstOL) {
		 			html = temp[0] + '<ol><li' + temp[1];
		 			firstOL = false;
		 		}
		 		else {
		 			html = temp[0] + '<li' + temp[1];
		 		}
		 		if (lastOL) {
		 			firstOL = true;
		 			lastOL = false;
		 		}
	 		}
	  		
	  		/* ------------------------ */
	 		/* 		Horizontal Line 	*/
	 		String line = '----';
	 		html = html.replace(line ,'<hr>');
	 		
	 		
	 		
	  		/* ------------------------ */
	 		/* 			HEADINGS 		*/
	 		 	String header = '=======';
	 		 	for (Integer i = 6; i > 1; i--) {
			 		if (header.length() > 1) {
			 			header = header.substring(1);
			 		}
			 		else {
			 			header = '=';
			 		}			
		 	 		while (html.lastIndexOf(header) != -1) {
				 		List<String> temp = new List<String>();
				 		List<String> temp2 = new List<String>();
				 		Integer indexOfHeader = html.indexOf(header);
				 		temp = html.split(header, 2);
				 		html = html.replaceFirst(header,'<h' + i + '>');
				 		String linkName = '';
				 		if (temp[1].indexOf(header) != -1 && ((temp[1].indexOf(header) < temp[1].indexOf('<br>')) || temp[1].indexOf('<br>') == -1 ) ) {
				 			temp2 = temp[1].split(header, 2);
				 			linkName = temp2[0].trim();
				 			html = html.replaceFirst(header,'</h' + i + '><hr>');
				 		}
				 		else {
				 			temp2.add(temp[1]);
				 			temp2.add('');
				 		}
						
						Integer fontSize;
						if (i == 2) { fontSize = 20; }
						if (i == 3) { fontSize = 18; }
						if (i == 4) { fontSize = 16; }
						if (i == 5) { fontSize = 14; }
						if (i == 6) { fontSize = 13; }
						
						if (temp[1].indexOf(header) != -1) {
				 			html = temp[0] + i + '%%%%<a name="' + linkName + '"></a>%%%%<h' + i + ' style="font-size:' + fontSize + 'px;">' + temp2[0] + '</h' + i + '><hr>' + temp2[1];
						}
						else {
							html = temp[0] + i + '%%%%<a name="' + linkName + '"></a>%%%%<h' + i + ' style="font-size:' + fontSize + 'px;">' + temp2[0];
						} 
				 		//toc += '<a style="padding-left:' + i + '0px;" href="#' + temp2[0] + '">' + temp2[0] + ' / ' + indexOfHeader + '</a><br>\n';
			 		} 
		
	 		
	 		 	}
		 			
		 	/* ------------------------ */	
		 		
		 		
		 		
	 		/* ------------------------ */
	 		/* 			Bold Text 		*/ 			
	 		String bold = '\'\'\'';
	 		while (html.lastIndexOf(bold) != -1) {
		 		html = html.replaceFirst(bold , '<b>');
		 		html = html.replaceFirst(bold , '</b>');
	 		}
	 		
	 		/* ------------------------ */
	 		/* 		SubScript Text 		*/ 			
	 		String sub = ',,';
	 		while (html.lastIndexOf(sub) != -1) {
		 		html = html.replaceFirst(sub , '<sub>');
		 		html = html.replaceFirst(sub , '</sub>');
	 		}
	 		
	 		/* ------------------------ */
	 		/* 		SuperScript Text 	*/ 			
	 		String sup = '^';
	 		String supExp = '\\^';
	 		while (html.lastIndexOf(sup) != -1) {
		 		html = html.replaceFirst(supExp , '<sup>');
		 		html = html.replaceFirst(supExp , '</sup>');
	 		}
	 		
			/* ------------------------ */
	 		/* 		Strike Text 		*/ 			
	 		String strikeOpen = '\\-\\-\\(';
	 		String strikeClose = '\\)\\-\\-';
		 	html = html.replaceAll(strikeOpen , '<strike>');
		 	html = html.replaceAll(strikeClose , '</strike>');
			
		 	
		 	
	 		/* ------------------------ */
	 		/* 			Italic Text 	*/ 		
	 		String italic = '\'\'';
	 		while (html.lastIndexOf(italic) != -1) {
		 		html = html.replaceFirst(italic , '<i>');
		 		html = html.replaceFirst(italic , '</i>');
	 		}
	
	 		/* ------------------------ */
	 		/* 		UnderLine Text 		*/ 			
	 		String under = '__';
	 		while (html.lastIndexOf(under) != -1) {
		 		html = html.replaceFirst(under , '<u>');
		 		html = html.replaceFirst(under , '</u>');
	 		}	
	
	 		/* ------------------------ */
	 		/* 		External Link 		*/
	 		/*		HTTPS SUPORT		*/  
	 		String extLink = '[http';
	 		while (html.lastIndexOf(extLink) != -1) {
	 			List<String> temp;
	 			String extL = '\\[http'; 
	 			temp = html.split(extL , 2);
	 			
	 			if (temp[1].indexOf(' ') != -1 && temp[1].indexOf(']') != -1) {
		 			html = temp[0] + '<a href="http';
		 			String[] temp2 = temp[1].split(' ', 2);
		 			html += temp2[0].trim() + '"';
		 			List<String> temp3 = new List<String>();
		 			if (temp2[1].indexOf('[Image:') != -1 && (temp2[1].indexOf('[Image:') < temp2[1].indexOf(']'))) {
		 				temp3 = temp2[1].split('\\]\\]', 2);
		 				temp3[0] += ']';
		 			}
		 			else {
		 				temp3 = temp2[1].split('\\]', 2);
		 			}
		 			html += '>' + temp3[0] + '</a>';
		 			html += temp3[1];
	 			}
	 			else {
	 				html = temp[0] + '<a href="javascript:;">Malformed Link</a>' + temp[1];	
	 			}
	 		} 
	
	 		
	 		/* ------------------------ */
	 		/* 		Embedded Image		*/ 
	 		String image = '[Image:';
	 		while (html.lastIndexOf(image) != -1) {
	 			List<String> temp;
	 			String img = '\\[Image:'; 
	 			temp = html.split(img , 2);
	 			if (temp[1].indexOf(']') != -1) {
		 			String[] temp2 = temp[1].split('\\]', 2);
		 			String contentImg = temp2[0];
		 			String imgTag = '<img';
		 			
		 			//<img width="100" height="20" align="right" src="nameOfTheAttachImage" _fcksavedurl="nameOfTheAttachImage" _moz_resizing="true"/>
		 			//System.debug('\n //////////////////// \n CONSTRUCTION OF THE IMG TAG: \n' + imgTag + '\n ////////////////////// \n ');
		 			
		 			if (contentImg.indexOf(';') != -1) {
	
			 			List<String> attributesImg = contentImg.split(';');
			 			
			 			for(String item : attributesImg) {
			 				if (item.indexOf(':') != -1) {
			 					List<String> attVals = item.split(':',2);
			 					String attName = attVals[0].trim();
			 					String attVal = attVals[1].trim();
			 					if (attName == 'w') {
			 						imgTag += ' width="' + attval + '"';	
			 					}
			 					if (attName == 'a') {
			 						imgTag += ' align="' + attval + '"';	
			 					}
			 					if (attName == 'h') {
			 						imgTag += ' height="' + attval + '"';	
			 					}
			 					if (attName == 'src') {
			 						String srcImg = '';
			 						if (attVal.toLowerCase().indexOf('http') != -1) {
			 							srcImg = attVal;
			 						}
			 						else {
				 						String imageName = attVal;
										if (idWikiPage == null) {
											idWikiPage = getWikiHome();
										}
										
							 			List<Attachment> AttachmentsImageLst = [select Name, Id from Attachment where Name =:imageName and parentid=:idWikiPage limit 1];
							 			
							 			if (AttachmentsImageLst.size() > 0) {	
								 			Attachment AttachmentsImage = AttachmentsImageLst[0];	
								 			String idSrc = AttachmentsImage.Id;
								 			srcImg = 'https://na1.salesforce.com/servlet/servlet.FileDownload?file=' + idSrc;
							 			}
			 						}
			 						imgTag += ' src="' + srcImg + '"';	
			 					}
			 					//System.debug('\n //////////////////// \n CONSTRUCTION OF THE IMG TAG: \n' + imgTag + '\n ////////////////////// \n ');
			 				}
			 			}
		 			}
		 			else {
		 				if (contentImg.indexOf(':') != -1) {
			 				List<String> attVals = contentImg.split(':',2);
		 					String attName = attVals[0].trim();
		 					String attVal = attVals[1].trim();
		 					if (attName == 'w') {
		 						imgTag += ' width="' + attval + '"';	
		 					}
		 					if (attName == 'a') {
		 						imgTag += ' align="' + attval + '"';	
		 					}
		 					if (attName == 'h') {
		 						imgTag += ' height="' + attval + '"';	
		 					}
		 					if (attName == 'src') {
		 						String srcImg = '';
		 						if (attVal.toLowerCase().indexOf('http') != -1) {
		 							srcImg = attVal;
		 						}
		 						else {
			 						String imageName = attVal;
									if (idWikiPage == null) {
										idWikiPage = getWikiHome();
									}
									
									List<Attachment> AttachmentsImageLst =[select Name, Id from Attachment where Name =:imageName and parentid=:idWikiPage limit 1];
						 			if (AttachmentsImageLst.size() > 0) {	
							 			Attachment AttachmentsImage = AttachmentsImageLst[0];	
							 			String idSrc = AttachmentsImage.Id;
							 			srcImg = 'https://na1.salesforce.com/servlet/servlet.FileDownload?file=' + idSrc;
						 			}
		 						}
		 						imgTag += ' src="' + srcImg + '"';	
		 					}
		 					//System.debug('\n //////////////////// \n CONSTRUCTION OF THE IMG TAG: \n' + imgTag + '\n ////////////////////// \n ');
		 				}
		 			}
		 			
		 			imgTag += '/>';
		 			
		 			//System.debug('\n //////////////////// \n CONSTRUCTION OF THE IMG TAG: \n' + imgTag + '\n ////////////////////// \n ');
		 			
		 			html = temp[0] + imgTag + temp2[1];
	 			}
	 			else {
	 				html = temp[0] + '<img title="Malformed Image" alt="Malformed Image" />' + temp[1];
	 			}
	 		}
	 		
	 		 /* ------------------------ */
	 		/* 		Embedded Flash		*/ 
	 		
	 		
	 		String flash = '[Flash:';
	 		while (html.lastIndexOf(flash) != -1) {
	 			
	 			//<embed type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" src="https://na1.salesforce.com/servlet/servlet.FileDownload?file=00P30000002lfndEAA" play="true" loop="true" menu="true"></embed>
	 			//<embed width="100%" height="100%" name="plugin" src="http://www.frightfactoryuk.com/30daysofnight.flv" type="application/x-shockwave-flash"></embed>
	 			
	 			List<String> temp;
	 			String flv = '\\[Flash:'; 
	 			temp = html.split(flv , 2);
	 			
	 			if (temp[1].indexOf(']') != -1) {
		 			html = temp[0] + '<embed width="100%" height="500px" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" src="';
		 			String[] temp2 = temp[1].split('\\]', 2);
		 			
		 			String flashName = temp2[0].trim();
					if (idWikiPage == null) {
						idWikiPage = getWikiHome();
					}
		 			
		 			List<Attachment> AttachmentsFlashLst = [select Name, Id from Attachment where Name =:FlashName and parentid=:idWikiPage limit 1];
		 			String src;
		 			if (AttachmentsFlashLst.size() > 0) {	
			 			Attachment AttachmentsFlash = AttachmentsFlashLst[0];	
			 			String idSrc = AttachmentsFlash.Id;
			 			src = 'https://na1.salesforce.com/servlet/servlet.FileDownload?file=' + idSrc;
			 			//src = 'http://www.frightfactoryuk.com/30daysofnight.flv';
			 			//src = 'https://na1.salesforce.com/servlet/servlet.FileDownload?file=00P30000002lfp5EAA';
			 			//src = '/servlet/servlet.FileDownload?file=01530000000WfJZ';
		 			}
		 			else {
		 				src = 'https://na1.salesforce.com/resource/1204736185000/noImage" width="116px';
		 			}
		 			
		 			//html += src + '" type="application/x-shockwave-flash"></embed>';
		 			html += src + '" play="true" loop="true" menu="true"></embed>';
			 		html += temp2[1];
	 			}
	 			else {
	 				html = temp[0] + '<embed width="100%" height="500px" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"></embed>' + temp[1];	
	 			}
	 		}
	 		
	 		/* ------------------------ */
	 		/* 		Embedded File		*/ 
	 		String fileS = '[File:';
	 		while (html.lastIndexOf(fileS) != -1) {
	 			List<String> temp;
	 			String file = '\\[File:'; 
	 			temp = html.split(file , 2);
	 			if (temp[1].indexOf(']') != -1) {
		 			String[] temp2 = temp[1].split('\\]', 2);
		 			
		 			String fileName = temp2[0].trim();
		 			
		 			List<Attachment> AttachmentsImageLst = [select Name,ContentType, Id from Attachment where Name =:fileName and parentid=:idWikiPage limit 1];	
		 			String href = '';
		 			String fileType = '';
		 			if (AttachmentsImageLst.size() > 0) {	
			 			Attachment AttachmentsImage = AttachmentsImageLst[0];
			 			String idHref = AttachmentsImage.Id;
			 			href = 'https://na1.salesforce.com/servlet/servlet.FileDownload?file=' + idHref;
			 			
			            String ContentType2 = AttachmentsImage.ContentType;
			            String image2 = '';
			            if (ContentType2 == null || ContentType2 == '') {
			            	// LO HAGO POR LA EXTENSION
			            	Integer extPos2 = AttachmentsImage.Name.lastIndexOf('.') + 1;
			            	String extension2 = AttachmentsImage.Name.substring(extPos2);	
			           		Map<String, String> typesExt2 = new Map<String, String>{'rar' => 'rar.gif', 'xls' => 'xls.gif', 'ppt' => 'ppt.gif', 'avi' => 'video.gif', 'mpeg' => 'video.gif', 'flv' => 'video.gif','mpg' => 'video.gif', 'mp3' => 'audio.gif' , 'wav' => 'audio.gif'};	
			           		if(typesExt2.containsKey(extension2)) {
			           			image2 = typesExt2.get(extension2);
			           		}
			           		else {
			           			image2 = 'generic.gif';
			           		}
			            }
			            else {
			           		// LO HAGO POR EL MIME TYPE
			           		Map<String, String> typesMime2 = new Map<String, String>{'image/jpeg' => 'images.gif', 'image/png' => 'images.gif', 'image/gif' => 'images.gif', 'image/bmp' => 'images.gif', 'application/pdf' => 'pdf.gif', 'text/plain' => 'txt.gif','application/msword' => 'doc.gif', 'application/x-zip-compressed' => 'zip.gif'};	
			           		if(typesMime2.containsKey(ContentType2)) {
			           			image2 = typesMime2.get(ContentType2);
			           		}
			           		else {
			           			image2 = 'generic.gif';
			           		}
			            }	 			
			 			
			 			fileType = '<img style="vertical-align:bottom;" src="https://na1.salesforce.com/resource/1204814978000/FileTypeIcons/' + image2 + '"/>';
		 			}
		 			else {
		 				href = '';
		 				fileType = '';
		 				fileName = '';
		 			}
		 			html = temp[0] + '<a href="' + href + '">' + fileType + '</a>&nbsp;<a href="';
		 			html += href + '">' + fileName + '</a>';
			 		html += temp2[1];
	 			}
	 			else {
	 				html = temp[0] + '<a href="javascript:;">Malformed Link</a>' + temp[1];
	 			}
	 		}
	 		 		
	 		/* ------------------------ */
	 		/* 		Internal Link 		*/  		
	 		
	 		
	 		String intLink = '[[';
	 		while (html.lastIndexOf(intLink) != -1) {
	 			
	 			
	 			List<String> temp;
	 			String intL = '\\[\\[';
	 			temp = html.split(intL , 2);
	 			if (temp[1].indexOf(']]') != -1) {
	 				String[] temp2 = temp[1].split('\\]\\]', 2);
		 			String nameWiki = '';
		 			String nameTeam = '';
		 			String linkContent = '';
		 			linkContent = temp2[0];
			 		
			 		if (linkContent.indexOf(':') != -1) {
			 			List<String> linkParts = new List<String>();
			 			linkParts = linkContent.split(':',2);
			 			nameWiki = linkParts[1].trim();
			 			nameTeam = linkParts[0].trim();
			 		}
			 		else {
			 			nameWiki = linkContent.trim();
			 		}
			 		
			 		if (nameWiki != '') {
				 		WikiPage__c wiki = new WikiPage__c();
				 		String idTeamLink = '';
				 		Integer countWs;
				 		if (nameTeam == '') {
				 			idTeamLink = idWikiSite;	
				 		}
				 		else {
				 			Team__c linkTeam = [select id, name from Team__c where name =: nameTeam limit 1];
				 			if (linkTeam != null) {
				 				idTeamLink = linkTeam.id;	
				 			}
				 		}
				 		
				 		List<WikiPage__c> wikiLst = [select Id, name from WikiPage__c where Name = :nameWiki and Team__c =:idTeamLink limit 1];
				 		if (wikiLst.size() > 0) {
				 			wiki = wikiLst[0];
					 		String id;
					 		id = wiki.Id;
								 		
							html = temp[0] + '<a href=\"/apex/WikiPage?idWP=' + id + '\">' + nameWiki + '</a>' + temp2[1];	 		
					 	}
					 	else {
					 		html = temp[0] + '<a href="javascript:;" onclick="viewOverlayForm(\'' + idWikiPage + '\',\'AddChildForm\');newChildPreField(\'' + nameWiki + '\')">Create Page ' + nameWiki + '</a>' + temp2[1];
					 	}
			 		}
			 		else {
			 			html = temp[0] + temp2[1];	
			 		}
	 			}
	 			else {
	 				html = temp[0] + temp[1];
	 			}
	 		}  				 		

	 		html = html.replaceAll('  ','&nbsp;');
	  		
	  		
	  		/* ------------------------ */
	 		/* 	   Table of Content 	*/ 	
	 		String tocSintax = '%TOC%';
	 		String tocCentinel = '%%%%';
	 		String tocCentinelStart = '%%%%<a name="';
	 		String tocCentinelEnd = '"></a>%%%%';  
	 		while (html.indexOf(tocCentinel) != -1) {
		 		List<String> tempToc1 = new List<String>();
		 		List<String> tempToc2 = new List<String>();
		 		
		 		tempToc1 = html.split(tocCentinelStart, 2);
		 		html = html.replaceFirst(tocCentinel,'');
		 		
		 		//System.debug('\n ////////////////////// \n TEMPTOC 1: ' + tempToc1 + '\n html: \n ' + html + '\n ///////////////////// \n');
		 		
		 		Integer a = tempToc1[0].length() - 1;
				String part1 = tempToc1[0].substring(0,a);
				String numH = tempToc1[0].substring(a,a + 1);
		 		
		 		if (tempToc1[1].indexOf(tocCentinelEnd) != -1) {	
			 		tempToc2 = tempToc1[1].split(tocCentinelEnd, 2);
			 		html = html.replaceFirst(tocCentinel,'');
			 	}
		 		else {
		 			tempToc2.add('');
		 			tempToc2.add(tempToc1[1]);
		 		}
				
				html = part1 + '<a name="'+ tempToc2[0] + '"></a>' + tempToc2[1]; 
			 	toc += '<a  href="#' + tempToc2[0] + '" style="padding-left:' + numH + '0px;padding-bottom:5px;">' + tempToc2[0] + '</a><br>\n';
				
	 		}	
	 		toc = '<table style="padding:20px;background-color:#FFFFFF;border:1px solid #AAAAAA;"><tr><td>' + toc + '</td></tr></table>';
	 		html = html.replaceAll(tocSintax, toc);	
	 		
	 		/* ------------------------ */
	 		/* 		Code (No parsed) 	*/
	 		Integer countCode = 0;
	 		String codeText;
	 		codeText = html;
	 		while (codeText.lastIndexOf(replacementCode) != -1) {
		 		codeText = codeText.replaceFirst(replacementCode,'<table style="border: 1px solid rgb(175, 175, 175); padding: 20px; background-color: rgb(250, 250, 250);"><tbody><tr><td>' + noparsedText.get(countCode) + '<span></span></td></tr></tbody></table>');
	 			countCode++;
	 		} 		
	 		html = codeText; 		
	 		
	 		
	 		
			/* ------------------------ */
	 		/* 		  Emoticons 		*/		
	 		
	 		String happy = ':\\)';
	 		String veryHappy = ':D';
	 		String sad = ':\\(';
			String crying = ':\'\\(';
			String wink = ';\\)';
			String evil = '\\(6\\)';
			String idea = '\\(I\\)';
			String thumbsUp = '\\(Y\\)';
			String thumbsDown = '\\(N\\)';
			String heart = '\\(L\\)';
			String brokenHeart = '\\(U\\)';
			String kiss = '\\(K\\)';
			String email = '\\(E\\)';
			String glasses = '\\(H\\)';
			String angry = ':@';
			String tongue = ':P';
	 		String shame = ':\\$';
	 		String oh = ':O'; 		
	 		String confused = ':S';
	 		String angel = '\\(A\\)';
	
	 		html = html.replaceAll(happy , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/regular_smile.gif\'>');
			html = html.replaceAll(veryHappy , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/teeth_smile.gif\'>');
			html = html.replaceAll(sad , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/sad_smile.gif\'>');
			html = html.replaceAll(crying , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/cry_smile.gif\'>');
			html = html.replaceAll(wink , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/wink_smile.gif\'>');
			html = html.replaceAll(evil , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/devil_smile.gif\'>');
			html = html.replaceAll(idea , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/lightbulb.gif\'>');
			html = html.replaceAll(thumbsUp , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/thumbs_up.gif\'>');
			html = html.replaceAll(thumbsDown , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/thumbs_down.gif\'>');
			html = html.replaceAll(heart , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/heart.gif\'>');
			html = html.replaceAll(brokenHeart , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/broken_heart.gif\'>');
			html = html.replaceAll(kiss , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/kiss.gif\'>');
			html = html.replaceAll(email , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/envelope.gif\'>');
			html = html.replaceAll(glasses , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/shades_smile.gif\'>');
			html = html.replaceAll(angry , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/angry_smile.gif\'>');
			html = html.replaceAll(tongue , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/tounge_smile.gif\'>');
			html = html.replaceAll(shame , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/embaressed_smile.gif\'>');
			html = html.replaceAll(oh , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/omg_smile.gif\'>');
			html = html.replaceAll(confused , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/confused_smile.gif\'>');
			html = html.replaceAll(angel , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/angel_smile.gif\'>'); 		
	
	 		/**/
		}
		else {
			html = '';
		}
 		
 	}   
 	
 	public String getHtml () {
 		return html;	
 	}
 	public String getHtml2 () {
 		String html2;
 		html2 = html;
 		html2 = html2.replaceAll('&nbsp;','  ');
 		html2 = html2.replaceAll('<br>','\n');
 		html2 = html2.replaceAll('\"','"');
		html = html.replaceAll('&gt;','>');
		html = html.replaceAll('&lt;','<');
 		return html2;	
 	}


   	/* ---------------------------- */
   	/*   CHILDREN OF A WIKI PAGE	*/
   	/* ---------------------------- */
   
   	public List<WikiPage__c> getChilds () {
   		
   		List<WikiPage__c> childs = new List<WikiPage__c>();
	   	childs = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c FROM WikiPage__c WHERE Parent__c = :idWikiPage order by Name];
	
   		return childs;
   	} 
   	 	
   	public Integer getChildsCount () {
   		Integer count;
		count = [select count() from WikiPage__c where Parent__c = :idWikiPage];
   		return count;
   	}   	

   	/* ---------------------------- */
   	/*   	 EDIT WIKI PAGE			*/
   	/* ---------------------------- */
   	
	public WikiPage__c editWP;
	WikiVersions__c editWV;
	
	/*
	public Boolean edit = false;
	public Boolean getEdit () {
		return this.edit;
	}
	*/
   	/* ---------------------------- */
   	/*   	   NEW WIKI PAGE		*/
   	/* ---------------------------- */	
	WikiPage__c newWP;
	WikiVersions__c newWV;
	
	public Boolean newPage = false;
	
	public Boolean getNewPage () {
		return this.newPage;
	}
	 
	public void cancelNew () {
		newPage = false;
	}
	
	public void newWiki () {
		newPage = true;
		newWP = null;	
		newWV = null;
	}

	public void setnewWP (WikiPage__c newWP) {
		this.newWP = newWP;
	}

	public void setnewWV (WikiVersions__c newWV) {
		this.newWV = newWV;
	}		
	
	public void SaveNew () {
		newWP.Parent__c = idWikiPage;
		newWP.Team__c = idWikiSite; 
		newWP.Body__c = '=== Congratulations! === \n You created a new wiki page for your team. Begin by clicking the "Edit" button above to modify this page.';
		insert newWP;	
		newWV = new WikiVersions__c();
		newWV.revisionCount__c = 1;
		newWV.WikiPageId__c = newWP.Id;
		newWV.Name = newWP.Name;
		newWV.Body__c = '=== Congratulations! === \n You created a new wiki page for your team. Begin by clicking the "Edit" button above to modify this page.';
		insert newWV;
		
		// To refresh the "Create Page XXXX" action
		//parseHTML();
		//infoGen();
		// To refresh the "Create Page XXXX" action
		
		newPage = false;	
	}   	

	public WikiPage__c getnewWP () {
		if (newWP == null) {
			newWP = new WikiPage__c();
		}		
		return newWP;	
	}    	   	

	public WikiVersions__c getnewWV () {
		if (newWV == null) {
			newWV = new WikiVersions__c();
		}		
		return newWV;	
	}
	
   	/* ---------------------------- */
   	/*   	  INFO WIKI PAGE		*/
   	/* ---------------------------- */	
	public class Info {
        
        String name;
        String createdBy;
        String createdById;
        String createdDate;
        String lastModifiedBy;
        String lastModifiedDate;
        String shortDescription;
        String lastModifiedById;
        
        public String getName() {
                return name;
        }

        public void setName(String name) {
                if (name.length() > 60) {
	            	this.name = name.substring(0,58) + '..';
	            }
	            else {
	            	this.name = name;
	            }
        }  
        
        public String getShortDescription() {
                return shortDescription;
        }

        public void setShortDescription (String shortDescription) {
                this.shortDescription = shortDescription;
        }
        
        public String getCreatedBy() {
                return createdBy;
        }

        public void setCreatedBy(Id id) {
                User user;
                user = [select Name from User where id = :id];
                this.createdBy = user.Name;
        }  
        
        public String getCreatedById() {
                return createdById;
        }

        public void setCreatedById(Id id) {
                this.createdById = id;
        }
        
        public String getLastModifiedBy() {
                return lastModifiedBy;
        }

        public void setLastModifiedBy (Id id) {
                User user;
                user = [select Name from User where id = :id];
                this.lastModifiedBy = user.Name;
        } 
        
        public void setLastModifiedById (Id id) {
        	this.lastModifiedById = id;	
        }	
		
		public String getLastModifiedById () {
			return lastModifiedById;	
		}
			
        public String getCreatedDate() {
                return createdDate;
        }

        public void setCreatedDate(Datetime createdDate) {
                this.createdDate = createdDate.format();
        } 
        
        public String getLastModifiedDate() {
                return lastModifiedDate;
        }

        public void setLastModifiedDate(Datetime lastModifiedDate) {
                this.lastModifiedDate = lastModifiedDate.format();
        }                
                                        
	} // end of the class	
   	

   
   	/*
   		
	public Boolean getInfo () {
		return this.Info;
	}   	
   
	public void okInfo () {
		info = false;
	}
	*/
	   	
   	public void infoGen () {
   		
   		WikiPage__c wiki;
		String idInfo = idWikiPage;	
    	if (idInfo == '0' || idInfo == null) {
    		wiki = [SELECT Name, ShortDescription__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate  From WikiPage__c WHERE Name = 'Home' AND Team__c =: idWikiSite  ];	
    	}
    	else {
    		wiki = [SELECT Name, ShortDescription__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate From WikiPage__c WHERE id = : idInfo ];
    	}
		
		infoWP.setName(wiki.Name);
		infoWP.setCreatedBy(wiki.CreatedById);
		infoWP.setCreatedById(wiki.CreatedById);
		infoWP.setCreatedDate(wiki.CreatedDate);
		infoWP.setLastModifiedById(wiki.LastModifiedById);
		infoWP.setLastModifiedBy(wiki.LastModifiedById);
		infoWP.setLastModifiedDate(wiki.LastModifiedDate);
		infoWP.setShortDescription(wiki.ShortDescription__c);  
			
		//info = true;
	}    		
   		
 	public Info getInfoWiki () {
 		return infoWP;
 	}


   	/* ---------------------------- */
   	/*   	  ATTACH WIKI PAGE		*/
   	/* ---------------------------- */	 	 
	public class AttachmentInfo {
        
        String name;
        String attachImage;
		String id;
        String lastModifiedDate;
        String lastModifiedBy;
        String createdDate;
        String lastModifiedById;
        
        public String getCreatedDate () {
        	return createdDate;
        }
        
        public void setCreatedDate (String createdDate) {
        	this.createdDate = createdDate;
        }
        
        public String getId () {
        	return id;
        }
        
        public void setId (String id) {
        	this.id = id;
        }
        
        public String getLastModifiedDate () {
        	return lastModifiedDate;
        }
        
        public void setLastModifiedDate (String lastModifiedDate) {
        	this.lastModifiedDate = lastModifiedDate;
        }
        
        public String getName() {
                return name;
        }

        public void setName(String name) {
                this.name = name;
        }  
        
        public String getAttachImage() {
                return attachImage;
        }

        public void setAttachImage (String attachImage) {
                this.attachImage = attachImage;
        } 
        
        public String getLastModifiedBy () {
        	return lastModifiedBy;
        }
        
        public void setLastModifiedBy (String lastModifiedBy) {
        	this.lastModifiedBy = lastModifiedBy;
        }
        
        public String getLastModifiedById () {
        	return lastModifiedById;
        }
        
        public void setLastModifiedById (String lastModifiedById) {
        	this.lastModifiedById = lastModifiedById;
        }
                                        
	}
	   
    public List<AttachmentInfo> getAttachments() {
    	
    	List<Attachment> Attachments = [select name, id, parentid, ContentType, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, CreatedDate from attachment where parentid=:idWikiPage order by name];		
		List<AttachmentInfo> infos = new List<AttachmentInfo>();

		for (Attachment item: Attachments){	
            AttachmentInfo info = new AttachmentInfo();
            info.setId(item.Id);
            info.setName(item.Name);
            info.setCreatedDate(item.CreatedDate.format());
            info.setLastModifiedDate(item.LastModifiedDate.format());
            info.setLastModifiedBy(item.LastModifiedBy.Name);
            info.setLastModifiedById(item.LastModifiedBy.Id);
            
            String ContentType = item.ContentType;
            String image = '';
            if (ContentType == null || ContentType == '') {
            	// EXTENTION
            	Integer extPos = item.Name.lastIndexOf('.') + 1;
            	String extension = item.Name.substring(extPos);	
           		Map<String, String> typesExt = new Map<String, String>{'rar' => 'rar.gif', 'xls' => 'xls.gif', 'ppt' => 'ppt.gif', 'avi' => 'video.gif', 'mpeg' => 'video.gif', 'flv' => 'video.gif','mpg' => 'video.gif', 'mp3' => 'audio.gif' , 'wav' => 'audio.gif'};	
           		if(typesExt.containsKey(extension)) {
           			image = typesExt.get(extension);
           		}
           		else {
           			image = 'generic.gif';
           		}
            }
            else {
           		// MIME TYPE
           		Map<String, String> typesMime = new Map<String, String>{'image/jpeg' => 'images.gif', 'image/pjpeg' => 'images.gif', 'image/png' => 'images.gif', 'image/gif' => 'images.gif', 'image/bmp' => 'images.gif', 'application/pdf' => 'pdf.gif', 'text/plain' => 'txt.gif','application/msword' => 'doc.gif', 'application/x-zip-compressed' => 'zip.gif'};	
           		if(typesMime.containsKey(ContentType)) {
           			image = typesMime.get(ContentType);
           		}
           		else {
           			image = 'generic.gif';
           		}
            }
            
            info.setAttachImage(image);
            infos.add(info);
        }	
		return infos;   	    									
    }     
    
    public Integer getAttachCount () {
    	return [select count() from attachment where parentid=:idWikiPage];
    }
    
    public void refreshAttachs () {
    	
    }

   	/* ---------------------------- */
   	/*   	  DELETE ATTACH			*/
   	/* ---------------------------- */  
   	
   	public void DeleteAttach () { 
   		String idAttach = System.currentPageReference().getParameters().get('idAttach');
   		Attachment delAttach;
   		delAttach = [select Id, Name from Attachment where id =:idAttach ];
   		delete delAttach; 
   	}
 
   	/* ---------------------------- */
   	/*   	  BREADCRUMBING			*/
   	/* ---------------------------- */ 
	  	
	public String getBreadCrumbing () {
	   	WikiPage__c wikiBC;
	   	String breadCrumbing = '';
	   	String parentBC = null;
		Integer crumbingLength = 1;
		Integer crumbingMaxLength = 2;
		
		if (idWikiPage == null) {
			idWikiPage = getWikiHome();
		}
   		wikiBC = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];
   		//breadCrumbing += wikiBC.Name;
   		parentBC = wikiBC.Parent__c;
	   	while (parentBC != null) {
	   		
	   		wikiBC = [select Name, Id, Parent__c from WikiPage__c where id =:parentBC];
	   		parentBC = wikiBC.Parent__c;
	   		
	   		String trunkName;
	   		if (wikiBC.Name.length() > 25) {
	   			trunkName = wikiBC.Name.substring(0,23) + '..';
	   		}
	   		else {
	   			trunkName = wikiBC.Name; 	
	   		}
	   		
	   		if (crumbingLength < crumbingMaxLength) {
	   			breadCrumbing = '<a href=\"/apex/WikiPage?idWP=' + wikiBC.Id + '\">' + trunkName + '</a> > ' + breadCrumbing;
	   		}
	   		else {
	   			if (parentBC == null) {
	   				breadCrumbing = '<a href=\"/apex/WikiPage?idWP=' + wikiBC.Id + '\">' + trunkName + '</a> > ' + breadCrumbing;
	   			}
	   			else {
	   				if (crumbingLength == crumbingMaxLength) {
	   					breadCrumbing = ' .. > ' + breadCrumbing;
	   				}
	   			}
	   		}
	   		crumbingLength++;
	   	} 
	   	return breadCrumbing;
	}
 
   	/* ---------------------------- */
   	/*   	OUTGOING / INCOMING		*/
   	/* ---------------------------- */  
   	
    public List<WikiLink__c> getOutgoing() {		
		return [select ToLink__r.ShortDescription__c, ToLink__r.Name, ToLink__r.Id from WikiLink__c where FromLink__c =:idWikiPage order by Name];   	    									
    }    	

    public Integer getCntOutgoing() {		
		return [select count() from WikiLink__c where FromLink__c =:idWikiPage];   	    									
    } 
       	
    public List<WikiLink__c> getIncoming() {		
		return [select FromLink__r.ShortDescription__c, FromLink__r.Name, FromLink__r.Id from WikiLink__c where ToLink__c =:idWikiPage order by Name];   	    									
    }  

    public Integer getCntIncoming() {		
		return [select count() from WikiLink__c where ToLink__c =:idWikiPage];   	    									
    }
   	/* ---------------------------- */
   	/*   	RECENTLY UPDATED		*/
   	/* ---------------------------- */
   	public List<WikiPage__c> getRecentlyUpdated () {
   		return	[ SELECT Id, Name, ShortDescription__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE Team__c =: idWikiSite ORDER BY LastModifiedDate desc limit 5];
   	}
   	    
   	/* ---------------------------- */
   	/*   	     TAG CLOUD			*/
   	/* ---------------------------- */
   	public Integer linksNum = 0;
 	public class Links {
 		String linkName;
 		Integer linkCount;
 		String linkId;
 		String linkClass;
        public String getLinkName () {
        	return linkName;
        } 
        public String getLinkId () {
        	return linkId;
        }        
        public Integer getLinkCount () {
        	return linkCount;
        } 
        public String getLinkClass () {
        	return linkClass;
        }        
        public void setLinkName (String linkName) {
        	this.linkName = linkName;
        }
        public void setLinkClass (String linkClass) {
        	this.linkClass = linkClass;
        }        
        public void setLinkId (String linkId) {
        	this.linkId = linkId;
        }        
        public void setLinkCount (Integer linkCount) {
        	this.linkCount = linkCount;
        }                              		
 	
 	}
	
	public List<Links> upsetting (List<Links> result) {
	    Integer resultSize = result.size() - 1;
	    Integer i;
	    for (i = 0; i <= resultSize; i++) {
	        Integer alea = Integer.valueOf(String.valueOf(Math.roundToLong(Math.ceil(Math.random() * resultSize))));
	        Links tempLink;
	 		tempLink = result.get(i);
	 		result.set(i, result.get(alea));
	 		result.set(alea, tempLink); 
	    }		
		return result;
	} 
	
 	public List<Links> getLinkCount () {
 		
 		List<Links> popularLinks = new List<Links>();
 		
 		for (WikiPage__c item: [select Name, id, linkCount__c from WikiPage__c where Team__c =:idWikiSite order by Name desc limit 15]) {
 			Links link = new Links();
 			if (item.linkCount__c != 0 && item.linkCount__c != null) {
 				Integer intCount = Integer.valueOf(String.valueOf(Math.roundToLong(item.linkCount__c)));
	 			if (intCount < 2) { link.setLinkClass('tag1');}
	 			if (intCount == 2 || intCount == 3) { link.setLinkClass('tag2');}
	 			if (intCount > 3 && intCount <= 5) { link.setLinkClass('tag3');}
	 			if (intCount > 5 && intCount <= 7) { link.setLinkClass('tag4');}
	 			if (intCount > 7 && intCount <= 10) { link.setLinkClass('tag5');}
	 			if (intCount > 10 && intCount <= 13) { link.setLinkClass('tag6');}
	 			if (intCount > 13 && intCount <= 17) { link.setLinkClass('tag7');}
	 			if (intCount > 17 && intCount <= 21) { link.setLinkClass('tag8');}
	 			if (intCount > 21 && intCount <= 25) { link.setLinkClass('tag9');}
	 			if (intCount > 25) { link.setLinkClass('tag10');}
	 			
	 			link.setLinkCount(intCount);
	 			link.setLinkName(item.Name);
	 			link.setLinkId(item.Id);
	 			popularLinks.add(link);
 			}		
 		}	
 		linksNum = popularLinks.size(); 
 		return upsetting(popularLinks);	
 	}  
 	public Integer getLinksNum () {
 		return linksNum;
 	}	   	
   	/* ---------------------------- */
   	/*   	   MY FAVOURITES		*/
   	/* ---------------------------- */
   	
   	public List<FavoriteWikis__c> getFavorite () {
   		return	[ SELECT WikiPage__r.Name, WikiPage__r.Id FROM FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() and WikiPage__r.Team__c =:idWikiSite order by WikiPage__r.Name];
   	}   	
   	
   	public without sharing class FavoriteSharing {
   		public void setFavorites (String idWikiPage, String userId) {
   			Integer countFav = [ SELECT count() FROM FavoriteWikis__c WHERE User__c = :userId AND WikiPage__r.Id =: idWikiPage];	
	   		if (countFav == 0 ) {
	   			FavoriteWikis__c  newFav = new FavoriteWikis__c();
	   			WikiPage__c favWiki = [Select Name, Team__c from WikiPage__c where Id = :idWikiPage];
	   			newFav.User__c = userId;
	   			newFav.Team__c = favWiki.Team__c;
	   			newFav.WikiPage__c = idWikiPage;
	   			newFav.Name = favWiki.Name; 
	   			insert newFav;
	   		}
	   		else {
	   			FavoriteWikis__c favWiki;
				favWiki = [ SELECT WikiPage__r.Name, WikiPage__r.Id FROM FavoriteWikis__c WHERE User__c = :userId AND WikiPage__r.Id =: idWikiPage];  
				delete favWiki; 			
	   		}
	   				
   		}
   		
   	}
   	 
   	public void save_del_fav () {
   		FavoriteSharing favClass = new FavoriteSharing();
   		favClass.setFavorites(idWikiPage, UserInfo.getUserId());
   	} 
   	
   	public Boolean getIsFav () {
   		Integer countFav = [ SELECT count() FROM FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() AND WikiPage__r.Id =: idWikiPage];
   		if (countFav == 0 ) {
   			return false;
   		}
   		else {
   			return true;
   		}
   	}  
   	
   	public Integer getCntFav () {
   		return [select count() from FavoriteWikis__c where User__c = :UserInfo.getUserId() and WikiPage__r.Team__c =:idWikiSite];
   	} 
   	
   	
   	/* ---------------------------- */
   	/*   	   RECENTLY VIEW		*/
   	/* ---------------------------- */
	public class RecentlyView {
		String wikiId;
		String wikiName;
		String parentName;
		Boolean belong;
		
		public void setWikiId (String wikiId) {
			this.wikiId = wikiId;
		}
		public void setWikiName (String wikiName) {
			this.wikiName = wikiName;
		}
		public void setParentName (String parentName) {
			this.parentName = parentName;
		}
		public void setBelong (Boolean belong) {
	   		this.belong = belong;			
		}
		public String getWikiId () {
			return wikiId;
		} 
		public String getWikiName () {
			return wikiName;
		}
		public String getParentName () {
			return parentName;
		}
		public Boolean getBelong () {
			return belong;
		}	
		
	}
	 
   	public List<RecentlyView> getRecentlyView () {
   		List<RecentlyView> views = new List<RecentlyView>();
   		for (WikiRecentlyViewed__c item :	[ SELECT WikiPage__r.Team__r.Id, WikiPage__r.Team__r.Name , WikiPage__r.Name, WikiPage__r.Id FROM WikiRecentlyViewed__c WHERE User__c = :UserInfo.getUserId()  ORDER BY LastModifiedDate desc limit :maxView]) { //and WikiId__r.WikiSpace__c =:idWikiSite
   			RecentlyView view = new RecentlyView();
   			view.setWikiId(item.WikiPage__r.Id);
   			view.setWikiName(item.WikiPage__r.Name);
   			view.setParentName(item.WikiPage__r.Team__r.Name);
   			if (item.WikiPage__r.Team__r.Id == idWikiSite) {
   				view.setBelong(true);
   			}
   			else {
   				view.setBelong(false);
   			}
   			views.add(view);
   		} 
   		return views;  	
   	}    	
   	public Integer getCntViews () {
   		return	[ SELECT count() FROM WikiRecentlyViewed__c WHERE User__c = :UserInfo.getUserId()];
   	}
   	
   	
   	/* ---------------------------- */
   	/*   		 COMMENTS			*/
   	/* ---------------------------- */
	public Boolean addComment = false;
   	public String commentName = '';
   	public String commentBody = '';

   	public class Comments {
   		String commentDate;
   		String comment;
   		String commentName;
   		String commentBy;
   		String commentPicture;
   		
   		public void setCommentName (String commentName) {
   			this.commentName = commentName;
   		}
	   	public void setComment (String comment) { 
	   		this.comment = comment;
	   	} 
	   	public void setCommentDate (Datetime commentDate) {
	   		this.commentDate = commentDate.format(); 
	   	}
	   	public void setCommentBy (String name) {
	   		this.commentBy = name;
	   	}
	   	public String getCommentName () {
	   		return commentName;
	   	}
	   	
	   	public void setCommentPicture (String userId) {
			String PictureId;
			Integer cntPicture;
			cntPicture = [SELECT count() FROM PeopleProfile__c WHERE User__c =:userId];
			if (cntPicture != 0) {
				PeopleProfile__c picture = [SELECT Picture__c FROM PeopleProfile__c WHERE User__c =:userId limit 1];
		        if(picture.Picture__c == '' || picture.Picture__c == null) {                	                                          	 
			     	PictureId = '01530000000VO5s';
				} 
				else {
					PictureId = picture.Picture__c;
				} 
			}
			else {
				PictureId = '01530000000VO5s';
			}
   			this.commentPicture = PictureId ;
   		}
   		
	   	public String getCommentPicture () {
	   		return commentPicture;
	   	}
	   	public String getCommentDate () {
	   		return commentDate;
	   	}
	   	public String getCommentBy () {
	   		return commentBy;
	   	}
	   	public String getComment () {
	   		return comment;
	   	}
   	}
   	   	
   	public String getCommentName () {
   		return commentName;
   	}
   	public void setCommentName (String commentName) {
   		this.commentName = commentName;
   	}
   	
   	public String getCommentBody () {
   		return commentBody;
   	}
   	public void setCommentBody (String commentBody) {
   		this.commentBody = commentBody;
   	}   
   	
   	public List<Comments> getComments () {
   		List<Comments> commentsList = new List<Comments>();
   		Integer countComment = [ SELECT count() from Comment__c WHERE ParentWikiPage__c =:idWikiPage];
   		if (countComment != 0) {
	   		for (Comment__c item: [ SELECT Message__c, CreatedBy.Name,CreatedById, LastModifiedDate FROM Comment__c WHERE ParentWikiPage__c =:idWikiPage ORDER BY LastModifiedDate desc]) {
	   			Comments itemComment = new Comments();
	   			itemComment.setCommentBy(item.CreatedBy.Name);
	   			itemComment.setComment(item.Message__c);
	   			itemComment.setCommentDate(item.LastModifiedDate);
	   			itemComment.setCommentPicture(item.CreatedById);
	   			commentsList.add(itemComment);
	   		}	
   		}
   		return	commentsList;
   	}
   	    	
   	public Integer getCntComments () {
   		return	[ SELECT count() FROM Comment__c WHERE ParentWikiPage__c =: idWikiPage];
   	}  
   	  
   	public Boolean getAddComment () {
   		return addComment;	
   	}
   	 	
   	public void addCommentLink () {
   		addComment = true;
   	}
   	
   	public void saveComment () {
   		Comment__c newComment = new Comment__c();
   		newComment.Message__c = commentBody;
   		newComment.ParentWikiPage__c = idWikiPage;
   		insert newComment;
   		commentBody = '';
   		addComment = false;
   	}
   	
   	public void cancelComment () {
   		commentBody = '';
   		addComment = false;
   	}
   	
   	/* ---------------------------- */
   	/*   		REVISIONS			*/
   	/* ---------------------------- */   	
   	
	public String getCurrentRevision () {
   		Integer revCount;
   		Integer resultCount = [select count() from WikiVersions__c where WikiPageId__c =:idWikiPage];
	   	//System.debug('\n //////// \n GUARDE ESTE CONTADOR DE VERSIONES: ' + resultCount + '\n /////////////\n' );
	   	if (resultCount != 0) {	
	   		WikiVersions__c wikiVersion = [select Name from WikiVersions__c where WikiPageId__c =:idWikiPage order by CreatedDate desc limit 1];
	   		/*if (wikiVersion.revisionCount__c == null) {
	   			revCount = 1;
	   		}
	   		else {
	   			revCount = Integer.valueOf(String.valueOf(Math.roundToLong(wikiVersion.revisionCount__c)));
	   		}*/
	   		revCount = 1;
	   	}
	   	else {
	   		revCount = 1;
	   	} 
   		return ('Revision v' + revCount);
   		//return ('Revision v1');
   	}
   	
   	/* ---------------------------- */
   	/*   		DELETE PAGE			*/
   	/* ---------------------------- */  
   	
   	public without sharing class DeleteWiki {
   		public PageReference deleteWikiPage (List<WikiPage__c> wikiPageBodyList, UserPermissions userPermissions) {
   			PageReference pageRef;
   			if (userPermissions.getCanManage()) {
		   		String wikiParent = '';
		   		String idWikiSite = '';
		   		//System.debug('\n\n///////////////////////////////////// \n wikiPageBodyList ' + wikiPageBodyList + '\n ////////////////////////// \n\n');
		   		if (wikiPageBodyList.size() > 0) {
		   			if (wikiPageBodyList[0].Parent__c != null) {
		   				wikiParent = wikiPageBodyList[0].Parent__c;	
		   			}
		   			idWikiSite = wikiPageBodyList[0].team__c;
		   			delete wikiPageBodyList;
		   		}
		   		//System.debug('\n\n///////////////////////////////////// \n wikiParent ' + wikiParent + '\n ////////////////////////// \n\n');
		   		if (wikiParent != '') {
		   			pageRef = new PageReference('https://na1.salesforce.com/apex/WikiPage?idWP=' + wikiParent);
		   		}
		   		else {
		   			pageRef = new PageReference('https://na1.salesforce.com/apex/WikiTeamOverview?tid=' + idWikiSite);
		   		}
	   		}
	   		else {
	   			throw new CustomException('Insufficient Privileges');		
	   		}
	   		pageRef.setRedirect(true);
			return pageRef;
   		}	
   	}
   	
   	public PageReference deletePage () {
   		DeleteWiki delW = new DeleteWiki();
   		return delW.deleteWikiPage(wikiPageBodyList,userPermissions);
   	}
   	  		  		 		
}