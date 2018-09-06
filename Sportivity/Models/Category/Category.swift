//
//  Category.swift
//  Sportivity
//
//  Created by Andrzej Frankowski on 18/04/2017.
//  Copyright © 2017 Sportivity. All rights reserved.
//

import UIKit
import Unbox
import Wrap

enum Category : String, UnboxableEnum, WrappableEnum {
    case basketball = "Basketball"
    case boxing = "Boxing"
    case fitness = "Fitness"
    case football = "Football"
    case pingPong = "Ping Pong"
    case tennis = "Tennis"
    case volleyball = "Volleyball"
    
    var name : String {
        switch self {
        case .basketball:
            return "Basketball"
        case .boxing:
            return "Boxing"
        case .fitness:
            return "Fitness"
        case .football:
            return "Football"
        case .pingPong:
            return "Ping Pong"
        case .tennis:
            return "Tennis"
        case .volleyball:
            return "Volleyball"
        }
    }
    
    var iconImage : UIImage {
        switch self {
        case .basketball:
            return R.image.basketballIcon()!
        case .boxing:
            return R.image.boxingIcon()!
        case .fitness:
            return R.image.fitnessIcon()!
        case .football:
            return R.image.footballIcon()!
        case .pingPong:
            return R.image.pingPongIcon()!
        case .tennis:
            return R.image.tennisIcon()!
        case .volleyball:
            return R.image.volleyballIcon()!
        }
    }
    
    static func all() -> [Category] {
        var all = [Category]()
        all.append(Category.basketball)
        all.append(Category.boxing)
        all.append(Category.fitness)
        all.append(Category.football)
        all.append(Category.pingPong)
        all.append(Category.tennis)
        all.append(Category.volleyball)
        return all
    }
}
