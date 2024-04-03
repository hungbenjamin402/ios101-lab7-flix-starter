//
//  Movie.swift
//  ios101-lab6-flix
//

import Foundation

struct MovieFeed: Decodable {
    let results: [Movie]
}

struct Movie: Codable, Equatable {
    let title: String
    let overview: String
    let posterPath: String? // Path used to create a URL to fetch the poster image

    // MARK: Additional properties for detail view
    let backdropPath: String? // Path used to create a URL to fetch the backdrop image
    let voteAverage: Double?
    let releaseDate: Date?

    // MARK: ID property to use when saving movie
    let id: Int

    // MARK: Custom coding keys
    // Allows us to map the property keys returned from the API that use underscores (i.e. `poster_path`)
    // to a more "swifty" lowerCamelCase naming (i.e. `posterPath` and `backdropPath`)
    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case id
    }
}

extension Movie {
    // The "Favorites" key: a computed property that returns a String.
    //    - Use when saving/retrieving or removing from UserDefaults
    //    - `static` means this property is "Type Property" (i.e. associated with the Movie "type", not any particular movie instance)
    //    - We can access this property anywhere like this... `Movie.favoritesKey` (i.e. Type.property)
    static var favoritesKey: String {
        return "Favorites"
    }

    // Save an array of favorite movies to UserDefaults.
    //    - Similar to the favoritesKey, we add the `static` keyword to make this a "Type Method".
    //    - We can call it from anywhere by calling it on the `Movie` type.
    //    - ex: `Movie.save(favoriteMovies, forKey: favoritesKey)`
    // 1. Create an instance of UserDefaults
    // 2. Try to encode the array of `Movie` objects to `Data`
    // 3. Save the encoded movie `Data` to UserDefaults
    static func save(_ movies: [Movie], forKey key: String) {
        // 1.
        let defaults = UserDefaults.standard
        // 2.
        let encodedData = try! JSONEncoder().encode(movies)
        // 3.
        defaults.set(encodedData, forKey: key)
    }

    // Get the array of favorite movies from UserDefaults
    //    - Again, a static "Type method" we can call anywhere like this...`Movie.getMovies(forKey: favoritesKey)`
    // 1. Create an instance of UserDefaults
    // 2. Get any favorite movies `Data` saved to UserDefaults (if any exist)
    // 3. Try to decode the movie `Data` to `Movie` objects
    // 4. If 2-3 are successful, return the array of movies
    // 5. Otherwise, return an empty array
    static func getMovies(forKey key: String) -> [Movie] {
        // 1.
        let defaults = UserDefaults.standard
        // 2.
        if let data = defaults.data(forKey: key) {
            // 3.
            let decodedMovies = try! JSONDecoder().decode([Movie].self, from: data)
            // 4.
            return decodedMovies
        } else {
            // 5.
            return []
        }
    }
    
    func addToFavorites() {
        var favoriteMovies = Movie.getMovies(forKey: Movie.favoritesKey)
        favoriteMovies.append(self)
        Movie.save(favoriteMovies, forKey: Movie.favoritesKey)
    }

    func removeFromFavorites() {
        var favoriteMovies = Movie.getMovies(forKey: Movie.favoritesKey)
        favoriteMovies.removeAll { $0 == self }
        Movie.save(favoriteMovies, forKey: Movie.favoritesKey)
    }
}
