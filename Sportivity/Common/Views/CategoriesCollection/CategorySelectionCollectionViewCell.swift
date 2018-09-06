//
//  CategorySelectionCollectionViewCell.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 26/05/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CategorySelectionCollectionViewCell: UICollectionViewCell, Configurable {
    
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    var viewModel: CategorySelectionViewModel!
    
    fileprivate var reuseBag = DisposeBag()
    
    override var isSelected: Bool {
        didSet {
            self.imageView.alpha = isSelected ? 1 : 0.5
            self.titleLabel.alpha = isSelected ? 1 : 0.5
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
    
    func configure() {
        imageView.image = viewModel.category.iconImage
        titleLabel.text = viewModel.category.name
        isSelected = viewModel.isSelected
    }
}
