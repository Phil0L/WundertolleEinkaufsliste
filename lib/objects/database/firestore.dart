import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';

import '../data.dart';
import '../item.dart';

void initializeDatabase() {
  FireStoreLoader((firestore) {
    FireStoreGetter().getCollection(callback: ((snapshot) {
      snapshot.forEach((listSnapshot) {
        ShoppingList list = ShoppingList().fromJson(listSnapshot.data());
        Data.onListAdded(list);
      });
      startListener();
    }));
  });
}

void startListener() {
  FirestoreListener().listenForChange((snapshot) {
    Data.onUpdate();
    List<ShoppingList> existingLists = List.from(Data.lists);
    snapshot.docs.forEach((listSnapshot) {
      ShoppingList list = ShoppingList().fromJson(listSnapshot.data());
      if (existingLists.contains(list)) {
        Data.onListUpdate(list, existingLists.firstWhere((element) => element.id == list.id, orElse: null));
        existingLists.remove(list);
      } else
        // List is born!
        Data.onListAdded(list);
    });
    if (existingLists.isNotEmpty)
      // List has died!
      existingLists.forEach((element) => Data.onListRemoved(element));
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

  void addList(ShoppingList list) {
    CollectionReference collectionReference = firestore.collection('lists');
    DocumentReference documentReference = collectionReference.doc(list.id);
    documentReference.set(list.toJson(), SetOptions(merge: true));
  }

  @deprecated
  void updateList(ShoppingList list, {Function callback}) {
    CollectionReference collectionReference = firestore.collection('lists');
    DocumentReference documentReference = collectionReference.doc(list.id);
    documentReference.update(list.toJson()).then((value) => callback.call());
  }

  void addItemToList(ShoppingList list, Item item, {Function callback}) {
    CollectionReference collectionReference = firestore.collection('lists');
    DocumentReference documentReference = collectionReference.doc(list.id);
    ShoppingList newList = list.clone();
    print(list);
    print(newList);
    newList.modify.addItem(item);
    documentReference.update(newList.toJson()).then((value) {
      if (callback != null) callback.call();
    });
  }

  void removeItemFromList(ShoppingList list, Item item, {Function callback}) {
    CollectionReference collectionReference = firestore.collection('lists');
    DocumentReference documentReference = collectionReference.doc(list.id);
    ShoppingList newList = list.clone();
    newList.modify.removeItem(item);
    documentReference.update(newList.toJson()).then((value) {
      if (callback != null) callback.call();
    });
  }

  void saveLikes(int likes) {
    DocumentReference doc = firestore.collection('likes').doc('likes');
    doc.update({'likes': likes});
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
      print('Database change detected!');
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

  void deleteList(ShoppingList list) {
    firestore.collection('lists').doc(list.id).delete();
  }
}
