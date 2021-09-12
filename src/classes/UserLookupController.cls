/**
 * Created by pankajjakhar on 11/09/21.
 */

public with sharing class UserLookupController {

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query parameters

        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                        RETURNING
                        User(Id, Name, Email WHERE ID NOT IN :selectedIds)
                LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:user';
        User[] users = (List<User>) searchResults[0];
        for (User user : users) {
            String subtitle = user.Name == null ? 'User' : 'User • ' + user.Name;
            results.add(new LookupSearchResult(user.Id, 'User', accountIcon, user.Name, subtitle));
        }

        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        List<RecentlyViewed> recentRecords = [
                SELECT Id, Name, Email, Type
                FROM RecentlyViewed
                WHERE Type = 'User'
                ORDER BY LastViewedDate DESC
                LIMIT 5
        ];

        // Convert recent records into LookupSearchResult
        for (RecentlyViewed recentRecord : recentRecords) {
            if (recentRecord.Type == 'User') {
                results.add(
                        new LookupSearchResult(
                                recentRecord.Id,
                                'User',
                                'standard:user',
                                recentRecord.Name,
                                'User • ' + recentRecord.Name
                        )
                );
            }
        }

        return results;
    }
}