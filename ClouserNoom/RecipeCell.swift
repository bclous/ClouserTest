//
//  RecipeCell.swift
//  ClouserNoom
//
//  Created by Brian Clouser on 9/28/18.
//  Copyright © 2018 Brian Clouser. All rights reserved.
//

import UIKit
import SDWebImage

class RecipeCell: UITableViewCell {
    
    static let identifier = "RecipeCell"
    
    let thumbnailImageView = UIImageView()
    let titleLabel = UILabel()
    let ingredientsLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubViews()
    }
    
    private func configureSubViews() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(ingredientsLabel)
        contentView.addSubview(thumbnailImageView)
        
        titleLabel.numberOfLines = 1
        
        ingredientsLabel.numberOfLines = 0
        ingredientsLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        ingredientsLabel.textColor = UIColor.gray
        ingredientsLabel.font = UIFont(name: ingredientsLabel.font.fontName, size: 14)
        
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 5
        
        configureSubviewConstraints()
    }
    
    private func configureSubviewConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        ingredientsLabel.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageBottomAbsoluteConstraint = thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        imageBottomAbsoluteConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            thumbnailImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 60),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            imageBottomAbsoluteConstraint,
            
            titleLabel.leftAnchor.constraint(equalTo: thumbnailImageView.rightAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 0),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 15),
            
            ingredientsLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            ingredientsLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            ingredientsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            ingredientsLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant:-10)
            ])
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureCellWithRecipe(_ recipe: Recipe) {
        thumbnailImageView.sd_setImage(with: URL(string: recipe.thumbnailURL), placeholderImage: UIImage(named: "plate"), options: [], completed: nil)
        ingredientsLabel.text = recipe.ingredients
        titleLabel.text = recipe.title
    }

}
