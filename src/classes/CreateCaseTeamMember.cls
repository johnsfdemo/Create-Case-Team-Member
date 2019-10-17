//  Flow component to assign a case team member to a case.
//  
//  The code checks to make sure that only one record is entered at a time.  To provide updates to multiple
//  cases, place this component inside a loop in flow builder.
//  
//  Returns a status string of either 'SUCCESS' or 'FAILURE'.  In case of FAILURE, a more detailed message
//  detailing the reason for failure is provided.
//
//  This code is provided AS IS, with no warranty or guarantee of suitability for use.
//  Contact: john.meyer@salesforce.com


global without sharing class CreateCaseTeamMember {
    
    private static final String SUCCESS = 'SUCCESS';
    private static final String FAILURE = 'FAILURE';
    
    global class Requests {
        @InvocableVariable(required=true) global Id caseId;					// The ID of the case        
        @InvocableVariable(required=true) global Id userId;					// The user ID of the team member        
        @InvocableVariable(required=true) global String teamRole;			// The case team role
    }
    
    global class Results {
        @InvocableVariable global String status;							// Either 'SUCCESS' or 'FAILURE'        
        @InvocableVariable global String message;							// In the case of FAILURE, a more detailed message
    }    
    
    @InvocableMethod(label='Create a Case Team Member' description='Adds a user to a case\'s case team')
    
    public static List<Results> createCaseTeamMember (List<Requests> records) {
        
        List<Results> resultList = new List<Results>();
        Results result = new Results();
        
        if (records.size() != 1) {
            result.status = FAILURE;
            result.message = 'You must supply exactly one case to use this action.';
            System.debug(result.message);
        } else            
            try {
                CaseTeamRole role = [SELECT Id FROM CaseTeamRole WHERE Name = :records[0].teamRole LIMIT 1];
                if (role != null) {
                    insert new CaseTeamMember (ParentId = records[0].caseId, MemberId = records[0].userId, TeamRoleId = role.Id);
                    result.status = SUCCESS;
                } else {
                    result.status = FAILURE;
                    result.message = 'Invalid case team role: "' + records[0].teamRole + '".';
                    System.debug(result.message);
                }
            } catch (DMLException e) {
                result.status = FAILURE;
                result.message = 'Could not create team member for user Id = "' + records[0].userId + '" on case Id = "' + records[0].caseId +
                    ' with role = "' + records[0].teamRole + '": ' + e.getMessage();
                System.debug(result.message);
            }
        
        resultList.add(result);
        return resultList;
    }
}