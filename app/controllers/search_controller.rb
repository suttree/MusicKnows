class SearchController < ApplicationController
  layout "main"

  def search
  end

  def results
    @page_title = "Search results for... '" + params[:q] + "'"

    @memories = Memory.find_by_sql(
      ['SELECT memories.*
      FROM memories
      WHERE title LIKE ?
      OR body LIKE ?
      LIMIT 10', '%' + params[:q] + '%', '%' + params[:q] + '%']
    )

    @tags = Tag.find_by_sql(
      ['SELECT tags.*
      FROM tags
      WHERE name LIKE ?
      LIMIT 10', '%' + params[:q] + '%']
    )
  end
end
