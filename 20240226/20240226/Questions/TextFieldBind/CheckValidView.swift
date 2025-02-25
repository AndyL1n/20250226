//
//  CheckValidView.swift
//  20240226
//
//  Created by Andy on 2025/2/25.
//

import UIKit
import RxSwift
import RxCocoa

class CheckValidView: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = CheckValidViewModel()
    
    private let emailTextField: UITextField = UITextField()
    
    private let passwordTextField: UITextField = UITextField()
    
    private let submitButton: UIButton = UIButton()
    
    private let errorMessage: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.binding()
    }
    
    private func binding() {
        
        emailTextField.rx.text.orEmpty.changed
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.emailTextField.text = text
                self.viewModel.input.emailText.onNext(text)
            })
            .disposed(by: disposeBag)
        
        
        passwordTextField.rx.text.orEmpty.changed
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.passwordTextField.text = text
                self.viewModel.input.passwordText.onNext(text)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.isSubmitValid
            .subscribe(onNext: { [weak self] isValid in
                guard let self = self else { return }
                self.submitButton.isEnabled = isValid
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorMessage
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.errorMessage.isHidden = message == nil || message == ""
                
                self.errorMessage.text = message
            })
            .disposed(by: disposeBag)
    }
    
}
