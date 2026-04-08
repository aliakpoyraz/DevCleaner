import SwiftUI
import Combine

// MARK: - Language Enum
enum AppLanguage: String, CaseIterable, Identifiable {
    case turkish = "tr"
    case english = "en"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }
    
    var locale: Locale {
        Locale(identifier: self.rawValue)
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    
    static let shared = LocalizationManager()
    
    @AppStorage(Constants.UserDefaultsKeys.appLanguage) var selectedLanguage: AppLanguage = .english {
        didSet {
            objectWillChange.send()
        }
    }
    
    private init() {
        // İlk açılışta sistem dilini algıla
        if UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.appLanguage) == nil {
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            if systemLang == "tr" {
                selectedLanguage = .turkish
            } else {
                selectedLanguage = .english
            }
        }
    }
    
    var locale: Locale {
        selectedLanguage.locale
    }
}
