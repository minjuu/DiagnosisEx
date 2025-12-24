//
//  DiagnosisViewModel.swift
//  DiagnosisEx
//
//  Created by LGRnD on 12/15/25.
//

import Foundation
import RxSwift
import RxCocoa

enum DiagnosisFilter: Int {
    case all = 0
    case basic = 1
    case premium = 2
}

final class HomeViewModel {

    private let diagnosisService: DiagnosisServiceProtocol

    init(service: DiagnosisServiceProtocol = MockDiagnosisService()) {
        self.diagnosisService = service
    }

    struct Input {
        let viewWillAppear: Observable<Void>
        let filterSelection: Observable<Int>
        let languageChanged: Observable<Void>
    }

    struct Output {
        let items: Driver<[Diagnosis]>
        let totalCount: Driver<String>
        let navTitle: Driver<String>
    }

    func transform(input: Input) -> Output {
        let allData: Driver<[Diagnosis]> = input.viewWillAppear
            .flatMapLatest { [weak self] _ -> Observable<[Diagnosis]> in
                guard let self else { return .just([]) }

                return self.diagnosisService.fetchDiagnoses()
                    .asObservable()
                    .catch { error in
                        print("fetchDiagnoses error:", error)
                        return .just([])
                    }
            }
            .asDriver(onErrorJustReturn: [])

        let currentFilter: Driver<DiagnosisFilter> = input.filterSelection
            .map { DiagnosisFilter(rawValue: $0) ?? .all }
            .startWith(.all)
            .asDriver(onErrorJustReturn: .all)

        let redrawTrigger: Driver<Void> = input.languageChanged
            .asDriver(onErrorDriveWith: .empty())
            .startWith(())

        let items: Driver<[Diagnosis]> = Driver.combineLatest(allData, currentFilter, redrawTrigger)
            .map { list, filter, _ in
                switch filter {
                case .all: return list
                case .basic: return list.filter { $0.type == .basic }
                case .premium: return list.filter { $0.type == .premium }
                }
            }

        let totalCount: Driver<String> = items
            .map { String(format: "total_format".localized, $0.count) }

        let navTitle: Driver<String> = Driver.combineLatest(
            LanguageManager.shared.currentLanguage.asDriver(),
            redrawTrigger
        )
        .map { _, _ in "home_title".localized }

        return Output(
            items: items,
            totalCount: totalCount,
            navTitle: navTitle
        )
    }
}

