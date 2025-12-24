//
//  LanguageManager.swift
//  DiagnosisEx
//
//  Created by LGRnD on 12/12/25.
//

import Foundation
import RxSwift
import RxCocoa

enum Language: String {
    case english = "en"
    case korean = "ko"
}

class LanguageManager {
    static let shared = LanguageManager()
    
    let currentLanguage = BehaviorRelay<Language>(value: .english)
    
    private init() {}
    
    func switchLanguage() {
        let next = currentLanguage.value == .english ? Language.korean : .english
        currentLanguage.accept(next)
    }
}

extension String {
    var localized: String {
        let lang = LanguageManager.shared.currentLanguage.value
        
        guard let path = Bundle.main.path(forResource: lang == .english ? "en" : "ko", ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return self
        }
        return NSLocalizedString(self, tableName: "Localizable", bundle: bundle, value: self, comment: "")
    }
}
