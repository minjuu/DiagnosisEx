//
//  DiagnosisService.swift
//  DiagnosisEx
//
//  Created by LGRnD on 12/15/25.
//

import Foundation
import RxSwift

enum NetworkError: Error {
    case decodingError
    case serverError
}

protocol DiagnosisServiceProtocol {
    func fetchDiagnoses() -> Single<[Diagnosis]>
}

final class MockDiagnosisService: DiagnosisServiceProtocol {
    
    func fetchDiagnoses() -> Single<[Diagnosis]> {
        return Single<[Diagnosis]>.create { single in
            let delay = DispatchTime.now() + 1.0
            DispatchQueue.global().asyncAfter(deadline: delay) {
                
                let isSuccess = Int.random(in: 0...10) > 2
                if !isSuccess {
                    single(.failure(NetworkError.serverError))
                    return
                }
                
                guard let url = Bundle.main.url(forResource: "mock_diagnosis", withExtension: "json"),
                      let data = try? Data(contentsOf: url) else {
                    single(.failure(NetworkError.decodingError))
                    return
                }
                
                do {
                    let list = try JSONDecoder().decode([Diagnosis].self, from: data)
                    single(.success(list))
                } catch {
                    single(.failure(NetworkError.decodingError))
                }
            }
            
            return Disposables.create()
        }
    }
}
