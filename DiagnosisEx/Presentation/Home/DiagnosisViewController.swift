//
//  DiagnosisViewController.swift
//  DiagnosisEx
//
//  Created by LGRnD on 12/15/25.
//
import UIKit
import RxSwift
import RxCocoa

final class DiagnosisViewController: UIViewController {

    private let headerContainerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    private let filterSegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: [
            "filter_all".localized,
            "filter_basic".localized,
            "filter_premium".localized
        ])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .secondarySystemBackground
        sc.selectedSegmentTintColor = .tertiarySystemBackground
        sc.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .normal)
        return sc
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        return tv
    }()

    private let languageFab: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 26
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 8
        btn.setImage(UIImage(systemName: "globe"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()

    private let languageChangedRelay = PublishRelay<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        applyLocalizedUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        headerContainerView.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground

        view.addSubview(headerContainerView)
        headerContainerView.addSubview(filterSegment)
        headerContainerView.addSubview(countLabel)
        view.addSubview(tableView)
        view.addSubview(languageFab)

        [headerContainerView, filterSegment, countLabel, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        tableView.register(DiagnosisCell.self, forCellReuseIdentifier: DiagnosisCell.id)

        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            filterSegment.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 10),
            filterSegment.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 20),
            filterSegment.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -20),
            filterSegment.heightAnchor.constraint(equalToConstant: 36),

            countLabel.topAnchor.constraint(equalTo: filterSegment.bottomAnchor, constant: 20),
            countLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 24),
            countLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            languageFab.widthAnchor.constraint(equalToConstant: 52),
            languageFab.heightAnchor.constraint(equalToConstant: 52),
            languageFab.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            languageFab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        view.bringSubviewToFront(languageFab)
    }

    private func applyLocalizedUI() {
        filterSegment.setTitle("filter_all".localized, forSegmentAt: 0)
        filterSegment.setTitle("filter_basic".localized, forSegmentAt: 1)
        filterSegment.setTitle("filter_premium".localized, forSegmentAt: 2)
        languageFab.accessibilityLabel = "change_language".localized
    }

    private func bind() {
        let viewWillAppearObservable = rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }

        let input = HomeViewModel.Input(
            viewWillAppear: viewWillAppearObservable,
            filterSelection: filterSegment.rx.selectedSegmentIndex.asObservable(),
            languageChanged: languageChangedRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.items
            .drive(tableView.rx.items(
                cellIdentifier: DiagnosisCell.id,
                cellType: DiagnosisCell.self
            )) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)

        output.totalCount
            .drive(countLabel.rx.text)
            .disposed(by: disposeBag)

        output.navTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)

        languageFab.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                LanguageManager.shared.switchLanguage()
                self.applyLocalizedUI()
                self.languageChangedRelay.accept(())
            }
            .disposed(by: disposeBag)
    }
}
