import Foundation


//Очередь с приоритетом под капотом по сути оказалась кучей
struct PriorityQueue{
    
    var elementsArr: [Int] = []
    var elementsCount: Int = 0
    
    // При добавлении идём снизу-вверх
    mutating func add(addedNum: Int){
        elementsArr.append(addedNum)
        elementsCount += 1
        
        var i = elementsCount - 1
        while i > 0 {
            let parent = (i - 1) / 2
            if elementsArr[i] > elementsArr[parent] {
                swap(higherElI: parent, lowerElI: i)
                i = parent
            } else {
                break
            }
        }
    }
    
    mutating func peek()-> Int?{ //тернарный
        if elementsCount > 0{
            return elementsArr[0]
        }else{
            return nil
        }
    }
    
    //При удалении делаем swap первого и последнего и идём сверху-вниз
    mutating func remove()-> Int?{ //guard
        if elementsCount > 0{
            let removingEl = elementsArr[0]
            swap(higherElI: 0, lowerElI: elementsCount - 1)
            elementsArr.removeLast()
            elementsCount -= 1
            if(elementsCount > 0){
                heapify(currElI: 0)
            }
            return removingEl
        }else{
            return nil
        }
    }
    
    private mutating func heapify(currElI: Int){
        var largestElI = currElI
        
        let leftElI = 2 * largestElI + 1
        let rightElI = 2 * largestElI + 2
        
        if(leftElI < elementsCount){
            if(elementsArr[leftElI] > elementsArr[largestElI]){
                largestElI = leftElI
            }
        }
        
        if(rightElI < elementsCount){
            if(elementsArr[rightElI] > elementsArr[largestElI] && elementsArr[rightElI] > elementsArr[leftElI]){
                largestElI = rightElI
            }
        }
        
        if(largestElI != currElI){
            swap(higherElI: largestElI, lowerElI: currElI)
            heapify(currElI:largestElI)
        }
    }
    
    private mutating func swap(higherElI: Int, lowerElI: Int){
        let transit = elementsArr[lowerElI]
        elementsArr[lowerElI] = elementsArr[higherElI]
        elementsArr[higherElI] = transit
    }
}

var pq = PriorityQueue()
pq.add(addedNum: 23)
pq.add(addedNum: 55)
pq.add(addedNum: 45)
pq.add(addedNum: 1)
pq.add(addedNum: -10)
pq.add(addedNum: 0)
pq.peek()

print("peek")
print(pq.peek())

print("remove")
while(pq.elementsCount > 0){
    print(pq.remove())
}
