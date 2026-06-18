import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData suffixIcon;
  final Function iconPressed;
  final Function onSubmit;
  final Function? onChanged;
  const SearchField({super.key, required this.controller, required this.hint, required this.suffixIcon, required this.iconPressed, required this.onSubmit, this.onChanged});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), borderSide: BorderSide.none),
        filled: true, fillColor: Theme.of(context).cardColor,
        isDense: true,
        suffixIcon: IconButton(
          onPressed: widget.iconPressed as VoidCallback ,
          icon: Icon(widget.suffixIcon),
        ),
      ),

    );
  }
}
