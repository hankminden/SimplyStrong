//
//  SimplyStrongProducts.swift
//  Simply Strong
//
//  Created by Henry Minden on 10/21/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import Foundation

import Foundation

public struct SimplyStrongProducts {
  
  public static let UnlockFullVersion = "simply_strong_iap_0"
  
  private static let productIdentifiers: Set<ProductIdentifier> = [SimplyStrongProducts.UnlockFullVersion]

  public static let store = IAPManager(productIds: SimplyStrongProducts.productIdentifiers)
    
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier
}
