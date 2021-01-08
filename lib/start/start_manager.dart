import 'package:flutter/material.dart';

class StartManager{

  StartLink link;
  List<StartEvent> _listener = [];
  bool loadedMe = false;
  bool loadedApp = false;
  BuildContext context;

  bool get isReady => this.link != null;

  bool get hasContext => this.context != null;

  void addListener(StartEvent callback) => _listener.add(callback);

  void registerEvent({loadedMe: false, loadedApp: false}){
    if (loadedMe) this.loadedMe = true;
    if (loadedApp) this.loadedApp = true;
    onEvent();
  }

  void registerContext(BuildContext context) {
    this.context = context;
    onEvent();
  }

  void registerStartLink(StartLink link){
    this.link = link;
    onEvent();
  }

  void onEvent(){
    if (this.isReady){
      for (StartEvent event in this._listener){
        if (event.requireAppLoad){
          if (!this.loadedApp)
            continue;
        }
        if (event.requireLogin){
          if (!this.loadedMe)
            continue;
        }
        if (event.requireContext){
          if (!this.hasContext)
            continue;
        }
        event.callback.call(this.link);
      }
    }
  }

}

abstract class StartLink{

  final String link;

  StartLink(this.link);

}

class StartEvent{
  final Function(StartLink) callback;
  final bool requireLogin;
  final bool requireAppLoad;
  final bool requireContext;

  StartEvent(
      {this.callback,
      this.requireLogin: false,
      this.requireAppLoad: false,
      this.requireContext: false});
}