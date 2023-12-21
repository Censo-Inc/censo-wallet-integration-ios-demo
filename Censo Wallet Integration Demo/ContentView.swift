//
//  ContentView.swift
//  Censo Wallet Integration Demo
//
//  Created by Ben Holzman on 12/21/23.
//

import SwiftUI
import CensoSDK

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var errorMessage: String?
    @State var showError: Bool = false
    @State var link: String?
    @State var result: Bool?

    var body: some View {
        var identifier: UIBackgroundTaskIdentifier? = nil

        VStack() {
            Text("Censo Wallet Integration SDK Demo")
                .font(.system(.largeTitle))
                .padding()
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                result = nil
                let sdk = CensoWalletIntegration()
                do {
                    let session = try sdk.initiate(onFinished: { status in
                        result = status
                    })
                    link = try session.connect(onConnected: {
                        do {
                            try session.phrase(binaryPhrase: "66c6a14c56cd7435d51a61b5aac215824dddd81917f6f80ed10bbf037c8e3676")
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    })
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } label: {
                Text("Export Seed Phrase")
                    .font(.system(.title))
                    .tint(.primary)
                    .padding()
            }
            switch link {
            case .some(let link):
                Link(destination: URL(string: link)!, label: {
                    Text("Tap Here to Export")
                        .font(.system(.title))
                        .tint(.primary)
                        .padding()
                })
            case .none:
                EmptyView()
            }
            switch result {
            case .none:
                EmptyView()
            case .some(let result):
                HStack {
                    if result {
                        Image(systemName: "checkmark")
                            .aspectRatio(contentMode: .fit)
                            .symbolRenderingMode(.palette)
                        Text("Export Successful")
                            .font(.system(.title2))
                    } else {
                        Image(systemName: "exclamationmark.triangle")
                            .aspectRatio(contentMode: .fit)
                            .symbolRenderingMode(.palette)
                        Text("Export Failed")
                            .font(.system(.title2))
                    }
                }
                .padding()
            }
            Spacer()
        }
        .padding()
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "UNKNOWN"),
                dismissButton: .default(Text("Ok")) {
                    showError = false
                }
            )
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active, .inactive:
                if identifier != nil {
                    UIApplication.shared.endBackgroundTask(identifier!)
                }
            case .background:
                identifier = UIApplication.shared.beginBackgroundTask {
                    UIApplication.shared.endBackgroundTask(identifier!)
                }
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
