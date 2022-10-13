//
//  SaveChannelQRCode.swift
//  Meshtastic
//
//  Copyright(c) Garth Vander Houwen 7/13/22.
//
import SwiftUI

struct SaveChannelQRCode: View {
	var channelHash: String
	
	var body: some View {
		VStack {
			Text("Save Channel Settings?")
				.font(.title)
			Text("These settings will replace the current LoRa Config and Channel Settings on your radio. After everything saves your device will reboot.")
				.foregroundColor(.gray)
				.font(.callout)
				.padding()
			Text(channelHash)
				.font(.caption2)
				.foregroundColor(.gray)
				.padding()
			
			Button {
				
			} label: {
				
				Label("Save", systemImage: "square.and.arrow.down")
			}
			.buttonStyle(.bordered)
			.buttonBorderShape(.capsule)
			.controlSize(.large)
			.padding()
		}
		.onChange(of: channelHash) { newSettings in
			var decodedString = newSettings.base64urlToBase64()
			if let decodedData = Data(base64Encoded: decodedString) {
				do {
					var channelSet: ChannelSet = try ChannelSet(serializedData: decodedData)
					print(channelSet)
				} catch {
					print("Invalid Meshtastic QR Code Link")
				}
			}
		}
	}
}
