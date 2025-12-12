import Foundation

struct FuzzyMatcher {
    static func search(query: String, in candidates: [String]) -> [String] {
        guard !query.isEmpty else { return candidates }
        
        let query = query.lowercased()
        
        return candidates.filter { candidate in
            let candidate = candidate.lowercased()
            var queryIndex = query.startIndex
            var candidateIndex = candidate.startIndex
            
            while queryIndex < query.endIndex && candidateIndex < candidate.endIndex {
                if query[queryIndex] == candidate[candidateIndex] {
                    queryIndex = query.index(after: queryIndex)
                }
                candidateIndex = candidate.index(after: candidateIndex)
            }
            
            return queryIndex == query.endIndex
        }
    }
}
