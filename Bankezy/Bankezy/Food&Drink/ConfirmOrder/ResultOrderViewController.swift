//
//  ResultOrderViewController.swift
//  Bankezy
//
//  Created by Andy on 30/12/2024.
//

import UIKit
import RxSwift
import RxCocoa

class ResultOrderViewController: UIViewController {
    
    lazy var resultOrderView = UIView(frame: .zero)
        .with(\.backgroundColor, setTo: .white)
        .with(\.layer.cornerRadius, setTo: 12)
    
    lazy var contentVstack = UIStackView(frame: .zero)
        .with(\.axis, setTo: .vertical)
        .with(\.alignment, setTo: .center)
        .with(\.spacing, setTo: 4)
    
    lazy var iconSuccess = UIImageView(frame: .zero)
        .with(\.image, setTo: resultStatus.iconImg?.image)
        .with(\.contentMode, setTo: .scaleToFill)
    
    lazy var lblSuccessNoti = UILabel(frame: .zero)
        .with(\.text, setTo: resultStatus.title?.title)
        .with(\.font, setTo: resultStatus.title?.font)
        .with(\.textColor, setTo: resultStatus.title?.color)
        .with(\.textAlignment, setTo: .center)
    
    lazy var lblDescription = UILabel(frame: .zero)
        .with(\.text, setTo: resultStatus.desciption?.title)
        .with(\.font, setTo: resultStatus.desciption?.font)
        .with(\.textColor, setTo: resultStatus.desciption?.color)
        .with(\.numberOfLines, setTo: 0)
        .with(\.textAlignment, setTo: .center)
    
    let resultStatus: ResultStatus
    
    init(resultStatus: ResultStatus) {
        self.resultStatus = resultStatus
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    func setupView() {
        view.backgroundColor = UIColor(hexString: "091E42").withAlphaComponent(0.4)
        
        view.addSubview(resultOrderView)
        resultOrderView.addSubview(contentVstack)
        
        resultOrderView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(35)
            make.trailing.equalToSuperview().inset(35)
            make.centerY.equalToSuperview()
        }
        contentVstack.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(24)
            make.bottom.trailing.equalToSuperview().inset(24)
        }
        
        lblDescription.setContentHuggingPriority(.required, for: .vertical)
        lblDescription.setContentCompressionResistancePriority(.required, for: .vertical)
        
        contentVstack.setContentHuggingPriority(.required, for: .vertical)
        
        if let iconImg = resultStatus.iconImg {
            contentVstack.addArrangedSubview(iconSuccess)
            iconSuccess.snp.makeConstraints { make in
                make.width.equalTo(iconImg.width)
                make.height.equalTo(iconImg.height)
            }
        }
        
        if resultStatus.title != nil  {
            contentVstack.addArrangedView(lblSuccessNoti, spacingAbove: 8)
        }
        
        if resultStatus.desciption != nil {
            contentVstack.addArrangedView(lblDescription, spacingAbove: 4)
            
            lblDescription.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
        
        resultStatus.buttons.forEach { button in
            
            let btn = UIButton(type: .custom)
            btn.setTitle(button.title, for: .normal)
            btn.setTitleColor(button.titleColor, for: .normal)
            btn.titleLabel?.font = button.titleFont
            
            contentVstack.addArrangedView(btn, spacingAbove: btn.spacingAbove)
            
            btn.snp.makeConstraints { make in
                make.height.equalTo(24)
                make.horizontalEdges.equalToSuperview()
            }
            
            btn.rx.tap
                .bind(onNext: {
                    button.action()
                })
                .disposed(by: btn.rx.disposeBag)
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

struct ResultStatus {
    let iconImg: IconInfor?
    
    // title
    let title: Label?
    
    // Description
    let desciption: Label?
    
    // Actions
    let buttons: [ButtonInfo]
    
    struct IconInfor {
        let image: UIImage?
        let width: CGFloat
        let height: CGFloat
    }
    
    struct Label {
        let title: String
        let font: UIFont
        let color: UIColor
    }
    
    struct ButtonInfo {
        let title: String
        let titleColor: UIColor
        let backgroundColor: UIColor
        let titleFont: UIFont
        let action: () -> Void
        var spacingAbove: CGFloat = 16
    }
}

extension UIViewController {
    func showResultStatus(_ resultStatus: ResultStatus) {
        let vc = ResultOrderViewController(resultStatus: resultStatus)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}
