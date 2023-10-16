public without sharing class WikiPageEditController {
  	
  	public Info infoWP = new Info();
  	public Boolean info = false;
	public String idWikiSite;
    public String idWikiPage = System.currentPageReference().getParameters().get('id'); 
	public WikiPage__c editWP = new WikiPage__c();   
	public Replace replace = new Replace();
    
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
    
    
    public WikiPageEditController () {
 		constWikiPageEdit();		
 	}
 	
 	public with sharing class WikiEditSharing {
 		public List<WikiPage__c> getWikiEditView (String idWikiPage) {
 			return [SELECT Id From WikiPage__c WHERE id =:idWikiPage];
 		}	
 	}
 	
 	public void constWikiPageEdit () {
 		if (idWikiPage != null && idWikiPage != '') {
	 		
	 		WikiEditSharing wikiView = new WikiEditSharing();
						    
			if(wikiView.getWikiEditView(idWikiPage).size() == 0) {
				System.debug('\n\n//////////////////////\n SAVE THIS \n wikiView : ' + wikiView + '\n idWikiPage : ' + idWikiPage + '\n ///////////////////////////// \n\n');
				throw new CustomException('Insufficient Privileges');	
			}
			else {
		 		iniReplace();
		 		genEditWP();
		 		idWikiSite = editWP.Team__r.Id;
		 		parseHTML();
		 		infoGen();
		 		iniBody = html;	
		 		genPermissions(editWP.PageCreatedBy__c);
		 		
		 		if(!userPermissions.getCanManage()) {
					throw new CustomException('Insufficient Privileges');	
				}
			}
 		}
 	}
    
    public void genEditWP () {
    	editWP = [SELECT Name, ShortDescription__c, Body__c, Parent__c,PageCreatedBy__c, Team__r.Id FROM WikiPage__c WHERE id = : idWikiPage];
    }
    
    public void setIdWikiPage (String idWikiPage){
		this.idWikiPage = idWikiPage;
	}
    
    public Replace getReplace (){
    	return replace; 
    }
 	
 	public void setReplace (Replace replace) {
 		this.replace = replace;
 	}
 	
 	public void iniReplace () {
 		WikiPage__c wikiHTML = [SELECT Body__c FROM WikiPage__c WHERE id =:idWikiPage]; 
 		replace.setContent(wikiHTML.Body__c); 
 	}
 	
 	public String getIdWikiPage () {
 		return idWikiPage;
 	}
 	
 	public String iniBody;
 	
 	public String getIniBody () {
 		return iniBody;
 	}
 	
 	public void setIniBody (String iniBody) {
 		this.iniBody = iniBody;
 	} 
 	
	public String getWikiHome () {
		return [select Id from WikiPage__c where Name = 'Home' and Team__c =:idWikiSite].Id;
	} 
 	  
	public class Replace {       
        String content; 
        
        public String getContent() {
                return content;
        }

        public void setContent(String content) {
                this.content = content;
        }            
	}

	public String idLink1 = '0:j_id226';
	public String linkpart1 = 'switchOverlay(true);;A4J.AJAX.Submit(\'_viewRoot\',\'WikiHome:wikisPageBlock:formTree\',event,{\'parameters\':{\'WikiHome:wikisPageBlock:formTree:wikiTable:' + idLink1 + '\':\'WikiHome:wikisPageBlock:formTree:wikiTable:' + idLink1 + '\',\'idWP\':\'';
	public String linkpart2 = '\'} ,\'actionUrl\':\'/apex/WikiHome?javax.portlet.faces.DirectLink=true\',\'oncomplete\':function(request,event,data){switchOverlay(false);}} );return false;\" name=\"WikiHome:wikisPageBlock:formTree:wikiTable:' + idLink1 + '\" id=\"WikiHome:wikisPageBlock:formTree:wikiTable:' + idLink1 + '\" href=\"#\">';
	
 	public String html = ' ';
 	
 	public void parseHTML() { 
		
		
    	String toc = '';
    			
  		html = replace.content;
		//System.debug('\n \n ///////////// \n HTML DEVUELTO POR EL WIKISYNTAX: \n ' + html + '\n /////////////// \n');
 		html = html.replaceAll('\n','<br>');
 		
 		/* ------------------------ */
 		/* 		Code (No parsed) 	*/
 		String noparsedOpen = '{{{';	
 		String noparsedClose = '}}}';
 		String splitOpen = '\\{\\{\\{';
 		String splitClose = '\\}\\}\\}';
 		String replacementCode = '%-%-%-%';
 		List<String> noparsedText = new List<String>();
 		while (html.lastIndexOf(noParsedOpen) != -1) {
	 		List<String> temp = new List<String>();
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
						tableAttParts = tableContent.split('(?i)<br>',2);
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
						captionTextParts = bodyTable.substring(2).split('(?i)<br>',2);
						
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
							rowAtt = iterRow.split('(?i)<br>',2);
							
							if (rowAtt.size() == 2) {
								tableTag += '<tr ';
								if (rowAtt[0] != '' && rowAtt[0] != null ) {
									tableTag += rowAtt[0].trim();
								}
								tableTag += '>';
								
								//System.debug('\n  //////////////( 6 )///////////////// \n SAVE THIS ITEM ROW: \n ' + itemRow + '\n ITER ROW: ' + iterRow + '\n ROW ATT: ' + rowAtt + '\n ///////////////////////////////// \n');
								iterRow = rowAtt[1].trim();
								
								for (String itemCell : iterRow.split('(?i)<br>')) {
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
						temp2 = tail.split('(?i)<br>', 2);	
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
						temp2 = tail.split('(?i)<br>', 2);	
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
 		/* 		Horizontal Line 	*/
 		String line = '----';
 		html = html.replace(line ,'<hr>');


		/* ------------------------ */
 		/* 			Emoticons	 	*/
 		String resourceId = '1211555009000';
		String surprised = ':\\|';
		html = html.replaceAll(surprised , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/whatchutalkingabout_smile.gif\'>');

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
		
		html = html.replaceAll(alignJustifyOpen ,'<p style="text-align: justify;">');
		html = html.replaceAll(alignRightOpen ,'<p style="text-align: right;">');
		html = html.replaceAll(alignLeftOpen ,'<p style="text-align: left;">');
		html = html.replaceAll(alignCenterOpen ,'<p style="text-align: center;">');
		
		html = html.replaceAll(alignJustifyClose ,'</p>');
		html = html.replaceAll(alignRightClose ,'</p>');
		html = html.replaceAll(alignLeftClose ,'</p>');
		html = html.replaceAll(alignCenterClosen ,'</p>');
 		
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
	 		if (temp[1].indexOf(listSyntax) >= temp[1].toLowerCase().indexOf('<br>') || temp[1].indexOf(listSyntax)== -1 ) {
	 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
	 				temp[1] = '>' + temp[1] + '</li></ul>';
	 				last = true;
	 			}
	 			else {	 
	 				List<String> temp2;	
	 				temp2 = temp[1].split('(?i)<br>',2);	
	 				if (temp2[1].indexOf(listSyntax) == 0) {	
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li>');
	 				}
	 				else {
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li></ul>');
	 					last = true;
	 				}
	 			}
	 		}
	 		else {
	 			temp[1] = temp[1].replaceFirst(listS,'');
	 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
	 				temp[1] = ' style="padding-left:10px;">' + temp[1] + '</li></ul>';
	 				last = true;
	 			}
	 			else {	 		
	 				temp[1] = ' style="padding-left:10px;">' + temp[1].replaceFirst('(?i)<br>', '</li>');
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
 		
 		//System.debug('\n ///////////////////////////// \n SAVE THIS HTML BEFORE APPLY ORDERED LIST PARSER: \n' + html + '\n ///////////////////////////// \n');
 		while (html.lastIndexOf(listSyntaxOL) != -1) {	
	 		String listS = '~';
	 		List<String> temp;
	 		temp = html.split(listS,2);
	 		html = html.replaceFirst(listS , '<li>');
	 		if (temp[1].indexOf(listSyntaxOL) >= temp[1].toLowerCase().indexOf('<br>') || temp[1].indexOf(listSyntaxOL)== -1 ) {
	 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
	 				temp[1] = '>' + temp[1] + '</li></ol>';
	 				lastOL = true;
	 			}
	 			else {	 
	 				List<String> temp2;	
	 				temp2 = temp[1].split('(?i)<br>',2);	
	 				if (temp2[1].indexOf(listSyntaxOL) == 0) {	
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li>');
	 				}
	 				else {
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li></ol>');
	 					lastOL = true;
	 				}
	 			}
	 		}
	 		else {
	 			temp[1] = temp[1].replaceFirst(listS,'');
	 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
	 				temp[1] = ' style="padding-left:10px;">' + temp[1] + '</li></ol>';
	 				lastOL = true;
	 			}
	 			else {	 		
	 				temp[1] = ' style="padding-left:10px;">' + temp[1].replaceFirst('(?i)<br>', '</li>');
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
 		//System.debug('\n ///////////////////////////// \n SAVE THIS HTML AFTER APPLY ORDERED LIST PARSER: \n' + html + '\n ///////////////////////////// \n');
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
 		/* 			Bold Text 		*/ 			
 		String bold = '\'\'\'';
 		while (html.lastIndexOf(bold) != -1) {
	 		html = html.replaceFirst(bold , '<b>');
	 		html = html.replaceFirst(bold , '</b>');
 		}
 		
 		/* ------------------------ */
 		/* 		UnderLine Text 		*/ 			
 		String under = '__';
 		while (html.lastIndexOf(under) != -1) {
	 		html = html.replaceFirst(under , '<u>');
	 		html = html.replaceFirst(under , '</u>');
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
 		/* 			Italic Text 	*/ 		
 		String italic = '\'\'';
 		while (html.lastIndexOf(italic) != -1) {
	 		html = html.replaceFirst(italic , '<i>');
	 		html = html.replaceFirst(italic , '</i>');
 		}
 		
		/* ------------------------ */
 		/* 		Strike Text 		*/ 			
 		String strikeOpen = '\\-\\-\\(';
 		String strikeClose = '\\)\\-\\-';
	 	html = html.replaceAll(strikeOpen , '<strike>');
	 	html = html.replaceAll(strikeClose , '</strike>');

 		/* ------------------------ */
 		/* 		External Link 		*/
 		/*		HTTPS SUPORT		*/  
 		String extLink = '[http';
 		while (html.lastIndexOf(extLink) != -1) {
 			List<String> temp;
 			String extL = '\\[http'; 
 			temp = html.split('(?i)' + extL , 2);
 			
 			if (temp[1].indexOf(' ') != -1 && temp[1].indexOf(']') != -1) {
	 			html = temp[0] + '<a href="http';
	 			String[] temp2 = temp[1].split(' ', 2);
	 			html += temp2[0] + '"';
	 			List<String> temp3 = new List<String>();
	 			//System.debug('\n ////////////////////// \n SAVE THIS LINK CONTENT TAIL: ' + temp2 + '\n /////////////////////// \n');
	 			if (temp2[1].indexOf('[Image:') != -1 && (temp2[1].indexOf('[Image:') < temp2[1].indexOf(']'))) {
	 				temp3 = temp2[1].split('\\]\\]', 2);
	 				//System.debug('\n ////////////////////// \n SAVE THIS LINK CONTENT VARS: \n temp3: ' + temp3 + '\n temp2[1].indexOf([Image:)' + temp2[1].indexOf('[Image:') + '\n temp2[1].indexOf(])' + temp2[1].indexOf(']') + '\n /////////////////////// \n');
	 				temp3[0] += ']';
	 				//System.debug('\n ////////////////////// \n SAVE THIS LINK CONTENT VARS: \n temp3: ' + temp3 + '\n temp2[1].indexOf([Image:)' + temp2[1].indexOf('[Image:') + '\n temp2[1].indexOf(])' + temp2[1].indexOf(']') + '\n /////////////////////// \n');
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
 			temp = html.split('(?i)' + img , 2);
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
									/*
									if (idWikiPage == null) {
										idWikiPage = getWikiHome();
									}
									*/
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
	 					/*
	 					if (attName == 'w') {
	 						imgTag += ' width="' + attval + '"';	
	 					}
	 					if (attName == 'a') {
	 						imgTag += ' align="' + attval + '"';	
	 					}
	 					if (attName == 'h') {
	 						imgTag += ' height="' + attval + '"';	
	 					}
	 					*/
	 					if (attName == 'src') {
	 						String srcImg = '';
	 						if (attVal.toLowerCase().indexOf('http') != -1) {
	 							srcImg = attVal;
	 						}
	 						else {
		 						String imageName = attVal;
								/*
								if (idWikiPage == null) {
									idWikiPage = getWikiHome();
								}
								*/
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
	 			
	 			imgTag += '/>';
	 			
	 			//System.debug('\n //////////////////// \n CONSTRUCTION OF THE IMG TAG: \n' + imgTag + '\n ////////////////////// \n ');
	 			
	 			html = temp[0] + imgTag + temp2[1];
 			}
 			else {
 				html = temp[0] + '<img title="Malformed Image" alt="Malformed Image" />' + temp[1];
 			}
 		}
 	
 		
 		/* ------------------------ */
 		/* 		Embedded File		*/ 
 		String fileS = '[File:';
 		while (html.lastIndexOf(fileS) != -1) {
 			List<String> temp;
 			String file = '\\[File:'; 
 			temp = html.split('(?i)' + file , 2);
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
		            	System.debug('\n ///////////////////// \n SAVE THIS ATTACH EXTENSION: ' + extension2 + '\n SAVE ATTACH NAME: ' + AttachmentsImage.Name + '\n /////////////////////////// \n');
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
	 			html = temp[0] + '<a href="';
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
	 		List<String> tempToc1;
	 		List<String> tempToc2;
	 		
	 		tempToc1 = html.split('(?i)' + tocCentinelStart, 2);
	 		html = html.replaceFirst('(?i)' + tocCentinel,'');
	 		
	 		tempToc2 = tempToc1[1].split('(?i)' + tocCentinelEnd, 2);
	 		html = html.replaceFirst('(?i)' + tocCentinel,'');
			
			Integer a = tempToc1[0].length() - 1;
			String part1 = tempToc1[0].substring(0,a);
			String numH = tempToc1[0].substring(a,a + 1);
	 		html = part1 + '<a name="'+ tempToc2[0] + '"></a>' + tempToc2[1]; 
	 		//style="padding-left:' + numH.substring(0,1) + '0px;"
	 		toc += '<a  href="#' + tempToc2[0] + '" style="padding-left:' + numH + '0px;padding-bottom:5px;">' + tempToc2[0] + '</a><br>\n';

	 		//toc += tempToc2[0];

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
 		
 		
 	}   
 	
 	public String getHtml () {
 		return html;	
 	}

 	public void parseWiki() { 
	
    			
  		html = replace.content;
		html = html.replaceAll('(?i)&nbsp;',' ');
		html = html.replaceAll('(?i)&amp;','&');
		html = html.replaceAll('(?i)&quot;','"');
		html = html.replaceAll('(?i)&gt;','>');
		html = html.replaceAll('(?i)&lt;','<');
		System.debug('\n \n ///////////// \n HTML DEVUELTO POR EL FCKEDITOR: \n ' + html + '\n /////////////// \n'); 		

  		/* ------------------------ */
 		/* 		Code (no parsed) 	*/ 		
		html = html.replaceAll('(?i)' + '<table style=\\\"border: 1px solid rgb\\(175, 175, 175\\); padding: 20px; background-color: rgb\\(250, 250, 250\\);\\\"><tbody><tr><td>','{{{');
		html = html.replaceAll('(?i)' + '<span></span></td></tr></tbody></table>','}}}'); 		

 		/* ------------------------ */
 		/* 		Background color 	*/ 		
		String bgcolorOpen = '<span style="background-color: ';
		
		String bgcolorClose = '</span>';
		List<String> tempBgcolor;
		while (html.toLowerCase().indexOf(bgcolorOpen) != -1) {
			tempBgcolor = html.split('(?i)' + bgcolorOpen, 2);
			List<String> tail = tempBgcolor[1].split('(?i)' + '[ ]*"[^>]*>', 2);
			String color = tail[0].replaceAll(';','');
			String resultHtml = tail[1].replaceFirst('(?i)' + bgcolorClose, ' Bgcolor]');
			html = tempBgcolor[0] + '[Bgcolor:' + color + ' ' + resultHtml;
		}

 		/* ------------------------ */
 		/* 		Text color 	*/ 		
		String colorOpen = '<span style="color: ';
		
		String colorClose = '</span>';
		List<String> tempColor;
		//System.debug('\n ///////////////////////// TEXT COLOR PARSER ///////////////////////');
		//System.debug('\n\n/////////////////////////\n HTML:\n' + html+ '\n /////////////////////// \n\n');
		while (html.toLowerCase().indexOf(colorOpen) != -1) {
			tempColor = html.split('(?i)' + colorOpen, 2);
			//System.debug('\n\n/////////////////////////\n tempColor:\n' + tempColor+ '\n /////////////////////// \n\n');
			List<String> tail = tempColor[1].split('(?i)' + '[ ]*"[^>]*>', 2);
			//System.debug('\n\n/////////////////////////\n tail:\n' + tail+ '\n /////////////////////// \n\n');
			String color = tail[0].replaceAll(';','');
			String resultHtml = tail[1].replaceFirst('(?i)' + colorClose, ' Color]');
			//System.debug('\n\n/////////////////////////\n resultHtml:\n' + resultHtml+ '\n /////////////////////// \n\n');
			html = tempColor[0] + '[Color:' + color + ' ' + resultHtml;
			//System.debug('\n\n/////////////////////////\n html:\n' + html+ '\n /////////////////////// \n\n');
		}
		
 		/* ------------------------ */
 		/* 			Ident Text 		*/ 		
		String identOpen = '<p style="margin-left: ';
		
		String identClose = '</p>';
		List<String> tempIdent;
		while (html.toLowerCase().indexOf(identOpen) != -1) {
			tempIdent = html.split('(?i)' + identOpen, 2);
			List<String> marginPx = tempIdent[1].split('(?i)' + 'px[^>]*">', 2);
			Integer numMinus = (Integer.valueOf(marginPx[0])) / 20;
			String minus = '';
			for (Integer i= 1; i<= numMinus; i++) {
				minus += '-';	
			}
			html = tempIdent[0] + '[[' + minus + '>' + marginPx[1].replaceFirst('(?i)' + identClose , minus + '>]]');
		}
		
				
  		/* ------------------------ */
 		/* 		UnOrdered List	 	*/
 		String ulOpen = '<ul>';
 		String ulClose = '</ul>';
 		while (html.toLowerCase().lastIndexOf(ulOpen) != -1) {
	 		List<String> ulPart;
	 		List<String> ulPart2;
	 		ulPart = html.split('(?i)' + ulOpen,2);
	 		ulPart2 = ulPart[1].split('(?i)' + ulClose,2);
	 		String ulString;
	 		ulString = ulPart2[0];
	 		String listTagOpen = '<li>';
	 		String listTagClose = '</li>';
	 		String listTagClose2 = '<br></li>';
	 		while (ulString.toLowerCase().lastIndexOf(listTagOpen) != -1) {
		 		List<String> temp;
		 		temp = ulString.split('(?i)' + listTagOpen ,2);
		 		ulString = ulString.replaceFirst('(?i)' + listTagOpen , '*');
		 		if (ulString.toLowerCase().indexOf(listTagClose2) < ulString.toLowerCase().indexOf(listTagClose) && ulString.toLowerCase().lastIndexOf(listTagClose2) != -1) {
		 			temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'');
		 		}
		 		else {
		 			temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'<br>');
		 		}
		 		ulString = temp[0] + '* ' + temp[1];
	 		} 		
	
	 		String listTagPadOpen = '<li style="padding-left: 10px;">';
	 		while (ulString.toLowerCase().lastIndexOf(listTagPadOpen) != -1) {
		 		List<String> temp;
		 		temp = ulString.split('(?i)' + listTagPadOpen ,2);
		 		ulString = ulString.replaceFirst('(?i)' + listTagPadOpen , '**');
		 		temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'<br>');
		 		ulString = temp[0] + '** ' + temp[1];
	 		} 
	 		
	 		html = ulPart[0] + ulString + ulPart2[1];
 		}

  		/* ------------------------ */
 		/* 		Ordered List	 	*/
 		String olOpen = '<ol>';
 		String olClose = '</ol>';
 		while (html.toLowerCase().lastIndexOf(olOpen) != -1) {
	 		List<String> olPart;
	 		List<String> olPart2;
	 		olPart = html.split('(?i)' + olOpen,2);
	 		olPart2 = olPart[1].split('(?i)' + olClose,2);
	 		String olString;
	 		olString = olPart2[0];
	 		String listTagOpen = '<li>';
	 		String listTagClose = '</li>';
	 		String listTagClose2 = '<br></li>';
	 		while (olString.toLowerCase().lastIndexOf(listTagOpen) != -1) {
		 		List<String> temp;
		 		temp = olString.split(listTagOpen ,2);
		 		olString = olString.replaceFirst('(?i)' + listTagOpen , '*');
		 		if (olString.toLowerCase().indexOf(listTagClose2) < olString.toLowerCase().indexOf(listTagClose) && olString.toLowerCase().lastIndexOf(listTagClose2) != -1) {
		 			temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'');
		 		}
		 		else {
		 			temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'<br>');
		 		}
		 		olString = temp[0] + '~ ' + temp[1];
	 		} 		
	
	 		String listTagPadOpen = '<li style="padding-left: 10px;">';
	 		while (olString.toLowerCase().lastIndexOf(listTagPadOpen) != -1) {
		 		List<String> temp;
		 		temp = olString.split('(?i)' + listTagPadOpen ,2);
		 		olString = olString.replaceFirst('(?i)' + listTagPadOpen , '~~');
		 		temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'<br>');
		 		olString = temp[0] + '~~* ' + temp[1];
	 		} 
	 		
	 		html = olPart[0] + olString + olPart2[1];
 		}
 		
		/* ------------------------ */
 		/* 			Text Align	 	*/
		
		String alignRightOpen = '<p style="text-align: right;">';
		String alignLeftOpen = '<p style="text-align: left;">';
		String alignCenterOpen = '<p style="text-align: center;">';
		String alignJustifyOpen = '<p style="text-align: justify;">';
		
		String alignClose = '</p>';
		List<String> tempRight;
		while (html.toLowerCase().indexOf(alignRightOpen) != -1) {
			tempRight = html.split('(?i)' + alignRightOpen, 2);
			html = tempRight[0] + '[[>' + tempRight[1].replaceFirst('(?i)' + alignClose ,'>]]');
		}
		
		while (html.toLowerCase().indexOf(alignLeftOpen) != -1) {
			tempRight = html.split('(?i)' + alignLeftOpen, 2);
			html = tempRight[0] + '[[<' + tempRight[1].replaceFirst('(?i)' + alignClose ,'<]]');
		}
		
		while (html.toLowerCase().indexOf(alignCenterOpen) != -1) {
			tempRight = html.split('(?i)' + alignCenterOpen, 2);
			html = tempRight[0] + '[[=' + tempRight[1].replaceFirst('(?i)' + alignClose ,'=]]');
		}
		
		while (html.toLowerCase().indexOf(alignJustifyOpen) != -1) {	
			tempRight = html.split('(?i)' + alignJustifyOpen, 2);
			html = tempRight[0] + '[[<>' + tempRight[1].replaceFirst('(?i)' + alignClose ,'<>]]');
		}

  		/* ------------------------ */
 		/* 			HEADINGS 		*/
 		for (Integer i = 6; i > 1; i--) {
	  		String headerOpen = '<h' + i + '[^>]*>'; 		
	  		String header = '';
	  		for (Integer j = 1; j <= i; j++) {
	  			header += '=';	
	  		} 
	  		
 			Integer fontSize;
			if (i == 2) { fontSize = 20; }
			if (i == 3) { fontSize = 18; }
			if (i == 4) { fontSize = 16; }
			if (i == 5) { fontSize = 14; }
			if (i == 6) { fontSize = 13; }			
 			  		
	 		html = html.replaceAll('(?i)' + headerOpen ,' ' + header + ' ');
	 		String headerClose1 = '<br></h' + i + '><hr>';
	 		String headerClose2 = '<br></h' + i + '>\r\n<hr>';
	 		String headerClose3 = '<br></h' + i + '>';
	 		String headerClose4 = '</h' + i + '><hr>';
	 		String headerClose5 = '</h' + i + '>\r\n<hr>';
	 		String headerClose6 = '</h' + i + '>';
	 		html = html.replaceAll('(?i)' + headerClose1 ,' ' + header + ' ');
	 		html = html.replaceAll('(?i)' + headerClose2 ,' ' + header + ' ');	
	 		html = html.replaceAll('(?i)' + headerClose3 ,' ' + header + ' ');
	 		html = html.replaceAll('(?i)' + headerClose4 ,' ' + header + ' ');	
	 		html = html.replaceAll('(?i)' + headerClose5 ,' ' + header + ' ');	
	 		html = html.replaceAll('(?i)' + headerClose6 ,' ' + header + ' ');		
 		}	
	 	
	 	/* ------------------------ */
 		/* 		Horizontal Line 	*/
 		String line = '<hr>';
 		html = html.replaceAll('(?i)' + line ,'----');
	 		
 		/* ------------------------ */
 		/* 			Bold Text 		*/ 			
  		String boldOpen = '<b>';
 		html = html.replaceAll('(?i)' + boldOpen ,' \'\'\' ');	
 		String boldClose = '</b>';
 		html = html.replaceAll('(?i)' + boldClose ,' \'\'\' '); 	
 		
 		/* ------------------------ */
 		/* 			Sub Text 		*/ 			
  		String subOpen = '<sub>';
 		html = html.replaceAll('(?i)' + subOpen ,',,');	
 		String subClose = '</sub>';
 		html = html.replaceAll('(?i)' + subClose ,',,'); 
 		
 		/* ------------------------ */
 		/* 			Sup Text 		*/ 			
  		String supOpen = '<sup>';
 		html = html.replaceAll('(?i)' + supOpen ,'^');	
 		String supClose = '</sup>';
 		html = html.replaceAll('(?i)' + supClose ,'^'); 		
 		
 		/* ------------------------ */
 		/* 			Italic Text 	*/ 		
  		String italicOpen = '<i>';
 		html = html.replaceAll('(?i)' + italicOpen ,' \'\' ');	
 		String italicClose = '</i>';
 		html = html.replaceAll('(?i)' + italicClose ,' \'\' '); 

 		/* ------------------------ */
 		/* 		  UnderLine Text 	*/ 		
  		String underOpen = '<u>';
 		html = html.replaceAll('(?i)' + underOpen ,' __');	
 		String underClose = '</u>';
 		html = html.replaceAll('(?i)' + underClose ,'__ ');
 		
 		/* ------------------------ */
 		/* 		 Strike Text 	*/ 
 		String strikeOpen = '<strike>';
 		String strikeClose = '</strike>';
	 	html = html.replaceAll('(?i)' + strikeOpen , '--(');
	 	html = html.replaceAll('(?i)' + strikeClose , ')--');

  		/* ------------------------ */
 		/* 		 Embedded Image 	*/  
  		
  		String imgTag = '<img ';
 		while (html.toLowerCase().indexOf(imgTag) != -1) {	
 			Boolean smileImg = false;
 			String imgTagGen = '';
 			List<String> imgTagContent = html.split('(?i)<img ', 2);
 			List<String> imgAtt = new List<String>();
 			if (imgtagContent[1].indexOf('/>') != -1) {
 				imgAtt = imgtagContent[1].split('/>',2);
 			}
 			else {
 				imgAtt = imgtagContent[1].split('>',2);
 			}
 			//System.debug('\n //////////( 1 )/////////////// \n THIS IMAGE ATTRIBUTES LIST : \n' + imgAtt[0] + '\n ///////////////////////// \n');	
 			
 			List<String> imgAttList = new List<String>();
 			String attributes = imgAtt[0]; 
 			//System.debug('\n //////////( 1 )/////////////// \n THIS ATTRIBUTES PARSER : \n' + attributes + '\n ///////////////////////// \n');
 			if (attributes.toLowerCase().indexOf('src') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)src',2);
 				if (tempAtt[1].toLowerCase().indexOf(' ') != -1) {
 					List<String> tempAtt2 = new List<String>();
 					tempAtt2 = tempAtt[1].split(' ', 2);
 					imgAttList.add('src' + tempAtt2[0]);
 					attributes = tempAtt[0] + tempAtt2 [1];
 				}
 				else {
 					imgAttList.add('src' + tempAtt[1]);
 					attributes = tempAtt[0];
 				}
 			}
 			//System.debug('\n //////////( 2 )/////////////// \n THIS ATTRIBUTES PARSER : \n' + attributes + '\n ///////////////////////// \n');
 			if (attributes.toLowerCase().indexOf('style') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)style',2);
 				String styleValue = tempAtt[1];
 				
 				styleValue = styleValue.substring(2);
 				List<String> tempAtt2 = new List<String>();
 				tempAtt2 = styleValue.split('"', 2);
 				imgAttList.add('style="' + tempAtt2[0] + '"');
 				attributes = tempAtt[0] + tempAtt2 [1];
 			}
 			//System.debug('\n //////////( 3 )/////////////// \n THIS ATTRIBUTES PARSER : \n' + attributes + '\n ///////////////////////// \n');
 			if (attributes.toLowerCase().indexOf('width') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)width',2);
 				if (tempAtt[1].toLowerCase().indexOf(' ') != -1) {
 					List<String> tempAtt2 = new List<String>();
 					tempAtt2 = tempAtt[1].split(' ', 2);
 					imgAttList.add('width' + tempAtt2[0]);
 					attributes = tempAtt[0] + tempAtt2 [1];
 				}
 				else {
 					imgAttList.add('width' + tempAtt[1]);
 					attributes = tempAtt[0];
 				}
 			}
 			//System.debug('\n //////////( 4 )/////////////// \n THIS ATTRIBUTES PARSER : \n' + attributes + '\n ///////////////////////// \n');
 			if (attributes.toLowerCase().indexOf('height') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)height',2);
 				if (tempAtt[1].toLowerCase().indexOf(' ') != -1) {
 					List<String> tempAtt2 = new List<String>();
 					tempAtt2 = tempAtt[1].split(' ', 2);
 					imgAttList.add('height' + tempAtt2[0]);
 					attributes = tempAtt[0] + tempAtt2 [1];
 				}
 				else {
 					imgAttList.add('height' + tempAtt[1]);
 					attributes = tempAtt[0];
 				}
 			}
 			//System.debug('\n //////////( 5 )/////////////// \n THIS ATTRIBUTES PARSER : \n' + attributes + '\n ///////////////////////// \n');
 			if (attributes.toLowerCase().indexOf('align') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)align',2);
 				if (tempAtt[1].toLowerCase().indexOf(' ') != -1) {
 					List<String> tempAtt2 = new List<String>();
 					tempAtt2 = tempAtt[1].split(' ', 2);
 					imgAttList.add('align' + tempAtt2[0]);
 					attributes = tempAtt[0] + tempAtt2 [1];
 				}
 				else {
 					imgAttList.add('align' + tempAtt[1]);
 					attributes = tempAtt[0];
 				}
 			}
 			//System.debug('\n ///////////( 2 )////////////// \n THIS IMAGE ATTRIBUTES LIST : \n' + imgAttList + '\n ///////////////////////// \n');
 			Integer widthSet = 0;
 			Integer heightSet = 0;
 			
 			for (String dim : imgAttList) {
 				if (dim.toLowerCase().indexOf('width') != -1) {
 					widthSet++;	
 				}
 				if (dim.toLowerCase().indexOf('height') != -1) {
 					heightSet++;	
 				}
 			}
 			
 			for (String item: imgAttList) {
 				if(item.indexOf('=') != -1) {
 					List<String> attParts = item.split('=', 2);
 					String attName = attParts[0].toLowerCase().trim();
 					String attVal = attParts[1].trim();
 					if (attName == 'style')	{
 						if (attVal.toLowerCase().indexOf('width') != -1 && widthSet < 2) {
 							List<String> styleW = new List<String>();
 							styleW = attVal.split('(?i)width[ ]*:',2);
 							String styleWVal = '';
 							if (styleW[1].indexOf(';') != -1) {
 								List<String> widthValS = new List<String>();
 								widthValS = styleW[1].split(';',2);
 								styleWVal = widthVals[0].trim();
 							}
 							else {
 								styleWVal = styleW[1].trim();	
 							}
 							imgTagGen += ' w:' + styleWVal.replaceAll('"', '') + ';';	
 						}
 						if (attVal.toLowerCase().indexOf('height') != -1 && heightSet < 2) {
 							List<String> styleH = new List<String>();
 							styleH = attVal.split('(?i)height[ ]*:',2);
 							String styleHVal = '';
 							//System.debug('\n ///////////( 2 )////////////// \n THIS IMAGE ATTRIBUTES VALUES : \n' + styleH + '\n ///////////////////////// \n');
 							if (styleH[1].indexOf(';') != -1) {
 								List<String> heightValS = new List<String>();
 								heightValS = styleH[1].split(';',2);
 								styleHVal = heightValS[0].trim();
 							}
 							else {
 								styleHVal = styleH[1].trim();	
 							}
 							imgTagGen += ' h:' + styleHVal.replaceAll('"', '') + ';';
 						}
 					}
 						
 					if (attName == 'width') {
						imgTagGen += ' w:' + attVal.replaceAll('"', '') + ';';	
 					}
 						
 					if (attName == 'height') {
 						imgTagGen += ' h:' + attVal.replaceAll('"', '') + ';';	
 					}
 						
 					if (attName == 'align') {
 						imgTagGen += ' a:' + attVal.replaceAll('"', '') + ';';	
 					}
 						
 					if (attName == 'src') {
 						String srcImage = '';
 						attVal = attVal.replaceAll('"', '');
 						//System.debug('\n ///////////( 1 )////////////// \n THIS IMAGE ATTRIBUTES SRC : \n' + attVal + '\n ///////////////////////// \n');
 						if (attVal.toLowerCase().indexOf('https://na1.salesforce.com/servlet/servlet') != -1) {
	 						
	 						String[] srcParts = attVal.split('(?i)file=',2);
	  				
				  			String imageId = srcParts[1];				
				 			List<Attachment> AttachmentsImage = [select Name, Id from Attachment where id =:imageId  limit 1];
				 			String imageName = '';
							//System.debug('\n ///////////( 2 )////////////// \n THIS IMAGE ATTRIBUTES SRC : \n' + counti + '\n ///////////////////////// \n');
							if (AttachmentsImage.size() > 0) {	
					 			//System.debug('\n ///////////( 3 )////////////// \n THIS IMAGE ATTRIBUTES SRC : \n' + AttachmentsImage + '\n ///////////////////////// \n');
					 			imageName = AttachmentsImage[0].Name;
							}
					 			
							imgTagGen += ' src:' + imageName + ';'; 
 						}	
 						else {
 							if (attVal.toLowerCase().indexOf('fckeditor/editor/images/smiley/msn') != -1) {
				 				if (attVal.toLowerCase().indexOf('regular_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('whatchutalkingabout_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':|';	
				 				}
				 				if (attVal.toLowerCase().indexOf('teeth_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':D';	
				 				}
				 				if (attVal.toLowerCase().indexOf('sad_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':(';	
				 				}
				 				if (attVal.toLowerCase().indexOf('cry_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':\'(';	
				 				}
				 				if (attVal.toLowerCase().indexOf('wink_smile.gif') != -1) {
				 					html = imgTagContent[0] + ';)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('devil_smile.gif') != -1) {
				 					html = imgTagContent[0] + '(6)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('lightbulb.gif') != -1) {
				 					html = imgTagContent[0] + '(I)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('thumbs_up.gif') != -1) {
				 					html = imgTagContent[0] + '(Y)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('thumbs_down.gif') != -1) {
				 					html = imgTagContent[0] + '(N)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('heart.gif') != -1) {
				 					html = imgTagContent[0] + '(L)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('broken_heart.gif') != -1) {
				 					html = imgTagContent[0] + '(U)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('kiss.gif') != -1) {
				 					html = imgTagContent[0] + '(K)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('envelope.gif') != -1) {
				 					html = imgTagContent[0] + '(E)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('shades_smile.gif') != -1) {
				 					html = imgTagContent[0] + '(H)';	
				 				}
				 				if (attVal.toLowerCase().indexOf('angry_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':@';	
				 				}
				 				if (attVal.toLowerCase().indexOf('tounge_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':P';	
				 				}
				 				if (attVal.toLowerCase().indexOf('embaressed_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':$';	
				 				}
				 				if (attVal.toLowerCase().indexOf('omg_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':O';	
				 				}
				 				if (attVal.toLowerCase().indexOf('confused_smile.gif') != -1) {
				 					html = imgTagContent[0] + ':S';	
				 				}
				 				if (attVal.toLowerCase().indexOf('angel_smile.gif') != -1) {
				 					html = imgTagContent[0] + '(A)';	
				 				}
				 				smileImg = true;		
 							}				
	 						else {
	 							imgTagGen += ' src:' + attVal + ';';
	 						}
						}
 					}
 				}
 			}
			
			if (!smileImg) {
				html = imgTagContent[0] + '[Image: ' + imgTagGen + ']';
			}
			if (imgAtt.size() > 1) {
	 			html += imgAtt[1];
			}
			//System.debug('\n ///////////////////////// \n THIS IMAGE HTML: \n' + html + '\n ///////////////////////// \n');
 		} 
 		
  		/* ------------------------ */
 		/* 		 Table of Content 	*/ 
 		String tocLinks = 'href="#[^>]*">[^>]*</a>';
 		html = html.replaceFirst('(?i)' + tocLinks,'>%TOC%');
 		html = html.replaceAll('(?i)' + tocLinks,'>');
 		
 		
 		/* ------------------------ */
 		/* 		  Linking Methods 	*/ 	 		
		
		String linkString = '<a';
		while (html.toLowerCase().indexOf(linkString) != -1) {
			String linkAttributes = '';
			String linkTail = '';
			String linkContent = '';
			String htmlTail = '';
			String idWikiLink = '';
			String idAttach = '';
			
			List<String> htmlLinkParts = new List<String>();
			htmlLinkParts = html.split('(?i)' + linkString,2);
			if (htmlLinkParts[1].indexOf('>') != -1) {
				List<String> linkParts = new List<String>();
				linkParts = htmlLinkParts[1].split('>', 2);
				linkAttributes = linkParts[0].trim();
				linkTail = linkParts[1];
				
				List<String> linkTailParts = new List<String>();
				if (linkTail.toLowerCase().indexOf('</a>') != -1) {
					linkTailParts = linkTail.split('(?i)</a>', 2);
					linkContent = linkTailParts[0];
					htmlTail = linkTailParts[1];
				}
				
				if (linkAttributes.toLowerCase().indexOf('apex/wikipage?idwp') != -1) {
					List<String> hrefParts = new List<String>();
					hrefParts = linkAttributes.split('(?i)href=[^>]*apex/wikipage\\?idwp=',2);
					List<String> idParts = new List<String>();
					idParts = hrefParts[1].split('"',2);
					idWikiLink = idParts[0].trim().replaceAll('&quot[^>]', '');
					
					//System.debug('\n /////////////////////////// \n SAVE THIS WIKI LINK ID: \n' + idWikiLink + '\n Link Attributes: ' + linkAttributes + '\n ///////////////////////////// \n');
					
					WikiPage__c wiki = [select name, team__r.name from WikiPage__c where id=: idWikilink];
					if (linkContent.trim().replaceAll('(?i)<br>', '') != '') {
						html =  htmlLinkParts[0] + '[['+ wiki.team__r.name + ':' + wiki.name + ']]' + htmlTail;
					}
					else {
						html =  htmlLinkParts[0] + htmlTail;
					}	
				}
				else {
					if (linkAttributes.toLowerCase().indexOf('servlet/servlet.filedownload?file=') != -1) {
						List<String> hrefParts = new List<String>();
						hrefParts = linkAttributes.split('(?i)href=[^>]*servlet/servlet.filedownload\\?file=',2);
						List<String> idParts = new List<String>();
						idParts = hrefParts[1].split('"',2);
						idAttach = idParts[0].trim().replaceAll('(?i)&quot[^>]', '');
						
						Attachment attch = [select name from Attachment where id=: idAttach];
						if (linkContent.trim().replaceAll('(?i)<br>', '') != '') {
							html =  htmlLinkParts[0] + '[File:'+ attch.name + ']' + htmlTail;
						}
						else {
							html =  htmlLinkParts[0] + htmlTail;
						}
					}
					else {
						if (linkAttributes.toLowerCase().indexOf('newchildprefield(') != -1) {
							List<String> newChildParts = new List<String>();
							newChildParts = linkContent.split('(?i) Page ', 2);
							html =  htmlLinkParts[0] + '[[' + newChildParts[1].trim() + ']]' + htmlTail;
						}
						else {
							if (linkAttributes.toLowerCase().indexOf('href="http') != -1) {
								List<String> hrefParts = new List<String>();
								hrefParts = linkAttributes.split('(?i)href="',2);
								List<String> idParts = new List<String>();
								idParts = hrefParts[1].split('"',2);
								idAttach = idParts[0].trim().replaceAll('(?i)&quot[^>]', '');
								if (linkContent.trim().replaceAll('(?i)<br>', '') != '') {
									html =  htmlLinkParts[0] + '[' + idParts[0].trim() + ' ' + linkContent.trim().replaceAll('<br>', '') + ']'+ htmlTail;
								}
								else {
									html =  htmlLinkParts[0] + htmlTail;
								}
							}
							else {
								if (linkAttributes.toLowerCase().indexOf('href=') == -1) {
									html =  htmlLinkParts[0] + htmlTail;	
								}
								else {
									List<String> hrefParts = new List<String>();
									//System.debug('\n /////////////////////////// \n SAVE THIS Link Attributes: ' + linkAttributes + '\n ///////////////////////////// \n');
									hrefParts = linkAttributes.split('(?i)href="',2);
									List<String> idParts = new List<String>();
									//System.debug('\n /////////////////////////// \n SAVE THIS hrefParts: ' + hrefParts + '\n ///////////////////////////// \n');
									idParts = hrefParts[1].split('"',2);
									//System.debug('\n /////////////////////////// \n SAVE THIS idParts: ' + idParts + '\n ///////////////////////////// \n');
									String wikiPageName = idParts[0].trim().replaceAll('(?i)&quot[^>]', '');
									html =  htmlLinkParts[0] + '[[' + wikiPageName.replaceAll('<br>', '').replaceAll('%20', ' ') + ']]'+ htmlTail;
								}
							}
						}
					}	
				}
			}
		}
		
   		
   		/* ------------------------ */
 		/* 			Tables	 		*/
 		String tableStart = '{|';
 		String tableEnd = '|}';
 		String tableCaption = '|+';
 		String tableRow = '|-';
 		String tableHeader = '!';
 		String tableData = '|';
 		
 		//System.debug('\n ///////////////////////// \n HTML ANTES ENTRAR PARSER TABLA: \n' + html + '\n ///////////////////////// \n');
 		while (html.toLowerCase().indexOf('<table') != -1) {
 			List<String> htmlParts = new List<String>();
 			htmlParts = html.split('(?i)<table',2);
 			
 			String tableContent = '';
 			String htmlHead = '';
 			String htmlTail = '';
 			
 			if (htmlParts[0] != null) {
 				htmlHead = htmlParts[0];
 			}
 			
 			if (htmlParts[1].toLowerCase().indexOf('</table>') != -1) {
 				List<String> htmlTailParts = new List<String>();
 				htmlTailParts = htmlParts[1].split('(?i)</table>', 2);
 				htmlTail = htmlTailParts[1];
 				
 				tableContent = htmlTailParts[0];
 				tableContent = tableContent.replaceAll('(?i)<br>','');
 				tableContent = tableContent.replaceAll('(?i)<br/>','');
 				tableContent = tableContent.replaceAll('(?i)\r\n','');
 				
 				//Fix Copy and paste problems 
 				tableContent = tableContent.replaceAll('(?i)\n','');
 				tableContent = tableContent.replaceAll('(?i)\t','');
 				tableContent = tableContent.replaceAll('(?i)>[ ]*<','><');
 				//Fix Copy and paste problems
 				
 				//System.debug('\n ///////////( class 1 )////////////// \n TABLE CONTENT BEFORE CLASS REMOVE: \n' + tableContent + '\n ///////////////////////// \n');
 				tableContent = tableContent.replaceAll('(?i)class=" FCK__ShowTableBorders"','');
 				tableContent = tableContent.replaceAll('(?i)class=[^ ^>]*','');
 				//System.debug('\n ///////////( class 2 )////////////// \n TABLE CONTENT AFTER CLASS REMOVE: \n' + tableContent + '\n ///////////////////////// \n');
 				
 				tableContent = tableContent.replaceFirst('(?i)>[ ]*','\n');
 				//System.debug('\n ///////////( 1 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
 				
 				tableContent = tableContent.replaceAll('(?i)[ ]*<tbody>','');
 				tableContent = tableContent.replaceAll('(?i)</tbody>[ ]*','');              
 				
 				//System.debug('\n ///////////( 2 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
 				
 				tableContent = tableContent.replaceAll('(?i)</td>[ ]*','\n');
 				tableContent = tableContent.replaceAll('(?i)</th>[ ]*','\n');
 				tableContent = tableContent.replaceAll('(?i)</tr>[ ]*','');
 				
 				//System.debug('\n ///////////( 3 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
 				
 				tableContent = tableContent.replaceAll('(?i)[ ]*<tr>','|-\n');
 				tableContent = tableContent.replaceAll('(?i)[ ]*<td>','|');
 				tableContent = tableContent.replaceAll('(?i)[ ]*<th>','!');
 				
 				//System.debug('\n ///////////( 4 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
 				
 				if (tableContent.toLowerCase().indexOf('<caption') != -1) {
 					
 					if (tableContent.toLowerCase().indexOf('<caption>') != -1) {
 						tableContent = tableContent.replaceAll('(?i)<caption>','|+');
 					}
 					else {
 						tableContent = tableContent.replaceAll('(?i)[ ]*<caption','|+');
 						tableContent = tableContent.replaceFirst('(?i)>[ ]*','|');	
 					}
 					tableContent = tableContent.replaceAll('(?i)</caption>[ ]*','\n');	
 				}
 				
 				//System.debug('\n ///////////( 5 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
 				
 				while (tableContent.toLowerCase().indexOf('<tr') != -1) {
 					List<String> trParts = new List<String>();
 					trParts = tableContent.split('(?i)[ ]*<tr',2);
 					trParts[1] = trParts[1].replaceFirst('>[ ]*','\n');	
 					tableContent = trParts[0] + '<tr' + trParts[1];
 					
 					tableContent = tableContent.replaceFirst('(?i)[ ]*<tr','|-');
 				
 					//System.debug('\n ///////////( 6 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
 					
 					while (tableContent.toLowerCase().indexOf('<td') != -1) {
	 					List<String> tdParts = new List<String>();
	 					tdParts = tableContent.split('(?i)[ ]*<td',2);
	 					tdParts[1] = tdParts[1].replaceFirst('>[ ]*','|');	
	 					tableContent = tdParts[0] + '<td' + tdParts[1];
	 					
	 					tableContent = tableContent.replaceFirst('(?i)[ ]*<td','|');	
	 					
	 					//System.debug('\n ///////////( 7 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
 					}
 					
 					while (tableContent.toLowerCase().indexOf('<th') != -1) {
	 					List<String> thParts = new List<String>();
	 					thParts = tableContent.split('(?i)[ ]*<th',2);
	 					thParts[1] = thParts[1].replaceFirst('>[ ]*','|');	
	 					tableContent = thParts[0] + '<th' + thParts[1];
	 					
	 					tableContent = tableContent.replaceFirst('(?i)[ ]*<th','!');
	 					
	 					//System.debug('\n ///////////( 8 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
	 				}
 				}
 				
 				while (tableContent.toLowerCase().indexOf('<td') != -1) {
	 				List<String> tdParts = new List<String>();
	 				tdParts = tableContent.split('(?i)[ ]*<td',2);
	 				tdParts[1] = tdParts[1].replaceFirst('>[ ]*','|');	
	 				tableContent = tdParts[0] + '<td' + tdParts[1];
	 					
	 				tableContent = tableContent.replaceFirst('(?i)[ ]*<td','|');	
	 					
	 				//System.debug('\n ///////////( 9 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
 				}
 					
 				while (tableContent.toLowerCase().indexOf('<th') != -1) {
	 				List<String> thParts = new List<String>();
	 				thParts = tableContent.split('(?i)[ ]*<th',2);
	 				thParts[1] = thParts[1].replaceFirst('>[ ]*','|');	
	 				tableContent = thParts[0] + '<th' + thParts[1];
	 					
	 				tableContent = tableContent.replaceFirst('(?i)[ ]*<th','!');
	 					
	 				//System.debug('\n ///////////( 10 )////////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
	 			}
	 			
 				tableContent = tableContent.replaceAll('\n','<br>');
 			}
 			else {
 				htmlTail = htmlParts[1];
 			}
 			//System.debug('\n //////////( final )///////////// \n TABLE CONTENT: \n' + tableContent + '\n ///////////////////////// \n');
 			html = htmlHead + '{|' + tableContent + '|}' + htmlTail;
 			//System.debug('\n ///////////////////////// \n HTML ADENTRO PARSER TABLA: \n' + html + '\n ///////////////////////// \n');
 		}
 		html = html.replaceAll('(?i)' + '<p>','');
 		html = html.replaceAll('(?i)' + '</p>','<br>');
 		//html = html.replaceAll('  ','&nbsp;');
 		//System.debug('\n //////////( final result )///////////// \n HTML RESULT: \n' + html + '\n ///////////////////////// \n');
  	}
 	
 	
   	/* ---------------------------- */
   	/*   	 EDIT WIKI PAGE			*/ 
   	/* ---------------------------- */
   	
	WikiVersions__c editWV;
	
	public PageReference SaveEdit () {
		System.debug('\n\n////////////////////////\nHTML BEFORE SAVE (1):' + html + '\n//////////////////////////\n\n');
		parseWiki();
		html = html.replaceAll('&nbsp;',' ');
		html = html.replaceAll('(?i)<br>','\n');
		System.debug('\n\n////////////////////////\nHTML BEFORE SAVE (2):' + html + '\n//////////////////////////\n\n');
		html = html.replaceAll('<[^>]*>', '');
		System.debug('\n\n////////////////////////\nHTML BEFORE SAVE (3):' + html + '\n//////////////////////////\n\n');
		editWV = new WikiVersions__c();
		editWV.Name = editWP.Name;
		editWV.Body__c = html;
		editWV.WikiPageId__c = editWP.Id;
		
		List<WikiVersions__c> oldCountLst = [select revisionCount__c from WikiVersions__c where WikiPageId__c =:editWP.id order by LastModifiedDate desc limit 1];
		
		if (oldCountLst.size() > 0) {
			Double oldCount = oldCountLst[0].revisionCount__c;
			if (oldCount == null) {
				editWV.revisionCount__c = 1;
			}
			else {
				editWV.revisionCount__c = oldCount + 1;
			}
		}
		else {
			editWV.revisionCount__c = 1;
		}
	 		
 		/* ------------------------ */
 		/* 		out/in Links 		*/	
 		List<WikiLink__c> wikiLinksDel = [select Id, Name,FromLink__c, ToLink__c from WikiLink__c where FromLink__c =: editWP.Id];
 		for (WikiLink__c delLink: wikiLinksDel){
 			// UPDATE WIKI LINK COUNT
 			WikiPage__c wikiUpdate1 = [select id,name,linkCount__c from WikiPage__c where id = :delLink.ToLink__c];
			wikiUpdate1.linkCount__c = wikiUpdate1.linkCount__c - 1;
			update wikiUpdate1;	
 			// UPDATE WIKI LINK COUNT
 			delete delLink;	
 		}
 		
 		String wikiBodyCode;
 		wikiBodyCode = html;
 		
 		String intLink = '[[';
 		while (wikiBodyCode.lastIndexOf(intLink) != -1) {
 			List<String> temp;
 			String intL = '\\[\\[';
 			temp = wikiBodyCode.split(intL , 2);
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
			 		
			 		List<WikiPage__c> wikiLst = [select Id, name from WikiPage__c where Name = :nameWiki and Team__c =:idTeamLink];
			 		
			 		if (wikiLst.size() > 0) {
			 			wiki = wikiLst[0];
				 		String id;
				 		id = wiki.Id; 	
				 		
					 	WikiLink__c wikiLinkOut = new WikiLink__c();
						wikiLinkOut.FromLink__c = editWP.Id;
						wikiLinkOut.ToLink__c = id;
						wikiLinkOut.Name = editWP.Name;								
						// UPDATE WIKI LINK COUNT
						WikiPage__c wikiUpdate = [select id,name,linkCount__c from WikiPage__c where id = :id];
						wikiUpdate.linkCount__c = wikiUpdate.linkCount__c + 1;
						update wikiUpdate;
						// UPDATE WIKI LINK COUNT
						upsert wikiLinkOut;
			 		}
		 		}
		 		wikiBodyCode = temp[0] + temp2[1];	
 			}
 			else {
 				wikiBodyCode = temp[0] + temp[1];
 			}
 		} 
 		
		insert editWV;		
		editWP.Body__c = html;
		update editWP;
		
		PageReference pageRef = new PageReference('https://na1.salesforce.com/apex/WikiPage?idWP=' + editWP.Id);
		pageRef.setRedirect(true);
		return pageRef;
	} 
	
	public PageReference CancelEdit () {
		PageReference pageRef = new PageReference('https://na1.salesforce.com/apex/WikiPage?idWP=' + editWP.Id);
		pageRef.setRedirect(true);
		return pageRef;	
	}
	
   	/* ---------------------------- */
   	/*   	  BREADCRUMBING			*/
   	/* ---------------------------- */ 
	
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
	   			breadCrumbing = '<a href="/apex/WikiPage?idWP=' + wikiBC.Id + '" style="text-decoration:underline; cursor:pointer;" >' + trunkName + '</a> > ' + breadCrumbing;
	   		}
	   		else {
	   			if (parentBC == null) {
	   				breadCrumbing = '<a href="/apex/WikiPage?idWP=' + wikiBC.Id + '" style="text-decoration:underline; cursor:pointer;" >' + trunkName + '</a> > ' + breadCrumbing;
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
            if (name.length() > 25) {
            	this.name = name.substring(0,23) + '..';
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
   	

   	
	public Boolean getInfo () {
		return this.Info;
	}   	
   
	public void okInfo () {
		info = false;
	}
	   	
   	public void infoGen () {
   		
   		WikiPage__c wiki;
		String idInfo = idWikiPage;
		//String idInfo = System.currentPageReference().getParameters().get('idWP');	
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
			
		info = true;
	}    		
   		
 	public Info getInfoWiki () {
 		return infoWP;
 	}		 	
}