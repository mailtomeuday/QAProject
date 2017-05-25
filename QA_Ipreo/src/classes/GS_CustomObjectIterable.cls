public class  GS_CustomObjectIterable implements Iterator<list<GS_CampaignMemberReportController.CampaignMemberWrapper>>
{ 
  public list<GS_CampaignMemberReportController.CampaignMemberWrapper> InnerList{get; set;}
  public list<GS_CampaignMemberReportController.CampaignMemberWrapper> ListRequested{get; set;}

   Integer i {get; set;} 
   public Integer setPageSize {get; set;} 

   public GS_CustomObjectIterable(List<GS_CampaignMemberReportController.CampaignMemberWrapper> lstAccWr)
   {
       InnerList = new list<GS_CampaignMemberReportController.CampaignMemberWrapper>(); 
       ListRequested = new list<GS_CampaignMemberReportController.CampaignMemberWrapper>();     
       InnerList = lstAccWr;
       setPageSize = 1000;
       i = 0; 
   }   

   public boolean hasNext(){ 
       if(i >= InnerList.size()) {
           return false; 
       } else {
           return true; 
       }
   } 
   
   public boolean hasPrevious(){ 
       system.debug('I am in hasPrevious' + i);
       if(i <= setPageSize) {
       		system.debug('I am in hasPrevious false');
           return false; 
       } else {
           system.debug('I am in hasPrevious true');
           return true;
            
       }
   }
   public boolean hasFirst(){ 
       system.debug('I am in hasFirst' + i);
       if(i <= setPageSize) {
           return false; 
       } else {
           return true; 
       }
   }       
   public boolean hasLast(){ 
       system.debug('I am in hasLast' + i);
       if(i >= InnerList.size()) {
           return false; 
       } else {
           return true; 
       }
   }   

   public list<GS_CampaignMemberReportController.CampaignMemberWrapper> next(){       
       system.debug('i value is ' + i);
       ListRequested = new list<GS_CampaignMemberReportController.CampaignMemberWrapper>(); 
       integer startNumber;
       integer size = InnerList.size();
       if(hasNext())
       {  
           if(size <= (i + setPageSize))
           {
               startNumber = i;
               i = size;
           }
           else
           {
               i = (i + setPageSize);
               startNumber = (i - setPageSize);
           }
           
           system.debug('i value is =====' + i);
           system.debug('i value is 2==== ' + (i - setPageSize));
           
           for(integer start = startNumber; start < i; start++)
           {
               ListRequested.add(InnerList[start]);
           }
       } 
       return ListRequested;
   } 
   
   public list<GS_CampaignMemberReportController.CampaignMemberWrapper> previous(){      
       ListRequested = new list<GS_CampaignMemberReportController.CampaignMemberWrapper>(); 
       system.debug('i value is previous before =====' + i);
       integer size = InnerList.size(); 
       if(i == size)
       {
           if(math.mod(size, setPageSize) > 0)
           {    
               i = size - math.mod(size, setPageSize);
           }
           else
           {
               i = (size - setPageSize);
           } 
       }
       else
       {
           i = (i - setPageSize);
       }
       
       system.debug('i value is previous =====' + i);
       system.debug('i value is 2previous ==== ' + (i - setPageSize));
       
       for(integer start = (i - setPageSize); start < i; ++start)
       {
           ListRequested.add(InnerList[start]);
       } 
       return ListRequested;
   }
    public list<GS_CampaignMemberReportController.CampaignMemberWrapper> First(){
        ListRequested = new list<GS_CampaignMemberReportController.CampaignMemberWrapper>();
        integer size = InnerList.size();
        if(size >= setPageSize){
            i = setPageSize;
        }
        else {
            i = size;
        }
        System.debug('I var--'+i);
        for(integer st = 0; st < i; ++st)
        {
           ListRequested.add(InnerList[st]);
        }
        return ListRequested;
    }    
    public list<GS_CampaignMemberReportController.CampaignMemberWrapper> Last(){
        ListRequested = new list<GS_CampaignMemberReportController.CampaignMemberWrapper>();
        integer size = InnerList.size();
        i = InnerList.size();
        Integer start = 0;
        if(math.mod(size, setPageSize) > 0){
            start = i - math.mod(size, setPageSize);
        }
        else if(math.mod(size, setPageSize) == 0 && i > setPageSize) {
            start = i - setPageSize;
        }
        System.debug('Start--'+Start);
        System.debug('I var--'+i);
        for(integer st = start; st < i; ++st)
        {
           ListRequested.add(InnerList[st]);
        }
        return ListRequested;
    }      
}