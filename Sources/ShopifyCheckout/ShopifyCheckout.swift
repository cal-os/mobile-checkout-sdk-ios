/*
MIT License

Copyright 2023 - Present, Shopify Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit
import SwiftUI

/// The version of the `ShopifyCheckout` library.
public let version = "0.1.0"

/// The configuration options for the `ShopifyCheckout` library.
public var configuration = Configuration() {
	didSet {
		CheckoutView.invalidate()
	}
}

/// A convienence function for configuring the `ShopifyCheckout` library.
public func configure(_ block: (inout Configuration) -> Void) {
	block(&configuration)
}

/// Preloads the checkout for faster presentation.
public func preload(checkout url: URL) {
	guard configuration.preloading.enabled else { return }
	CheckoutView.for(checkout: url).load(checkout: url)
}

/// Presents the checkout from a given `UIViewController`.
public func present(checkout url: URL, from: UIViewController, delegate: CheckoutDelegate? = nil) {
	let rootViewController = CheckoutViewController(checkoutURL: url, delegate: delegate)
	let viewController = UINavigationController(rootViewController: rootViewController)
	viewController.presentationController?.delegate = rootViewController
	from.present(viewController, animated: true)
}

struct ShopifyCheckoutView: UIViewControllerRepresentable {

    private let url: URL
    
    init(url: URL) {
        self.url = url
    }

    func makeUIViewController(context: Context) -> CheckoutViewController {
        ShopifyCheckout.configure { configuration in
            configuration.preloading.enabled = true
        }
        return CheckoutViewController(checkoutURL: url, delegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: CheckoutViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
    
    final public class Coordinator: NSObject, CheckoutDelegate {
        
        private let parent: ShopifyCheckoutView

        init(parent: ShopifyCheckoutView) {
            self.parent = parent
        }
        
        public func checkoutDidComplete() {
            
        }
        
        public func checkoutDidCancel() {
            
        }
        
        public func checkoutDidFail(error: CheckoutError) {
            
        }
    }
}

private struct URLContainer: Identifiable {
    let url: URL
    var id: Int {
        url.hashValue
    }
}

extension URL: Identifiable {
    public var id: Int {
        self.hashValue
    }
}

public extension View {
    func checkoutSheet(url: Binding<URL?>) -> some View {
        sheet(
            item: url,
            onDismiss: {
                url.wrappedValue = nil
            },
            content: { url in
                ShopifyCheckoutView(url: url)
            }
        )
    }
}
