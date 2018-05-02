//
//  NetworkController.swift
//  WeatherApp
//
//  Created by Vuk Knežević on 5/2/18.
//  Copyright © 2018 Knežević, Vuk. All rights reserved.
//

import Foundation

public protocol NetworkController {
    
    // ovo je za chain of responsibility - Fallback Service
    var backupController: NetworkController? { get }
    init(backupController: NetworkController?)
    
    func fetchCurrentWeatherData(city: String, completionHandler: @escaping (WeatherData?, NetworkControllerError?) -> Void)
}

extension NetworkController {
    var backupController: NetworkController? {
        return nil
    }
}

public struct WeatherData {
    var temperature: Float
    var condition: String
    var unit: TemperatureUnit
}

public enum TemperatureUnit: String {
    case scientific = "K"
    case metric = "C"
    case imperial = "F"
}

public enum NetworkControllerError: Error {
    case invalidURL(String)
    case invalidPayload(URL)
    case forwarded(Error)
}
