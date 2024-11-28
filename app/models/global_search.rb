class GlobalSearch
  include PgSearch::Model

  multisearchable against: [:searchable_text]

  pg_search_scope :search_across_models,
    against: [:searchable_text],
    using: {
      tsearch: { prefix: true, dictionary: 'french' },
      trigram: { threshold: 0.3 }
    }

  # Configuration pour la recherche multitable
  PgSearch.multisearch_options = {
    using: {
      tsearch: { prefix: true, dictionary: 'french' },
      trigram: { threshold: 0.3 }
    }
  }
end
