import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var tapBackButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Properties
    
    var image: UIImage?
        
    var largeImageUrl: String?
    
    // MARK: - Constants
    
    private enum Constants {
            static let minZoomScale = 0.1
            static let maxZoomScale = 1.25
        }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = Constants.minZoomScale
        scrollView.maximumZoomScale = Constants.maxZoomScale
        
        loadImage()
    }
    
    // MARK: - Back Button Function
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Share Button Function
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
            guard let image = imageView.image else { return }
            
            let sharingVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            present(sharingVC, animated: true, completion: nil)
        }
    
    // MARK: - Image Settings
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        imageView.image = image
        imageView.frame.size = image.size
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0  else { return }
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        updateContentInsets()
        
    }
    
    private func updateContentInsets() {
        let x = max(0, (scrollView.bounds.width - scrollView.contentSize.width) / 2)
        let y = max(0, (scrollView.bounds.height - scrollView.contentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
        guard let image else { return }
        scrollView.contentSize = image.size
    }
    
    // MARK: - Image Loading
    
    func loadImage() {
        guard let largeImageUrl = largeImageUrl else { return }
        guard let url = URL(string: largeImageUrl) else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let value):
                self.rescaleAndCenterImageInScrollView(image: value.image)
                print(value.image)
                print(value.cacheType)
                print(value.source)
            case .failure:
                showError()
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateContentInsets()
    }
}

// MARK: - Alerts

extension SingleImageViewController {
    func showError() {
        let alert = UIAlertController(title: "Something went wrong.", message: "Do you want to try again?", preferredStyle: .alert)
        let alertActionNo = UIAlertAction(title: "No", style: .default) { [weak self] _ in
            guard let self else { return }
            alert.dismiss(animated: true)
        }
        let alertActionTry = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
            guard let self else { return }
            self.loadImage()
        }
        alert.addAction(alertActionNo)
        alert.addAction(alertActionTry)
        present(alert, animated: true)
    }
}
