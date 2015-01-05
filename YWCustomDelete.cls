public class YWCustomDelete {
    private Map<Id, Task> newTaskMap;
    private Boolean open, attachment, click, presentation;

    //defines the map of tasks and SFDC custom setting fields for later use
    public YWCustomDelete() {
        //set tasks in Trigger.newMap as newTaskMap
        this.newTaskMap = (Map<Id, Task>) Trigger.newMap;
        //Set Boolean for pulled SFDC Custom Settings/Fields
		YWDelete__c ywCustomSetting = YWDelete__c.getOrgDefaults();
		this.open = ywCustomSetting.Open__c;
		this.attachment = ywCustomSetting.Attachment__c;
		this.click = ywCustomSetting.Click__c;
		this.presentation = ywCustomSetting.Presentation__c;
	}

    //Method runs through map of Tasks from Trigger to find Yesware inserted Tasks to create list for specific tasks to delete.
	public void addedYeswareTask() { 
        //If no Yesware tasks found in Map, exit
		if (isYeswareMap(newTaskMap) == null) return;

        //list of tasks to be deleted at the end of this class
		List<Task> taskToDelete = new List<Task>();
		
        for (Task n : isYeswareMap(newTaskMap).values()) {
            if (n.Subject != null) {
                if (open == True && String.valueOf(n.Subject).startsWith('Message Opened:')) {
                    taskToDelete.add(n);
                }
                if (attachment == True && String.valueOf(n.Subject).startsWith('Attachment Opened in Message:')) {
                    taskToDelete.add(n);
                }
                if (click == True && String.valueOf(n.Subject).startsWith('Link Clicked in Message:')) {
                    taskToDelete.add(n);
                }
                if (presentation == True && String.valueOf(n.Subject).startsWith('Presentation Viewed in Message:')) {
                    taskToDelete.add(n);
                }
            }
        }

		if (taskToDelete != null && taskToDelete.size() > 0) {
			delete taskToDelete;
		}
	}

    //looks at map of task and returns only map of Task inserted by Yesware
	private static Map<Id, Task> isYeswareMap(Map<Id, Task> newMap) {
        Map<Id, Task> ywTasksMap = new Map<Id, Task>();

        Task [ ] ywAddedTask = [SELECT Id, Subject, Description FROM Task WHERE Id IN : newMap.keySet()];

        for (Task t : ywAddedTask) {
            if (t.Description != null && String.valueOf(t.Description).contains('Data provided by Yesware')) {
                ywTasksMap.put(t.Id, t);
            }
        }
        return ywTasksMap;
    }	
}