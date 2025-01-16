//
//  DeliveryOnGoingViewController.swift
//  Bankezy
//
//  Created by Andy on 31/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit
import Kingfisher

class DeliveryOnGoingViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var lblTimeDelivery: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblProductName: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblItemsCount: UILabel!
    
    @IBOutlet weak var lblPaymentMethod: UILabel!
    
    @IBOutlet weak var lblBrandName: UILabel!
    
    @IBOutlet weak var lblTypeBrand: UILabel!
    
    @IBOutlet weak var lblTimeStart: UILabel!
    
    @IBOutlet weak var lblReceiveAddress: UILabel!
    
    @IBOutlet weak var lblHomeOrCompany: UILabel!
    
    @IBOutlet weak var lblTimeRecieve: UILabel!
    
    @IBOutlet weak var avatarIcon: UIImageView!
    
    @IBOutlet weak var lblShipperName: UILabel!
    
    @IBOutlet weak var lblPhoneNumber: UILabel!
    
    private let viewModel: DeliveryStatusViewModel
    private let locationManager = CLLocationManager()
    private var deliveryURL: String?
    
    init(viewModel: DeliveryStatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "DeliveryOnGoingViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationPermission()
        bindingData()
    }
    
    func bindingData() {
        let input = DeliveryStatusViewModel.Input(viewDidload: .just(()))
        
        let output = viewModel.transform(input: input)
        
        output.deliveryInfor
            .drive(onNext: { location in
                self.deliveryURL = location.data?.driverInfo?.iconGoing
                self.addAnnotationsAndRoute(response: location)
                
            })
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.items)
            .map { items in
                let productNames = items.compactMap { $0.productName }
                return productNames.joined(separator: "-")
            }
            .drive(lblProductName.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.finalAmount)
            .map { "$ \($0)"}
            .drive(lblPrice.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.items)
            .map { "\($0.count) items" }
            .drive(lblItemsCount.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.paymentMethod)
            .drive(lblPaymentMethod.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.pickupLocation)
            .compactMap(\.address)
            .drive(lblBrandName.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.startTime)
            .drive(lblTimeStart.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.deliveryLocation)
            .compactMap(\.address)
            .drive(lblReceiveAddress.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.deliveryTimeEstimate)
            .drive(lblTimeRecieve.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.driverInfo)
            .compactMap(\.profilePicture)
            .compactMap { URL(string: $0) }
            .drive(onNext: { url in
                self.avatarIcon.kf.setImage(with: url)
            })
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.driverInfo)
            .compactMap(\.name)
            .drive(lblShipperName.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.deliveryInfor
            .compactMap(\.data)
            .compactMap(\.driverInfo)
            .compactMap(\.phone)
            .drive(lblPhoneNumber.rx.text)
            .disposed(by: rx.disposeBag)
        
        Driver.combineLatest(
            output.deliveryInfor.compactMap(\.data).compactMap(\.startTime),
            output.deliveryInfor.compactMap(\.data).compactMap(\.deliveryTimeEstimate)
        )
        .drive(onNext: { startTime, deliveryTimeEstimate in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            
            // Chuyển chuỗi thành Date
            if let startTime = dateFormatter.date(from: startTime),
               let endTime = dateFormatter.date(from: deliveryTimeEstimate) {
                
                // Tính sự chênh lệch giữa hai thời gian
                let timeInterval = endTime.timeIntervalSince(startTime)
                
                // Chuyển thời gian thành phút
                let minutes = timeInterval / 60
                self.lblTimeDelivery.rx.text.onNext("Coming within \(Int(minutes)) minutes")
            }
        })
        .disposed(by: rx.disposeBag)
    }
    
    func requestLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
    }
    
    func addAnnotationsAndRoute(response: DeliveryStatusResponse) {
        let startCoordinate = CLLocationCoordinate2D(
            latitude: response.data?.pickupLocation?.latitude ?? 0.0,
            longitude: response.data?.pickupLocation?.longitude ?? 0.0
        ) // Điểm bắt đầu
        
        let driverCoordinate = CLLocationCoordinate2D(
            latitude: response.data?.currentDriverLocation?.latitude ?? 0.0,
            longitude: response.data?.currentDriverLocation?.longitude ?? 0.0
        )
        
        let endCoordinate = CLLocationCoordinate2D(
            latitude: response.data?.deliveryLocation?.latitude ?? 0.0,
            longitude: response.data?.deliveryLocation?.longitude ?? 0.0
        )   // Điểm kết thúc
        
        // Thêm annotations
        addAnotation(coordinate: startCoordinate, title: "Pickup Location")
        addAnotation(coordinate: driverCoordinate, title: "Driver Location")
        addAnotation(coordinate: endCoordinate, title: "Delivery Location")
        addCircle(at: startCoordinate, radius: 6)
        addCircle(at: endCoordinate, radius: 6)
        
        let mapPoint = [
            response.data?.pickupLocation,
            response.data?.deliveryLocation,
        ].compactMap { $0 }
        
        drawRouteForThreePoints(mapPoints: mapPoint)
    }
    
    func addAnotation(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func addCircle(at coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let circle = MKCircle(center: coordinate, radius: radius)
        mapView.addOverlay(circle)
    }
    
    func drawRouteForThreePoints(mapPoints: [DeliveryStatusResponse.Data.Location]) {
        guard mapPoints.count == 2 else { return }
        
        let coordinates = mapPoints.map { CLLocationCoordinate2D(latitude: $0.latitude!, longitude: $0.longitude!) }
        let sourceCoordinate = coordinates[0]
//        let middleCoordinate = coordinates[1]
        let destinationCoordinate = coordinates[1]
        
        // Xóa các overlay cũ
        mapView.removeOverlays(mapView.overlays.filter { !( $0 is MKCircle) })
        
        // Vẽ đường từ điểm 1 -> điểm 2
        calculateRoute(from: sourceCoordinate, to: destinationCoordinate) { [weak self] route1 in
            guard let self = self, let route1 = route1 else { return }
            self.mapView.addOverlay(route1.polyline)

            self.zoomToFitAnnotations(mapPoints: mapPoints)
        }
    }

    private func calculateRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (MKRoute?) -> Void) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionsRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionsRequest.transportType = .automobile // Sử dụng xe máy/xe hơi

        let directions = MKDirections(request: directionsRequest)
        directions.calculate { response, error in
            guard let route = response?.routes.first, error == nil else {
                print("Error calculating route: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            completion(route)
        }
    }

    
    func zoomToFitAnnotations(mapPoints: [DeliveryStatusResponse.Data.Location]) {
        guard mapPoints.count >= 2 else { return }
        
        // Lấy danh sách tọa độ và điểm giữa
        let coordinates = mapPoints.map { CLLocationCoordinate2D(latitude: $0.latitude!, longitude: $0.longitude!) }
        let middleIndex = coordinates.count / 2
        let middlePoint = coordinates[middleIndex]
        
        // Tính min và max của các tọa độ
        var minLat = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var minLng = Double.greatestFiniteMagnitude
        var maxLng = -Double.greatestFiniteMagnitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLng = min(minLng, coordinate.longitude)
            maxLng = max(maxLng, coordinate.longitude)
        }
        
        // Tính span để bao phủ tất cả các điểm
        let latSpan = max((maxLat - minLat) * 1.2, 0.01) // Đảm bảo có khoảng cách nhỏ
        let lngSpan = max((maxLng - minLng) * 1.2, 0.01)
        
        // Tính tâm trung bình và dịch xuống 1/3 màn hình
        let centerLat = (minLat + maxLat) / 2
        let centerLng = (minLng + maxLng) / 2
        let adjustedCenterLat = centerLat - latSpan * 1 / 3 // Dịch xuống 1/3 màn hình
        
        // Tạo region để hiển thị
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: adjustedCenterLat, longitude: centerLng),
            span: MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: lngSpan)
        )
        
        // Hiển thị bản đồ
        mapView.setRegion(region, animated: true)
    }
}

extension DeliveryOnGoingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor(hexString: "EF9F27")
            renderer.lineWidth = 5.0
            return renderer
        } else if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.fillColor = UIColor(hexString: "EF9F27")
            renderer.strokeColor = UIColor(hexString: "FFFFFF")
            renderer.lineWidth = 3.0
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CustomAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // Tải ảnh từ URL và xử lý
        if annotation.title == "Driver Location", let urlString = deliveryURL, let url = URL(string: urlString) {
            let imageView = UIImageView()
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor(hexString: "FFFFFF").cgColor
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder")) { result in
                switch result {
                case .success(let value):
                    // Resize và bo tròn ảnh
                    let resizedImage = self.resizeAndRoundImage(image: value.image, size: CGSize(width: 16, height: 16))
                    DispatchQueue.main.async {
                        annotationView?.image = resizedImage
                    }
                case .failure(let error):
                    print("Error loading image: \(error.localizedDescription)")
                }
            }
        }
        
        return annotationView
    }
    
    private func resizeAndRoundImage(image: UIImage, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: size)
            UIBezierPath(ovalIn: rect).addClip() // Bo tròn ảnh
            image.draw(in: rect)
        }
    }
}
