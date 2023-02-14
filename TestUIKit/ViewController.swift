//
//  ViewController.swift
//  TestUIKit
//
//  Created by Alexey Lazukin on 14.02.2023.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray

        let dashboardView = DashboardView(
            headerHeight: 200.0,
            dataItems: ["promo", "settings", "terms", "support"],
            headerPadding: 50.0
        )

        view.addSubview(dashboardView)
        dashboardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dashboardView.topAnchor.constraint(equalTo: view.topAnchor),
            dashboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dashboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dashboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - DashboardView
private final class DashboardView: UIView {

    // MARK: - Private (Properties)
    private let dataItems: [String]
    private let headerHeight: CGFloat

    /// value means where top scroll should be stopped
    private let headerPadding: CGFloat

    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var tableViewTopAnchor: NSLayoutConstraint!
    private var tableViewTopIndent: CGFloat

    private var headerView: UILabel = {
        let view = UILabel()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "USER NAME"
        return view
    }()

    private var headerViewTopAnchor: NSLayoutConstraint!
    private var headerViewTopIndent: CGFloat

    // MARK: - Init
    init(headerHeight: CGFloat = 200.0, dataItems: [String], headerPadding: CGFloat = 40.0) {
        self.dataItems = dataItems
        self.headerHeight = headerHeight
        self.headerPadding = headerPadding
        tableViewTopIndent = headerHeight
        headerViewTopIndent = .zero

        super.init(frame: .zero)

        addSubview(headerView)
        addSubview(tableView)

        tableView.dataSource = self
        tableView.isScrollEnabled = false

        tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: topAnchor, constant: tableViewTopIndent)
        headerViewTopAnchor = headerView.topAnchor.constraint(equalTo: topAnchor, constant: headerViewTopIndent)

        let swipe = UIPanGestureRecognizer(target: self, action: #selector(swipeView))
        addGestureRecognizer(swipe)

        NSLayoutConstraint.activate(
            [
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
                tableViewTopAnchor,
                headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                headerView.heightAnchor.constraint(equalToConstant: headerHeight),
                headerViewTopAnchor
            ]
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private (Interface)
    @objc
    private func swipeView(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self)
            let tableViewIndent = tableViewTopIndent + translation.y

            if tableViewIndent <= headerPadding {
                tableViewTopAnchor.constant = headerPadding
                tableView.contentOffset.y = -tableViewIndent + headerPadding
            } else {
                tableViewTopAnchor.constant = tableViewIndent
            }

            let headerViewIndent = headerViewTopIndent + translation.y
            headerViewTopAnchor.constant = headerViewIndent <= -headerHeight ? -headerHeight : headerViewIndent
        case .ended:
            if tableViewTopAnchor.constant >= headerHeight {
                UIView.animate(withDuration: 0.75, delay: .zero, options: .curveEaseOut) { [weak self] in
                    self?.tableViewTopAnchor.constant = self?.headerHeight ?? .zero
                    self?.headerViewTopAnchor.constant = .zero
                    self?.layoutIfNeeded()
                }
            }

            UIView.animate(withDuration: 0.75, delay: .zero, options: .curveEaseOut) { [weak self] in
                self?.tableView.contentOffset.y = .zero
            }

            tableViewTopIndent = tableViewTopAnchor.constant
            headerViewTopIndent = headerViewTopAnchor.constant
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource
extension DashboardView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = dataItems[indexPath.row]
        return cell
    }
}
