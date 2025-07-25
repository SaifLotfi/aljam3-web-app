# frozen_string_literal: true

class Components::SearchResultsList < Components::Base
  def initialize(results:, pagy:, search_query_id:)
    @results = results
    @pagy = pagy
    @search_query_id = search_query_id
  end

  def view_template
    turbo_frame_tag :results_list, current_page do
      div(
        class: [
          "mt-2 space-y-4",
          ("mt-4" if current_page > 1)
        ]
      ) do
        @results.each_with_index do |result, index|
          case result
          when Book
            SearchBookCard(book: result, index: index + (current_page - 1) * 20, search_query_id: @search_query_id)
          when Page
            SearchPageCard(page: result, index: index + (current_page - 1) * 20, search_query_id: @search_query_id)
          end

          if (index + 1) == (results_count - 5) && next_page
            turbo_frame_tag :next_page, src: root_path(
              q: params[:q],
              s: params.dig(:s),
              l: params.dig(:l),
              c: params.dig(:c),
              a: params.dig(:a),
              page: next_page,
              qid: @search_query_id
            ), loading: :lazy
          end
        end

        turbo_frame_tag :results_list, next_page if next_page
      end
    end
  end

  private

  def current_page = @pagy&.page || (params[:page] || 1).to_i

  def next_page
    return @pagy.next if @pagy

    @results.metadata["estimatedTotalHits"] > current_page * Pagy::DEFAULT[:limit] ? current_page + 1 : nil
  end

  def results_count = @results.respond_to?(:hits) ? @results.hits.size : @results.size
end
