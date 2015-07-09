// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library database.server;

import 'package:rpc/rpc.dart';
import 'dart:async';
import 'package:gcloud/db.dart' as db;
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert' as convert;

// This class defines the interface that the server provides.
@ApiClass(name: 'dbservices', version: 'v1')
class dbServer {
  
  dbServer();
  
  @ApiMethod(method:'POST', path:'export') 
  Future<KeyContainer> returnKey(DataSaveObject data) {
    GaeSourceRecord record = new GaeSourceRecord.FromDSO(data);
    sha1(record);
    db.dbService.commit(inserts: [record])
      .catchError((error, stackTrace) {
      print('Error recording');
    });
    return new Future.value(new KeyContainer.FromKey(record.id));
  }
  
  @ApiMethod(method:'GET', path:'return')
  Future<DataSaveObject> returnContent({String key}) {
    //TODO: Query for, and delete the specified object.
    return new Future.value(new DataSaveObject());
  }
}

/*
 * This is the schema for source code storage
 */
@db.Kind()
class GaeSourceRecord extends db.Model {
  @db.StringProperty()
  String dart;

  @db.StringProperty()
  String html;

  @db.StringProperty()
  String css;

  GaeSourceRecord();

  GaeSourceRecord.FromData(String dart, String html, String css) {
    this.dart = dart;
    this.html = html;
    this.css = css;
  }
  
  GaeSourceRecord.FromDSO(DataSaveObject dso) {
    this.dart = dso.dart;
    this.html = dso.html;
    this.css = dso.css;
  }
}

class DataSaveObject {
  String dart;
  String html;
  String css;

  DataSaveObject();

  DataSaveObject.FromData(String dart, String html, String css) {
    this.dart = dart;
    this.html = html;
    this.css = css;
  }
}

class KeyContainer {
  String key;
  KeyContainer();
  KeyContainer.FromKey(String key) {
    this.key = key;
  }
}

// SHA1 set the id
void sha1(GaeSourceRecord record) {
  crypto.SHA1 sha1 = new crypto.SHA1();
  convert.Utf8Encoder utf8 = new convert.Utf8Encoder();
  sha1.add(utf8.convert('blob \n '+record.html+record.css+record.dart));
  record.id = crypto.CryptoUtils.bytesToHex(sha1.close());
}