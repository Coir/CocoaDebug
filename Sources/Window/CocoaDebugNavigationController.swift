//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class CocoaDebugNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false //liman
        
        navigationBar.tintColor = Color.mainGreen
        //适配iOS13以后的tabbar颜色、属性
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .darkGray
        barAppearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20),
                                             .foregroundColor: Color.mainGreen]
        navigationBar.standardAppearance = barAppearance
        navigationBar.scrollEdgeAppearance = barAppearance
        
//        navigationBar.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20),
//                                             .foregroundColor: Color.mainGreen]
        
        let selector = #selector(CocoaDebugNavigationController.exit)
        
        let image = UIImage(named: "_icon_file_type_close", in: Bundle(for: CocoaDebugNavigationController.self), compatibleWith: nil)
        let leftItem = UIBarButtonItem(image: image,
                                       style: .done, target: self, action: selector)
        leftItem.tintColor = Color.mainGreen
        topViewController?.navigationItem.leftBarButtonItem = leftItem
    }
    
    
    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }
}
