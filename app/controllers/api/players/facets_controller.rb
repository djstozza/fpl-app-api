module Api::Players
  class FacetsController < Api::PlayersController
    # GET /api/players/facets
    def index
      respond_with SqlQuery.load('players/facets').result
    end
  end
end
