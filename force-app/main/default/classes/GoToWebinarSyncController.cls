public class GoToWebinarSyncController {
    public  static void getAllwebinars() {
        System.enqueueJob(new GoToWebinarQueueable());
    }    
}