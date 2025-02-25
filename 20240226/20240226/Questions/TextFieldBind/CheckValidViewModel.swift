//
//  CheckValidViewModel.swift
//  20240226
//
//  Created by Andy on 2025/2/25.
//

import Foundation
import RxSwift
import RxRelay

class CheckValidViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let emailText: AnyObserver<String>
        let passwordText: AnyObserver<String>
    }
    
    struct Output {
        /// 是否可以提交
        let isSubmitValid: BehaviorRelay<Bool>
        /// 錯誤訊息
        let errorMessage: BehaviorRelay<String?>
    }
    
    
    let input: Input
    let output: Output
    
    
    private let emailTextSub = PublishSubject<String>()
    private let passwordTextSub = PublishSubject<String>()
    
    
    /// 是否可以提交
    private let isSubmitValid = BehaviorRelay<Bool>(value: false)
    private let errorMessage = BehaviorRelay<String?>(value: nil)
    
    
    private let emailText = BehaviorRelay<String>(value: "")
    private let passwordText = BehaviorRelay<String>(value: "")
    
    init() {
        
        self.input = Input(
            emailText: emailTextSub.asObserver(),
            passwordText: passwordTextSub.asObserver()
        )
        
        self.output = Output(
            isSubmitValid: isSubmitValid,
            errorMessage: errorMessage
        )
        
        self.binding()
    }
    
    private func binding() {
        
        emailTextSub
            .bind(to: emailText)
            .disposed(by: disposeBag)
        
        passwordTextSub
            .bind(to: passwordText)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                emailText,
                passwordText)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] email, password in
                guard let self = self else { return }
                
                var errorMessage: String?
                
                if !email.checkEmailIsValid() {
                    errorMessage = NSLocalizedString("invalid email format", comment: "")
                } else if !password.checkPasswordIsValid() {
                    errorMessage = NSLocalizedString("invalid password format", comment: "")
                }
                
                let isSubmitValid = email.checkEmailIsValid() && password.checkPasswordIsValid()
                self.errorMessage.accept(errorMessage)

            })
            .disposed(by: disposeBag)
            
    }
    
}

extension String {
    
    /// email規則
    fileprivate func checkEmailIsValid() -> Bool {
        
        // do somthing..
        return false
    }
    
    /// 密碼規則
    fileprivate func checkPasswordIsValid() -> Bool {
        
        // do somthing..
        return false
    }
}
