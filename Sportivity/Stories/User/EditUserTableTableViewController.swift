//
//  EditUserTableTableViewController.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 08/06/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class EditUserTableTableViewController: UITableViewController, ViewControllerProtocol, Configurable {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /// Tag of the view
    let viewTag : ViewTag = .editUser
    /// Main `DisposeBag` of the `ViewController`
    let disposeBag = DisposeBag()
    /// Observable that informs that `Router` should route to the `Route`
    let onRouteTo : Observable<Route> = PublishSubject<Route>()
    
    var viewModel: EditUserViewModel! = EditUserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        viewModel
            .photoURL
            .asObservable()
            .subscribeNext { [unowned self] (url) in
                if let url = url {
                    self.avatarImageView.kf.setImage(with: url)
                } else {
                    self.avatarImageView.image = R.image.userPlaceholder()
                }
            }
            .addDisposableTo(disposeBag)
        
        viewModel
            .name
            .asObservable()
            .bind(to: nameTextField.rx.text)
            .addDisposableTo(disposeBag)
        
        nameTextField
            .rx.text
            .asObservable()
            .map { $0 == nil ? "" : $0! }
            .bind(to: viewModel.name)
            .addDisposableTo(disposeBag)
        
        emailTextField.rx.text <-> viewModel.email
        
        passwordTextField.rx.text <-> viewModel.newPassword
        
        cancelButton
            .rx.tap
            .asObservable()
            .subscribeNext { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        saveButton
            .rx.tap
            .asObservable()
            .doOnNext { [unowned self] in
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                activityIndicator.startAnimating()
                self.navigationItem.rightBarButtonItem?.customView = activityIndicator
            }
            .flatMap({ [unowned self] () -> Observable<Void> in
                return self.viewModel.save().catchErrorJustReturn()
            })
            .subscribeNext { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
