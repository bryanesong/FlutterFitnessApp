import 'package:FlutterFitnessApp/ContainerClasses/AppStateEnum.dart';
import 'package:FlutterFitnessApp/ContainerClasses/PSize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CosmeticSelector extends StatefulWidget {
  final Function(AppState appState) onAppStateChange;
  final AppState appState;

  CosmeticSelector({@required this.appState, @required this.onAppStateChange});

  @override
  CosmeticSelectorState createState() => CosmeticSelectorState();
}

class CosmeticSelectorState extends State<CosmeticSelector>
    with TickerProviderStateMixin {
  List<bool> isSelected = [true, false, false, false];
  List<Widget> gridViewTiles = new List<Widget>();

  @override
  void initState() {
    for (int i = 0; i < 30; i++) {
      if (i != 20) {
        gridViewTiles.add(
          Stack(
            children: [
              Image.asset("assets/images/upPanel.png"),
              Image.asset("assets/images/shopItems/pelletDrum.png"),
              FlatButton(
                  child: Container(constraints: BoxConstraints.expand()),
                  onPressed: () {
                    setState(() {

                    });
                  })
            ],
          ),
        );
      } else {
        gridViewTiles.add(
          Stack(
            children: [
              Image.asset("assets/images/downPanel.png"),
              Image.asset("assets/images/shopItems/pelletDrum.png"),
              FlatButton(
                  child: Container(constraints: BoxConstraints.expand()),
                  onPressed: () {
                    print("hi");
                  })
            ],
          ),
        );
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.appState) {
      case AppState.Cosmetics_Home:
        return gridView();
      default:
        return null;
    }
  }

  Widget gridView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.blue,
          ),
        ),
        Container(
          height: PSize.hPix(5),
          width: PSize.wPix(100),
          child: ToggleButtons(
            children: [
              Container(
                width: PSize.wPix(24.7),
                child: Text(
                  "Hats",
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: PSize.wPix(24.7),
                child: Text(
                  "Shirts",
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: PSize.wPix(24.7),
                child: Text(
                  "Hand",
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: PSize.wPix(24.7),
                child: Text(
                  "Shoes",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0;
                    buttonIndex < isSelected.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    isSelected[buttonIndex] = true;
                  } else {
                    isSelected[buttonIndex] = false;
                  }
                }
              });
            },
            isSelected: isSelected,
          ),
        ),
        Container(
          color: Colors.white,
          alignment: Alignment.bottomCenter,
          width: PSize.wPix(100),
          height: PSize.hPix(30),
          child: GridView.count(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            crossAxisCount: 5,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
            children: gridViewTiles,
          ),
        )
      ],
    );
  }
}
