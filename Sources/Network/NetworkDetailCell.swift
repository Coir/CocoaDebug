//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import CryptoSwift
import Combine

class NetworkDetailCell: UITableViewCell {
    var encryptSwitchPublisher: PassthroughSubject<(NetworkDetailModel?, IndexPath), Never> = .init()
    var index: IndexPath = .init()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: CustomTextView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var middleLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var editView: UIImageView!
    
    @IBOutlet weak var encryptTitleLabel: UILabel!
    @IBOutlet weak var encryptSwitch: UISwitch!
    @IBOutlet weak var titleViewBottomSpaceToMiddleLine: NSLayoutConstraint!
    
    func decryptData() {
        guard let httpModel = detailModel?.httpModel, let header = httpModel.responseHeaderFields,
              let json = try? JSONSerialization.jsonObject(with: httpModel.responseData, options: .fragmentsAllowed) as? [String: Any],
              let encryptString = json["cipherText"] as? String, !encryptString.isEmpty else { return }
        var key = ""
        let config = CocoaDebugSettings.shared
        if header["x-encrypt"] as? String == "true"         { key = config.encryptKey }
        else if header["encrypt"] as? String == "encrypt"   { key = config.defaultEncryptKey }
        guard !key.isEmpty,
        let aes = try? CryptoSwift.AES(key: key.bytes, blockMode: ECB(), padding: .pkcs7),
        let decryptedBytes = try? aes.decrypt(Array(base64: encryptString)) else { return }
        encryptTitleLabel.isHidden = false
        encryptSwitch.isHidden = false
        if httpModel.decryptResponseData != nil { return }
        httpModel.decryptResponseData = Data(decryptedBytes)
        detailModel?.httpModel = httpModel
        switchModelData(httpModel)
    }
    
    var tapEditViewCallback:((NetworkDetailModel?) -> Void)?
    
    var detailModel: NetworkDetailModel? {
        didSet { configWithModel() }
    }
    func configWithModel() {
        let isResponse = detailModel?.title == "RESPONSE"
        /// 只在RESPONSE显示详情，跳转JsonViewController
        editView.isHidden = !isResponse
        if isResponse { decryptData() }

        titleLabel.text = detailModel?.title
        contentTextView.text = detailModel?.content
        
        //image
        if detailModel?.image == nil {
            imgView.isHidden = true
        } else {
            imgView.isHidden = false
            imgView.image = detailModel?.image
        }
        
        //Hide content automatically
        if detailModel?.blankContent == "..." {
            middleLine.isHidden = true
            imgView.isHidden = true
            titleViewBottomSpaceToMiddleLine.constant = -12.5 + 2
        } else {
            middleLine.isHidden = false
            if detailModel?.image != nil {
                imgView.isHidden = false
            }
            titleViewBottomSpaceToMiddleLine.constant = 0
        }
        
        //Bottom dividing line
        if detailModel?.isLast == true {
            bottomLine.isHidden = false
        } else {
            bottomLine.isHidden = true
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        editView.image = UIImage(systemName: "ellipsis.circle")
        editView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapEditView)))
        
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.textContainerInset = .zero
    }
    
    //MARK: - target action
    //edit
    @objc func tapEditView() {
        if let tapEditViewCallback = tapEditViewCallback {
            tapEditViewCallback(detailModel)
        }
    }
    
    @IBAction func encryptSwitchTapped(_ sender: UISwitch) {
        switchModelData()
        configWithModel()
        encryptSwitchPublisher.send((detailModel, index))
    }
    func switchModelData(_ httpModel: _HttpModel? = nil) {
        let model = httpModel ?? detailModel?.httpModel
        detailModel?.content = encryptSwitch.isOn ? model?.decryptResponseData.dataToPrettyPrintString() : model?.responseData.dataToPrettyPrintString()
    }
}
