//
//  StatusThreadRootTableViewCell.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-17.
//

import os.log
import UIKit
import Combine
import MastodonAsset
import MastodonLocalization
import MastodonUI

final class StatusThreadRootTableViewCell: UITableViewCell {
    
    static let marginForRegularHorizontalSizeClass: CGFloat = 64
    
    let logger = Logger(subsystem: "StatusThreadRootTableViewCell", category: "View")
        
    weak var delegate: StatusTableViewCellDelegate?
    var disposeBag = Set<AnyCancellable>()

    let statusView = StatusView()
    let separatorLine = UIView.separatorLine
    
    var containerViewLeadingLayoutConstraint: NSLayoutConstraint!
    var containerViewTrailingLayoutConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag.removeAll()
        statusView.prepareForReuse()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    deinit {
        os_log(.info, log: .debug, "%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

extension StatusThreadRootTableViewCell {
    
    private func _init() {
        selectionStyle = .none
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusView)
        setupContainerViewMarginConstraints()
        NSLayoutConstraint.activate([
            statusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerViewLeadingLayoutConstraint,
            containerViewTrailingLayoutConstraint,
            statusView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        statusView.setup(style: .plain)
        updateContainerViewMarginConstraints()
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine)
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: UIView.separatorLineHeight(of: contentView)).priority(.required - 1),
        ])
        
        statusView.delegate = self
        
        // a11y
        statusView.contentMetaText.textView.isAccessibilityElement = false
        statusView.contentMetaText.textView.isSelectable = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateContainerViewMarginConstraints()
    }
    
}

extension StatusThreadRootTableViewCell {
    
    override var accessibilityElements: [Any]? {
        get {
            var elements = [
                statusView.headerContainerView,
                statusView.avatarButton,
                statusView.authorNameLabel,
                statusView.menuButton,
                statusView.authorUsernameLabel,
                statusView.dateLabel,
                statusView.contentSensitiveeToggleButton,
                statusView.spoilerOverlayView,
                statusView.contentMetaText.textView,
                statusView.mediaGridContainerView,
                statusView.pollTableView,
                statusView.pollStatusStackView,
                statusView.actionToolbarContainer,
                statusView.statusMetricView
            ]
            
            if !statusView.viewModel.isMediaSensitive {
                elements.removeAll(where: { $0 === statusView.contentSensitiveeToggleButton })
            }
            
            if statusView.viewModel.isContentReveal {
                elements.removeAll(where: { $0 === statusView.spoilerOverlayView })
            } else {
                elements.removeAll(where: { $0 === statusView.contentMetaText.textView })
            }
            
            if statusView.viewModel.pollItems.isEmpty {
                elements.removeAll(where: { $0 === statusView.pollTableView })
                elements.removeAll(where: { $0 === statusView.pollStatusStackView })
            }
            
            return elements
        }
        set { }
    }

}

extension StatusThreadRootTableViewCell: AdaptiveContainerMarginTableViewCell {
    var containerView: StatusView {
        statusView
    }
}


// MARK: - StatusViewContainerTableViewCell
extension StatusThreadRootTableViewCell: StatusViewContainerTableViewCell { }

// MARK: - StatusViewDelegate
extension StatusThreadRootTableViewCell: StatusViewDelegate { }