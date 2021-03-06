//
//  DetailsViewController.swift
//  mvpDesginPatterm
//
//  Created by Mdo on 21/08/2020.
//  Copyright © 2020 Mdo. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, SecretDetailsDelegate {

    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLable: UILabel!
    
    @IBOutlet weak var ageLable: UILabel!
    
    @IBOutlet weak var genderLable: UILabel!
    
    var detailsPresenter: DetailsPresenter!
    fileprivate var secretDetailsViewControllerMaker: DependencyRegistry.SecretDetailsViewControllerMaker!
    weak var navigationCoordinator: NavigationCoordinator?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        superView()
        
       
        
        

        
    }
    
    func configure(with detailsPresenter: DetailsPresenter, navigationCoordinator:NavigationCoordinator ){
        
      //  self.spy = spy
        self.detailsPresenter = detailsPresenter
        self.navigationCoordinator = navigationCoordinator
       // self.secretDetailsViewControllerMaker = secretDetailsViewControllerMaker
    }
    
    func superView(){
//
        profileImage.image = UIImage(named: self.detailsPresenter.imagename)
        nameLable.text = self.detailsPresenter.name
        ageLable.text = "\(self.detailsPresenter.age)"
        genderLable.text = self.detailsPresenter.gender
    }
    
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
         if isMovingFromParent{
          
          navigationCoordinator?.movingBack()
          }
      }




}

extension DetailsViewController{
    
    func passwordCrackingFinished() {
        // close the middle layer too
        navigationController?.popViewController(animated: true)
    }
}

extension DetailsViewController{
    
    @IBAction func briefcaseTapped(_ button:UIButton){
      //  let secretDetailsPresenter = SecretDetailsPresenter(with: detailsPresenter.spy)
       // let vc = SecretDetailsViewController(with: secretDetailsPresenter, and: self as SecretDetailsDelegate)
     //   let vc = secretDetailsViewControllerMaker(detailsPresenter.spy, self)
      //  navigationController?.pushViewController(vc, animated: true)
        next(spy: detailsPresenter.spy)
        
        
    }
    
    func next(spy:SpyDTO){
        
        let args = ["spy":spy]
        navigationCoordinator!.next(arguments: args)
    }
}
