//
//  ViewController.swift
//  ClouserNoom
//
//  Created by Brian Clouser on 9/26/18.
//  Copyright © 2018 Brian Clouser. All rights reserved.
//

import UIKit
import SafariServices

class RecipeSearchViewController: UITableViewController {
    
    var recipes : [Recipe] = []
    var currentPage = 1
    var timer = Timer()
    var requestInProgress = false
    let searchController = UISearchController(searchResultsController: nil)
    
    var canLoadMoreResults : Bool = false {
        didSet {
            if canLoadMoreResults {
                let spinner = UIActivityIndicatorView(style: .gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
                tableView.tableFooterView = spinner
            } else {
                tableView.tableFooterView = nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        definesPresentationContext = true
    }
    
    private func configureTableView() {
        tableView.register(RecipeCell.classForCoder(), forCellReuseIdentifier: RecipeCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    @objc func autoCompleteRecipes() {
        requestInProgress = true
        PuppyAPIUtility.shared.getRecipes(searchItem: searchController.searchBar.text!, ingredients: [], page: currentPage, maxAttempts: 3, success: { (response) in
            self.handleResponse(response)
            self.requestInProgress = false
            self.tableView.reloadData()
        }) { (error) in
            if self.currentPage == 1 {
               let alertVC = UIAlertController(title: "Could not load recipes", message: "Check your connection and try again", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertVC, animated: false, completion: nil)
            }
            self.canLoadMoreResults = false
        }
    }
    
    func handleResponse(_ response: [String : Any]) {
        
        var newResults : [Recipe] = []
        if let results = response["results"] as? [[String : String]] {
            canLoadMoreResults = results.count == 10
            for result in results {
                let recipe = Recipe(response: result)
                newResults.append(recipe)
            }
        }
        recipes = currentPage == 1 ? newResults : recipes + newResults
    }
    
    //TableView delegate/datasource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipeCell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.identifier) as! RecipeCell
        recipeCell.configureCellWithRecipe(recipes[indexPath.row])
        return recipeCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string:recipes[indexPath.row].url) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (recipes.count > 0) {
            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        } else {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
            let label = UILabel()
            footerView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
            label.textColor = UIColor.gray
            
            if let userInput = searchController.searchBar.text {
                label.text = userInput.count == 0 ? "Search for recipes" : "No results"
                return footerView
            } else {
                label.text = "Search for recipes"
                return footerView
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return recipes.count > 0 ? 1 : 100
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == recipes.count - 1 && canLoadMoreResults && !requestInProgress {
            currentPage += 1
            autoCompleteRecipes()
        }
    }
    
}

extension RecipeSearchViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        currentPage = 1
        timer.invalidate()
        if searchController.searchBar.text == "" {
            PuppyAPIUtility.shared.cancelCurrentRequest()
            recipes.removeAll()
            canLoadMoreResults = false
            tableView.reloadData()
        } else {
            currentPage = 1
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(autoCompleteRecipes), userInfo: nil, repeats: false)
        }
    }
}

struct Recipe {
    
    let url : String
    let ingredients : String
    let thumbnailURL : String
    let title : String
    
    init(response: [String : String]) {
        self.url = response["href"] ?? ""
        self.ingredients = response["ingredients"] ?? ""
        self.thumbnailURL = response["thumbnail"] ?? ""
        self.title = response["title"] ?? ""
    }
}

