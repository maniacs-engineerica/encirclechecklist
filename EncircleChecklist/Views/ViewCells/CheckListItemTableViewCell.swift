//
//  CheckListItemTableViewCell.swift
//  EncircleChecklist
//
//  Created by Matias Cohen on 06/07/2021.
//

import UIKit

class CheckListItemTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var dateView: UILabel!
    
    
    func load(item: CheckListItem){
        titleView.text = item.title
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if let date = item.creationDate {
            dateView.text = formatter.string(from: date)
        } else {
            dateView.text = nil
        }
        
        accessoryType = item.checked ? .checkmark : .none
        
    }
}
