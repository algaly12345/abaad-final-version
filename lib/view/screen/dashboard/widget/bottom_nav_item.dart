import 'package:abaad_flutter/util/styles.dart';
import 'package:flutter/material.dart';

class BottomNavItem extends StatelessWidget {
  final String? iconData;
  final Function? onTap;
  final bool? isSelected;
  final String? name;
  const BottomNavItem({super.key,  this.iconData,this.name, this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {

    return  Expanded(
      child: GestureDetector(
        onTap: onTap as GestureTapCallback?,
        child: SizedBox(
          child: Material(
            type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset( (iconData ?? "") , color: (isSelected ?? false) ? Theme.of(context).primaryColor : Colors.grey, width: 30,height: 30),
                  SizedBox(

                    child: Text(
                        name ?? "", style: robotoBlack.copyWith(fontSize: 11)
                    ),
                  )
                ],
              ),

          ),
        ),
      ),
    );
  }
}
