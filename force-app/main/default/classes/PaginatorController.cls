public class PaginatorController {
    
    public Integer totalItemsNumber= 0;
    public void serTotalItemsNumber(Integer num) {
        totalItemsNumber = num;
    }
    
    public Integer getTotalItemsNumber () {
        return totalItemsNumber;
    }
    
    /* ************************ */
    /*        Pagination        */
    /* ************************ */
    
    /**
    * Set of Integers to control pagination
    */
    public Integer numberOfItemsToShow = 10;
    public Integer cntPagination;
    public Integer currentPagination = 1;
    public Integer firstRow = 0;
    
    public void setNumberOfItemsToShow (Integer i){
        numberOfItemsToShow = i;
    }
    
    
    /**
    * Set of Booleans to show or not prev / next links
    */
    public boolean prevPageLinkShow = false;
    public boolean prevPageShow  = false;
    public boolean nextPageLinkShow  = false;
    public boolean nextPageShow  = false;
    public boolean disabledInput  = false;
    
    public boolean getdisabledInput() {
        if(nextPageShow && prevPageShow){
            disabledInput = true;
        }
        else {
            disabledInput = false;
        }
        return disabledInput;
    }
        
    public void genCntPagination() {
        cntPagination = (totalItemsNumber - (Math.mod(totalItemsNumber, numberOfItemsToShow)))/ numberOfItemsToShow;    
        if (Math.mod(totalItemsNumber, numberOfItemsToShow) != 0 ) {
            cntPagination++;
        }   
    }
    
    public void clearPagination(){
        firstRow = 0;
        currentPagination = 1;
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

    public void refreshPages () {}
    
    /**
    * Pagination Integer Getters
    */
    public Integer getFirstItem () {
        return (firstRow);
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
        
        if(currentPagination == 1){ prevPageShow = true; 
        } else {prevPageShow = false;}
        
        return prevPageShow;
    }
    
    public boolean getNextPageLinkShow () {
        
        
        if((currentPagination == cntPagination) || (cntPagination == 0)){   nextPageLinkShow = false; 
        } else { nextPageLinkShow = true;}          
        
        return nextPageLinkShow;
    }
    
    public boolean getNextPageShow () {
        
        if((currentPagination == cntPagination) || (cntPagination == 0)){ nextPageShow = true; 
        } else { nextPageShow = false;} 
        
        return nextPageShow;
    }   
    
    /* ************************ */
    /*        Jump to Page      */
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