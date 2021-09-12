/**
 * Created by pankajjakhar on 11/09/21.
 */
public with sharing class QueueLookupController {
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
                        Group(Id, Name WHERE id NOT IN :selectedIds)
                LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Group[] accounts = (List<Group>) searchResults[0];
        for (Group groupRecord : accounts) {
            String subtitle = groupRecord.Name == null ? 'Group' : 'Group • ' + groupRecord.Name;
            results.add(new LookupSearchResult(groupRecord.Id, 'Group', accountIcon, groupRecord.Name, subtitle));
        }

        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        List<RecentlyViewed> recentRecords = [
                SELECT Id, Name
                FROM RecentlyViewed
                WHERE Type = 'Group'
                ORDER BY LastViewedDate DESC
                LIMIT 5
        ];

        // Convert recent records into LookupSearchResult
        for (RecentlyViewed recentRecord : recentRecords) {
            if (recentRecord.Type == 'Account') {
                results.add(
                        new LookupSearchResult(
                                recentRecord.Id,
                                'Group',
                                'standard:account',
                                recentRecord.Name,
                                'Group • ' + recentRecord.Name
                        )
                );
            }
        }
        return results;
    }
}