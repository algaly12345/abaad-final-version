import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/util/styles.dart';

import 'package:flutter/material.dart';

class InterfaceItem extends StatelessWidget {
  final Estate? estate;
  final List<Interface>? restaurants;
  const InterfaceItem({Key? key, this.estate, this.restaurants})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool? isNull = true;
    int? length = 0;

    isNull = restaurants == null;
    if (!isNull) {
      length = restaurants?.length ?? 100;
      return !isNull
          ? length > 0
              ? Container(
                  height: estate!.interface!.isEmpty ? 0 : 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.surface,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 0.5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: estate!.interface!.length,
                    itemBuilder: (context, index) {
                      return estate!.interface![index].space != null
                          ? Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(
                                        0, 0.5), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text(estate!
                                              .interface![index].name!))),
                                  VerticalDivider(width: 1.0),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                              "${estate!.interface![index]!.space} م ",
                                              style: robotoBlack.copyWith(
                                                  fontSize: 14)))),
                                ],
                              ),
                            )
                          : Container();
                    },
                  ),
                )
              : Text("")
          : Text("");
    }

    // fallback when restaurants is null
    return Text("not data");

  }
}
