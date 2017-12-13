//
//  UIImageView+AlamofireImage.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/17/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
import AlamofireImage

extension UIImageView {
    func setImage(withPath path: String){
        guard let url = try? path.asURL() else {
            return
        }
        self.af_setImage(withURL: url)
    }
    
    func setImage(withPath path: String, placeholderImage placeholder: UIImage? = nil){
        guard let url = try? path.asURL() else {
            self.image =  placeholder
            return
        }
        self.af_setImage(withURL: url, placeholderImage: placeholder)
    }
}

