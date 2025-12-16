import Foundation

struct Config {
#if DEBUG
    static let baseURL = "http://localhost:8000/api/v1"
#else
    static let baseURL = "https://api.thelevittlab.com/api/v1"
#endif
}
