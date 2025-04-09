class CardsController < ApplicationController
  include CollectionScoped

  skip_before_action :set_collection, only: :index

  before_action :set_filter, only: :index
  before_action :set_card, only: %i[ show edit update destroy ]

  RECENTLY_CLOSED_LIMIT = 100

  def index
    @considering_cards = @filter.cards.considering.load_async
    @doing_cards = @filter.cards.doing.load_async
    @closed_cards = @filter.with(indexed_by: "closed").cards.recently_closed_first.limit(RECENTLY_CLOSED_LIMIT).load_async
  end

  def create
    redirect_to @collection.cards.create!
  end

  def show
  end

  def edit
  end

  def destroy
    @card.destroy!
    redirect_to cards_path(collection_ids: [ @card.collection ]), notice: deleted_notice
  end

  def update
    @card.update! card_params
    redirect_to @card
  end

  private
    DEFAULT_PARAMS = { indexed_by: "newest" }

    def set_filter
      @filter = Current.user.filters.from_params params.reverse_merge(**DEFAULT_PARAMS).permit(*Filter::PERMITTED_PARAMS)
    end

    def set_card
      @card = @collection.cards.find params[:id]
    end

    def card_params
      params.expect(card: [ :status, :title, :color, :due_on, :image, :draft_comment, tag_ids: [] ])
    end

    def deleted_notice
      "Card deleted" unless @card.creating?
    end
end
