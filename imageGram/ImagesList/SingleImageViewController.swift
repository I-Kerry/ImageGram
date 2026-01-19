import UIKit

final class SingleImageViewController: UIViewController {
    private enum Constants {
        static let minZoomScale = 0.1
        static let maxZoomScale = 1.25
    }
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var tapBackButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = Constants.minZoomScale
        scrollView.maximumZoomScale = Constants.maxZoomScale
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
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
//        let newContentSize = scrollView.contentSize
//        let x = (newContentSize.width - visibleRectSize.width) / 2
//        let y = (newContentSize.height - visibleRectSize.height) / 2
//        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
//        let x = max(0, (scrollView.bounds.width - scrollView.contentSize.width) / 2)
//        let y = max(0, (scrollView.bounds.height - scrollView.contentSize.height) / 2)
//        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
//        scrollView.contentOffset = .zero
        updateContentInsets()
        
    }
    
    private func updateContentInsets() {
        let x = max(0, (scrollView.bounds.width - scrollView.contentSize.width) / 2)
        let y = max(0, (scrollView.bounds.height - scrollView.contentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let sharingVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(sharingVC, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateContentInsets()
    }
}
