//
//  ViewModel.swift
//  lab3
//
//  Created by FergeS on 20.10.2026.
//
import Observation

@Observable
class FirstViewModel {
    private var counter = Counter()
    
    var number: Int {
        counter.number
    }
    
    func increase() {
        counter.number += 1
    }
}
