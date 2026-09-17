import SwiftUI
import SceneKit

struct VirtualForestView: View {
    @State private var selectedNodeName: String? = nil
    
    var body: some View {
        ZStack {
            VirtualForestSceneView(selectedNodeName: $selectedNodeName)
                .ignoresSafeArea()
            
            if let nodeName = selectedNodeName {
                VStack {
                    Spacer()
                    Text("Selected: \(nodeName)")
                        .font(.headline)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

// MARK: - SceneKit UIViewRepresentable Wrapper
struct VirtualForestSceneView: UIViewRepresentable {
    @Binding var selectedNodeName: String?
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createForestScene()
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor.systemBackground
        
        // Add tap gesture recognizer for node hit-testing
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        scnView.addGestureRecognizer(tapGesture)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Scene Setup
    private func createForestScene() -> SCNScene {
        let scene = SCNScene()
        
        // Camera setup
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi / 6, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // Ambient Light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 400
        scene.rootNode.addChildNode(ambientLight)
        
        // Directional Light (Sunlight)
        let sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.type = .directional
        sunLight.light?.intensity = 800
        sunLight.position = SCNVector3(x: 10, y: 15, z: 10)
        sunLight.eulerAngles = SCNVector3(x: -Float.pi / 3, y: Float.pi / 4, z: 0)
        scene.rootNode.addChildNode(sunLight)
        
        // Ground Floor
        let floorGeometry = SCNFloor()
        floorGeometry.firstMaterial?.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.6)
        let floorNode = SCNNode(geometry: floorGeometry)
        scene.rootNode.addChildNode(floorNode)
        
        // Sample Trees
        let positions: [SCNVector3] = [
            SCNVector3(-2, 0, -2),
            SCNVector3(2, 0, -4),
            SCNVector3(0, 0, -6),
            SCNVector3(-3, 0, -8)
        ]
        
        for (index, pos) in positions.enumerated() {
            let treeNode = createTreeContainerNode(name: "Tree_\(index + 1)")
            treeNode.position = pos
            scene.rootNode.addChildNode(treeNode)
        }
        
        return scene
    }
    
    private func createTreeContainerNode(name: String) -> SCNNode {
        let container = SCNNode()
        container.name = name
        
        // Trunk
        let trunkGeo = SCNCylinder(radius: 0.2, height: 1.5)
        trunkGeo.firstMaterial?.diffuse.contents = UIColor.brown
        let trunkNode = SCNNode(geometry: trunkGeo)
        trunkNode.position = SCNVector3(0, 0.75, 0)
        container.addChildNode(trunkNode)
        
        // Foliage
        let foliageGeo = SCNCone(topRadius: 0, bottomRadius: 1.0, height: 2.0)
        foliageGeo.firstMaterial?.diffuse.contents = UIColor.systemGreen
        let foliageNode = SCNNode(geometry: foliageGeo)
        foliageNode.position = SCNVector3(0, 2.25, 0)
        container.addChildNode(foliageNode)
        
        return container
    }
    
    // MARK: - Tap Coordinator
    class Coordinator: NSObject {
        var parent: VirtualForestSceneView
        
        init(_ parent: VirtualForestSceneView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            guard let scnView = gestureRecognize.view as? SCNView else { return }
            let location = gestureRecognize.location(in: scnView)
            
            // Fixed: SceneKit automatically searches child nodes when options is nil
            let hitResults = scnView.hitTest(location, options: nil)
            
            if let firstHit = hitResults.first {
                // Traverse up to find named root tree container if hit node is geometry child
                var currentNode: SCNNode? = firstHit.node
                while currentNode != nil && currentNode?.name == nil {
                    currentNode = currentNode?.parent
                }
                
                DispatchQueue.main.async {
                    self.parent.selectedNodeName = currentNode?.name ?? firstHit.node.name ?? "Unknown Object"
                }
            } else {
                DispatchQueue.main.async {
                    self.parent.selectedNodeName = nil
                }
            }
        }
    }
}

#Preview {
    VirtualForestView()
}
