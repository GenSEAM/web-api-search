(module aslWebApiSearch/hybrid
  :d "Hybrid multi-engine SERP merger with RRF ranking and URL deduplication"
  :x [calculateRrfScore deduplicateSerpResults mergeSerpStreams rankSerpResults]
  :i [(engine :a eng)])

(df calculateRrfScore [(rank I64) (k I64)] -> F64
  :d "Calculates Reciprocal Rank Fusion component score"
  (let [(denom (float (+ k rank)))]
    (if (> denom 0.0)
        (/ 1.0 denom)
        0.0)))

(df addOrUpdateRrfItem [(acc (List eng/SearchResult)) (item eng/SearchResult) (rrfScore F64)] -> (List eng/SearchResult)
  (let [(cleanTarget (eng/cleanUrl (.-url item)))
        (existing (filter (fn [(r eng/SearchResult)] -> Bool
                            (= (eng/cleanUrl (.-url r)) cleanTarget))
                          acc))]
    (if (list-empty? existing)
        (list-cons (eng/SearchResult
                     :title (.-title item)
                     :url cleanTarget
                     :snippet (.-snippet item)
                     :engine (.-engine item)
                     :score rrfScore)
                   acc)
        (map (fn [(r eng/SearchResult)] -> eng/SearchResult
               (if (= (eng/cleanUrl (.-url r)) cleanTarget)
                   (eng/SearchResult
                     :title (.-title r)
                     :url (.-url r)
                     :snippet (if (> (string-length (.-snippet item)) (string-length (.-snippet r)))
                                  (.-snippet item)
                                  (.-snippet r))
                     :engine (str (.-engine r) "+" (.-engine item))
                     :score (+ (.-score r) rrfScore))
                   r))
             acc))))

(df indexStreamRrf [(items (List eng/SearchResult)) (idx I64) (acc (List eng/SearchResult))] -> (List eng/SearchResult)
  (if (list-empty? items)
      acc
      (let [(h (option-or (list-head items) (eng/SearchResult :title "" :url "" :snippet "" :engine "" :score 0.0)))
            (rest (option-or (list-tail items) (list)))
            (score (calculateRrfScore idx 60))
            (nextAcc (addOrUpdateRrfItem acc h score))]
        (indexStreamRrf rest (+ idx 1) nextAcc))))

(df mergeSerpStreams [(resultsA (List eng/SearchResult)) (resultsB (List eng/SearchResult))] -> (List eng/SearchResult)
  :d "Merges two result streams using Reciprocal Rank Fusion (RRF) and URL deduplication"
  (let [(indexedA (indexStreamRrf resultsA 1 (list)))
        (indexedBoth (indexStreamRrf resultsB 1 indexedA))]
    indexedBoth))

(df deduplicateSerpResults [(results (List eng/SearchResult))] -> (List eng/SearchResult)
  :d "Deduplicates SERP results by canonical normalized URL"
  (fold (fn [(acc (List eng/SearchResult)) (item eng/SearchResult)] -> (List eng/SearchResult)
          (let [(targetUrl (eng/cleanUrl (.-url item)))
                (exists (any? (map (fn [(r eng/SearchResult)] -> Bool
                                     (= (eng/cleanUrl (.-url r)) targetUrl))
                                   acc)))]
            (if exists
                acc
                (list-cons (eng/SearchResult
                             :title (.-title item)
                             :url targetUrl
                             :snippet (.-snippet item)
                             :engine (.-engine item)
                             :score (.-score item))
                           acc))))
        (list)
        results))

(df insertSerpResult [(item eng/SearchResult) (sorted (List eng/SearchResult))] -> (List eng/SearchResult)
  (if (list-empty? sorted)
      (list item)
      (let [(headS (option-or (list-head sorted) (eng/SearchResult :title "" :url "" :snippet "" :engine "" :score 0.0)))
            (tailS (option-or (list-tail sorted) (list)))]
        (if (> (.-score item) (.-score headS))
            (list-cons item sorted)
            (list-cons headS (insertSerpResult item tailS))))))

(df sortSerpResultsLoop [(unsorted (List eng/SearchResult)) (sorted (List eng/SearchResult))] -> (List eng/SearchResult)
  (if (list-empty? unsorted)
      sorted
      (let [(item (option-or (list-head unsorted) (eng/SearchResult :title "" :url "" :snippet "" :engine "" :score 0.0)))
            (rest (option-or (list-tail unsorted) (list)))]
        (sortSerpResultsLoop rest (insertSerpResult item sorted)))))

(df rankSerpResults [(results (List eng/SearchResult))] -> (List eng/SearchResult)
  :d "Orders SERP results descending by score"
  (sortSerpResultsLoop results (list)))

