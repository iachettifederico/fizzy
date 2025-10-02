class Collections::Columns::NotNowsController < ApplicationController
  include CollectionScoped, FilterScoped

  def show
    set_page_and_extract_portion_from @collection.cards.postponed.reverse_chronologically.with_golden_first
    fresh_when etag: [ @collection, @page.records ]
  end
end
