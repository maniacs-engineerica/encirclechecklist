//
//  ItemViewController.swift
//  EncircleChecklist
//
//  Created by Matias Cohen on 13/07/2021.
//

import UIKit

protocol ItemViewControllerDelegate {
    func itemDidSave(_ item: CheckListItem)
}

class ItemViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    private lazy var repository = RepositoryFactory().itemRepository()
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    private func setupRightBarButtons() {
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveDidPress))
        navigationItem.rightBarButtonItem = save
    }
    
    private func setupTextView(){
        if let item = item {
            textView.text = item.title
        }
    }
    
    @objc private func saveDidPress(){
        let item = item ?? createItem()
        item.title = textView.text
        if (repository.save()){
            delegate?.itemDidSave(item)
        }
        close()
    }
    
    private func createItem() -> CheckListItem {
        let item = repository.create()
        item.id = UUID()
        item.creationDate = Date()
        return item
    }
    
    private func close(){
        navigationController?.popViewController(animated: true)
    }

}
