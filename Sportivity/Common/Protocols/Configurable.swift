//
//  ConfigurableViewControllerProtocol.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import Foundation

protocol Configurable : class {
    associatedtype V
    var viewModel: V! { get set }
    func configure(with viewModel: V)
    func configure()
}

extension Configurable {
    
    final func configure(with viewModel: V) {
        self.viewModel = viewModel
        self.configure()
    }
    
    func configure() { }
}
