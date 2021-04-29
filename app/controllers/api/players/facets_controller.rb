module Api::Players
  class FacetsController < Api::PlayersController
    # GET /api/players/facets
    def index
      respond_with SqlQuery.run(
        'players/facets'
      )[0]
    end
  end
end
