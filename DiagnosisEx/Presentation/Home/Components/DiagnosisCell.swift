//
//  DiagnosisCell.swift
//  DiagnosisEx
//
//  Created by LGRnD on 12/15/25.
//

import UIKit
import RxSwift

final class DiagnosisCell: UITableViewCell {
    static let id = "DiagnosisCell"
    
    var disposeBag = DisposeBag()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let vehicleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let licenseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusIcon: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        [vehicleLabel, licenseLabel, statusIcon, statusLabel].forEach {
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110), // 최소 높이
            
            vehicleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            vehicleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            licenseLabel.topAnchor.constraint(equalTo: vehicleLabel.bottomAnchor, constant: 4),
            licenseLabel.leadingAnchor.constraint(equalTo: vehicleLabel.leadingAnchor),
            
            statusIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            statusIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10),
            statusIcon.widthAnchor.constraint(equalToConstant: 32),
            statusIcon.heightAnchor.constraint(equalToConstant: 32),
            
            statusLabel.topAnchor.constraint(equalTo: statusIcon.bottomAnchor, constant: 6),
            statusLabel.centerXAnchor.constraint(equalTo: statusIcon.centerXAnchor)
        ])
    }
    
    func configure(with item: Diagnosis) {
        vehicleLabel.text = item.vehicleName
        licenseLabel.text = item.licensePlate
        containerView.backgroundColor = item.status.color
        statusLabel.text = item.status.title
        
        statusIcon.image = UIImage(systemName: getIconName(for: item.status))
    }
    
    private func getIconName(for status: DiagnosisStatus) -> String {
        switch status {
        case .preparing: return "clock.fill"
        case .analyzing: return "waveform.path.ecg"
        case .actionNeeded: return "exclamationmark.triangle.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
}
