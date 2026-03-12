
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tableImage: UIImageView!

    static let reuseIdentifier = "ImageListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tableImage.kf.cancelDownloadTask()
//        tableImage.image = nil
    }
    
    @IBAction func likeButtonClicked() {
        delegate?.imagesListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .buttonActive) : UIImage(resource: .buttonNonActive)
        likeButton.setImage(image, for: .normal)
    }
}
