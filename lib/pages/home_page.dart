import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lista_supermercado/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore
  final FirestoreService firestoreService = FirestoreService();
  
  // Controlador de texto
  final TextEditingController textController = TextEditingController();

  // Abre caixa para inserir o produto novo
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          // Botão para salvar
          ElevatedButton(
            onPressed: () {
              // Adiciona um novo produto
              if (docID == null) {
                firestoreService.addProduto(textController.text);
              } else {
                firestoreService.updateProduto(docID, textController.text);
              }
              // Limpa o controlador de texto
              textController.clear();

              // Fecha o dialog
              Navigator.pop(context);
            }, 
            child: Text("Adicionar"),
          )
        ],
      ),
    );
  }

  // Função para atualizar o estado do checkbox
  void updateProdutoChecked(String docID, bool checked) {
    firestoreService.updateProdutoChecked(docID, checked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EA2F1), // Cor do AppBar
        title: const Text("Lista SuperMercado", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        backgroundColor: Color(0xFFB6B9F5), // Cor do FAB
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Center( // Centra a lista na tela
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // Largura menor que a tela (90%)
          padding: const EdgeInsets.all(16.0), // Adiciona o espaçamento interno da lista
          color: Color(0xFFE7E8FC), // Cor de fundo da lista
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getProdutosStream(), 
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List produtosList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: produtosList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = produtosList[index];
                    String docID = document.id;

                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    String produtoText = data['produto'];
                    bool isChecked = data['checked'] ?? false;  // Definindo o valor padrão como false, caso não exista

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Maior espaçamento entre os itens
                      child: Container(
                        decoration: BoxDecoration(
                          color: isChecked ? Color(0xFFCFD1F8) : Colors.white, // Altera a cor de fundo se marcado
                          borderRadius: BorderRadius.circular(12), // Borda arredondada
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2), // sombra suave para dar um efeito 3D
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            produtoText,
                            style: TextStyle(
                              decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none, // Riscar o texto se marcado
                              color: isChecked ? Colors.grey : Color(0xFF9EA2F1), // Cor do texto muda quando marcado
                            ),
                          ),
                          leading: Checkbox(
                            value: isChecked,
                            onChanged: (bool? newValue) {
                              setState(() {
                                isChecked = newValue!;
                              });
                              // Atualiza o estado no Firestore
                              updateProdutoChecked(docID, isChecked);
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Atualizar
                              IconButton(
                                onPressed: () => openNoteBox(docID: docID), 
                                icon: Icon(Icons.settings, color: Color(0xFF9EA2F1))),

                              // Deletar
                              IconButton(
                                onPressed: () => firestoreService.deleteProduto(docID), 
                                icon: Icon(Icons.delete, color: Color(0xFF9EA2F1))),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Text("Não tem produto na lista!", style: TextStyle(color: Color(0xFF9EA2F1)));
              }    
            },
          ),
        ),
      ),
    );
  }
}
