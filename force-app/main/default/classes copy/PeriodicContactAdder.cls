    public with sharing class PeriodicContactAdder implements Schedulable  {
        public List<Id> accountIds;
        public static Integer JOB_NUMBER = 1;

        public PeriodicContactAdder(List<Id> accountIds) {
            this.accountIds = accountIds;
        }

        public static void schedulJob(List<Id> accountIds, Integer intervalCreate) {
        
            List<String> crones = generateCrones(intervalCreate);

            for(String sch : crones){
                System.schedule('Periodic Contact Job' + JOB_NUMBER , sch, new PeriodicContactAdder(accountIds));
                JOB_NUMBER++;
            }
        }

        
        public static List<String> generateCrones(Integer minuteInterval) {
            List<String> crones = new List<String>();
            
            if(minuteInterval != 0 && minuteInterval <= 60)  {
                for (Integer i = 0; i < 60; i += minuteInterval) {
                    String crone = '0 '+ i +' * * * ?';
                    crones.add(crone);
                }
            }else {
                String errorMessage = 'Interval of job is incorrect. Please set the interval less than 60 or equal to 1 minutes';
                throw new PeriodicContactAdderException(errorMessage);
            }
            return crones;
            
        }

        public void execute(SchedulableContext sc) {
            System.enqueueJob(new ContactController(accountIds));
        }

        public class PeriodicContactAdderException extends Exception {}
    }