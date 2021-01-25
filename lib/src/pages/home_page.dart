import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:brand_names/src/models/band.dart';
import 'package:brand_names/src/services/socket_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    /* 
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Guns and Roses', votes: 7),
    Band(id: '3', name: 'Aerosmith', votes: 6),
    Band(id: '4', name: 'Queen', votes: 4), */
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', (payload) {
      this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _serverStatus = Provider.of<SocketService>(context).serverStatus;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Band Names',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          Container(
              margin: EdgeInsets.only(right: 12.0),
              child: (_serverStatus == ServerStatus.Online)
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.deepPurple,
                      size: 28,
                    )
                  : Icon(
                      Icons.offline_bolt,
                      color: Colors.red,
                      size: 28,
                    ))
        ],
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTile(bands[i]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('Direction: $direction ID: ${band.id}');
        //TODO: get delete in server
      },
      background: Container(
        padding: EdgeInsets.only(left: 12.0),
        color: Colors.red.shade300,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete Band',
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            band.name.substring(0, 2),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 18),
        ),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    Platform.isIOS
        ? iOsAlertDialog(textController)
        : androidAlertDialog(textController);
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      this
          .bands
          .add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }

  androidAlertDialog(TextEditingController textController) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('New band name:'),
              content: TextField(
                controller: textController,
              ),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () => addBandToList(textController.text),
                  child: Text('Add'),
                  textColor: Colors.deepPurple,
                  elevation: 5,
                )
              ],
            ));
  }

  iOsAlertDialog(TextEditingController textController) {
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text('New band name:'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text('Dismiss'),
                    onPressed: () => Navigator.pop(context)),
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Add'),
                    onPressed: () => addBandToList(textController.text)),
              ],
            ));
  }
}
