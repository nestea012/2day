//
//  PageController.swift
//  SoSueMe
//
//  Created by Anastasiya Dumyak on 3/6/17.
//  Copyright © 2017 Inoxoft. All rights reserved.
//

import UIKit


class PController {
    static var controller: PageController!
}

class PageController: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate {

    var index = 0
    var nextButton: UIButton!
    var prevButton: UIButton!
    var swipeRight: UISwipeGestureRecognizer!
    var swipeLeft: UISwipeGestureRecognizer!
    
     let pages = ["HomeController","ListController","WeatherController","TodoController","ScheduleController"]
    
    lazy var VCArr: [UIViewController] = []
        
    private func VCInstance() {
        let home = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeController")
        let list = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListController") as! ListController
        list.isTodayMode = true
        let weather = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherController") as! WeatherController
        weather.isTodayMode = true
        let todo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TodoController") as! ToDoListController
        todo.isTodayMode = true
        let schedule = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScheduleController")
        VCArr.append(home)
        VCArr.append(list)
        VCArr.append(weather)
        VCArr.append(todo)
        VCArr.append(schedule)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        self.dataSource = self
        self.delegate = self
        VCInstance()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeController")
        setViewControllers([vc!], direction: .forward,animated: true, completion: nil)
     }
    
    func right() {
        nextScreen()
    }
    
    func left() {
        prev()
    }
    
    func logout() {
        UserManager.sharedInstance.logout()
        performSegue(withIdentifier: "LogoutSegue", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PController.controller = self
        
        if  !UserManager.sharedInstance.checkUserInformation() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController") as! LoginController
            viewController.isModalInPopover = true
            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
            UserManager.sharedInstance.logout()
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
   
}

extension PageController {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let identifier = viewControllers?.first?.restorationIdentifier {
            if let index = pages.index(of: identifier) {
                return index
            }
        }
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
      
        if index > 0 {
            index -= 1
            return  VCArr[index]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if index < pages.count - 1 {
            index += 1
            return VCArr[index]
        }
        
        return nil
    }
    
    func nextScreen() {
        if index < VCArr.count-1 {
            index += 1
            setViewControllers([VCArr[index]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func prev() {
        if index > 0  {
            index -= 1
            if index == 0 {

            }
            setViewControllers([VCArr[index]], direction: .reverse, animated: true, completion: nil)
        }
    }
}
