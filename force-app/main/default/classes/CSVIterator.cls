public class CSVIterator implements Iterator<CSVToContact>, Iterable<CSVToContact>{
   private List<CSVToContact> m_lstCon;
   private Integer currentPosition;

   public CSVIterator(List<CSVToContact> lstCon ){  
      m_lstCon = lstCon; 
      currentPosition = 0;
      System.debug('inside iterator');
   }
   public Boolean hasNext(){
      System.debug('m_SCVdata hasnext--'+currentPosition);
      return currentPosition < m_lstCon.size()  ;
   } 
   public CSVToContact next(){
      System.debug(' m_CSVData--'+ m_lstCon);
      
      
   if (currentPosition <m_lstCon.size() ) {
      CSVToContact con = m_lstCon[currentPosition];
      currentPosition++;
      return con;
      }
      return null;   
   }
   public Iterator<CSVToContact> Iterator(){
      return this;
   }
}