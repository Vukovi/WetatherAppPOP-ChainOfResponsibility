import Foundation

final class OpenWeatherMapNetworkController: NetworkController {
    
    // chain of responsibility - Fallback Service
    let backupController: NetworkController?
    init(backupController: NetworkController? = nil) {
        self.backupController = backupController
    }
    
    // za sad zakucano da uvek ide preko ChainOfResponsibiluty pattern
    private func simulateFailure() -> NetworkControllerError? {
        return .forwarded(NSError(domain: "OpenWeatherMapNetworkController", code: -1, userInfo: nil))
    }
    
    public let tempUnit: TemperatureUnit = .imperial
    
    func fetchCurrentWeatherData(city: String, completionHandler: @escaping (WeatherData?, NetworkControllerError?) -> Void) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let endpoint = "http://api.openweathermap.org/data/2.5/weather?q=\(city)&units=\(tempUnit)&appid=\(API.key)"
        
        let safeURLString = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let endpointURL = URL(string: safeURLString!) else {
            completionHandler(nil,NetworkControllerError.invalidURL(safeURLString!))
            return
        }
        
        let dataTask = session.dataTask(with: endpointURL) { (data, response, error) in
            
            // chain of responsibility - Fallback Service
            guard self.simulateFailure() == nil else {
                if let backup = self.backupController {
                    print("Korisitm backup servis")
                    backup.fetchCurrentWeatherData(city: city, completionHandler: completionHandler)
                } else {
                    completionHandler(nil,self.simulateFailure())
                }
                return
            }
            // dovde
            
            
            guard error == nil else {
                completionHandler(nil, NetworkControllerError.forwarded(error!))
                return
            }
            guard let jsonData = data else {
                completionHandler(nil,NetworkControllerError.invalidPayload(endpointURL))
                return
            }
            self.decode(jsonData: jsonData, endpointURL: endpointURL, completionHandler: completionHandler)
        }
        
        dataTask.resume()
        
    }
    
    
    
    private func decode(jsonData: Data, endpointURL: URL, completionHandler: @escaping (WeatherData?, NetworkControllerError?) -> Void) {
        let decoder = JSONDecoder()
        do {
            let weatherInfo = try decoder.decode(OpenMapWeatherData.self, from: jsonData)
            
            let weatherData = WeatherData(temperature: weatherInfo.main.temp, condition: (weatherInfo.weather.first?.main ?? "?"), unit: self.tempUnit)
            completionHandler(weatherData, nil)
        } catch let error {
            completionHandler(nil, NetworkControllerError.forwarded(error))
        }
    }
    
}


private enum API {
    static let key = "cebac556ad70fbc5dddbeab627443c2b"
}
