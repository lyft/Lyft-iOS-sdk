import CoreLocation
import UIKit

/// The preferred size of the button. Anything smaller may result in cut off or overlapping text
public let LyftButtonPreferredSize = CGSize(width: 260, height: 50)

private let kButtonCornerRadius: CGFloat = 5

private enum LyftButtonStatus {
    case noData
    case rideTypeETA
    case fullData

    var nibName: String {
        switch self {
        case .noData:
            return "LyftButtonNone"
        case .rideTypeETA:
            return "LyftButtonRideTypeETA"
        case .fullData:
            return "LyftButtonFull"
        }
    }

    init(cost: Cost?, eta: ETA?) {
        if cost != nil && eta != nil {
            self = cost?.estimate == nil ? .rideTypeETA : .fullData
        } else {
            self = .noData
        }
    }
}

/// Primary view container for LyftButton.  All styling and automatic configuration functions are here.
/// To use this, create a UIView, and set the custom class to `LyftButton`
@IBDesignable
public class LyftButton: UIView {

    @IBOutlet private var button: Button!
    @IBOutlet private var logo: UIImageView!
    @IBOutlet private var mainMessage: UILabel!
    @IBOutlet private var rideMessage: UILabel?
    @IBOutlet private var primetimeIndicator: UIImageView?
    @IBOutlet private var price: UILabel?

    private var buttonStateView: UIView?
    private var pressUpAction: ((Void) -> Void)?

    private var status: LyftButtonStatus = .noData {
        didSet { self.setupNib() }
    }

    /// Preset LyftButton styles. Refer to documentation for available styles.
    public var style: LyftButtonStyle = .mulberryDark {
        didSet { self.setupStyle() }
    }

    /// The deep link behavior for this button
    public var deepLinkBehavior: LyftDeepLinkBehavior = .native

    /// Initializes a LyftButton with its preferred size
    convenience public init() {
        self.init(frame: CGRect(origin: CGPoint.zero, size: LyftButtonPreferredSize))
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
        self.setupStyle()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setupNib()
        self.setupStyle()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.awakeFromNib()
    }

    /// Configures the button by providing optional pickup and destination
    ///
    /// - parameter rideKind:       Ride kind to show data for. Defaults to Standard if ride kind unavailable
    ///                             for the region the pickup is located within
    /// - parameter pickup:         Optional pickup (aka origin) coordinate
    /// - parameter destination:    Optional destination coordinate.  If pickup is not provided, providing
    ///                             this will have nil effect.
    public func configure(rideKind: RideKind = .Standard, pickup: CLLocationCoordinate2D? = nil,
                          destination: CLLocationCoordinate2D? = nil)
    {
        self.pressUpAction = { [weak self] in
            if let behavior = self?.deepLinkBehavior {
                LyftDeepLink.requestRide(using: behavior, kind: rideKind, from: pickup, to: destination)
            }
        }

        guard let pickup = pickup else {
            return self.configureLayout()
        }

        var eta: ETA?
        var cost: Cost?

        LyftAPI.ETAs(to: pickup) { [weak self] result in
            eta = result.value?.filter { $0.rideKind == rideKind }.first ??
                result.value?.filter { $0.rideKind == .Standard }.first
            self?.configureLayout(cost: cost, eta: eta)
        }

        LyftAPI.costEstimates(from: pickup, to: destination) { [weak self] result in
            cost = result.value?.filter { $0.rideKind == rideKind }.first ??
                result.value?.filter { $0.rideKind == .Standard }.first
            self?.configureLayout(cost: cost, eta: eta)
        }
    }

    private func configureLayout(cost: Cost? = nil, eta: ETA? = nil) {
        self.status = LyftButtonStatus(cost: cost, eta: eta)
        self.setupStyle()

        if let eta = eta, let cost = cost {
            self.rideMessage?.text = String(format: I18N.LyftButton.RideETAFormat, cost.displayName,
                                            eta.minutes)
        }

        if let estimate = cost?.estimate {
            let minPriceText = estimate.minEstimate.formattedPrice()
            let maxPriceText = estimate.maxEstimate.formattedPrice()
            self.price?.text = estimate.minEstimate == estimate.maxEstimate ? minPriceText :
                String(format: I18N.LyftButton.CostEstimateRangeFormat, minPriceText, maxPriceText)
        }

        if let cost = cost {
            self.primetimeIndicator?.isHidden = cost.primeTimePercentageText == "0%"
        }
    }

    private func setupStyle() {
        self.button.backgroundColor = self.style.backgroundColor
        self.button.highlightedColor = self.style.highlightedColor
        self.logo.image = self.style.icon
        self.primetimeIndicator?.image = self.style.primeTimeIcon
        self.mainMessage.textColor = self.style.foregroundColor
        self.rideMessage?.textColor = self.style.foregroundColor
        self.price?.textColor = self.style.foregroundColor
    }

    private func setupNib() {
        self.buttonStateView?.removeFromSuperview()
        self.buttonStateView = self.buttonStateView(withNibName: self.status.nibName)
        self.button.layer.cornerRadius = kButtonCornerRadius

        guard let buttonStateView = self.buttonStateView else {
            return
        }

        self.insertSubview(buttonStateView, at: 0)
        buttonStateView.frame = self.bounds
        buttonStateView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private func buttonStateView(withNibName nibName: String) -> UIView? {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        let topLevelViews = nib.instantiate(withOwner: self, options: nil)
        return topLevelViews.first as? UIView
    }

    @IBAction private func handleClick() {
        self.pressUpAction?()
    }
}
