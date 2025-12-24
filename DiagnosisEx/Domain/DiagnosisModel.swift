//
//  DiagnosisModel.swift
//  DiagnosisEx
//
//  Created by LGRnD on 12/15/25.
//

import UIKit

enum DiagnosisStatus: String, Codable {
    case preparing = "PREPARING"       // 진단 준비중
    case analyzing = "ANALYZING"       // 배터리 분석중
    case actionNeeded = "ACTION_NEEDED" // 추가정보 필요
    case completed = "COMPLETED"       // 진단 완료
    
    var color: UIColor {
        switch self {
        case .preparing: return .systemGray
        case .analyzing: return .systemBlue
        case .actionNeeded: return .systemOrange
        case .completed: return UIColor(red: 0.0, green: 0.17, blue: 0.35, alpha: 1.0)
        }
    }
    
    var title: String {
        switch self {
        case .preparing: return "진단 준비중"
        case .analyzing: return "분석중"
        case .actionNeeded: return "추가 정보"
        case .completed: return "진단 완료"
        }
    }
}

enum DiagnosisType: String, Codable {
    case basic = "Basic"
    case premium = "Premium"
}

struct Diagnosis: Codable {
    let id: String
    let vehicleName: String
    let licensePlate: String
    let date: String
    let status: DiagnosisStatus
    let type: DiagnosisType
}
