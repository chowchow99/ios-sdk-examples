//
//  RuntimeMultipleAnnotationsExample2.3.swift
//  Examples
//
//  Created by Eric Wolfe on 12/2/16.
//  Copyright © 2016 Mapbox. All rights reserved.
//

#if !swift(>=3.0)
import Mapbox

@objc(RuntimeMultipleAnnotationsExample_Swift)

class RuntimeMultipleAnnotationsExample_Swift: UIViewController, MGLMapViewDelegate {
    var mapView: MGLMapView!

    override func viewDidLoad() {
	super.viewDidLoad()

	let mapView = MGLMapView(frame: view.bounds)
	mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

	mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 37.090240, longitude: -95.712891), zoomLevel: 2, animated: false)

	mapView.delegate = self

	view.addSubview(mapView)

	// Add our own gesture recognizer to handle taps on our custom map features
	mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:))))

	self.mapView = mapView
    }

    func mapView(mapView: MGLMapView, didFinishLoadingStyle style: MGLStyle) {
	self.fetchPoints(withCompletion: { (features) in
	    self.addItemsToMap(features)
	})
    }

    func addItemsToMap(features: [MGLFeature]) {
	// You can add custom UIImages to the map style
	// These can be referenced by an MGLSymbolStyleLayer's iconImage property
	let lighthouseIcon = UIImage(named: "lighthouse")!
	self.mapView.style().setImage(lighthouseIcon, forName: "lighthouse")

	// Add the features to the map as a GeoJSONSource
	let source = MGLGeoJSONSource(identifier: "lighthouses", features: features, options: nil)
	self.mapView.style().addSource(source)

	let lighthouseColor = UIColor(red: 0.08, green: 0.44, blue: 0.96, alpha: 1.0)

	// Use MGLCircleStyleLayer to represent the points with simple circles
	// In this case, we can use style functions to gradually change properties between zoom level 2 and 7: the circle opacity from 50% to 100% and the circle radius from 2px to 3px
	let circles = MGLCircleStyleLayer(identifier: "lighthouse-circles", source: source)
	circles.circleColor = MGLStyleValue(rawValue: lighthouseColor)
	circles.circleOpacity = MGLStyleValue(stops: [
	    2: MGLStyleValue(rawValue: 0.5),
	    7: MGLStyleValue(rawValue: 1),
	])
	circles.circleRadius = MGLStyleValue(stops: [
	    2: MGLStyleValue(rawValue: 2),
	    7: MGLStyleValue(rawValue: 3),
	])

	// Use MGLSymbolStyleLayer for more complex styling of points including custom icons and text rendering
	let symbols = MGLSymbolStyleLayer(identifier: "lighthouse-symbols", source: source)
	symbols.iconImage = MGLStyleValue(rawValue: "lighthouse")
	symbols.iconSize = MGLStyleValue(rawValue: 0.5)
	symbols.iconOpacity = MGLStyleValue(stops: [
	    5.9: MGLStyleValue(rawValue: 0),
	    6: MGLStyleValue(rawValue: 1)
	])
	symbols.iconHaloColor = MGLStyleValue(rawValue: UIColor.whiteColor().colorWithAlphaComponent(0.5))
	symbols.iconHaloWidth = MGLStyleValue(rawValue: 1)
	// {name} references the "name" key in an MGLPointFeature's attributes dictionary
	symbols.textField = MGLStyleValue(rawValue: "{name}")
	symbols.textColor = symbols.iconColor
	symbols.textSize = MGLStyleValue(stops: [
	    10: MGLStyleValue(rawValue: 10),
	    16: MGLStyleValue(rawValue: 16)
	])
	symbols.textTranslate = MGLStyleValue(rawValue: NSValue(CGVector: CGVectorMake(10, 0)))
	symbols.textOpacity = symbols.iconOpacity
	symbols.textHaloColor = symbols.iconHaloColor
	symbols.textHaloWidth = symbols.iconHaloWidth
	symbols.textJustify = MGLStyleValue(rawValue: NSValue(MGLTextJustify: .Left))
	symbols.textAnchor = MGLStyleValue(rawValue: NSValue(MGLTextAnchor: .Left))

	self.mapView.style().addLayer(circles)
	self.mapView.style().addLayer(symbols)
    }

    // MARK: - Feature interaction
    func handleMapTap(sender: UITapGestureRecognizer) {
	if sender.state == .Ended {
	    // Limit feature selection to just the following layer identifiers
	    let layerIdentifiers = ["lighthouse-symbols", "lighthouse-circles"]

	    // Try matching the exact point first
	    let point = sender.locationInView(sender.view!)
	    for f in mapView.visibleFeatures(at: point, styleLayerIdentifiers: Set(layerIdentifiers)) {
		if let f = f as? MGLPointFeature {
		    self.showCallout(f)
		    return
		}
	    }

	    let touchCoordinate = mapView.convertPoint(point, toCoordinateFromView: sender.view!)
	    let touchLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)

	    // Otherwise, get all features within a rect the size of a touch (44x44)
	    let touchRect = CGRect(origin: point, size: .zero).insetBy(dx: -22.0, dy: -22.0)
	    var possibleFeatures = [MGLPointFeature]()
	    for f in mapView.visibleFeatures(in: touchRect, styleLayerIdentifiers: Set(layerIdentifiers)) {
		if let f = f as? MGLPointFeature {
		    possibleFeatures.append(f)
		}
	    }

	    // Select the closest feature to the touch center
	    let closestFeatures = possibleFeatures.sort({ (a, b) -> Bool in
		return CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude).distanceFromLocation(touchLocation) < CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude).distanceFromLocation(touchLocation)
	    })
	    if let f = closestFeatures.first {
		self.showCallout(f)
		return
	    }

	    // If no features were found, deselect the selected annotation, if any
	    self.mapView.deselectAnnotation(self.mapView.selectedAnnotations.first, animated: true)
	}
    }

    func showCallout(feature: MGLPointFeature) {
	let point = MGLPointFeature()
	point.title = feature.attributes["name"] as? String
	point.coordinate = feature.coordinate

	// Selecting an feature that doesn't already exist on the map will add a new annotation view
	// We'll need to use the map's delegate methods to add an empty annotation view and remove it when we're done selecting it
	mapView.selectAnnotation(point, animated: true)
    }

    // MARK: - MGLMapViewDelegate

    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
	return true
    }

    func mapView(mapView: MGLMapView, didDeselectAnnotation annotation: MGLAnnotation) {
	mapView.removeAnnotations([annotation])
    }

    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
	return MGLAnnotationView()
    }

    // MARK: - Data fetching and parsing

    func fetchPoints(withCompletion completion: (([MGLFeature]) -> Void)) {
	// Wikidata query for all lighthouses in the United States: https://query.wikidata.org/#%23added%20before%202016-10%0A%23defaultView%3AMap%0ASELECT%20DISTINCT%20%3Fitem%20%3FitemLabel%20%3Fcoor%20%3Fimage%0AWHERE%0A%7B%0A%09%3Fitem%20wdt%3AP31%20wd%3AQ39715%20.%20%0A%09%3Fitem%20wdt%3AP17%20wd%3AQ30%20.%0A%09%3Fitem%20wdt%3AP625%20%3Fcoor%20.%0A%09OPTIONAL%20%7B%20%3Fitem%20wdt%3AP18%20%3Fimage%20%7D%20%20%0A%09SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22en%22%20%20%7D%20%20%0A%7D%0AORDER%20BY%20%3FitemLabel
	let query = "SELECT DISTINCT ?item " +
	    "?itemLabel ?coor ?image " +
	    "WHERE " +
	    "{ " +
		"?item wdt:P31 wd:Q39715 . " +
		"?item wdt:P17 wd:Q30 . " +
		"?item wdt:P625 ?coor . " +
		"OPTIONAL { ?item wdt:P18 ?image } . " +
		"SERVICE wikibase:label { bd:serviceParam wikibase:language \"en\" } " +
	    "} " +
	    "ORDER BY ?itemLabel"

	let characterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
	characterSet.removeCharactersInString("?")
	characterSet.removeCharactersInString("&")
	characterSet.removeCharactersInString(":")

	let encodedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!

	let request = NSURLRequest(URL: NSURL(string: "https://query.wikidata.org/sparql?query=\(encodedQuery)&format=json")!)

	NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
	    guard let data = data else { return }
	    guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) else { return }
	    guard let results = json["results"] as? [String: AnyObject] else { return }
	    guard let items = results["bindings"] as? [[String: AnyObject]] else { return }
	    dispatch_async(dispatch_get_main_queue(), {
		completion(self.parseJSONItems(items))
	    })
	}).resume()
    }

    func parseJSONItems(items: [[String: AnyObject]]) -> [MGLFeature] {
	var features = [MGLFeature]()
	for item in items {
	    guard let label = item["itemLabel"] as? [String: AnyObject],
		let title = label["value"] as? String else { continue }
	    guard let coor = item["coor"] as? [String: AnyObject],
		let point = coor["value"] as? String else { continue }
	    let parsedPoint = point.stringByReplacingOccurrencesOfString("Point(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "")
	    let pointComponents = parsedPoint.componentsSeparatedByString(" ")
	    let coordinate = CLLocationCoordinate2D(latitude: Double(pointComponents[1])!, longitude: Double(pointComponents[0])!)
	    let feature = MGLPointFeature()
	    feature.coordinate = coordinate
	    feature.title = title
	    // A feature's attributes can used by runtime styling for things like text labels
	    feature.attributes = [
		"name": title,
	    ]
	    features.append(feature)
	}
	return features
    }
}
#endif
