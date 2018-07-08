//
//  RulesViewController.swift
//  getFilter
//
//  Created by Farzad Nazifi on 6/22/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit

protocol RulesViewControllerDelegate {
    func updateHeight(const: CGFloat)
}

class RulesViewController: UIViewController, UISearchResultsUpdating  {
    required init?(coder aDecoder: NSCoder) { fatalError("...") }

    let gf = try! GetFilter(readOnly: false)
    let searchController = UISearchController(searchResultsController: nil)
    
    var delegate: RulesViewControllerDelegate
    
    @IBOutlet var toggle: UISwitch!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var noruleLabel: UILabel!
    
    init(delegate: RulesViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        tableView.backgroundView = backgroundView
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.tintColor = .white
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.subviews[0].backgroundColor = #colorLiteral(red: 0.1334325373, green: 0.1330040991, blue: 0.1455509365, alpha: 1)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "RuleTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .dataReload, object: nil)
    }

    @objc func reload() {
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    @IBAction func newRuleTapped(_ sender: UIButton) {
        let newRuleVC = NewRuleViewController()
        present(newRuleVC, animated: true, completion: nil)
    }
}

extension RulesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = gf.storage.rules.count
        noruleLabel.isHidden = count == 0 ? false : true
        delegate.updateHeight(const: count == 0 ? UIScreen.main.bounds.height - 260 : (54.0 * CGFloat(count)) + 108)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RuleTableViewCell
        cell.setData(rule: gf.storage.rules[indexPath.row])
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = #colorLiteral(red: 0.1137871966, green: 0.1135108247, blue: 0.1218691245, alpha: 1)
        }else{
            cell.backgroundColor = #colorLiteral(red: 0.1334325373, green: 0.1330040991, blue: 0.1455509365, alpha: 1)
        }
        return cell
    }
}
