//
//  PersistenceEntityExtenstion.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 11/28/21.
//

import CoreData
import CoreLocation
import MapKit
import SwiftUI

extension PositionEntity {
	
	static func allPositionsFetchRequest() -> NSFetchRequest<PositionEntity> {
		let request: NSFetchRequest<PositionEntity> = PositionEntity.fetchRequest()
		request.fetchLimit = 200
		//request.fetchBatchSize = 1
		request.returnsObjectsAsFaults = false
		request.includesSubentities = true
		request.returnsDistinctResults = true
		request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
		let positionPredicate = NSPredicate(format: "nodePosition != nil && (nodePosition.user.shortName != nil || nodePosition.user.shortName != '') && latest == true && time >= %@", Calendar.current.date(byAdding: .day, value: -2, to: Date())! as NSDate)
		
		let pointOfInterest = LocationHelper.currentLocation
		
		if pointOfInterest.latitude != LocationHelper.DefaultLocation.latitude && pointOfInterest.longitude != LocationHelper.DefaultLocation.longitude {
			let D: Double = UserDefaults.meshMapDistance * 1.1
			let R: Double = 6371009
			let meanLatitidue = pointOfInterest.latitude * .pi / 180
			let deltaLatitude = D / R * 180 / .pi
			let deltaLongitude = D / (R * cos(meanLatitidue)) * 180 / .pi
			let minLatitude: Double = pointOfInterest.latitude - deltaLatitude
			let maxLatitude: Double = pointOfInterest.latitude + deltaLatitude
			let minLongitude: Double = pointOfInterest.longitude - deltaLongitude
			let maxLongitude: Double = pointOfInterest.longitude + deltaLongitude
			let distancePredicate = NSPredicate(format: "(%lf <= (longitudeI / 1e7)) AND ((longitudeI / 1e7) <= %lf) AND (%lf <= (latitudeI / 1e7)) AND ((latitudeI / 1e7) <= %lf)", minLongitude, maxLongitude,minLatitude, maxLatitude)
			request.predicate = NSCompoundPredicate(type: .and, subpredicates: [positionPredicate, distancePredicate])
		} else {
			request.predicate = positionPredicate
		}
		return request
	}

	var latitude: Double? {

		let d = Double(latitudeI)
		if d == 0 {
			return 0
		}
		return d / 1e7
	}

	var longitude: Double? {

		let d = Double(longitudeI)
		if d == 0 {
			return 0
		}
		return d / 1e7
	}

	var nodeCoordinate: CLLocationCoordinate2D? {
		if latitudeI != 0 && longitudeI != 0 {
			let coord = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
			return coord
		} else {
		   return nil
		}
	}

	var nodeLocation: CLLocation? {
		if latitudeI != 0 && longitudeI != 0 {
			let location = CLLocation(latitude: latitude!, longitude: longitude!)
			return location
		} else {
		   return nil
		}
	}

	var annotaton: MKPointAnnotation {
		let pointAnn = MKPointAnnotation()
		if nodeCoordinate != nil {
			pointAnn.coordinate = nodeCoordinate!
		}
		return pointAnn
	}
}

extension PositionEntity: MKAnnotation {
	public var coordinate: CLLocationCoordinate2D { nodeCoordinate ?? LocationHelper.DefaultLocation }
	public var title: String? {  nodePosition?.user?.shortName ?? "unknown".localized }
	public var subtitle: String? {  time?.formatted() }
}
