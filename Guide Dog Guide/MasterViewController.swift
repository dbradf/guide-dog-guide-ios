//
//  MasterViewController.swift
//  Guide Dog Guide
//
//  Created by David Bradford on 1/14/17.
//  Copyright © 2017 David Bradford. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    private var articleCache: ArticleCache? = nil
    let uiRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleCache = ArticleCache(self.finishRefresh)
        self.tableView.refreshControl = self.uiRefreshControl
        self.uiRefreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let startIndex = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: startIndex, animated: true, scrollPosition: UITableViewScrollPosition.none)
            
            self.performSegue(withIdentifier: "showDetail", sender: startIndex)
        }
    }
    
    func finishRefresh() {
        self.tableView.reloadData()
        self.uiRefreshControl.endRefreshing()
    }
    
    func refreshData() {
        self.articleCache?.refresh(force: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = "Loading..."
                controller.navigationItem.title = "Loading..."
                if let cache = self.articleCache {
                    let row = indexPath.row
                    if (row < cache.documents.count) {
                        controller.detailItem = cache.documents[row]
                        controller.navigationItem.title = cache.topics[row]
                    }
                }
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cache = articleCache {
            return cache.topics.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        var object = ""
        if let cache = articleCache {
            object = cache.topics[indexPath.row]
        }
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
}

