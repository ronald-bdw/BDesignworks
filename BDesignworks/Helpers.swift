//
//  Helpers.swift
//  BDesignworks
//
//  Created by Kruperfone on 19.11.15.
//  Copyright © 2015 Flatstack. All rights reserved.
//

import Foundation

func GetTechnicalInfo() -> String {
    
    let device = UIDevice.current
    
    var info = ""
    
    let AppVersion = Bundle.main.infoDictionary?.fs_objectForKey("CFBundleShortVersionString", orDefault: "0") as! String
    let BuildNumber = Bundle.main.infoDictionary?.fs_objectForKey("CFBundleVersion", orDefault: "0") as! String
    
    info += "App version:   \(AppVersion) (\(BuildNumber))"
    info += "\nDevice:      \(device.model)"
    info += "\nSoftware:    \(device.systemName) \(device.systemVersion)"
    
    if let vendorID = device.identifierForVendor {
        info += "\nVendor ID:   \(vendorID.uuidString)"
    }
    
    let message = "\n\n\n\nWe need this information to understand the problem better\n\(info)"
    
    return message
}

enum LoadingState {
    case loading
    case done
    case failed
}

let topBarHeight: CGFloat = 64.0 // Status and navigation bar's summary height

//MARK: - Foundation
extension NSObject {
    
    class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var className: String {
        return type(of: self).className
    }
}

enum FSScreenType {
    
    case _3_5
    case _4
    case _4_7
    case _5_5
    
    init?() {
        switch UIScreen.main.bounds.size {
        case CGSize(width: 320, height: 480): self = ._3_5
        case CGSize(width: 320, height: 568): self = ._4
        case CGSize(width: 375, height: 667): self = ._4_7
        case CGSize(width: 414, height: 736): self = ._5_5
        default                             : return nil
        }
    }
    
    var size: CGSize {
        switch self {
        case ._3_5 : return CGSize(width: 320, height: 480)
        case ._4   : return CGSize(width: 320, height: 568)
        case ._4_7 : return CGSize(width: 375, height: 667)
        case ._5_5 : return CGSize(width: 414, height: 736)
        }
    }
}

extension UIView {
    
    var fs_bottom: CGFloat {
        return self.fs_origin.y + self.fs_height
    }
    
    var fs_trailing: CGFloat {
        return self.fs_origin.x + self.fs_width
    }
    
    var fs_leading: CGFloat {
        return self.fs_origin.x
    }
    
    var fs_top: CGFloat {
        return self.fs_origin.y
    }
}

extension UIView {
    
    func performRecursively(_ block: ((_ view: UIView)->(Void))) {
        
        block(self)
        
        for subview in self.subviews {
            subview.performRecursively(block)
        }
    }
}

var countryCodes: [String : [Area]] = {
    
    var list: [Area] = []
    guard let filePath = Bundle.main.path(forResource: "PhoneCountries", ofType: "txt") else { return [:] }
    let stringData: Data? = try? Data(contentsOf: URL(fileURLWithPath: filePath))
    guard let lStringData = stringData else { return [:] }

    let data: String? = String(data: lStringData, encoding: String.Encoding.utf8)
    
    guard let lData = data else { return [:] }
    
    let separator: String = ";"
    let endOfLine: String = "\n"
    
    let lines: [String] = lData.components(separatedBy: endOfLine)
    
    let trimmingCharacters: CharacterSet = CharacterSet(charactersIn: "\r")
    
    for line in lines {
        
        let currentLine: String = line.trimmingCharacters(in: trimmingCharacters)
        let components: [String] = currentLine.components(separatedBy: separator)
        guard let countryName = components.fs_objectAtIndexOrNil(2) else { continue }
        guard let code        = components.fs_objectAtIndexOrNil(0)?.fs_toInt() else { continue }
        let area: Area = Area(countryName: countryName, areaCode: code)
        list.append(area)
    }
    
    return list.categorise { (area: Area) -> String in
        return area.countryName.substring(to: area.countryName.characters.index(area.countryName.startIndex, offsetBy: 1))
    }
}()
