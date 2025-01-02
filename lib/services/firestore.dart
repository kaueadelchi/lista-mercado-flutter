import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Pegar coleção de produtos
  final CollectionReference produtos = 
    FirebaseFirestore.instance.collection('produtos');
    final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Criar um produto
  Future<void> addProduto(String produto) {
    return produtos.add({
      'produto': produto,
      'timestamp': Timestamp.now(),
    });
  }
  // Pegar a lista de produtos do banco de dados
  Stream<QuerySnapshot> getProdutosStream() {
    final produtosStream =
    produtos.orderBy('timestamp', descending: true).snapshots();

    return produtosStream;
  }

  // Atualizar um produto
  Future<void> updateProduto(String docID, String newProduto) {
    return produtos.doc(docID).update({
      'produto': newProduto,
      'timestamp': Timestamp.now(),
    });
  }

  // Remover algum produto
  Future<void> deleteProduto(String docID){
    return produtos.doc(docID).delete();
  }

    // Atualiza o estado do checkbox
  Future<void> updateProdutoChecked(String docID, bool checked) async {
    await _db.collection('produtos').doc(docID).update({
      'checked': checked,
    });
  }
}