import 'package:FlutterFitnessApp/ContainerClasses/AppStateEnum.dart';
import 'package:FlutterFitnessApp/ContainerClasses/OwnedCosmeticsRealtime.dart';
import 'package:FlutterFitnessApp/ContainerClasses/PSize.dart';
import 'package:FlutterFitnessApp/ContainerClasses/PenguinCosmeticRealtime.dart';
import 'package:FlutterFitnessApp/PenguinCreator.dart';
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
  List<bool> _selected = [true, false, false, false];
  OwnedCosmeticsRealtime _ownedCosmeticListener;
  PenguinCosmeticRealtime _equippedCosmeticListener;

  //the list that the gridview uses
  List<Widget> _displayedCosmetics = new List<Widget>();

  List<Widget> _ownedHats = new List<Widget>();
  List<Widget> _ownedShirts = new List<Widget>();
  List<Widget> _ownedArms = new List<Widget>();
  List<Widget> _ownedShoes = new List<Widget>();
  List<Widget> _ownedShadows = new List<Widget>();
  //inventory holder [0] = hats, [1] = shirts, [2] = arm, [3] = shoes, [4] = shadows
  List<List<Widget>> _ownedCosmeticList;


  @override
  void initState() {

    _ownedCosmeticList = [_ownedHats, _ownedShirts, _ownedArms, _ownedShoes, _ownedShadows];
    updateInventory();
    _ownedCosmeticListener = new OwnedCosmeticsRealtime(onNewOwnedCosmetic: () {
        _updateGridview();
    });

    _equippedCosmeticListener = new PenguinCosmeticRealtime(penguinType: PenguinType.penguin, onNewCosmetics: () {
      _updateGridview();
    });

    _displayedCosmetics = _ownedCosmeticList[0];
    super.initState();
  }

  void _updateGridview() {
    updateInventory();
    List<Widget> _dudList = new List<Widget>();
    List<Widget> temp = setOwnedCosmeticsList();
    for(int i = 0; i < temp.length; i++) {
      _dudList.add(temp[i]);
    }
    setState(() {
      _displayedCosmetics =_dudList;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        setOwnedCosmeticsList();
      });
    });
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
    return Stack(
      fit: StackFit.expand,
      children: [
        //background
        FittedBox(fit: BoxFit.fill, child: Image.asset("assets/images/inventoryBackground.jpg"),),
        Column(
          children: [
            Expanded(
              //penguin
              child: Stack(
                children: [
                  PenguinCreator(centerXCoord: PSize.wPix(50), centerYCoord: PSize.hPix(30), size: PSize.wPix(60), penguinAnimationType: PenguinAnimationType.wave, penguinType: PenguinType.penguin,)
                ],
              ),
            ),
            //inventory
            Container(
              height: PSize.hPix(5),
              margin: EdgeInsets.fromLTRB(0, 0, 0, PSize.hPix(1)),
              child: Row(
                children: _createInventoryTypeButtons(),
              ),
            ),
            Container(
              color: Colors.white,
              alignment: Alignment.bottomCenter,
              width: PSize.wPix(100),
              height: PSize.hPix(30),
              child: GridView.count(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                crossAxisCount: 4,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                children: _displayedCosmetics,
              ),
            )
          ],
        ),
      ],
    );
  }

  List<Widget> _createInventoryTypeButtons() {
    List<String> inventoryTypes = ["Hats","Shirts","Hand","Shoes"];
    List<Widget> buttonList = new List<Widget>();
    for(int i = 0; i < inventoryTypes.length; i++) {
      //create spacing
      buttonList.add(Container(width: PSize.wPix(2),));

      //create circular buttons
      buttonList.add(Expanded(
          child: FlatButton(
            color: _selected[i] ? Colors.cyan : Colors.white,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () {
              setState(() {
                _inventoryTypeSelected(i);
                setOwnedCosmeticsList();
              });
            },
            child: Text(
              inventoryTypes[i],
              textAlign: TextAlign.center,
            ),
          )
      ),);

    }

    //tag on spacing on far right
    buttonList.add(Container(width: PSize.wPix(2),));

    return buttonList;
  }

  void _inventoryTypeSelected(int index) {
    //when flat button for inventory type has been selected
    for(int i = 0; i < _selected.length; i++) {
      if(i != index) {
        _selected[i] = false;
      } else {
        _selected[i] = true;
      }
    }
  }

  void updateInventory() {
    //called when new cosmetic is added or new cosmetic is equipped
    for (int i = 0; i < _ownedCosmeticList.length; i++) {
      _ownedCosmeticList[i].clear();
      for (int j = 0; j < 40; j++) {
        Widget createdStack;
        if (OwnedCosmeticsRealtime.ownedCosmetics[i].length > j) {
          createdStack = Stack(children: [
            //bottom tile
          //test if current item owned is equipped
            tileImage(OwnedCosmeticsRealtime.ownedCosmetics[i][j],
                //0 to specify the main character penguin
                PenguinCosmeticRealtime.listOfPenguinCosmetics[0].getCosmetic(i)),
            Image.asset("assets/images/shopItems/" + OwnedCosmeticsRealtime.ownedCosmetics[i][j] + ".png", gaplessPlayback: true,),
            FlatButton(
                onPressed: () {_equipItem(j, i);  },
            child: Container(),)


          ]);
        } else {
          createdStack = Stack(children: [Image.asset("assets/images/questionPanel.png", gaplessPlayback: true,)]);
        }
        _ownedCosmeticList[i].add(createdStack);
      }
    }
  }

  Widget tileImage(String chosenCosmetic, String equippedCosmetic) {
    if (chosenCosmetic == equippedCosmetic) {
      return Image.asset("assets/images/downPanel.png", gaplessPlayback: true,);
    } else {
      return Image.asset("assets/images/upPanel.png", gaplessPlayback: true,);
    }
  }

  List<Widget> setOwnedCosmeticsList() {
    //returns selected type of cosmetic
    for (int i = 0; i < _selected.length; i++) {
      if (_selected[i]) {
        print("returned " + i.toString());
        _displayedCosmetics = _ownedCosmeticList[i];
        return _ownedCosmeticList[i];

      }
    }
    return null;
  }

  void _equipItem(int index, int type) {
    //called when tile is clicked in inventory gridview
    //updates firebase with new equipped cosmetic
    PenguinCosmeticRealtime.pushCosmetics(penguinType: PenguinType.penguin, cosmeticName: OwnedCosmeticsRealtime.ownedCosmetics[type][index]);
  }

  @override
  void dispose() {
    _ownedCosmeticListener.dispose();
    _equippedCosmeticListener.dispose();
    super.dispose();
  }
}
