//
//  FeedCell.swift
//  TestInk
//
//  Created by C4Q on 3/14/18.
//  Copyright © 2018 C4Q. All rights reserved.
//

import UIKit

protocol FeedCellDelegate: class {
    func didTapFlag(onPost post: DesignPost, cell: FeedCell)
    func didTapShare(image: UIImage, forPost post: DesignPost)
    func didTapLike(onPost post: DesignPost)
}

class FeedCell: UITableViewCell {
    public var delegate: FeedCellDelegate?
    private var designPost: DesignPost?
    
    //lazy vars
    lazy var userImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .purple
        iv.image = #imageLiteral(resourceName: "placeholder-image") //placeholder
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    //Meseret
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Billy"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        return label
    }()
    
    lazy var feedImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "placeholder-image") //placeholder
        return iv
    }()
    
    lazy var flagButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "flagUnfilled"), for: .normal)
        button.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        button.addTarget(self, action: #selector(flagButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "heartUnfilled"), for: .normal)
        button.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var numberOfLikes: UILabel = {
        let label = UILabel()
        label.text = "23" // to do
        label.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        return label
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "actionIcon"), for: .normal)
        button.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "FeedCell")
        setUpGUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpGUI() {
        backgroundColor = .white
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImage.layer.cornerRadius = userImage.bounds.width / 2.0
        userImage.layer.masksToBounds = true
    }

    private func setupViews() {
        setupUserImage()
        setupUserNameLabel()
        setupFlagButton()
        setupFeedImage()
        setupLikeButton()
        setupNumberOfLikes()
        setupShareButton()
    }
    
    public func configureCell(withPost post: DesignPost) {
        self.designPost = post
        numberOfLikes.text = post.likes.description
        configureFeedImage(withPost: post)
        configureUserNameAndImage(withPost: post)
        configureFlag(withPost: post)
    }
    
    private func configureFeedImage(withPost post: DesignPost) {
        guard let imageURLString = post.image else {
            print("could not get image URL")
            return
        }
        //get image from cache, if non existent then run this
        if let image = NSCacheHelper.manager.getImage(with: post.uid) {
            feedImage.image = image
            layoutIfNeeded()
        } else {
            ImageHelper.manager.getImage(from: imageURLString, completionHandler: { (image) in
                //cache image for post id
                NSCacheHelper.manager.addImage(with: post.uid, and: image)
                self.feedImage.image = image
                self.layoutIfNeeded()
            }, errorHandler: { (error) in
                print("Error: Could not get image:\n\(error)")
            })
        }
    }
    
    private func configureUserNameAndImage(withPost post: DesignPost) {
        UserProfileService.manager.getName(from: post.userID) { (username) in
            self.userNameLabel.text = username
        }
    }
    
    private func configureFlag(withPost post: DesignPost) {
        FirebaseFlaggingService.service.checkIfPostIsFlagged(post: post, byUserID: AuthUserService.manager.getCurrentUser()!.uid) { (postHasBeenFlaggedByUser) in
            if postHasBeenFlaggedByUser {
                self.flagButton.setImage(#imageLiteral(resourceName: "flagFilled"), for: .normal)
            } else {
                self.flagButton.setImage(#imageLiteral(resourceName: "flagUnfilled"), for: .normal)
            }
        }
    }
    
    //constraints
    private func setupUserImage() {
        contentView.addSubview(userImage)
        userImage.snp.makeConstraints { (make) -> Void in
            make.leading.top.equalTo(contentView).offset(8)
            make.height.equalTo(40)
            make.width.equalTo(userImage.snp.height)
//            make.centerY.equalTo(safeAreaLayoutGuide.snp.centerY)
        }
    }

    private func setupUserNameLabel() {
        contentView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(userImage.snp.trailing).offset(8)
//            make.trailing.equalTo(contentView).inset(8)
            make.centerY.equalTo(userImage)
//            make.height.equalTo(contentView.snp.height)
//            favoriteImageView.clipsToBounds = true
        }
    }
    
    private func setupFlagButton() {
        contentView.addSubview(flagButton)
        
        flagButton.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(userImage)
            make.leading.equalTo(userNameLabel.snp.trailing).offset(8)
            make.trailing.equalTo(contentView).offset(-8)
        }
    }

    private func setupFeedImage() {
        contentView.addSubview(feedImage)
        feedImage.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(userImage.snp.bottom).offset(8).priority(999)
            make.bottom.equalTo(contentView.snp.bottom).priority(999)
            make.leading.trailing.equalTo(contentView)
            make.height.lessThanOrEqualTo(feedImage.snp.width).priority(999)
        }
        feedImage.clipsToBounds = true
    }

    private func setupLikeButton() {
        addSubview(likeButton)
        likeButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(feedImage.snp.bottom).offset(8)
            make.height.equalTo(userImage)
            make.leading.bottom.equalTo(contentView).inset(8)
        }
    }

    private func setupNumberOfLikes() {
        contentView.addSubview(numberOfLikes)
        numberOfLikes.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(likeButton.snp.trailing).offset(8)
            make.centerY.equalTo(likeButton)
//            make.trailing.equalTo(contentView.snp.trailing)
//            make.height.equalTo(contentView.snp.height)
        }
    }

    private func setupShareButton() {
        addSubview(shareButton)
        shareButton.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(numberOfLikes.snp.trailing).offset(8)
            make.trailing.equalTo(contentView).offset(-8)
            make.top.equalTo(feedImage.snp.bottom).offset(8)
            make.bottom.equalTo(contentView).offset(-8)
            make.height.equalTo(likeButton)
        }
    }
    
    @objc private func flagButtonTapped() {
        if let designPost = designPost {
            delegate?.didTapFlag(onPost: designPost, cell: self)
        }
    }
    
    @objc private func shareButtonTapped() {
        if let designPost = designPost, let image = feedImage.image {
            delegate?.didTapShare(image: image, forPost: designPost)
        }
    }
    
    @objc private func likeButtonTapped() {
        if let designPost = designPost {
            delegate?.didTapLike(onPost: designPost)
        }
    }
}
