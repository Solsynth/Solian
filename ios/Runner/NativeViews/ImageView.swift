//
//  ImageView.swift
//  Runner
//
//  Created by LittleSheep on 2025/4/21.
//

import UIKit
import Kingfisher

class ImageView: UIImageView {
    private var _size: CGSize = CGSize(width: 0, height: 0)
    
    // Initialize the image view
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
    
    // Method to set the image from a URL using Kingfisher
    func setImage(from url: URL, blurHash: String?) {
        let placeholderImage = blurHash != nil ? UIImage.init(blurHash: blurHash!, size: _size) : nil
        let processor = DownsamplingImageProcessor(size: _size) |> RoundCornerImageProcessor(cornerRadius: 20)
        
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .transition(.fade(0.3))
            ]
        )
    }
}
