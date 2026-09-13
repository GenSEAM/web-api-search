(module asl-web-api-search/hybrid
  :d "Hybrid multi-engine SERP merger with RRF ranking and URL deduplication"
  :x [calculate-rrf-score deduplicate-serp-results merge-serp-streams rank-serp-results]
  :i [(engine :a eng)])

(df calculate-rrf-score [(rank I64) (k I64)] -> F64
  :d "Calculates Reciprocal Rank Fusion component score"
  (let [(denom (float (+ k rank)))]
    (if (> denom 0.0)
        (/ 1.0 denom)
        0.0)))

(df add-or-update-rrf-item [(acc (List eng/SearchResult)) (item eng/SearchResult) (rrf-score F64)] -> (List eng/SearchResult)
  (let [(clean-target (eng/clean-url (.-url item)))
        (existing (filter (fn [(r eng/SearchResult)] -> Bool
                            (= (eng/clean-url (.-url r)) clean-target))
                          acc))]
    (if (list-empty? existing)
        (list-cons (eng/SearchResult
                     :title (.-title item)
                     :url clean-target
                     :snippet (.-snippet item)
                     :engine (.-engine item)
                     :score rrf-score)
                   acc)
        (map (fn [(r eng/SearchResult)] -> eng/SearchResult
               (if (= (eng/clean-url (.-url r)) clean-target)
                   (eng/SearchResult
                     :title (.-title r)
                     :url (.-url r)
                     :snippet (if (> (string-length (.-snippet item)) (string-length (.-snippet r)))
                                  (.-snippet item)
                                  (.-snippet r))
                     :engine (str (.-engine r) "+" (.-engine item))
                     :score (+ (.-score r) rrf-score))
                   r))
             acc))))

(df index-stream-rrf [(items (List eng/SearchResult)) (idx I64) (acc (List eng/SearchResult))] -> (List eng/SearchResult)
  (if (list-empty? items)
      acc
      (let [(h (option-or (list-head items) (eng/SearchResult :title "" :url "" :snippet "" :engine "" :score 0.0)))
            (rest (option-or (list-tail items) (list)))
            (score (calculate-rrf-score idx 60))
            (next-acc (add-or-update-rrf-item acc h score))]
        (index-stream-rrf rest (+ idx 1) next-acc))))

(df merge-serp-streams [(results-a (List eng/SearchResult)) (results-b (List eng/SearchResult))] -> (List eng/SearchResult)
  :d "Merges two result streams using Reciprocal Rank Fusion (RRF) and URL deduplication"
  (let [(indexed-a (index-stream-rrf results-a 1 (list)))
        (indexed-both (index-stream-rrf results-b 1 indexed-a))]
    indexed-both))

(df deduplicate-serp-results [(results (List eng/SearchResult))] -> (List eng/SearchResult)
  :d "Deduplicates SERP results by canonical normalized URL"
  (fold (fn [(acc (List eng/SearchResult)) (item eng/SearchResult)] -> (List eng/SearchResult)
          (let [(target-url (eng/clean-url (.-url item)))
                (exists (any? (map (fn [(r eng/SearchResult)] -> Bool
                                     (= (eng/clean-url (.-url r)) target-url))
                                   acc)))]
            (if exists
                acc
                (list-cons (eng/SearchResult
                             :title (.-title item)
                             :url target-url
                             :snippet (.-snippet item)
                             :engine (.-engine item)
                             :score (.-score item))
                           acc))))
        (list)
        results))

(df insert-serp-result [(item eng/SearchResult) (sorted (List eng/SearchResult))] -> (List eng/SearchResult)
  (if (list-empty? sorted)
      (list item)
      (let [(head-s (option-or (list-head sorted) (eng/SearchResult :title "" :url "" :snippet "" :engine "" :score 0.0)))
            (tail-s (option-or (list-tail sorted) (list)))]
        (if (> (.-score item) (.-score head-s))
            (list-cons item sorted)
            (list-cons head-s (insert-serp-result item tail-s))))))

(df sort-serp-results-loop [(unsorted (List eng/SearchResult)) (sorted (List eng/SearchResult))] -> (List eng/SearchResult)
  (if (list-empty? unsorted)
      sorted
      (let [(item (option-or (list-head unsorted) (eng/SearchResult :title "" :url "" :snippet "" :engine "" :score 0.0)))
            (rest (option-or (list-tail unsorted) (list)))]
        (sort-serp-results-loop rest (insert-serp-result item sorted)))))

(df rank-serp-results [(results (List eng/SearchResult))] -> (List eng/SearchResult)
  :d "Orders SERP results descending by score"
  (sort-serp-results-loop results (list)))

