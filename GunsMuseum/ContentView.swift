import UIKit
import ARKit
import AVFoundation

struct ARObject {
    let name: String        // Nome legível para o usuário
    let filename: String    // Nome do arquivo de modelo 3D
    let scale: SCNVector3   // Escala do objeto 3D
    let description: String // Descrição do objeto
}
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var sceneView: ARSCNView!
    var currentObject: SCNNode? // Propriedade para armazenar o objeto atual
    var lightNode1: SCNNode? // Propriedade para armazenar a luz
    var lightNode2: SCNNode? // Propriedade para armazenar a luz
    var toggleButton: UIButton! // Adicionada a propriedade toggleButton
    var soundButton: UIButton!
    var audioPlayer: AVAudioPlayer?

    
    // Array de objetos AR com seus respectivos nomes, escalas e descrições
    let objectOptions: [ARObject] = [
        ARObject(
            name: "Espingarda Marlin",
            filename: "shotgun",
            scale: SCNVector3(0.001, 0.001, 0.001),
            description: "A Marlin é uma espingarda de repetição americana desenvolvida no final do século XIX. Sua construção robusta e precisão a tornaram um sucesso entre caçadores e atiradores esportivos. Este modelo destaca-se pela alta confiabilidade e fácil manutenção, sendo utilizada por várias gerações. Popular nos Estados Unidos, é considerada uma arma icônica para caça e defesa rural."
        ),
        ARObject(
            name: "Fuzil AK-47",
            filename: "ak47",
            scale: SCNVector3(0.001, 0.001, 0.001),
            description: "Desenvolvido por Mikhail Kalashnikov em 1947, o AK-47 é um dos fuzis de assalto mais famosos do mundo. A arma é conhecida por sua simplicidade, durabilidade e eficácia em diferentes condições, de desertos a florestas tropicais. Utilizado amplamente em conflitos ao redor do globo, o AK-47 tornou-se um símbolo de revoluções e é frequentemente associado a sua longa durabilidade e confiabilidade extrema."
        ),
        ARObject(
            name: "Pistola Desert Eagle",
            filename: "eagle",
            scale: SCNVector3(0.008, 0.008, 0.008),
            description: "Introduzida na década de 1980, a Desert Eagle é uma pistola semi-automática de alto calibre conhecida pelo seu design imponente e poder de fogo. Fabricada inicialmente em Israel e nos Estados Unidos, ela tornou-se popular em filmes e videogames devido ao seu porte robusto e som característico. A arma é frequentemente vista como uma peça de luxo para colecionadores e entusiastas de armas de fogo."
        ),
        ARObject(
            name: "Submetralhadora MP7",
            filename: "mp7",
            scale: SCNVector3(0.001, 0.001, 0.001),
            description: "Desenvolvida pela Heckler & Koch na Alemanha, a MP7 é uma submetralhadora moderna projetada para atender a necessidades de combate em ambientes urbanos. Leve e compacta, é capaz de perfurar coletes blindados, oferecendo grande mobilidade e eficiência em operações táticas. Desde seu lançamento nos anos 2000, a MP7 tem sido adotada por forças especiais e unidades policiais em todo o mundo."
        ),
        ARObject(
            name: "Rifle M1 Garand",
            filename: "rifle",
            scale: SCNVector3(0.001, 0.001, 0.001),
            description: "O M1 Garand foi o primeiro rifle semi-automático adotado por uma força militar. Utilizado pelas Forças Armadas dos Estados Unidos durante a Segunda Guerra Mundial e a Guerra da Coreia, ele é conhecido por seu desempenho em combate e sua durabilidade. Suas características revolucionárias influenciaram o design de armas posteriores, consolidando-o como uma lenda entre os rifles militares."
        ),
        ARObject(
            name: "Rifle Winchester 1892",
            filename: "winschester",
            scale: SCNVector3(0.008, 0.008, 0.008),
            description: "O Winchester 1892 é um rifle de repetição icônico, projetado por John Browning. Lançado no final do século XIX, ele é muitas vezes associado ao Velho Oeste americano e aos filmes de faroeste. Com sua construção refinada e facilidade de manuseio, este modelo se tornou popular entre caçadores e colecionadores, sendo uma peça de destaque na história das armas de fogo."
        ),
        ARObject(
            name: "Pistola M1911",
            filename: "handgun",
            scale: SCNVector3(0.002, 0.002, 0.002),
            description: "A M1911 foi projetada por John Browning e adotada pelo Exército dos EUA em 1911, onde permaneceu em serviço por mais de 70 anos. Esta pistola é famosa por sua precisão e confiabilidade, características que a tornaram popular entre militares e civis. A M1911 é uma das pistolas mais influentes na história das armas de fogo, inspirando inúmeros modelos ao longo dos anos."
        )
    ]


    
    var selectedObjectIndex = 0 // Índice do objeto selecionado
    var detailView: UIView! // View para exibir mais detalhes
    var detailLabel: UILabel! // Label para mostrar a descrição
    var detailButton: UIButton! // Botão de "Mais Detalhes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar a ARSCNView
        sceneView = ARSCNView(frame: self.view.bounds)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // Adicionar iluminação
        addLighting()
        
        // Configurar a sessão AR
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
        
        // Configura o delegate
        sceneView.delegate = self

        // Adicionar um UIPickerView
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Estilizar o PickerView com fundo
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundView)
        
        backgroundView.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
            backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 150),
            pickerView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
        ])
        
        self.view.addSubview(backgroundView)

        // Adicionar botão de Adicionar/Remover
        toggleButton = UIButton(type: .system)
        toggleButton.setTitle("Adicionar Objeto", for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleObject), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Estilizar o botão
        toggleButton.backgroundColor = UIColor.systemBlue
        toggleButton.setTitleColor(UIColor.white, for: .normal)
        toggleButton.layer.cornerRadius = 10
        toggleButton.layer.shadowColor = UIColor.black.cgColor
        toggleButton.layer.shadowOpacity = 0.3
        toggleButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        toggleButton.layer.shadowRadius = 4
        
        self.view.addSubview(toggleButton)
        
        // Configurar botão de "Mais Detalhes"
        detailButton = UIButton(type: .system)
        detailButton.setTitle("Mais Detalhes", for: .normal)
        detailButton.addTarget(self, action: #selector(toggleDetailView), for: .touchUpInside)
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.isEnabled = false // Desabilitado até um objeto ser adicionado
        
        // Estilizar o botão
        detailButton.backgroundColor = UIColor.systemGray
        detailButton.setTitleColor(UIColor.white, for: .normal)
        detailButton.layer.cornerRadius = 10
        detailButton.layer.shadowColor = UIColor.black.cgColor
        detailButton.layer.shadowOpacity = 0.3
        detailButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        detailButton.layer.shadowRadius = 4
        
        self.view.addSubview(detailButton)
        
        // Configurar o layout dos botões com espaçamento ajustado
        NSLayoutConstraint.activate([
            toggleButton.bottomAnchor.constraint(equalTo: backgroundView.topAnchor, constant: -20),
            toggleButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20), // Agora à direita
            toggleButton.widthAnchor.constraint(equalToConstant: 150),
            toggleButton.heightAnchor.constraint(equalToConstant: 50),
            
            detailButton.bottomAnchor.constraint(equalTo: backgroundView.topAnchor, constant: -20),
            detailButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20), // Agora à esquerda
            detailButton.widthAnchor.constraint(equalToConstant: 150),
            detailButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        
        // Configurar a view de detalhes
        detailView = UIView()
        detailView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        detailView.layer.cornerRadius = 10
        detailView.isHidden = true // Oculta por padrão
        detailView.translatesAutoresizingMaskIntoConstraints = false

        detailLabel = UILabel()
        detailLabel.textColor = UIColor.white
        detailLabel.numberOfLines = 0 // Permite linhas múltiplas
        detailLabel.textAlignment = .center
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        detailView.addSubview(detailLabel)
        self.view.addSubview(detailView)

        // Atualização das constraints para permitir altura flexível
        NSLayoutConstraint.activate([
            detailView.bottomAnchor.constraint(equalTo: toggleButton.topAnchor, constant: -20),
            detailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            detailView.widthAnchor.constraint(equalToConstant: 300),
            detailView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100), // Altura mínima de 100
            
            detailLabel.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 10),
            detailLabel.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 10),
            detailLabel.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -10),
            detailLabel.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -10)
        ])

        
        // Adicionar botão de som
        soundButton = UIButton(type: .system)
        soundButton.setImage(UIImage(systemName: "speaker.fill"), for: .normal) // Ícone de volume
        soundButton.tintColor = UIColor.white // Cor do ícone
        soundButton.layer.cornerRadius = 25 // Torna o botão circular
        soundButton.layer.masksToBounds = true
        soundButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7) // Cor de fundo do botão
        soundButton.translatesAutoresizingMaskIntoConstraints = false
        soundButton.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)

        self.view.addSubview(soundButton)

        // Configurar layout do botão de som
        NSLayoutConstraint.activate([
            soundButton.widthAnchor.constraint(equalToConstant: 50),
            soundButton.heightAnchor.constraint(equalToConstant: 50),
            soundButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20), // Distância do topo
            soundButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20) // Distância da direita
        ])

        // Inicialmente ocultar o botão de som
        soundButton.isHidden = true
    }


    @objc func toggleObject() {
        if currentObject == nil {
            let tapLocation = sceneView.center
            let hitTestResults = sceneView.hitTest(tapLocation, types: [.existingPlaneUsingExtent])
            if let result = hitTestResults.first {
                let objectNode = createObject()
                let position = SCNVector3(result.worldTransform.columns.3.x,
                                          result.worldTransform.columns.3.y + Float(0.1 / 2),
                                          result.worldTransform.columns.3.z)
                objectNode.position = position
                sceneView.scene.rootNode.addChildNode(objectNode)
                
                currentObject = objectNode
                detailButton.isEnabled = true
                detailButton.backgroundColor = UIColor.systemBlue
                toggleButton.setTitle("Remover Objeto", for: .normal) // Alterar título
            }
        } else {
            currentObject?.removeFromParentNode()
            currentObject = nil
            detailButton.isEnabled = false
            detailButton.backgroundColor = UIColor.systemGray

            detailView.isHidden = true
            toggleButton.setTitle("Adicionar Objeto", for: .normal) // Alterar título
        }
    }

    
    @objc func toggleDetailView() {
        if detailView.isHidden {
            detailView.isHidden = false
            detailLabel.text = objectOptions[selectedObjectIndex].description
            detailButton.setTitle("Menos Detalhes", for: .normal)

            // Mostrar o botão de som quando a descrição estiver visível
            soundButton.isHidden = false
        } else {
            detailView.isHidden = true
            detailButton.setTitle("Mais Detalhes", for: .normal)

            // Ocultar o botão de som quando a descrição estiver oculta
            soundButton.isHidden = true
        }
    }
    
    @objc func soundButtonTapped() {
        let selectedObject = objectOptions[selectedObjectIndex]
        guard let soundURL = Bundle.main.url(forResource: "\(selectedObject.filename.lowercased())", withExtension: "mp3") else {
            print("Arquivo de som não encontrado")
            return
        }

        do {
            print("Tiro")
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Erro ao tocar o som: \(error.localizedDescription)")
        }
    }
    
    func addLighting() {
        // Luz direcional 1
        let light1 = SCNLight()
        light1.type = .directional
        light1.color = UIColor.white
        light1.intensity = 1000

        let lightNode1 = SCNNode()
        lightNode1.light = light1
        lightNode1.position = SCNVector3(x: 0, y: 10, z: 10)
        sceneView.scene.rootNode.addChildNode(lightNode1)

        // Luz direcional 2 oposta
        let light2 = SCNLight()
        light2.type = .directional
        light2.color = UIColor.white
        light2.intensity = 700

        let lightNode2 = SCNNode()
        lightNode2.light = light2
        lightNode2.position = SCNVector3(x: 0, y: -10, z: -10)
        sceneView.scene.rootNode.addChildNode(lightNode2)
        
        // Luz ambiente para iluminação uniforme
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
        ambientLight.intensity = 10

        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        sceneView.scene.rootNode.addChildNode(ambientLightNode)

        // Armazena referências para remover se necessário
        self.lightNode1 = lightNode1
        self.lightNode2 = lightNode2
    }

    func createObject() -> SCNNode {
        let selectedObject = objectOptions[selectedObjectIndex]
        guard let objectScene = SCNScene(named: "\(selectedObject.filename.lowercased()).usdz") else {
            fatalError("Não foi possível encontrar o arquivo USDZ")
        }
        
        let objectNode = objectScene.rootNode.childNodes.first!
        objectNode.scale = selectedObject.scale

        // Adiciona uma luz omni ao objeto
        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.color = UIColor.white
        omniLight.intensity = 10
        
        let omniLightNode = SCNNode()
        omniLightNode.light = omniLight
        omniLightNode.position = SCNVector3(0, 0.5, 0) // Posição centralizada próxima ao objeto
        objectNode.addChildNode(omniLightNode)

        return objectNode
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - UIPickerView DataSource and Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return objectOptions.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return objectOptions[row].name }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { selectedObjectIndex = row }
}

extension ViewController: ARSCNViewDelegate {
    // Delegate methods implementadas conforme necessário
}
