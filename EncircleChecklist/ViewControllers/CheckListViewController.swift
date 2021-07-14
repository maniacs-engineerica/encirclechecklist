//
//  ViewController.swift
//  EncircleChecklist
//
//  Created by Matias Cohen on 06/07/2021.
//

import UIKit

import FirebaseCrashlytics

class CheckListViewController: UIViewController, ItemViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noItemsMessageView: UILabel! {
        didSet{
            noItemsMessageView.text = "(+)\nAdd new items!"
        }
    }
    
    private lazy var repository = RepositoryFactory().itemRepository()
    
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
        let systemItem: UIBarButtonItem.SystemItem = !tableView.isEditing ? .edit : .cancel
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(editModeDidPress))
    }
    
    private func setupTableView(){
        let nib = UINib(nibName: "CheckListItemTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CheckListItem")
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    private func loadItems(){
        do {
            items = try repository.get()
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }
    
    
    @objc private func editModeDidPress() {
        tableView.isEditing = !tableView.isEditing
        setupRightBarButton()
    }
    
    @IBAction func addDidPress(_ sender: Any) {
        tableView.isEditing = false
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
        
        if (tableView.isEditing){
            edit(item: item)
        } else {
            checkOrUncheck(item: item)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }
        
        let item = items[indexPath.row]
        if (repository.delete(object: item)){
            itemDidRemove(item)
        }
    }
    
    private func checkOrUncheck(item: CheckListItem){
        item.checked = !item.checked
        if (repository.save()){
            itemDidSave(item)
        }
    }
    
}

