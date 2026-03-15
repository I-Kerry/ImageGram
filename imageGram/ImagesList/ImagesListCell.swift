
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tableImage: UIImageView!
    
    let colorControls = ColorControls()

    static let reuseIdentifier = "ImageListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    private var gradient = CAGradientLayer()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tableImage.kf.cancelDownloadTask()
        cellAnimate(state: .loading)
    }
    
    @IBAction func likeButtonClicked() {
        delegate?.imagesListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .buttonActive) : UIImage(resource: .buttonNonActive)
        likeButton.setImage(image, for: .normal)
    }
    
    func cellAnimate(state: FeedCellImagesState) {
        switch state {
        case .loading:
            gradient = colorControls.makeUploadingAnimation(view: tableImage)
            tableImage.layer.addSublayer(gradient)
            colorControls.startAnimation(on: gradient)
        case .finished(let image):
            colorControls.stopAnimations()
            tableImage.image = image
        case .error:
            colorControls.stopAnimations()
            tableImage.image = MagicConstants.photoPlaceholder
        }
    }
}

enum FeedCellImagesState {
    case loading
    case error
    case finished(UIImage)
}

