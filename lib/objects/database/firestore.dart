import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/objects/savable/save_list.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';

import '../data.dart';

void initializeDatabase() {
  FireStoreLoader((firestore) {
    FireStoreGetter().getCollection(callback: ((snapshot) {
      snapshot.forEach((listSnapshot) {
        ShoppingList list = ListParser.parse(listSnapshot.data());
        Data.addList(list);
      });
      startListener();
    }));
  });
}

void startListener(){
  FirestoreListener().listenForChange((snapshot) {
    List<String> ids = [];
    Data.getLists().forEach((element) => ids.add(element.id));
    snapshot.docs.forEach((listSnapshot) {
      ShoppingList list = ListParser.parse(listSnapshot.data());
      Data.updateList(list);
      if (ids.contains(list.id))
        ids.remove(list.id);
    });
    if (ids.isNotEmpty)
      ids.forEach((element) => Data.removeListByID(element));
    BarState.pages.forEach((list, view) {
      if (view.state != null)
        view.state.notifyListChanged();
    });
  });
}

class FireStoreLoader {
  static FirebaseApp firebase;
  static FirebaseFirestore firestore;

  FireStoreLoader(Function(FirebaseFirestore) callback) {
    loadFirebase(() {
      loadFireStore((firestore) {
        callback.call(firestore);
      });
    });
  }

  void loadFirebase(Function callback) async {
    await Firebase.initializeApp();
    firebase = Firebase.app();
    callback.call();
  }

  void loadFireStore(Function(FirebaseFirestore) callback) {
    firestore = FirebaseFirestore.instance;
    callback.call(firestore);
  }
}

class FireStoreGetter {
  static FirebaseFirestore firestore;

  FireStoreGetter() {
    if (firestore == null) firestore = FireStoreLoader.firestore;
  }

  void getDocument(
      {DocumentReference documentReference,
      Function(DocumentSnapshot) callback}) {
    documentReference.get().then((snapshot) {
      callback.call(snapshot);
    });
  }

  void getCollection(
      {CollectionReference collectionReference,
      Function(List<QueryDocumentSnapshot>) callback}) {
    if (collectionReference == null)
      collectionReference = firestore.collection('lists');
    collectionReference.get().then((snapshot) {
      callback.call(snapshot.docs);
    });
  }
}

class FirestoreSaver {
  static FirebaseFirestore firestore;

  FirestoreSaver() {
    if (firestore == null) firestore = FireStoreLoader.firestore;
  }

  void saveList(ShoppingList list) {
    CollectionReference collectionReference = firestore.collection('lists');
    DocumentReference documentReference = collectionReference.doc(list.name);
    documentReference.set(ShoppingListSavable().withShoppingList(list).toJson(),
        SetOptions(merge: true));
  }

  void updateList(ShoppingList list, {Function callback}) {
    CollectionReference collectionReference = firestore.collection('lists');
    DocumentReference documentReference = collectionReference.doc(list.name);
    documentReference
        .update(ShoppingListSavable().withShoppingList(list).toJson())
        .then((value) => callback.call());
  }

  void saveLikes(int likes){
    DocumentReference doc = firestore.collection('likes').doc('likes');
    doc.update({'likes': likes });
  }
}

class FirestoreListener {
  static FirebaseFirestore firestore;

  FirestoreListener() {
    if (firestore == null) firestore = FireStoreLoader.firestore;
  }

  void listenForChange(Function(QuerySnapshot) callback) {
    firestore
        .collection('lists')
        .snapshots(includeMetadataChanges: true)
        .listen((event) {
      print('database change detected!');
      callback.call(event);
    }, onError: ((error, stacktrace) {
      print('database error!');
      print(error.toString());
      print(stacktrace.toString());
    }), onDone: (() {
      print('done');
    }));
  }
}

class FirestoreDeleter {
  static FirebaseFirestore firestore;

  FirestoreDeleter() {
    if (firestore == null) firestore = FireStoreLoader.firestore;
  }

  void deleteList(ShoppingList list){
    firestore.collection('lists').doc(list.name).delete();
  }
  
}
