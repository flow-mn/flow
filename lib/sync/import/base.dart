import 'package:flow/sync/import.dart';
import 'package:flow/sync/model/base.dart';
import 'package:flutter/material.dart';

abstract class Importer {
  ImportMode get mode;
  SyncModelBase get data;
  ValueNotifier get progressNotifier;
}
