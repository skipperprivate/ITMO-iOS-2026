//
//  WeatherUIState.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//

public enum WeatherUIState : Equatable, Hashable{
    case Loading
    case Success(ForecastUI)
    case Fail(WeatherErrorUI)
    
    // Вложенный enum только для случаев
        enum Kind {
            case loading
            case success
            case fail
        }
        
        // Вычисляемое свойство для получения «вида» состояния
        var kind: Kind {
            switch self {
            case .Loading: return .loading
            case .Success: return .success
            case .Fail: return .fail
            }
        }
}
