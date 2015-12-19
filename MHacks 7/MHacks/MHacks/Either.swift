//
//  Either.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import Foundation

enum Either<T>
{
	case Value(T)
	case NetworkingError(NSError)
	case UnknownError
}