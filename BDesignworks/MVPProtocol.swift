//
//  MVPProtocol.swift
//  JaneStore
//
//  Created by Sergey Nikolaev on 05.05.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

struct MVPContainer<View: MVPView, Presenter: MVPPresenter, Model: MVPModel> {
    
    let view: View
    let presenter: Presenter
    let model: Model
    
    init (view: View, makeAssemble: Bool = true) {
        
        self.view = view
        self.presenter = Presenter()
        self.model = Model()
        
        guard makeAssemble else {return}
        self.assemble()
    }
    
    init (navigationController: UINavigationController, makeAssemble: Bool = true) {
        let view = navigationController.topViewController as! View
        self.init(view: view, makeAssemble: makeAssemble)
    }
    
    init (identifier: String, storyboard: UIStoryboard = Storyboard.Login.storyboard, makeAssemble: Bool = true) {
        let controller = storyboard.instantiateViewControllerWithIdentifier(identifier)
        
        if let view = controller as? View {
            self.init(view: view, makeAssemble: makeAssemble)
        } else if let navigation = controller as? UINavigationController {
            self.init(navigationController: navigation, makeAssemble: makeAssemble)
        } else {
            fatalError()
        }
    }
    
    init(controller: UIViewController, makeAssemble: Bool = true) {
        if let view = controller as? View {
            self.init(view: view, makeAssemble: makeAssemble)
        } else {
            fatalError()
        }
    }
    
    func assemble () {
        self.view.setMVP(self.presenter)
        self.presenter.setMVP(self.view, model: self.model)
        self.model.setMVP(self.presenter)
        
        if let viewController = view as? UIViewController {
            if #available(iOS 9.0, *) {
                viewController.loadViewIfNeeded()
            } 
        }
    }
}

// ---
protocol MVPView: class {
    associatedtype PresenterProtocol
    
    var presenter: PresenterProtocol? {get set}
    
    func setMVP (presenter: Any)
}

extension MVPView {
    func setMVP (presenter: Any) {
        self.presenter = (presenter as! PresenterProtocol)
    }
}

// ---
protocol MVPPresenter: class {
    associatedtype ViewProtocol
    associatedtype ModelProtocol
    
    var view    : ViewProtocol?      {get set}
    var model   : ModelProtocol?     {get set}
    
    func setMVP (view: Any, model: Any)
    
    init ()
}

extension MVPPresenter {
    func setMVP (view: Any, model: Any) {
        self.view = (view as! ViewProtocol)
        self.model = (model as! ModelProtocol)
    }
}

// ---
protocol MVPModel: class {
    associatedtype PresenterProtocol
    
    var presenter: PresenterProtocol? {get set}
    
    func setMVP (presenter: Any)
    
    init ()
}

extension MVPModel {
    func setMVP (presenter: Any) {
        self.presenter = (presenter as! PresenterProtocol)
    }
}
