//
//  SourceCustomVectorExample.swift
//  Examples
//
//  Created by Eric Wolfe on 12/2/16.
//  Copyright © 2016 Mapbox. All rights reserved.
//

#if swift(>=3.0)
import Mapbox

@objc(SourceCustomVectorExample_Swift)

class SourceCustomVectorExample_Swift: UIViewController {

    var mapView: MGLMapView!

    override func viewDidLoad() {
	super.viewDidLoad()

	// Third party vector tile sources can be added
	// In this case we're using a custom style json (https://www.mapbox.com/mapbox-gl-style-spec/) to add a third party tile source: "https://vector.mapzen.com/osm/all/{z}/{x}/{y}.mvt
	mapView = MGLMapView(frame: view.bounds, styleURL: Bundle.main.url(forResource: "third_party_vector_style", withExtension: "json")!)

	mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

	view.addSubview(mapView)
    }
}
#endif
