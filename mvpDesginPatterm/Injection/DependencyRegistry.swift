import UIKit
import Swinject
import SwinjectStoryboard

protocol DependencyRegistry {
    
    var container: Container{ get }
    var navigationCoordinator: NavigationCoordinator! { get}
    typealias DetailViewControllerMaker = (SpyDTO) -> DetailsViewController
    func makeSpyCell(for tableView: UITableView, at indexPath: IndexPath, spy: SpyDTO) -> SpyCell
    
    typealias SecretDetailsViewControllerMaker = (SpyDTO, SecretDetailsDelegate)  -> SecretDetailsViewController
    func makeDetailViewController(with spy: SpyDTO) -> DetailsViewController
    
    typealias SpyCellMaker = (UITableView, IndexPath, SpyDTO) -> SpyCell
    func makeSecretDetailsViewController(with spy: SpyDTO) -> SecretDetailsViewController
    
    
    typealias rootNavigationCoordinatorMaker = (UIViewController) -> NavigationCoordinator
    func makeRootNavigationCoordinator(rootViewController: UIViewController) -> NavigationCoordinator
    
}
class DependencyRegistryImp: DependencyRegistry {

    

    
    var navigationCoordinator: NavigationCoordinator!

    var container: Container
    
    init(container: Container) {
        
        Container.loggingFunction = nil
        
        self.container = container
        
        registerDependencies()
        registerPresenters()
        registerViewControllers()
    }
    
    func registerDependencies() {
        
        container.register(NavigationCoordinator.self) { (r, rootViewController: UIViewController) in
            return RootNavigationCoordinatorImpl(registry: self, rootViewController: rootViewController)
        }.inObjectScope(.container)
        
        container.register(NetworkLayer.self    ) { _ in NetworkLayerImp()  }.inObjectScope(.container)
        container.register(DatabaseLayer.self       ) { _ in DatabaseLayerImp()     }.inObjectScope(.container)
        container.register(SpyTranslator.self   ) { _ in SpyTranslatorImp() }.inObjectScope(.container)
        
        container.register(TranslationLayer.self) { r in
            TranslationLayerImp(spyTranslator: r.resolve(SpyTranslator.self)!)
        }.inObjectScope(.container)

        container.register(ModelLayer.self){ r in
            ModelLayerImp(networkLayer:     r.resolve(NetworkLayer.self)!, dataBaseLayer:        r.resolve(DatabaseLayer.self)!,
                             translationLayer: r.resolve(TranslationLayer.self)!)
        }.inObjectScope(.container)
    }
    
    func registerPresenters() {
        container.register(SpyListPresenter.self) { r in SpyListPresenterImp(modelLayer: r.resolve(ModelLayer.self)!) }
        container.register( DetailsPresenter.self) { (r, spy: SpyDTO)  in DetailsPresenterImp(with: spy) }
        container.register(SpyCellPresenter.self) { (r, spy: SpyDTO) in SpyCellPresenterImp(spy: spy) }
        container.register(SecretDetailsPresenter.self) { (r, spy: SpyDTO) in SecretDetailsPresenterImp(with: spy) }
    }
    
    func registerViewControllers() {
        container.register(SecretDetailsViewController.self) { (r, spy: SpyDTO) in
            
            let presenter = r.resolve(SecretDetailsPresenter.self, argument: spy)!
            
            return SecretDetailsViewController(with: presenter, navigationCoordinator: self.navigationCoordinator)
        }
        
        container.register(DetailsViewController.self) {  (r,spy:SpyDTO) in
            let presenter =  r.resolve(DetailsPresenter.self, argument: spy)
            let detailViewController = DetailsViewController(nibName: "DetailsViewController", bundle: nil)
            detailViewController.configure(with: presenter!, navigationCoordinator: self.navigationCoordinator)
            
            return detailViewController
            
        }
     //   container.register(DetailsViewController.self) { _ in
     //       DetailsViewController()
            
            
     //   }.inObjectScope(.container)
    }

    //MARK: - Maker Methods
    
    func makeSpyCell(for tableView: UITableView, at indexPath: IndexPath, spy: SpyDTO) -> SpyCell {
        let presenter = container.resolve(SpyCellPresenter.self, argument: spy)!
        let cell = SpyCell.dequeue(from: tableView, for: indexPath, with: presenter
        )
        return cell
    }
    
    
    func makeDetailViewController(with spy: SpyDTO) -> DetailsViewController {
        return container.resolve(DetailsViewController.self, argument: spy)!
    }

    
    func makeSecretDetailsViewController(with spy: SpyDTO) -> SecretDetailsViewController {
        
     //   navigationCoordinator = container.resolve(NavigationCoordinator.self)
        
        print("makeSecretDetailsViewController.spy \(spy.name)")
        return container.resolve(SecretDetailsViewController.self, argument: spy)!
    }
    
    func makeRootNavigationCoordinator(rootViewController: UIViewController) -> NavigationCoordinator {
        navigationCoordinator = container.resolve(NavigationCoordinator.self, argument:rootViewController )
        return navigationCoordinator
    }
}
