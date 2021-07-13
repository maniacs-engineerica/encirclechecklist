//
//  ItemViewController.swift
//  EncircleChecklist
//
//  Created by Matias Cohen on 13/07/2021.
//

import UIKit

import Firebase

protocol ItemViewControllerDelegate {
    func itemDidSave(_ item: CheckListItem)
    func itemDidRemove(_ item: CheckListItem)
}

class ItemViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var item: CheckListItem?
    var delegate: ItemViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRightBarButtons()
        setupTextView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.textView.becomeFirstResponder()
        }
    }
    
    private func setupRightBarButtons() {
        var actions = [UIBarButtonItem]()
        
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveDidPress))
        actions.append(save)
        
        if item != nil {
            let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeDidPress))
            actions.append(trash)
        }
        
        navigationItem.rightBarButtonItems = actions
    }
    
    private func setupTextView(){
        if let item = item {
            textView.text = item.title
        }
    }
    
    @objc private func saveDidPress(){
        let item = item ?? createItem()
        item.title = textView.text
        do {
            try RepositoryFactory().itemRepository().context.save()
            delegate?.itemDidSave(item)
        } catch let error {
            //TODO:
            print(error)
        }
        close()
    }
    
    @objc private func removeDidPress(){
        guard let item = item else { return }
        
        do {
            let context = RepositoryFactory().itemRepository().context
            context.delete(item)
            delegate?.itemDidRemove(item)
            try context.save()
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
        
        close()
    }
    
    private func createItem() -> CheckListItem {
        let item = RepositoryFactory().itemRepository().create()
        item.id = UUID()
        item.creationDate = Date()
        return item
    }
    
    private func close(){
        navigationController?.popViewController(animated: true)
    }

}
