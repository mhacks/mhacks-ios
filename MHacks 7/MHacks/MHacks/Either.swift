//
//  Either.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MPowered. All rights reserved.
//

import Foundation

enum Either<T>
{
	case Value(T)
	case Error(ErrorType)
}