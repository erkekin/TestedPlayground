//: Playground - noun: a place where people can play

import XCTest
import XCPlayground

class Node<E, T:EmptyInitable>:CustomStringConvertible{
    let key:E
    var output:T = T()
    init(_ key:E) {
        self.key = key
    }

    var description:String{return "\(self.key)"}
}

struct MultipleOutput<T>:EmptyInitable{
    
    var outputs:[Node<T, MultipleOutput<T>>]? = nil
    
}
struct BinaryOutput<T>:EmptyInitable{
    
    var left: Node<T, BinaryOutput<T>>? = nil
    var right:Node<T, BinaryOutput<T>>? = nil
    
    var hasOneLeaf:Node<T, BinaryOutput<T>>?{
        
        let a = [right, left].flatMap{$0}
        if a.count == 1{return a.first!}else{return nil}
        
    }
    
    var isLeaf:Bool{ return left == nil && right == nil }
    var isFull:Bool{ return left != nil && right != nil }
    
}

struct UnaryOutput<T>:EmptyInitable{
    
    var next:Node<T, UnaryOutput<T>>? = nil
    
}
protocol EmptyInitable{

    init()
    
}

extension LinkedList:CustomStringConvertible{
    
    var description:String{
        var keys = [String]()
        var current = root
        while current != nil {
            keys.append("(\(current!.key))")
            current = current!.output.next
        }
        
        return keys.joined(separator: " -> ")
        
    }
    
}
struct LinkedList<N>{
    var root:Node<N, UnaryOutput<N>>? = nil
    
    var last:Node<N, UnaryOutput<N>>?{
        var current = root
        while current != nil {
            if current?.output.next == nil {
                return current
            }
            
            current = current?.output.next
        }
        
        return nil
    }
    
    mutating func append(_ element:N){
        let newRoot = Node<N, UnaryOutput<N>>(element)
        guard let _ = root else{
            self.root = newRoot
            return
        }
        last?.output.next = newRoot
    }
    
    mutating func insert(element:N, after node:Node<N, UnaryOutput<N>>){
        let newRoot = Node<N, UnaryOutput<N>>(element)
        newRoot.output.next = node.output.next
        node.output.next = newRoot
    }
    
    mutating func remove(after node:Node<N, UnaryOutput<N>>){
        node.output.next = node.output.next?.output.next
    }
    mutating func insertBeginning(_ element:N){
        let newRoot = Node<N, UnaryOutput<N>>(element)
        newRoot.output.next = root
        root = newRoot
    }
    mutating func removeBeginning(){
        root = root?.output.next
    }
    mutating func removeLast(){
        
        guard let _ = root?.output.next else {
            root = nil
            return}
        
        var current = root
        
        while current != nil {
            if current?.output.next?.output.next == nil {
                current?.output.next = nil
                break
            }
            current = current?.output.next
        }
        
    }
}

struct Queue<S> {
    var linkedlist = LinkedList<S>()
    mutating func enqueue(_ element:S){ linkedlist.append(element) }
    mutating func dequeue(){ linkedlist.removeLast() }
}

struct Stack<S> {
    
    var linkedlist = LinkedList<S>()
    mutating func push(_ element:S){ linkedlist.append(element) }
    
    mutating func pop() -> S?  {
        
        guard let last = linkedlist.last else {return nil}
        linkedlist.removeLast()
        
        return last.key
    }
    
    var top:S? { return linkedlist.last?.key  }
}

enum TraverseMethod{
    case preorder, inorder, postorder
}

struct Traverser<T>{
    var nodes = [Node<T, BinaryOutput<T>>]()
    let method:TraverseMethod
    let process:(Node<T, BinaryOutput<T>>) -> ()
    
    init(method:TraverseMethod, process:@escaping (Node<T, BinaryOutput<T>>) -> ()) {
        self.process = process
        self.method = method
    }
    
    mutating func preorder(_ node: Node<T, BinaryOutput<T>>){
        
        process(node)
        nodes.append(node)
        traverse(node.output.left)
        traverse(node.output.right)
        
    }
    
    mutating func inorder(_ node: Node<T, BinaryOutput<T>>){
        
        traverse(node.output.left)
        process(node)
        nodes.append(node)
        traverse(node.output.right)
        
    }
    
    mutating func postorder(_ node: Node<T, BinaryOutput<T>>){
        
        traverse(node.output.left)
        traverse(node.output.right)
        process(node)
        nodes.append(node)
        
    }
    
    mutating func traverse(_ node:Node<T, BinaryOutput<T>>?){
        guard let node = node else {return}
        
        switch method {
        case .preorder:
            preorder(node)
        case .inorder:
            inorder(node)
        case .postorder:
            postorder(node)
        }
    }
    
}


struct BinaryTree<T:Comparable>{
    
    init(_ elements: [T]) {
        elements.forEach{insert($0) }
    }
    
    var root:Node<T, BinaryOutput<T>>? = nil
    var numberOfLeaves:Int{
        var _numberOfLeaves = 0
        var traverser = Traverser<T>(method:.preorder, process: {node in
            _numberOfLeaves += node.output.isLeaf ? 1 : 0
        })
        traverser.traverse(root)
        return _numberOfLeaves
        
    }
    mutating func insert(_ element:T){
        root = insert(element, to: root)
    }
    func print(method:TraverseMethod)->[T]{
        var traverser = Traverser<T>(method:method, process: {node in
            // you can use any node here
        })
        traverser.traverse(root)
        return traverser.nodes.map{$0.key}
    }
    
    var height:Int{
        return height(root)
    }
    
    private func height(_ node:Node<T, BinaryOutput<T>>?) -> Int{
        guard let node = node else{return 0}
        return 1 + max( height(node.output.left), height(node.output.right))
    }
    
    func search(_ element:T) -> Node<T, BinaryOutput<T>>?{
        return search(root, element: element)
    }
    
    private func search(_ node:Node<T, BinaryOutput<T>>?, element:T) -> Node<T, BinaryOutput<T>>?{
        guard let node = node else{return nil}
        if node.key < element
        {return search(node.output.right, element:element)}
        else if node.key > element
        {return search(node.output.left, element:element)}
        else {return node}
    }
    
    
    func findMax(_ node:Node<T, BinaryOutput<T>>?) -> Node<T, BinaryOutput<T>>?{
        guard let node = node else{return nil}
        if node.output.isLeaf {
            return node
        }
        return findMax(node.output.right)
    }
    
    func findParentOf(_ element:T) -> Node<T, BinaryOutput<T>>?{
        return findParentOf(root, element:element)
        
    }
    
    private func findParentOf(_ node:Node<T, BinaryOutput<T>>?, element:T) -> Node<T, BinaryOutput<T>>?{
        guard let node = node else{return nil}
        if let left = node.output.left, left.key == element {
            return node
        }else if let right = node.output.right, right.key == element {
            return node
        }
        
        if node.key < element{
            
            return findParentOf(node.output.right, element: element)
        }else{
            return findParentOf(node.output.left, element: element)
        }
        
    }
    mutating func delete(_ element:T) -> Bool{
        guard let deletingNode = search(element) else{return false}
        return delete(root, deletingNode: deletingNode)
    }
    
    mutating private func delete(_ node:Node<T, BinaryOutput<T>>?, deletingNode:Node<T, BinaryOutput<T>>) -> Bool{
        guard let node = node else{return false}
        guard root?.key != deletingNode.key else{
            
            let root = self.root!
            let maxDescendant = findMax(root.output.left)
            let maxDescendentParent = findParentOf(maxDescendant!.key)
            maxDescendant?.output.right = root.output.right
            if maxDescendant?.key != maxDescendentParent?.output.left?.key{
                maxDescendant?.output.left = root.output.left
            }
            maxDescendentParent?.output.right = nil
            self.root = maxDescendant
            
            return true
        }
        
        if let leftNode = node.output.left, leftNode.key == deletingNode.key{
            if leftNode.output.isLeaf {
                node.output.left = nil
            }else if let leaf = leftNode.output.hasOneLeaf{
                node.output.left = leaf
                
            }else if leftNode.output.isFull{
                let maxDescendant = findMax(leftNode.output.left)
                let maxDescendentParent = findParentOf(maxDescendant!.key)
                maxDescendant?.output.right = leftNode.output.right
                if maxDescendant?.key != maxDescendentParent?.output.left?.key{
                    maxDescendant?.output.left = leftNode.output.left
                }
                maxDescendentParent?.output.right = nil
                node.output.left = maxDescendant
                
            }
            return true
        }else if let rightNode = node.output.right, rightNode.key == deletingNode.key{
            if rightNode.output.isLeaf {
                node.output.right = nil
            }else if let leaf = rightNode.output.hasOneLeaf{
                node.output.right = leaf
            }else if rightNode.output.isFull{
                // find max keyed node in left subtree and swap it.
                // then delete big one
                
                let maxDescendant = findMax(rightNode.output.left)
                let maxDescendentParent = findParentOf(maxDescendant!.key)
                maxDescendant?.output.right = rightNode.output.right
                
                if maxDescendant?.key != maxDescendentParent?.output.left?.key{
                    maxDescendant?.output.left = rightNode.output.left
                }
                
                maxDescendentParent?.output.right = nil
                node.output.right = maxDescendant
                
            }
            return true
        }
        if node.key == deletingNode.key {
            return true
        }else if node.key < deletingNode.key {
            return delete(node.output.right, deletingNode: deletingNode)
        }else if node.key > deletingNode.key {
            return delete(node.output.left, deletingNode: deletingNode)
        }else{return false}
        
    }
    
    mutating func insert(_ element:T, to node:Node<T, BinaryOutput<T>>?) -> Node<T, BinaryOutput<T>>{
        guard let node = node else{
            let newNode = Node<T, BinaryOutput<T>>(element)
            return newNode
        }
        
        if node.key == element{
            return node
        }
        
        if node.key > element {
            node.output.left = insert(element, to: node.output.left)
        }else{
            node.output.right = insert(element, to: node.output.right)
        }
        
        return node
    }
    
}

class TestedPlayground: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
        func testLinkedList(){
            var linkedList = LinkedList<Int>()
            linkedList.append(1)
            XCTAssert(linkedList.last?.key == 1)
            linkedList.append(2)
            XCTAssert(linkedList.last?.key == 2)
            linkedList.insert(element: 3, after: linkedList.root!)
            XCTAssert(linkedList.last?.key == 2)
            linkedList.append(4)
            XCTAssert(linkedList.last?.key == 4)
            linkedList.remove(after: linkedList.root!)
            XCTAssert(linkedList.root?.output.next?.key == 2)
            linkedList.removeBeginning()
            XCTAssert(linkedList.root?.key == 2)
            linkedList.removeLast()
            XCTAssert(linkedList.last!.key == 2)
            linkedList.insertBeginning(5)
            XCTAssert(linkedList.root?.key == 5)
        }
    
        func testStack(){
            var stack = Stack<Int>()
            stack.push(1)
            stack.linkedlist
            stack.push(2)
            stack.linkedlist
            XCTAssert(stack.top == 2)
            stack.linkedlist
            XCTAssert(stack.pop() == 2)
            stack.linkedlist
            XCTAssert(stack.pop() == 1)
            stack.linkedlist
            stack.push(2)
            stack.linkedlist
            XCTAssert(stack.top == 2)
            stack.linkedlist
            stack.pop()
            stack.linkedlist
            XCTAssert(stack.top == nil)
        }
    
        func testQueue(){
            var queue = Queue<Int>()
            queue.enqueue(1)
            queue.enqueue(2)
            queue.enqueue(3)
            queue.linkedlist
            queue.dequeue()
            queue.linkedlist
            queue.dequeue()
            queue.linkedlist
            queue.dequeue()
            queue.linkedlist
        }
        func testBinaryTreePart2(){
            var binaryTree = BinaryTree<Int>( [11, 6, 8, 19, 4, 10, 5, 17, 43, 49, 31,16,18])
    
            // DELETE
            // node is full
            binaryTree.delete(6)
            XCTAssert(binaryTree.print(method: .preorder) == [11, 5, 4, 8, 10, 19, 17, 16, 18, 43, 31, 49])
    
    
            binaryTree.delete(19)
            XCTAssert(binaryTree.print(method: .preorder) == [11, 5, 4, 8, 10, 18, 17, 16, 43, 31, 49])
    
        }
    
        func testBinaryTreePart1(){
            var binaryTree = BinaryTree<Int>( [11, 6, 8, 19, 4, 10, 5, 17, 43, 49, 31])
            binaryTree.insert(11)
            XCTAssert( binaryTree.numberOfLeaves == 5 )
            XCTAssert( binaryTree.height == 4 )
    
            XCTAssert( binaryTree.print(method: .preorder) == [11, 6, 4, 5, 8, 10, 19, 17, 43, 31, 49])
            XCTAssert( binaryTree.print(method: .inorder) == [4, 5, 6, 8, 10, 11, 17, 19, 31, 43, 49]) // ordered
            XCTAssert( binaryTree.print(method: .postorder) == [5, 4, 10, 8, 6, 17, 31, 49, 43, 19, 11])
            XCTAssert( binaryTree.numberOfLeaves == 5 )
            XCTAssert( binaryTree.height == 4 )
    
            let found = binaryTree.search(19)
            XCTAssert( found?.key == 19)
    
    
            // DELETE
            // node is leaf
            let fourty_nine = binaryTree.delete(49)
            XCTAssert(binaryTree.print(method: .preorder) == [11, 6, 4, 5, 8, 10, 19, 17, 43, 31])
    
            XCTAssert( fourty_nine == true)
            XCTAssert( binaryTree.delete(49) == false)
            binaryTree.insert(49)
    
            //        // node has only one leaf
            let four = binaryTree.delete(4)
    
            XCTAssert( four == true)
            let fourAgain = binaryTree.delete(4)
            XCTAssert( fourAgain == false)
            // node has only one leaf
            let five = binaryTree.delete(5)
            XCTAssert( five == true)
            let fiveAgain = binaryTree.delete(5)
            XCTAssert( fiveAgain == false)
            // node has only one leaf
            let eight = binaryTree.delete(8)
            XCTAssert( eight == true)
            let eightAgain = binaryTree.delete(8)
            XCTAssert( eightAgain == false)
    
            // node has only one leaf
            binaryTree.delete(43)
            XCTAssert(binaryTree.findParentOf(31)?.key == 19)
            XCTAssert( binaryTree.search(43) == nil)
    
            XCTAssert(binaryTree.findParentOf(31)?.key == 19)
            XCTAssert(binaryTree.findParentOf(49)?.key == 31)
    
        }
    
        func testBinaryTreeDeleteRoot(){
            var binaryTree = BinaryTree<Int>([11, 6, 8, 19, 4, 10, 5, 17, 43, 49, 31])
    
            binaryTree.delete(11)
            XCTAssert(binaryTree.print(method: .preorder) == [10, 6, 4, 5, 8, 19, 17, 43, 31, 49])
        }
}

TestedPlayground.defaultTestSuite().run()
