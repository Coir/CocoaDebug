//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class CocoaDebugTabBarController: UITabBarController {
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.keyWindow?.endEditing(true)
        
        setChildControllers()
        
        self.selectedIndex = CocoaDebugSettings.shared.tabBarSelectItem
        
        //适配iOS13以后的tabbar颜色、属性
        self.tabBar.tintColor = Color.mainGreen
        
        let itemAppearance = UITabBarItemAppearance()
        // 设置正常和选中的颜色
        
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: Color.mainGreen]
        let barAppearence = UITabBarAppearance()
        barAppearence.stackedLayoutAppearance = itemAppearance
        barAppearence.backgroundColor = .darkGray
        tabBar.standardAppearance = barAppearence
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = barAppearence
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CocoaDebugSettings.shared.visible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CocoaDebugSettings.shared.visible = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WindowHelper.shared.displayedList = false
    }
    
    //MARK: - private
    func setChildControllers() {
        
        //1.
//        let logs = UIStoryboard(name: "Logs", bundle: Bundle(for: CocoaDebug.self)).instantiateViewController(withIdentifier: "Logs")
        let network = UIStoryboard(name: "Network", bundle: Bundle(for: CocoaDebug.self)).instantiateViewController(withIdentifier: "Network")
        let app = UIStoryboard(name: "App", bundle: Bundle(for: CocoaDebug.self)).instantiateViewController(withIdentifier: "App")
        
        //2.
        _Sandboxer.shared.isSystemFilesHidden = false
        _Sandboxer.shared.isExtensionHidden = false
        _Sandboxer.shared.isShareable = true
        _Sandboxer.shared.isFileDeletable = true
        _Sandboxer.shared.isDirectoryDeletable = true
        guard let sandbox = _Sandboxer.shared.homeDirectoryNavigationController() else {return}
        sandbox.tabBarItem.title = "Sandbox"
        sandbox.tabBarItem.image = UIImage.init(named: "_icon_file_type_sandbox", in: Bundle.init(for: CocoaDebug.self), compatibleWith: nil)
        
        //3.
        guard let additionalViewController = CocoaDebugSettings.shared.additionalViewController else {
            self.viewControllers = [network, sandbox, app]
            return
        }
        
        //4.Add additional controller
        let nav = CocoaDebugNavigationController(rootViewController: additionalViewController)
        nav.tabBarItem.title = "WebSocket"
        nav.tabBarItem.image = UIImage.init(named: "_icon_file_type_logs", in: Bundle.init(for: CocoaDebug.self), compatibleWith: nil)

        nav.navigationBar.tintColor = sandbox.navigationBar.tintColor
        nav.navigationBar.standardAppearance = sandbox.navigationBar.standardAppearance
        nav.navigationBar.scrollEdgeAppearance = sandbox.navigationBar.scrollEdgeAppearance

        let image = UIImage(named: "_icon_file_type_close", in: Bundle(for: CocoaDebugNavigationController.self), compatibleWith: nil)
        let leftItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(CocoaDebugNavigationController.exit))
        leftItem.tintColor = Color.mainGreen
        nav.topViewController?.navigationItem.leftBarButtonItem = leftItem
        
        self.viewControllers = [network, sandbox, nav, app]
    }
    
    //MARK: - target action
    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - show more than 5 tabs by CocoaDebug
    //    override var traitCollection: UITraitCollection {
    //        var realTraits = super.traitCollection
    //        var lieTrait = UITraitCollection.init(horizontalSizeClass: .regular)
    //        return UITraitCollection(traitsFrom: [realTraits, lieTrait])
    //    }
}

//MARK: - UITabBarDelegate
extension CocoaDebugTabBarController {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = self.tabBar.items else {return}
        
        for index in 0...items.count-1 {
            if item == items[index] {
                CocoaDebugSettings.shared.tabBarSelectItem = index
            }
        }
    }
}
