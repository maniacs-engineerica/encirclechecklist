//
//  ViewController.swift
//  EncircleChecklist
//
//  Created by Matias Cohen on 06/07/2021.
//

import UIKit

import Firebase

class CheckListViewController: UIViewController, ItemViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noItemsMessageView: UILabel! {
        didSet{
            noItemsMessageView.text = "(+)\nAdd new items!"
        }
    }
    
    var items = [CheckListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CheckList App"
        
        setupRightBarButton()
        setupTableView()
        
        loadItems()
        updateMessageVisibility()
    }
    
    private func setupRightBarButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDidPress))
    }
    
    private func setupTableView(){
        let nib = UINib(nibName: "CheckListItemTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CheckListItem")
    }
    
    private func loadItems(){
        do {
            items = try RepositoryFactory().itemRepository().get()
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }
    
    @objc private func addDidPress(){
        edit()
    }
    
    private func edit(item: CheckListItem? = nil){
        let controller = ItemViewController(nibName: "ItemViewController", bundle: nil)
        controller.item = item
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func itemDidSave(_ item: CheckListItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)
        } else {
            items.append(item)
            tableView.reloadData()
        }
        updateMessageVisibility()
    }
    
    func itemDidRemove(_ item: CheckListItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateMessageVisibility()
        }
    }
    
    private func updateMessageVisibility(){
        noItemsMessageView.isHidden = !items.isEmpty
        tableView.isHidden = items.isEmpty
    }
}

extension CheckListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListItem", for: indexPath) as! CheckListItemTableViewCell
        
        let item = items[indexPath.row]
        
        cell.load(item: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        showOptions(for: item)
    }
    
    private func showOptions(for item: CheckListItem){
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let check = UIAlertAction(title: item.checked ? "Uncheck" : "Check", style: .default) { _ in
            self.checkOrUncheck(item: item)
        }
        controller.addAction(check)
        
        let edit = UIAlertAction(title: "Edit", style: .default) { _ in
            self.edit(item: item)
        }
        controller.addAction(edit)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(cancel)
        
        present(controller, animated: true, completion: nil)
    }
    
    private func checkOrUncheck(item: CheckListItem){
        item.checked = !item.checked
        do {
            try RepositoryFactory().itemRepository().context.save()
            itemDidSave(item)
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }
    
}

