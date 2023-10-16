public class WikiPageTableParserController {

	public String tableHtmlResult = '';
	public String tableWikiSintax = '';
	
	public String getTableWikiSintax () {
		return tableWikiSintax;
	}
	
	public void setTableWikiSintax (String tableWikiSintax) {
		this.tableWikiSintax = tableWikiSintax;
	}
	
	public String getTableHtmlResult () {
		return tableHtmlResult;
	}
	
	public void parseTableWikiSintax () {
		String html = tableWikiSintax;
		
		html = html.replaceAll('\n','<br>');
 		
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
			String tableTag = '<table';
			String tailHtml = '';
			
			if (htmlParts[1].indexOf(tableEnd) != -1) {
				List<String> tailParts = new List<String>();
				tailParts = htmlParts[1].split(tableEndExp,2);
				String tableContent = '';
				System.debug('\n  //////////////( 10 )///////////////// \n SAVE THIS TABLE CONTENT: \n ' + tailParts + '\n ///////////////////////////////// \n');
				
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
						bodyTable = tableAttParts[1];
						
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
							tableTag += tableAttParts[0]; //support all attributes
						}	
					}
					tableTag += '>';
					
					// If have caption Syntax
					System.debug('\n  //////////////( 1 )///////////////// \n SAVE THIS BODY TABLE: \n ' + bodyTable + '\n ///////////////////////////////// \n');
					List<String> captionTextParts = new List<String>();
					
					if (bodyTable.toLowerCase().indexOf('<br>') != -1) {
						captionTextParts = bodyTable.substring(2).split('<br>',2);
						
						if (bodyTable.trim().indexOf(tableCaption) == 0 && bodyTable.toLowerCase().indexOf('<br>') != -1) {
							System.debug('\n  //////////////( 2 )///////////////// \n SAVE THIS CAPTIONS PARTS: \n ' + captionTextParts + '\n ///////////////////////////////// \n');
							String captionText = captionTextParts[0];
							if (captionText.indexOf(tableData) == -1) {
								System.debug('\n  //////////////( 3 )///////////////// \n SAVE THIS CAPTIONS TEXT NO ATTRIBUTES : \n ' + captionText + '\n ///////////////////////////////// \n');
								tableTag += '<caption>' + captionText + '</caption>';
							}
							else {
								List<String> captionParts = new List<String>();
								captionParts = captionText.split(tableDataExp,2);
								System.debug('\n  ///////////////( 4 )//////////////// \n SAVE THIS CAPTIONS TEXT ATTRIBUTES : \n ' + captionText + '\n' + captionParts + '\n ///////////////////////////////// \n');
								tableTag += '<caption ' + captionParts[0] + '>' + captionParts[1] + '</caption>';	
							}
							bodyTable = captionTextParts[1];
						}
						else {
							if (bodyTable.trim().indexOf(tableRow) != 0) {
								bodyTable = '<br>' + bodyTable;
							}	
						}
						System.debug('\n  ///////////////( 5 )//////////////// \n SAVE THIS BODY TABLE: \n ' + bodyTable + '\n ///////////////////////////////// \n');
						
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
									tableTag += rowAtt[0];
								}
								tableTag += '>';
								
								System.debug('\n  //////////////( 6 )///////////////// \n SAVE THIS ITEM ROW: \n ' + itemRow + '\n ITER ROW: ' + iterRow + '\n ROW ATT: ' + rowAtt + '\n ///////////////////////////////// \n');
								iterRow = rowAtt[1];
								
								for (String itemCell : iterRow.split('<br>')) {
									System.debug('\n  ///////////////( 7 )//////////////// \n SAVE THIS ITEM CELL: \n ' + itemCell + '\n ///////////////////////////////// \n');
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
													tdAtt = tdAtts[0];
												}
												if (tdAtts[1] != null) {
													tdContent = tdAtts[1];
												}
												tableTag += tdAtt;	 
											}	
											else {
												tdContent = itemCell;	
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
														tdAtt = tdAtts[0];
													}
													if (tdAtts[1] != null) {
														tdContent = tdAtts[1];
													}
													tableTag += tdAtt;	 
												}	
												else {
													tdContent = itemCell;	
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
				html = htmlParts[0] + '<table>' + htmlParts[1];
			}
			
			System.debug('\n  //////////////( 8 )///////////////// \n SAVE THIS TABLE TAG: \n ' + tableTag + '\n ///////////////////////////////// \n');
 		}
		
		System.debug('\n  ///////////////( 9 )//////////////// \n SAVE THIS HTML RESULT: \n ' + html + '\n ///////////////////////////////// \n');
		
		tableHtmlResult = html;
	}
	
	public void insertGroupMember () {
		GroupMember newMember = new GroupMember();
		newMember.GroupId = '00G30000001BWQYEA4';
		newMember.UserOrGroupId = '00530000001IOnRAAW';	
		insert newMember;
	}
	
}